import gleam/json
import gleam/option.{type Option, None, Some}

import kitazith/internal/json_helper
import kitazith/timestamp

/// Learn more: [Message Resource - Documentation - Discord > Embed Object](https://docs.discord.com/developers/resources/message#embed-object)
///
/// Up to 6000 characters total across all `title`, `description`,
/// `field.name`, `field.value`, `footer.text`, and `author.name` fields
/// in all embeds per message.
///
/// Source: [Message Resource - Documentation - Discord > Embed Object > Embed Limits](https://docs.discord.com/developers/resources/message#embed-object-embed-limits)
///
/// `type`, `provider`, and `video` filds are not supported for the webhook embed objects.
///
/// Source: [Webhook Resource - Documentation - Discord > Execute Webhook](https://docs.discord.com/developers/resources/webhook#execute-webhook)
pub type Embed {
  Embed(
    /// Up to 256 characters.
    title: Option(String),
    /// Up to 4096 characters.
    description: Option(String),
    url: Option(String),
    /// ISO8601 timestamp
    timestamp: Option(timestamp.Timestamp),
    color: Option(Int),
    footer: Option(EmbedFooter),
    image: Option(EmbedImage),
    thumbnail: Option(EmbedThumbnail),
    author: Option(EmbedAuthor),
    /// Up to 25 fields.
    fields: Option(List(EmbedField)),
  )
}

/// Learn more: [Message Resource - Documentation - Discord > Embed Footer Structure](https://docs.discord.com/developers/resources/message#embed-object-embed-footer-structure)
pub type EmbedFooter {
  EmbedFooter(
    /// Up to 2048 characters.
    text: String,
    icon_url: Option(String),
  )
}

/// Learn more: [Message Resource - Documentation - Discord > Embed Image Structure](https://docs.discord.com/developers/resources/message#embed-object-embed-image-structure)
pub type EmbedImage {
  EmbedImage(url: String)
}

/// Learn more: [Message Resource - Documentation - Discord > Embed Thumbnail Structure](https://docs.discord.com/developers/resources/message#embed-object-embed-thumbnail-structure)
pub type EmbedThumbnail {
  EmbedThumbnail(url: String)
}

/// Learn more: [Message Resource - Documentation - Discord > Embed Author Structure](https://docs.discord.com/developers/resources/message#embed-object-embed-author-structure)
pub type EmbedAuthor {
  EmbedAuthor(
    /// Up to 256 characters.
    name: String,
    url: Option(String),
    icon_url: Option(String),
  )
}

/// Learn more: [Message Resource - Documentation - Discord > Embed Field Structure](https://docs.discord.com/developers/resources/message#embed-object-embed-field-structure)
pub type EmbedField {
  EmbedField(
    /// Up to 256 characters.
    name: String,
    /// Up to 1024 characters.
    value: String,
    inline: Option(Bool),
  )
}

pub fn new_embed() -> Embed {
  Embed(
    title: None,
    description: None,
    url: None,
    timestamp: None,
    color: None,
    footer: None,
    image: None,
    thumbnail: None,
    author: None,
    fields: None,
  )
}

pub fn with_title(embed: Embed, title: String) -> Embed {
  Embed(..embed, title: Some(title))
}

pub fn with_description(embed: Embed, description: String) -> Embed {
  Embed(..embed, description: Some(description))
}

pub fn with_url(embed: Embed, url: String) -> Embed {
  Embed(..embed, url: Some(url))
}

pub fn with_timestamp(embed: Embed, timestamp: timestamp.Timestamp) -> Embed {
  Embed(..embed, timestamp: Some(timestamp))
}

pub fn with_color(embed: Embed, color: Int) -> Embed {
  Embed(..embed, color: Some(color))
}

/// Converts RGB components to a single color integer for use with `with_color`.
///
/// ## Examples
///
/// ```gleam
/// color_from_rgb(255, 0, 0)
/// // -> 0xFF0000 (== 16711680)
/// ```
///
/// ```gleam
/// embed.new_embed()
/// |> embed.with_color(embed.color_from_rgb(88, 101, 242))
/// ```
pub fn color_from_rgb(red: Int, green: Int, blue: Int) -> Int {
  red * 65_536 + green * 256 + blue
}

pub fn with_footer(embed: Embed, footer: EmbedFooter) -> Embed {
  Embed(..embed, footer: Some(footer))
}

pub fn with_image(embed: Embed, image: EmbedImage) -> Embed {
  Embed(..embed, image: Some(image))
}

pub fn with_thumbnail(embed: Embed, thumbnail: EmbedThumbnail) -> Embed {
  Embed(..embed, thumbnail: Some(thumbnail))
}

pub fn with_author(embed: Embed, author: EmbedAuthor) -> Embed {
  Embed(..embed, author: Some(author))
}

pub fn with_fields(embed: Embed, fields: List(EmbedField)) -> Embed {
  Embed(..embed, fields: Some(fields))
}

pub fn new_footer(text: String) -> EmbedFooter {
  EmbedFooter(text: text, icon_url: None)
}

pub fn with_footer_icon_url(
  footer: EmbedFooter,
  icon_url: String,
) -> EmbedFooter {
  EmbedFooter(..footer, icon_url: Some(icon_url))
}

pub fn new_author(name: String) -> EmbedAuthor {
  EmbedAuthor(name: name, url: None, icon_url: None)
}

pub fn with_author_url(author: EmbedAuthor, url: String) -> EmbedAuthor {
  EmbedAuthor(..author, url: Some(url))
}

pub fn with_author_icon_url(
  author: EmbedAuthor,
  icon_url: String,
) -> EmbedAuthor {
  EmbedAuthor(..author, icon_url: Some(icon_url))
}

pub fn new_field(name: String, value: String) -> EmbedField {
  EmbedField(name: name, value: value, inline: None)
}

pub fn with_field_inline(field: EmbedField, inline: Bool) -> EmbedField {
  EmbedField(..field, inline: Some(inline))
}

pub fn to_json(embed: Embed) -> json.Json {
  json_helper.object_omit_none([
    json_helper.optional("title", embed.title, json.string),
    json_helper.optional("description", embed.description, json.string),
    json_helper.optional("url", embed.url, json.string),
    json_helper.optional("timestamp", embed.timestamp, timestamp.to_json),
    json_helper.optional("color", embed.color, json.int),
    json_helper.optional("footer", embed.footer, embed_footer_to_json),
    json_helper.optional("image", embed.image, embed_image_to_json),
    json_helper.optional("thumbnail", embed.thumbnail, embed_thumbnail_to_json),
    json_helper.optional("author", embed.author, embed_author_to_json),
    json_helper.optional("fields", embed.fields, fn(fields) {
      json.array(fields, embed_field_to_json)
    }),
  ])
}

fn embed_footer_to_json(footer: EmbedFooter) -> json.Json {
  json_helper.object_omit_none([
    Some(#("text", json.string(footer.text))),
    json_helper.optional("icon_url", footer.icon_url, json.string),
  ])
}

fn embed_image_to_json(image: EmbedImage) -> json.Json {
  json.object([#("url", json.string(image.url))])
}

fn embed_thumbnail_to_json(thumbnail: EmbedThumbnail) -> json.Json {
  json.object([#("url", json.string(thumbnail.url))])
}

fn embed_author_to_json(author: EmbedAuthor) -> json.Json {
  json_helper.object_omit_none([
    Some(#("name", json.string(author.name))),
    json_helper.optional("url", author.url, json.string),
    json_helper.optional("icon_url", author.icon_url, json.string),
  ])
}

fn embed_field_to_json(field: EmbedField) -> json.Json {
  json_helper.object_omit_none([
    Some(#("name", json.string(field.name))),
    Some(#("value", json.string(field.value))),
    json_helper.optional("inline", field.inline, json.bool),
  ])
}
