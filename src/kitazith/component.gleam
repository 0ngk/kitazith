import gleam/json

import kitazith/component/file as component_file
import kitazith/component/media_gallery as component_media_gallery
import kitazith/component/section as component_section
import kitazith/component/separator as component_separator
import kitazith/component/text_display as component_text_display

/// Learn more:
///   [Component Reference - Documentation - Discord](https://docs.discord.com/developers/components/reference)
pub type Component {
  /// Escape hatch for component shapes not modeled by this library.
  Component(raw: json.Json)
  TextDisplayComponent(component_text_display.TextDisplay)
  SectionComponent(component_section.Section)
  MediaGalleryComponent(component_media_gallery.MediaGallery)
  FileComponent(component_file.File)
  SeparatorComponent(component_separator.Separator)
}

pub fn raw(data: json.Json) -> Component {
  Component(data)
}

pub fn text_display(
  text_display: component_text_display.TextDisplay,
) -> Component {
  TextDisplayComponent(text_display)
}

pub fn section(section: component_section.Section) -> Component {
  SectionComponent(section)
}

pub fn media_gallery(
  media_gallery: component_media_gallery.MediaGallery,
) -> Component {
  MediaGalleryComponent(media_gallery)
}

pub fn file(file: component_file.File) -> Component {
  FileComponent(file)
}

pub fn separator(separator: component_separator.Separator) -> Component {
  SeparatorComponent(separator)
}

pub fn to_json(component: Component) -> json.Json {
  case component {
    Component(raw) -> raw
    TextDisplayComponent(text_display) ->
      component_text_display.to_json(text_display)
    SectionComponent(section) -> component_section.to_json(section)
    MediaGalleryComponent(media_gallery) ->
      component_media_gallery.to_json(media_gallery)
    FileComponent(file) -> component_file.to_json(file)
    SeparatorComponent(separator) -> component_separator.to_json(separator)
  }
}
