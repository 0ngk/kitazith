import gleam/json
import gleam/option.{Some}

import kitazith/attachment
import kitazith/embed
import kitazith/test_fixtures

pub fn color_from_rgb_test() {
  assert embed.color_from_rgb(red: 255, green: 0, blue: 0) == 0xFF0000
  assert embed.color_from_rgb(red: 0, green: 255, blue: 0) == 0x00FF00
  assert embed.color_from_rgb(red: 0, green: 0, blue: 255) == 0x0000FF
  assert embed.color_from_rgb(red: 88, green: 101, blue: 242) == 5_793_266
  assert embed.color_from_rgb(red: 0, green: 0, blue: 0) == 0
  assert embed.color_from_rgb(red: 255, green: 255, blue: 255) == 0xFFFFFF
}

pub fn builder_embed_test() {
  let e =
    embed.new()
    |> embed.with_title("Release")
    |> embed.with_description("The build is ready.")
    |> embed.with_url("https://example.com")
    |> embed.with_timestamp(test_fixtures.sample_timestamp())
    |> embed.with_color(5_792_266)
    |> embed.with_footer(
      embed.new_footer("kitazith")
      |> embed.with_footer_icon_url("https://example.com/footer.png"),
    )
    |> embed.with_image(embed.EmbedImage(url: "https://example.com/image.png"))
    |> embed.with_thumbnail(embed.EmbedThumbnail(
      url: "https://example.com/thumb.png",
    ))
    |> embed.with_author(
      embed.new_author("Deployment Bot")
      |> embed.with_author_url("https://example.com")
      |> embed.with_author_icon_url("https://example.com/avatar.png"),
    )
    |> embed.with_fields([
      embed.new_field(name: "Status", value: "Green")
      |> embed.with_field_inline(True),
    ])

  assert e.title == Some("Release")
  assert e.description == Some("The build is ready.")
  assert e.url == Some("https://example.com")
  assert e.color == Some(5_792_266)
  assert e.footer
    == Some(embed.EmbedFooter(
      text: "kitazith",
      icon_url: Some("https://example.com/footer.png"),
    ))
  assert e.author
    == Some(embed.EmbedAuthor(
      name: "Deployment Bot",
      url: Some("https://example.com"),
      icon_url: Some("https://example.com/avatar.png"),
    ))
  assert e.fields
    == Some([
      embed.EmbedField(name: "Status", value: "Green", inline: Some(True)),
    ])
}

pub fn embed_to_json_test() {
  let result =
    embed.new()
    |> embed.with_title("Release")
    |> embed.with_description("The build is ready.")
    |> embed.with_timestamp(test_fixtures.sample_timestamp())
    |> embed.with_color(5_792_266)
    |> embed.with_footer(
      embed.new_footer("kitazith")
      |> embed.with_footer_icon_url("https://example.com/footer.png"),
    )
    |> embed.with_image(embed.EmbedImage(url: "https://example.com/image.png"))
    |> embed.with_author(
      embed.new_author("Bot")
      |> embed.with_author_icon_url("https://example.com/avatar.png"),
    )
    |> embed.with_fields([
      embed.new_field(name: "Status", value: "Green")
      |> embed.with_field_inline(True),
    ])
    |> embed.to_json
    |> json.to_string

  assert result
    == "{\"title\":\"Release\",\"description\":\"The build is ready.\",\"timestamp\":\"2026-03-15T09:30:00Z\",\"color\":5792266,\"footer\":{\"text\":\"kitazith\",\"icon_url\":\"https://example.com/footer.png\"},\"image\":{\"url\":\"https://example.com/image.png\"},\"author\":{\"name\":\"Bot\",\"icon_url\":\"https://example.com/avatar.png\"},\"fields\":[{\"name\":\"Status\",\"value\":\"Green\",\"inline\":true}]}"
}

pub fn embed_to_json_with_attachment_thumbnail_test() {
  let result =
    embed.new()
    |> embed.with_thumbnail(
      embed.EmbedThumbnail(
        url: attachment.to_embed_url(attachment.new(
          id: 0,
          filename: "thumb.png",
        )),
      ),
    )
    |> embed.to_json
    |> json.to_string

  assert result == "{\"thumbnail\":{\"url\":\"attachment://thumb.png\"}}"
}
