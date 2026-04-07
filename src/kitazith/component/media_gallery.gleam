import gleam/json
import gleam/option.{type Option, None, Some}

import kitazith/component/media as component_media
import kitazith/internal/json_helper

/// Learn more:
///   [Component Reference - Documentation - Discord > Media Gallery](https://docs.discord.com/developers/components/reference#media-gallery)
pub type MediaGallery {
  MediaGallery(
    id: Option(Int),
    /// One to ten media gallery items.
    items: List(MediaGalleryItem),
  )
}

/// Learn more:
///   [Component Reference - Documentation - Discord > Media Gallery Item Structure](https://docs.discord.com/developers/components/reference#media-gallery-media-gallery-item-structure)
pub type MediaGalleryItem {
  MediaGalleryItem(
    media: component_media.UnfurledMediaItem,
    /// Up to 1024 characters.
    description: Option(String),
    spoiler: Option(Bool),
  )
}

pub fn new(items: List(MediaGalleryItem)) -> MediaGallery {
  MediaGallery(id: None, items:)
}

pub fn with_id(media_gallery: MediaGallery, id: Int) -> MediaGallery {
  MediaGallery(..media_gallery, id: Some(id))
}

pub fn new_item(media: component_media.UnfurledMediaItem) -> MediaGalleryItem {
  MediaGalleryItem(media:, description: None, spoiler: None)
}

pub fn with_item_description(
  item: MediaGalleryItem,
  description: String,
) -> MediaGalleryItem {
  MediaGalleryItem(..item, description: Some(description))
}

pub fn with_item_spoiler(
  item: MediaGalleryItem,
  spoiler: Bool,
) -> MediaGalleryItem {
  MediaGalleryItem(..item, spoiler: Some(spoiler))
}

pub fn to_json(media_gallery: MediaGallery) -> json.Json {
  json_helper.object_omit_none([
    Some(#("type", json.int(12))),
    json_helper.optional("id", media_gallery.id, json.int),
    Some(#("items", json.array(media_gallery.items, item_to_json))),
  ])
}

fn item_to_json(item: MediaGalleryItem) -> json.Json {
  json_helper.object_omit_none([
    Some(#("media", component_media.to_json(item.media))),
    json_helper.optional("description", item.description, json.string),
    json_helper.optional("spoiler", item.spoiler, json.bool),
  ])
}
