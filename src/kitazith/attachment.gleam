import gleam/json
import gleam/option.{type Option, None, Some}

import kitazith/internal/json_helper

pub type Attachment {
  Attachment(
    id: Int,
    filename: String,
    /// At least 1 character and up to 1024 characters.
    description: Option(String),
  )
}

pub fn new_attachment(id id: Int, filename filename: String) -> Attachment {
  Attachment(id:, filename:, description: None)
}

pub fn with_description(
  attachment: Attachment,
  description: String,
) -> Attachment {
  Attachment(..attachment, description: Some(description))
}

pub fn to_json(a: Attachment) -> json.Json {
  json_helper.object_omit_none([
    Some(#("id", json.int(a.id))),
    Some(#("filename", json.string(a.filename))),
    json_helper.optional("description", a.description, json.string),
  ])
}
