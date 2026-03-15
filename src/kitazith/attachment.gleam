import gleam/option

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
