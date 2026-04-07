import gleam/json
import gleam/option.{type Option, None, Some}

import kitazith/component/file as component_file
import kitazith/component/media_gallery as component_media_gallery
import kitazith/component/section as component_section
import kitazith/component/separator as component_separator
import kitazith/component/text_display as component_text_display
import kitazith/internal/json_helper

/// Components allowed inside a container for non-interactive webhook payloads.
pub type ContainerChild {
  ContainerTextDisplay(component_text_display.TextDisplay)
  ContainerSection(component_section.Section)
  ContainerMediaGallery(component_media_gallery.MediaGallery)
  ContainerFile(component_file.File)
  ContainerSeparator(component_separator.Separator)
}

/// Learn more:
///   [Components > Container](https://docs.discord.com/developers/components/reference#container)
pub type Container {
  Container(
    id: Option(Int),
    components: List(ContainerChild),
    /// RGB value from `0x000000` to `0xFFFFFF`.
    accent_color: Option(Int),
    spoiler: Option(Bool),
  )
}

pub fn new(components: List(ContainerChild)) -> Container {
  Container(id: None, components:, accent_color: None, spoiler: None)
}

pub fn with_id(container: Container, id: Int) -> Container {
  Container(..container, id: Some(id))
}

/// Use `kitazith/color.from_rgb` to build the packed integer from RGB components.
pub fn with_accent_color(container: Container, accent_color: Int) -> Container {
  Container(..container, accent_color: Some(accent_color))
}

pub fn with_spoiler(container: Container, spoiler: Bool) -> Container {
  Container(..container, spoiler: Some(spoiler))
}

pub fn text_display(
  text_display: component_text_display.TextDisplay,
) -> ContainerChild {
  ContainerTextDisplay(text_display)
}

pub fn section(section: component_section.Section) -> ContainerChild {
  ContainerSection(section)
}

pub fn media_gallery(
  media_gallery: component_media_gallery.MediaGallery,
) -> ContainerChild {
  ContainerMediaGallery(media_gallery)
}

pub fn file(file: component_file.File) -> ContainerChild {
  ContainerFile(file)
}

pub fn separator(separator: component_separator.Separator) -> ContainerChild {
  ContainerSeparator(separator)
}

pub fn to_json(container: Container) -> json.Json {
  json_helper.object_omit_none([
    Some(#("type", json.int(17))),
    json_helper.optional("id", container.id, json.int),
    Some(#("components", json.array(container.components, child_to_json))),
    json_helper.optional("accent_color", container.accent_color, json.int),
    json_helper.optional("spoiler", container.spoiler, json.bool),
  ])
}

fn child_to_json(child: ContainerChild) -> json.Json {
  case child {
    ContainerTextDisplay(text_display) ->
      component_text_display.to_json(text_display)
    ContainerSection(section) -> component_section.to_json(section)
    ContainerMediaGallery(media_gallery) ->
      component_media_gallery.to_json(media_gallery)
    ContainerFile(file) -> component_file.to_json(file)
    ContainerSeparator(separator) -> component_separator.to_json(separator)
  }
}
