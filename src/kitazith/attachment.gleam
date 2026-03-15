import gleam/option

pub type Attachment {
  Attachment(id: String, filename: String, description: option.Option(String))
}
