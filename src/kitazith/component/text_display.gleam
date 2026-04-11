import gleam/json
import gleam/option.{type Option, None, Some}

import kitazith/internal/json_helper

/// Learn more:
///   [Component Reference - Documentation - Discord > Text Display](https://docs.discord.com/developers/components/reference#text-display)
pub type TextDisplay {
  TextDisplay(id: Option(Int), content: String)
}

pub fn new(content: String) -> TextDisplay {
  TextDisplay(id: None, content:)
}

pub fn with_id(text_display: TextDisplay, id: Int) -> TextDisplay {
  TextDisplay(..text_display, id: Some(id))
}

pub fn to_json(text_display: TextDisplay) -> json.Json {
  json_helper.object_omit_none([
    Some(#("type", json.int(10))),
    json_helper.optional("id", text_display.id, json.int),
    Some(#("content", json.string(text_display.content))),
  ])
}
