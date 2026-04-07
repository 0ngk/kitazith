import gleam/json

/// Learn more:
///   [Component Reference - Documentation - Discord > Unfurled Media Item Structure](https://docs.discord.com/developers/components/reference#unfurled-media-item-unfurled-media-item-structure)
pub type UnfurledMediaItem {
  UnfurledMediaItem(url: String)
}

pub fn new(url: String) -> UnfurledMediaItem {
  UnfurledMediaItem(url:)
}

pub fn to_json(item: UnfurledMediaItem) -> json.Json {
  json.object([#("url", json.string(item.url))])
}
