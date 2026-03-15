import gleam/option

pub type Embed {
  Embed(
    title: option.Option(String),
    description: option.Option(String),
    url: option.Option(String),
    timestamp: option.Option(EmbedTimestamp),
    color: option.Option(Int),
    footer: option.Option(EmbedFooter),
    image: option.Option(EmbedImage),
    thumbnail: option.Option(EmbedThumbnail),
    author: option.Option(EmbedAuthor),
    fields: option.Option(List(EmbedField)),
  )
}

pub type EmbedTimestamp {
  EmbedTimestamp(iso8601: String)
}

pub type EmbedFooter {
  EmbedFooter(text: String, icon_url: option.Option(String))
}

pub type EmbedImage {
  EmbedImage(url: String)
}

pub type EmbedThumbnail {
  EmbedThumbnail(url: String)
}

pub type EmbedAuthor {
  EmbedAuthor(
    name: String,
    url: option.Option(String),
    icon_url: option.Option(String),
  )
}

pub type EmbedField {
  EmbedField(name: String, value: String, inline: option.Option(Bool))
}

pub fn new_embed() -> Embed {
  Embed(
    title: option.None,
    description: option.None,
    url: option.None,
    timestamp: option.None,
    color: option.None,
    footer: option.None,
    image: option.None,
    thumbnail: option.None,
    author: option.None,
    fields: option.None,
  )
}

pub fn with_title(embed: Embed, title: String) -> Embed {
  Embed(..embed, title: option.Some(title))
}

pub fn with_description(embed: Embed, description: String) -> Embed {
  Embed(..embed, description: option.Some(description))
}

pub fn with_url(embed: Embed, url: String) -> Embed {
  Embed(..embed, url: option.Some(url))
}

pub fn with_timestamp(embed: Embed, timestamp: EmbedTimestamp) -> Embed {
  Embed(..embed, timestamp: option.Some(timestamp))
}

pub fn with_color(embed: Embed, color: Int) -> Embed {
  Embed(..embed, color: option.Some(color))
}

pub fn with_footer(embed: Embed, footer: EmbedFooter) -> Embed {
  Embed(..embed, footer: option.Some(footer))
}

pub fn with_image(embed: Embed, image: EmbedImage) -> Embed {
  Embed(..embed, image: option.Some(image))
}

pub fn with_thumbnail(embed: Embed, thumbnail: EmbedThumbnail) -> Embed {
  Embed(..embed, thumbnail: option.Some(thumbnail))
}

pub fn with_author(embed: Embed, author: EmbedAuthor) -> Embed {
  Embed(..embed, author: option.Some(author))
}

pub fn with_fields(embed: Embed, fields: List(EmbedField)) -> Embed {
  Embed(..embed, fields: option.Some(fields))
}

pub fn new_footer(text: String) -> EmbedFooter {
  EmbedFooter(text: text, icon_url: option.None)
}

pub fn with_footer_icon_url(
  footer: EmbedFooter,
  icon_url: String,
) -> EmbedFooter {
  EmbedFooter(..footer, icon_url: option.Some(icon_url))
}

pub fn new_author(name: String) -> EmbedAuthor {
  EmbedAuthor(name: name, url: option.None, icon_url: option.None)
}

pub fn with_author_url(author: EmbedAuthor, url: String) -> EmbedAuthor {
  EmbedAuthor(..author, url: option.Some(url))
}

pub fn with_author_icon_url(
  author: EmbedAuthor,
  icon_url: String,
) -> EmbedAuthor {
  EmbedAuthor(..author, icon_url: option.Some(icon_url))
}

pub fn new_field(name: String, value: String) -> EmbedField {
  EmbedField(name: name, value: value, inline: option.None)
}

pub fn with_field_inline(field: EmbedField, inline: Bool) -> EmbedField {
  EmbedField(..field, inline: option.Some(inline))
}
