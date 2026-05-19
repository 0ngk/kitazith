import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

import kitazith/embed
import kitazith/internal/validation/attachment
import kitazith/internal/validation/common
import kitazith/validation

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
    common.validate_list_max_length(path, embeds, max: 10, noun: "embeds"),
    case total_character_count <= 6000 {
      True -> []
      False -> [
        common.error(
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
          common.indexed_path(path, index),
          embed,
          attachment_filenames: attachment_filenames,
        )
      })
      |> list.flatten,
  ])
}

fn validate_embed(
  path: String,
  embed: embed.Embed,
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  list.flatten([
    case embed.title {
      Some(title) ->
        common.validate_string_max_length(
          common.join_path(path, "title"),
          title,
          max: 256,
        )

      None -> []
    },
    case embed.description {
      Some(description) ->
        common.validate_string_max_length(
          common.join_path(path, "description"),
          description,
          max: 4096,
        )

      None -> []
    },
    case embed.footer {
      Some(footer) ->
        list.flatten([
          common.validate_string_length(
            common.join_path(path, "footer.text"),
            footer.text,
            min: 1,
            max: 2048,
          ),
          case footer.icon_url {
            Some(icon_url) ->
              attachment.validate_attachment_reference(
                common.join_path(path, "footer.icon_url"),
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
        attachment.validate_attachment_reference(
          common.join_path(path, "image.url"),
          image.url,
          attachment_filenames: attachment_filenames,
        )

      None -> []
    },
    case embed.thumbnail {
      Some(thumbnail) ->
        attachment.validate_attachment_reference(
          common.join_path(path, "thumbnail.url"),
          thumbnail.url,
          attachment_filenames: attachment_filenames,
        )

      None -> []
    },
    case embed.author {
      Some(author) ->
        list.flatten([
          common.validate_string_length(
            common.join_path(path, "author.name"),
            author.name,
            min: 1,
            max: 256,
          ),
          case author.icon_url {
            Some(icon_url) ->
              attachment.validate_attachment_reference(
                common.join_path(path, "author.icon_url"),
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
          common.validate_list_max_length(
            common.join_path(path, "fields"),
            fields,
            max: 25,
            noun: "fields",
          ),
          fields
            |> list.index_map(fn(field, index) {
              list.flatten([
                common.validate_string_length(
                  common.join_path(
                    common.indexed_path(common.join_path(path, "fields"), index),
                    "name",
                  ),
                  field.name,
                  min: 1,
                  max: 256,
                ),
                common.validate_string_length(
                  common.join_path(
                    common.indexed_path(common.join_path(path, "fields"), index),
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

fn optional_field_character_count(
  value: Option(List(embed.EmbedField)),
) -> Int {
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
