import gleam/dynamic/decode as dynamic_decode
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}

import kitazith/component
import kitazith/component/container as component_container
import kitazith/component/file as component_file
import kitazith/component/media_gallery as component_media_gallery
import kitazith/component/section as component_section
import kitazith/component/text_display as component_text_display
import kitazith/internal/validation/attachment
import kitazith/internal/validation/common
import kitazith/validation

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
        common.error(
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
          common.indexed_path(path, index),
          component,
          attachment_filenames: attachment_filenames,
        )
      })
      |> list.flatten,
  ])
}

pub fn components_require_v2_flag(
  components: List(component.Component),
) -> Bool {
  case components {
    [] -> False
    [component, ..rest] ->
      component_requires_v2_flag(component) || components_require_v2_flag(rest)
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
        common.error(
          common.join_path(path, "components"),
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
          common.indexed_path(common.join_path(path, "components"), index),
          text_display,
        )
      })
      |> list.flatten,
    validate_thumbnail(
      common.join_path(path, "accessory"),
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
  attachment.validate_attachment_reference(
    common.join_path(path, "media.url"),
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
        common.error(
          common.join_path(path, "items"),
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
          common.indexed_path(common.join_path(path, "items"), index),
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
        common.validate_string_max_length(
          common.join_path(path, "description"),
          description,
          max: 1024,
        )

      None -> []
    },
    attachment.validate_attachment_reference(
      common.join_path(path, "media.url"),
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
  case attachment.attachment_reference_filename(file.file.url) {
    Some(_) ->
      attachment.validate_attachment_reference(
        common.join_path(path, "file.url"),
        file.file.url,
        attachment_filenames: attachment_filenames,
      )

    None -> [
      common.error(
        common.join_path(path, "file.url"),
        validation.AttachmentReferenceRequired,
      ),
    ]
  }
}

fn validate_container(
  path: String,
  container: component_container.Container,
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  list.flatten([
    case container.accent_color {
      Some(accent_color) ->
        case accent_color >= 0 && accent_color <= 0xFFFFFF {
          True -> []
          False -> [
            common.error(
              common.join_path(path, "accent_color"),
              validation.NumericOutOfRange(
                min: 0,
                max: 0xFFFFFF,
                actual: accent_color,
                unit: "RGB values",
              ),
            ),
          ]
        }

      None -> []
    },
    container.components
      |> list.index_map(fn(child, index) {
        validate_container_child(
          common.indexed_path(common.join_path(path, "components"), index),
          child,
          attachment_filenames: attachment_filenames,
        )
      })
      |> list.flatten,
  ])
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
