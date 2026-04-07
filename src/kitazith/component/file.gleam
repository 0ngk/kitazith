import gleam/json
import gleam/option.{type Option, None, Some}

import kitazith/component/media as component_media
import kitazith/internal/json_helper

/// Learn more:
///   [Component Reference - Documentation - Discord > File](https://docs.discord.com/developers/components/reference#file)
pub type File {
  File(
    id: Option(Int),
    /// `attachment://<filename>` only.
    file: component_media.UnfurledMediaItem,
    spoiler: Option(Bool),
  )
}

pub fn new(file file: component_media.UnfurledMediaItem) -> File {
  File(id: None, file:, spoiler: None)
}

pub fn with_id(file: File, id: Int) -> File {
  File(..file, id: Some(id))
}

pub fn with_spoiler(file: File, spoiler: Bool) -> File {
  File(..file, spoiler: Some(spoiler))
}

pub fn to_json(file: File) -> json.Json {
  json_helper.object_omit_none([
    Some(#("type", json.int(13))),
    json_helper.optional("id", file.id, json.int),
    Some(#("file", component_media.to_json(file.file))),
    json_helper.optional("spoiler", file.spoiler, json.bool),
  ])
}
