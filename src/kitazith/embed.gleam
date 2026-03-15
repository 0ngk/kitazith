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
