import gleam/json
import gleam/option.{type Option, None, Some}

import kitazith/component/media as component_media
import kitazith/component/text_display as component_text_display
import kitazith/internal/json_helper

/// Learn more:
///   [Component Reference - Documentation - Discord > Section](https://docs.discord.com/developers/components/reference#section)
pub type Section {
  Section(
    id: Option(Int),
    /// 1 to 3 text display components.
    components: List(component_text_display.TextDisplay),
    /// Only thumbnail accessories are modeled by this library.
    accessory: Thumbnail,
  )
}

/// Learn more:
///   [Component Reference - Documentation - Discord > Thumbnail](https://docs.discord.com/developers/components/reference#thumbnail)
pub type Thumbnail {
  Thumbnail(id: Option(Int), media: component_media.UnfurledMediaItem)
}

pub fn new_thumbnail(
  media media: component_media.UnfurledMediaItem,
) -> Thumbnail {
  Thumbnail(id: None, media:)
}

pub fn with_thumbnail_id(thumbnail: Thumbnail, id: Int) -> Thumbnail {
  Thumbnail(..thumbnail, id: Some(id))
}

pub fn new(
  components components: List(component_text_display.TextDisplay),
  accessory accessory: Thumbnail,
) -> Section {
  Section(id: None, components:, accessory:)
}

pub fn with_id(section: Section, id: Int) -> Section {
  Section(..section, id: Some(id))
}

pub fn to_json(section: Section) -> json.Json {
  json_helper.object_omit_none([
    Some(#("type", json.int(9))),
    json_helper.optional("id", section.id, json.int),
    Some(#(
      "components",
      json.array(section.components, component_text_display.to_json),
    )),
    Some(#("accessory", thumbnail_to_json(section.accessory))),
  ])
}

fn thumbnail_to_json(thumbnail: Thumbnail) -> json.Json {
  json_helper.object_omit_none([
    Some(#("type", json.int(11))),
    json_helper.optional("id", thumbnail.id, json.int),
    Some(#("media", component_media.to_json(thumbnail.media))),
  ])
}
