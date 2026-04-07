import gleam/dynamic/decode as dynamic_decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

import kitazith/allowed_mentions
import kitazith/attachment
import kitazith/component
import kitazith/component/container as component_container
import kitazith/component/file as component_file
import kitazith/component/media_gallery as component_media_gallery
import kitazith/component/section as component_section
import kitazith/component/text_display as component_text_display
import kitazith/embed
import kitazith/poll
import kitazith/validation

pub fn validate_with_query(
  payload: a,
  query: b,
  validate: fn(a) -> Result(a, List(validation.ValidationError)),
  validate_query: fn(b, a) -> List(validation.ValidationError),
) -> Result(a, List(validation.ValidationError)) {
  let errors =
    list.flatten([
      case validate(payload) {
        Ok(_) -> []
        Error(errors) -> errors
      },
      validate_query(query, payload),
    ])

  case errors {
    [] -> Ok(payload)
    _ -> Error(errors)
  }
}

pub fn attachment_filenames(
  attachments: List(attachment.Attachment),
) -> List(String) {
  attachments |> list.map(fn(attachment) { attachment.filename })
}

pub fn validate_string_length(
  path: String,
  value: String,
  min min: Int,
  max max: Int,
) -> List(validation.ValidationError) {
  let length = string.length(value)

  case length >= min && length <= max {
    True -> []
    False -> [
      error(path, validation.StringLengthOutOfRange(min:, max:, actual: length)),
    ]
  }
}

pub fn validate_string_max_length(
  path: String,
  value: String,
  max max: Int,
) -> List(validation.ValidationError) {
  let length = string.length(value)

  case length <= max {
    True -> []
    False -> [
      error(path, validation.StringLengthExceeded(max:, actual: length)),
    ]
  }
}

pub fn validate_list_max_length(
  path: String,
  items: List(a),
  max max: Int,
  noun noun: String,
) -> List(validation.ValidationError) {
  let count = list.length(items)

  case count <= max {
    True -> []
    False -> [
      error(
        path,
        validation.ListLengthExceeded(max:, actual: count, item_label: noun),
      ),
    ]
  }
}

pub fn validate_allowed_mentions(
  path: String,
  mentions: allowed_mentions.AllowedMentions,
) -> List(validation.ValidationError) {
  list.flatten([
    case mentions.roles {
      Some(roles) ->
        validate_list_max_length(
          join_path(path, "roles"),
          roles,
          max: 100,
          noun: "role ids",
        )

      None -> []
    },
    case mentions.users {
      Some(users) ->
        validate_list_max_length(
          join_path(path, "users"),
          users,
          max: 100,
          noun: "user ids",
        )

      None -> []
    },
  ])
}

pub fn validate_attachments(
  path: String,
  attachments: List(attachment.Attachment),
) -> List(validation.ValidationError) {
  list.flatten([
    attachments
      |> list.index_map(fn(attachment, index) {
        case attachment.description {
          Some(description) ->
            validate_string_length(
              join_path(indexed_path(path, index), "description"),
              description,
              min: 1,
              max: 1024,
            )

          None -> []
        }
      })
      |> list.flatten,
    duplicate_attachment_filename_errors(path, attachments),
  ])
}

pub fn validate_embeds(
  path: String,
  embeds: List(embed.Embed),
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  let total_character_count =
    embeds
    |> list.map(embed_character_count)
    |> list.fold(0, fn(total, count) { total + count })

  list.flatten([
    validate_list_max_length(path, embeds, max: 10, noun: "embeds"),
    case total_character_count <= 6000 {
      True -> []
      False -> [
        error(
          path,
          validation.AggregateCharacterLimitExceeded(
            limit_label: "embed_total_characters",
            max: 6000,
            actual: total_character_count,
          ),
        ),
      ]
    },
    embeds
      |> list.index_map(fn(embed, index) {
        validate_embed(
          indexed_path(path, index),
          embed,
          attachment_filenames: attachment_filenames,
        )
      })
      |> list.flatten,
  ])
}

pub fn validate_poll(
  path: String,
  poll: poll.Poll,
) -> List(validation.ValidationError) {
  // 768 hours
  let max_poll_duration_hours = 24 * 32
  list.flatten([
    validate_string_length(
      join_path(path, "question.text"),
      poll.question.text,
      min: 1,
      max: 300,
    ),
    validate_list_max_length(
      join_path(path, "answers"),
      poll.answers,
      max: 10,
      noun: "answers",
    ),
    case poll.duration {
      Some(duration) ->
        case duration > max_poll_duration_hours {
          True -> [
            error(
              join_path(path, "duration"),
              validation.NumericMaximumExceeded(
                max: max_poll_duration_hours,
                actual: duration,
                unit: "hours",
              ),
            ),
          ]

          False -> []
        }
      _ -> []
    },
    poll.answers
      |> list.index_map(fn(answer, index) {
        validate_poll_answer(
          indexed_path(join_path(path, "answers"), index),
          answer,
        )
      })
      |> list.flatten,
  ])
}

pub fn validate_components(
  path: String,
  components: List(component.Component),
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  let total_component_count =
    components
    |> list.map(component_count)
    |> list.fold(0, fn(total, count) { total + count })

  list.flatten([
    case total_component_count <= 40 {
      True -> []
      False -> [
        error(
          path,
          validation.AggregateComponentLimitExceeded(
            max: 40,
            actual: total_component_count,
          ),
        ),
      ]
    },
    components
      |> list.index_map(fn(component, index) {
        validate_component(
          indexed_path(path, index),
          component,
          attachment_filenames: attachment_filenames,
        )
      })
      |> list.flatten,
  ])
}

pub fn components_require_v2_flag(components: List(component.Component)) -> Bool {
  case components {
    [] -> False
    [component, ..rest] ->
      component_requires_v2_flag(component) || components_require_v2_flag(rest)
  }
}

fn validate_embed(
  path: String,
  embed: embed.Embed,
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  list.flatten([
    case embed.title {
      Some(title) ->
        validate_string_max_length(join_path(path, "title"), title, max: 256)
      None -> []
    },
    case embed.description {
      Some(description) ->
        validate_string_max_length(
          join_path(path, "description"),
          description,
          max: 4096,
        )

      None -> []
    },
    case embed.footer {
      Some(footer) ->
        list.flatten([
          validate_string_length(
            join_path(path, "footer.text"),
            footer.text,
            min: 1,
            max: 2048,
          ),
          case footer.icon_url {
            Some(icon_url) ->
              validate_attachment_reference(
                join_path(path, "footer.icon_url"),
                icon_url,
                attachment_filenames: attachment_filenames,
              )

            None -> []
          },
        ])

      None -> []
    },
    case embed.image {
      Some(image) ->
        validate_attachment_reference(
          join_path(path, "image.url"),
          image.url,
          attachment_filenames: attachment_filenames,
        )

      None -> []
    },
    case embed.thumbnail {
      Some(thumbnail) ->
        validate_attachment_reference(
          join_path(path, "thumbnail.url"),
          thumbnail.url,
          attachment_filenames: attachment_filenames,
        )

      None -> []
    },
    case embed.author {
      Some(author) ->
        list.flatten([
          validate_string_length(
            join_path(path, "author.name"),
            author.name,
            min: 1,
            max: 256,
          ),
          case author.icon_url {
            Some(icon_url) ->
              validate_attachment_reference(
                join_path(path, "author.icon_url"),
                icon_url,
                attachment_filenames: attachment_filenames,
              )

            None -> []
          },
        ])

      None -> []
    },
    case embed.fields {
      Some(fields) ->
        list.flatten([
          validate_list_max_length(
            join_path(path, "fields"),
            fields,
            max: 25,
            noun: "fields",
          ),
          fields
            |> list.index_map(fn(field, index) {
              list.flatten([
                validate_string_length(
                  join_path(
                    indexed_path(join_path(path, "fields"), index),
                    "name",
                  ),
                  field.name,
                  min: 1,
                  max: 256,
                ),
                validate_string_length(
                  join_path(
                    indexed_path(join_path(path, "fields"), index),
                    "value",
                  ),
                  field.value,
                  min: 1,
                  max: 1024,
                ),
              ])
            })
            |> list.flatten,
        ])

      None -> []
    },
  ])
}

fn validate_poll_answer(
  path: String,
  answer: poll.PollAnswer,
) -> List(validation.ValidationError) {
  case answer.poll_media.text {
    Some(text) ->
      validate_string_length(
        join_path(path, "poll_media.text"),
        text,
        min: 1,
        max: 55,
      )

    None -> []
  }
}

fn validate_component(
  path: String,
  component: component.Component,
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  case component {
    component.Component(_) -> []
    component.TextDisplayComponent(text_display) ->
      validate_text_display(path, text_display)
    component.SectionComponent(section) ->
      validate_section(
        path,
        section,
        attachment_filenames: attachment_filenames,
      )
    component.MediaGalleryComponent(media_gallery) ->
      validate_media_gallery(
        path,
        media_gallery,
        attachment_filenames: attachment_filenames,
      )
    component.FileComponent(file) ->
      validate_file(path, file, attachment_filenames: attachment_filenames)
    component.SeparatorComponent(_) -> []
    component.ContainerComponent(container) ->
      validate_container(
        path,
        container,
        attachment_filenames: attachment_filenames,
      )
  }
}

fn validate_text_display(
  _path: String,
  _text_display: component_text_display.TextDisplay,
) -> List(validation.ValidationError) {
  []
}

fn validate_section(
  path: String,
  section: component_section.Section,
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  let component_count = list.length(section.components)

  list.flatten([
    case component_count >= 1 && component_count <= 3 {
      True -> []
      False -> [
        error(
          join_path(path, "components"),
          validation.ComponentCountOutOfRange(
            min: 1,
            max: 3,
            actual: component_count,
            item_label: "text display components",
          ),
        ),
      ]
    },
    section.components
      |> list.index_map(fn(text_display, index) {
        validate_text_display(
          indexed_path(join_path(path, "components"), index),
          text_display,
        )
      })
      |> list.flatten,
    validate_thumbnail(
      join_path(path, "accessory"),
      section.accessory,
      attachment_filenames: attachment_filenames,
    ),
  ])
}

fn validate_thumbnail(
  path: String,
  thumbnail: component_section.Thumbnail,
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  validate_attachment_reference(
    join_path(path, "media.url"),
    thumbnail.media.url,
    attachment_filenames: attachment_filenames,
  )
}

fn validate_media_gallery(
  path: String,
  media_gallery: component_media_gallery.MediaGallery,
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  let item_count = list.length(media_gallery.items)

  list.flatten([
    case item_count >= 1 && item_count <= 10 {
      True -> []
      False -> [
        error(
          join_path(path, "items"),
          validation.ComponentCountOutOfRange(
            min: 1,
            max: 10,
            actual: item_count,
            item_label: "media gallery items",
          ),
        ),
      ]
    },
    media_gallery.items
      |> list.index_map(fn(item, index) {
        validate_media_gallery_item(
          indexed_path(join_path(path, "items"), index),
          item,
          attachment_filenames: attachment_filenames,
        )
      })
      |> list.flatten,
  ])
}

fn validate_media_gallery_item(
  path: String,
  item: component_media_gallery.MediaGalleryItem,
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  list.flatten([
    case item.description {
      Some(description) ->
        validate_string_max_length(
          join_path(path, "description"),
          description,
          max: 1024,
        )

      None -> []
    },
    validate_attachment_reference(
      join_path(path, "media.url"),
      item.media.url,
      attachment_filenames: attachment_filenames,
    ),
  ])
}

fn validate_file(
  path: String,
  file: component_file.File,
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  case attachment_reference_filename(file.file.url) {
    Some(_) ->
      validate_attachment_reference(
        join_path(path, "file.url"),
        file.file.url,
        attachment_filenames: attachment_filenames,
      )

    None -> [
      error(join_path(path, "file.url"), validation.AttachmentReferenceRequired),
    ]
  }
}

fn validate_container(
  path: String,
  container: component_container.Container,
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  container.components
  |> list.index_map(fn(child, index) {
    validate_container_child(
      indexed_path(join_path(path, "components"), index),
      child,
      attachment_filenames: attachment_filenames,
    )
  })
  |> list.flatten
}

fn validate_container_child(
  path: String,
  child: component_container.ContainerChild,
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  case child {
    component_container.ContainerTextDisplay(text_display) ->
      validate_text_display(path, text_display)
    component_container.ContainerSection(section) ->
      validate_section(
        path,
        section,
        attachment_filenames: attachment_filenames,
      )
    component_container.ContainerMediaGallery(media_gallery) ->
      validate_media_gallery(
        path,
        media_gallery,
        attachment_filenames: attachment_filenames,
      )
    component_container.ContainerFile(file) ->
      validate_file(path, file, attachment_filenames: attachment_filenames)
    component_container.ContainerSeparator(_) -> []
  }
}

fn validate_attachment_reference(
  path: String,
  url: String,
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  case attachment_reference_filename(url), attachment_filenames {
    Some(filename), Some(attachment_filenames) ->
      case filename == "" {
        True -> [error(path, validation.AttachmentReferenceMissingFilename)]

        False ->
          case contains_string(in: attachment_filenames, target: filename) {
            True -> []
            False -> [
              error(path, validation.MissingAttachmentReference(filename)),
            ]
          }
      }

    _, _ -> []
  }
}

/// ## Examples
///
/// ```gleam
/// assert attachment_reference_filename("attachment://landscape.jpg") == Some("landscape.jpg")
/// ```
///
/// ```gleam
/// assert attachment_reference_filename("an_invalid_filename") == None
/// ```
fn attachment_reference_filename(url: String) -> Option(String) {
  let prefix = "attachment://"

  case string.starts_with(url, prefix) {
    True ->
      Some(string.slice(
        from: url,
        at_index: string.length(prefix),
        length: string.length(url) - string.length(prefix),
      ))

    False -> None
  }
}

fn component_count(component: component.Component) -> Int {
  case component {
    component.Component(_) -> 1
    component.TextDisplayComponent(_) -> 1
    component.SectionComponent(section) ->
      1 + list.length(section.components) + 1
    component.MediaGalleryComponent(_) -> 1
    component.FileComponent(_) -> 1
    component.SeparatorComponent(_) -> 1
    component.ContainerComponent(container) ->
      1
      + {
        container.components
        |> list.map(container_child_count)
        |> list.fold(0, fn(total, count) { total + count })
      }
  }
}

fn container_child_count(child: component_container.ContainerChild) -> Int {
  case child {
    component_container.ContainerTextDisplay(_) -> 1
    component_container.ContainerSection(section) ->
      1 + list.length(section.components) + 1
    component_container.ContainerMediaGallery(_) -> 1
    component_container.ContainerFile(_) -> 1
    component_container.ContainerSeparator(_) -> 1
  }
}

fn component_requires_v2_flag(component: component.Component) -> Bool {
  case component {
    component.Component(raw) ->
      case raw_component_type(raw) {
        Some(component_type) -> is_v2_component_type(component_type)
        None -> False
      }

    _ -> True
  }
}

fn raw_component_type(raw: json.Json) -> Option(Int) {
  let decoder = {
    use component_type <- dynamic_decode.optional_field(
      "type",
      None,
      dynamic_decode.optional(dynamic_decode.int),
    )
    dynamic_decode.success(component_type)
  }

  case json.parse(from: json.to_string(raw), using: decoder) {
    Ok(component_type) -> component_type
    Error(_) -> None
  }
}

fn is_v2_component_type(component_type: Int) -> Bool {
  case component_type {
    9 -> True
    10 -> True
    11 -> True
    12 -> True
    13 -> True
    14 -> True
    17 -> True
    _ -> False
  }
}

fn embed_character_count(embed: embed.Embed) -> Int {
  optional_string_length(embed.title)
  + optional_string_length(embed.description)
  + optional_footer_text_length(embed.footer)
  + optional_author_name_length(embed.author)
  + optional_field_character_count(embed.fields)
}

fn optional_string_length(value: Option(String)) -> Int {
  case value {
    Some(value) -> string.length(value)
    None -> 0
  }
}

fn optional_footer_text_length(value: Option(embed.EmbedFooter)) -> Int {
  case value {
    Some(footer) -> string.length(footer.text)
    None -> 0
  }
}

fn optional_author_name_length(value: Option(embed.EmbedAuthor)) -> Int {
  case value {
    Some(author) -> string.length(author.name)
    None -> 0
  }
}

fn optional_field_character_count(value: Option(List(embed.EmbedField))) -> Int {
  case value {
    Some(fields) ->
      fields
      |> list.map(fn(field) {
        string.length(field.name) + string.length(field.value)
      })
      |> list.fold(0, fn(total, count) { total + count })

    None -> 0
  }
}

fn contains_string(in items: List(String), target target: String) -> Bool {
  case items {
    [] -> False
    [item, ..rest] -> item == target || contains_string(in: rest, target:)
  }
}

fn duplicate_attachment_filename_errors(
  path: String,
  attachments: List(attachment.Attachment),
) -> List(validation.ValidationError) {
  attachments
  |> list.index_map(fn(attachment, index) { #(attachment.filename, index) })
  |> collect_duplicate_attachment_filename_errors(path, seen_filenames: [])
}

fn collect_duplicate_attachment_filename_errors(
  indexed_filenames: List(#(String, Int)),
  path: String,
  seen_filenames seen_filenames: List(String),
) -> List(validation.ValidationError) {
  case indexed_filenames {
    [] -> []
    [#(filename, index), ..rest] ->
      case contains_string(in: seen_filenames, target: filename) {
        True ->
          collect_duplicate_attachment_filename_errors(
            rest,
            path,
            seen_filenames: seen_filenames,
          )

        False -> {
          let indexes = [
            index,
            ..collect_attachment_filename_indexes(rest, filename)
          ]

          let duplicates = case list.length(indexes) > 1 {
            True -> [
              error(
                path,
                validation.DuplicateAttachmentFilename(filename:, indexes:),
              ),
            ]

            False -> []
          }

          list.append(
            duplicates,
            collect_duplicate_attachment_filename_errors(
              rest,
              path,
              seen_filenames: [filename, ..seen_filenames],
            ),
          )
        }
      }
  }
}

fn collect_attachment_filename_indexes(
  indexed_filenames: List(#(String, Int)),
  filename: String,
) -> List(Int) {
  indexed_filenames
  |> list.filter_map(fn(indexed_filename) {
    let #(candiate_filename, candiate_index) = indexed_filename
    case candiate_filename == filename {
      True -> Ok(candiate_index)
      False -> Error(Nil)
    }
  })
}

fn join_path(base: String, suffix: String) -> String {
  base <> "." <> suffix
}

fn indexed_path(base: String, index: Int) -> String {
  string.concat([base, "[", int.to_string(index), "]"])
}

fn error(
  path: String,
  reason: validation.ValidationReason,
) -> validation.ValidationError {
  validation.ValidationError(path:, reason:)
}
