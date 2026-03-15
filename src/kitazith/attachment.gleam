import gleam/json
import gleam/option.{Some}

import kitazith/internal/json_helper

pub type Attachment {
  Attachment(id: String, filename: String, description: option.Option(String))
}

pub fn new_attachment(id: String, filename: String) -> Attachment {
  Attachment(id: id, filename: filename, description: option.None)
}

pub fn with_description(
  attachment: Attachment,
  description: String,
) -> Attachment {
  Attachment(..attachment, description: option.Some(description))
}

pub fn to_json(a: Attachment) -> json.Json {
  json_helper.object_omit_none([
    Some(#("id", json.string(a.id))),
    Some(#("filename", json.string(a.filename))),
    json_helper.optional("description", a.description, json.string),
  ])
}
