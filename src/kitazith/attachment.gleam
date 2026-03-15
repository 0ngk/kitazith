import gleam/json
import gleam/option.{type Option, None, Some}

import kitazith/internal/json_helper

pub type Attachment {
  Attachment(id: String, filename: String, description: Option(String))
}

pub fn new_attachment(id: String, filename: String) -> Attachment {
  Attachment(id: id, filename: filename, description: None)
}

pub fn with_description(
  attachment: Attachment,
  description: String,
) -> Attachment {
  Attachment(..attachment, description: Some(description))
}

pub fn to_json(a: Attachment) -> json.Json {
  json_helper.object_omit_none([
    Some(#("id", json.string(a.id))),
    Some(#("filename", json.string(a.filename))),
    json_helper.optional("description", a.description, json.string),
  ])
}
