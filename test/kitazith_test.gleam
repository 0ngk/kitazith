import gleam/json
import gleam/option
import gleeunit

import kitazith/attachment
import kitazith/component
import kitazith/embed
import kitazith/mentions
import kitazith/payload
import kitazith/poll

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn new_payload_starts_empty_test() {
  let webhook_payload = payload.new_payload()

  assert webhook_payload.content == option.None
  assert webhook_payload.username == option.None
  assert webhook_payload.avatar_url == option.None
  assert webhook_payload.tts == option.None
  assert webhook_payload.embeds == option.None
  assert webhook_payload.allowed_mentions == option.None
  assert webhook_payload.components == option.None
  assert webhook_payload.attachments == option.None
  assert webhook_payload.flags == option.None
  assert webhook_payload.thread_name == option.None
  assert webhook_payload.applied_tags == option.None
  assert webhook_payload.poll == option.None
}

pub fn poll_only_payload_test() {
  let webhook_payload =
    payload.Payload(
      content: option.None,
      username: option.None,
      avatar_url: option.None,
      tts: option.None,
      embeds: option.None,
      allowed_mentions: option.None,
      components: option.None,
      attachments: option.None,
      flags: option.None,
      thread_name: option.None,
      applied_tags: option.None,
      poll: option.Some(sample_poll()),
    )

  assert webhook_payload.content == option.None
  assert webhook_payload.poll == option.Some(sample_poll())
}

pub fn payload_supports_all_submodules_test() {
  let webhook_payload =
    payload.Payload(
      content: option.None,
      username: option.Some("kitazith"),
      avatar_url: option.None,
      tts: option.Some(False),
      embeds: option.Some([sample_embed()]),
      allowed_mentions: option.Some(sample_mentions()),
      components: option.Some([sample_component()]),
      attachments: option.Some([sample_attachment()]),
      flags: option.Some(0),
      thread_name: option.Some("release-notes"),
      applied_tags: option.Some(["1234567890"]),
      poll: option.Some(sample_poll()),
    )

  assert webhook_payload.username == option.Some("kitazith")
  assert webhook_payload.embeds == option.Some([sample_embed()])
  assert webhook_payload.allowed_mentions == option.Some(sample_mentions())
  assert webhook_payload.components == option.Some([sample_component()])
  assert webhook_payload.attachments == option.Some([sample_attachment()])
  assert webhook_payload.poll == option.Some(sample_poll())
}

fn sample_attachment() -> attachment.Attachment {
  attachment.Attachment(
    id: "0",
    filename: "banner.png",
    description: option.Some("Release banner"),
  )
}

fn sample_component() -> component.Component {
  component.raw(json.object([#("type", json.int(1))]))
}

fn sample_embed() -> embed.Embed {
  embed.Embed(
    title: option.Some("Release"),
    description: option.Some("The build is ready."),
    url: option.None,
    timestamp: option.Some(embed.EmbedTimestamp("2026-03-15T09:30:00Z")),
    color: option.Some(5_792_266),
    footer: option.Some(embed.EmbedFooter(
      text: "kitazith",
      icon_url: option.Some("https://example.com/footer.png"),
    )),
    image: option.Some(embed.EmbedImage(url: "https://example.com/image.png")),
    thumbnail: option.Some(embed.EmbedThumbnail(
      url: "https://example.com/thumb.png",
    )),
    author: option.Some(embed.EmbedAuthor(
      name: "Deployment Bot",
      url: option.None,
      icon_url: option.Some("https://example.com/avatar.png"),
    )),
    fields: option.Some([
      embed.EmbedField(
        name: "Status",
        value: "Green",
        inline: option.Some(True),
      ),
    ]),
  )
}

fn sample_mentions() -> mentions.AllowedMentions {
  mentions.AllowedMentions(
    parse: option.Some([mentions.Users]),
    roles: option.Some([]),
    users: option.Some(["42"]),
    replied_user: option.Some(False),
  )
}

pub fn builder_payload_test() {
  let webhook_payload =
    payload.new_payload()
    |> payload.with_content("Hello")
    |> payload.with_username("kitazith")
    |> payload.with_avatar_url("https://example.com/avatar.png")
    |> payload.with_tts(False)
    |> payload.with_embeds([sample_embed()])
    |> payload.with_allowed_mentions(sample_mentions())
    |> payload.with_components([sample_component()])
    |> payload.with_attachments([sample_attachment()])
    |> payload.with_flags(0)
    |> payload.with_thread_name("release-notes")
    |> payload.with_applied_tags(["1234567890"])
    |> payload.with_poll(sample_poll())

  assert webhook_payload.content == option.Some("Hello")
  assert webhook_payload.username == option.Some("kitazith")
  assert webhook_payload.avatar_url
    == option.Some("https://example.com/avatar.png")
  assert webhook_payload.tts == option.Some(False)
  assert webhook_payload.embeds == option.Some([sample_embed()])
  assert webhook_payload.allowed_mentions == option.Some(sample_mentions())
  assert webhook_payload.components == option.Some([sample_component()])
  assert webhook_payload.attachments == option.Some([sample_attachment()])
  assert webhook_payload.flags == option.Some(0)
  assert webhook_payload.thread_name == option.Some("release-notes")
  assert webhook_payload.applied_tags == option.Some(["1234567890"])
  assert webhook_payload.poll == option.Some(sample_poll())
}

pub fn builder_embed_test() {
  let e =
    embed.new_embed()
    |> embed.with_title("Release")
    |> embed.with_description("The build is ready.")
    |> embed.with_url("https://example.com")
    |> embed.with_timestamp(embed.EmbedTimestamp("2026-03-15T09:30:00Z"))
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
      embed.new_field("Status", "Green")
      |> embed.with_field_inline(True),
    ])

  assert e.title == option.Some("Release")
  assert e.description == option.Some("The build is ready.")
  assert e.url == option.Some("https://example.com")
  assert e.color == option.Some(5_792_266)
  assert e.footer
    == option.Some(embed.EmbedFooter(
      text: "kitazith",
      icon_url: option.Some("https://example.com/footer.png"),
    ))
  assert e.author
    == option.Some(embed.EmbedAuthor(
      name: "Deployment Bot",
      url: option.Some("https://example.com"),
      icon_url: option.Some("https://example.com/avatar.png"),
    ))
  assert e.fields
    == option.Some([
      embed.EmbedField(
        name: "Status",
        value: "Green",
        inline: option.Some(True),
      ),
    ])
}

pub fn builder_poll_test() {
  let p =
    poll.new_poll(poll.PollQuestion(text: "Pick one"), [
      poll.PollAnswer(
        poll_media: poll.new_poll_media()
        |> poll.with_poll_media_text("Option A"),
      ),
      poll.PollAnswer(
        poll_media: poll.new_poll_media()
        |> poll.with_poll_media_text("Option B")
        |> poll.with_poll_media_emoji(
          poll.new_poll_emoji()
          |> poll.with_poll_emoji_name("\u{1f525}"),
        ),
      ),
    ])
    |> poll.with_duration(24)
    |> poll.with_allow_multiselect(False)
    |> poll.with_layout_type(1)

  assert p.duration == option.Some(24)
  assert p.allow_multiselect == option.Some(False)
  assert p.layout_type == option.Some(1)
}

pub fn builder_mentions_test() {
  let m =
    mentions.new_allowed_mentions()
    |> mentions.with_parse([mentions.Users])
    |> mentions.with_users(["42"])
    |> mentions.with_replied_user(False)

  assert m.parse == option.Some([mentions.Users])
  assert m.roles == option.None
  assert m.users == option.Some(["42"])
  assert m.replied_user == option.Some(False)
}

pub fn builder_attachment_test() {
  let a =
    attachment.new_attachment("0", "banner.png")
    |> attachment.with_description("Release banner")

  assert a.id == "0"
  assert a.filename == "banner.png"
  assert a.description == option.Some("Release banner")
}

pub fn payload_empty_to_json_test() {
  let result = payload.new_payload() |> payload.to_string
  assert result == "{}"
}

pub fn payload_none_fields_omitted_test() {
  let result =
    payload.new_payload()
    |> payload.with_content("Hello")
    |> payload.to_string

  assert result == "{\"content\":\"Hello\"}"
}

pub fn payload_falsy_values_preserved_test() {
  let result =
    payload.new_payload()
    |> payload.with_tts(False)
    |> payload.with_flags(0)
    |> payload.with_embeds([])
    |> payload.to_string

  assert result == "{\"tts\":false,\"embeds\":[],\"flags\":0}"
}

pub fn payload_full_to_json_test() {
  let result =
    payload.new_payload()
    |> payload.with_content("Hello")
    |> payload.with_username("kitazith")
    |> payload.with_tts(False)
    |> payload.with_embeds([
      embed.new_embed()
      |> embed.with_title("Release"),
    ])
    |> payload.with_allowed_mentions(
      mentions.new_allowed_mentions()
      |> mentions.with_parse([mentions.Users]),
    )
    |> payload.with_components([
      component.raw(json.object([#("type", json.int(1))])),
    ])
    |> payload.with_attachments([
      attachment.new_attachment("0", "banner.png"),
    ])
    |> payload.with_flags(0)
    |> payload.with_thread_name("release-notes")
    |> payload.with_applied_tags(["1234567890"])
    |> payload.to_string

  assert result
    == "{\"content\":\"Hello\",\"username\":\"kitazith\",\"tts\":false,\"embeds\":[{\"title\":\"Release\"}],\"allowed_mentions\":{\"parse\":[\"users\"]},\"components\":[{\"type\":1}],\"attachments\":[{\"id\":\"0\",\"filename\":\"banner.png\"}],\"flags\":0,\"thread_name\":\"release-notes\",\"applied_tags\":[\"1234567890\"]}"
}

pub fn embed_to_json_test() {
  let result =
    embed.new_embed()
    |> embed.with_title("Release")
    |> embed.with_description("The build is ready.")
    |> embed.with_timestamp(embed.EmbedTimestamp("2026-03-15T09:30:00Z"))
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
      embed.new_field("Status", "Green")
      |> embed.with_field_inline(True),
    ])
    |> embed.to_json
    |> json.to_string

  assert result
    == "{\"title\":\"Release\",\"description\":\"The build is ready.\",\"timestamp\":\"2026-03-15T09:30:00Z\",\"color\":5792266,\"footer\":{\"text\":\"kitazith\",\"icon_url\":\"https://example.com/footer.png\"},\"image\":{\"url\":\"https://example.com/image.png\"},\"author\":{\"name\":\"Bot\",\"icon_url\":\"https://example.com/avatar.png\"},\"fields\":[{\"name\":\"Status\",\"value\":\"Green\",\"inline\":true}]}"
}

pub fn mentions_to_json_test() {
  let result =
    mentions.new_allowed_mentions()
    |> mentions.with_parse([mentions.Roles, mentions.Users, mentions.Everyone])
    |> mentions.with_users(["42"])
    |> mentions.with_replied_user(False)
    |> mentions.to_json
    |> json.to_string

  assert result
    == "{\"parse\":[\"roles\",\"users\",\"everyone\"],\"users\":[\"42\"],\"replied_user\":false}"
}

pub fn component_to_json_passthrough_test() {
  let data =
    json.object([#("type", json.int(1)), #("label", json.string("Click"))])
  let result =
    component.raw(data)
    |> component.to_json
    |> json.to_string

  assert result == "{\"type\":1,\"label\":\"Click\"}"
}

pub fn attachment_to_json_test() {
  let result =
    attachment.new_attachment("0", "banner.png")
    |> attachment.with_description("Release banner")
    |> attachment.to_json
    |> json.to_string

  assert result
    == "{\"id\":\"0\",\"filename\":\"banner.png\",\"description\":\"Release banner\"}"
}

pub fn poll_to_json_test() {
  let result =
    poll.new_poll(poll.PollQuestion(text: "Pick one"), [
      poll.PollAnswer(
        poll_media: poll.new_poll_media()
        |> poll.with_poll_media_text("Option A"),
      ),
      poll.PollAnswer(
        poll_media: poll.new_poll_media()
        |> poll.with_poll_media_text("Option B")
        |> poll.with_poll_media_emoji(
          poll.new_poll_emoji()
          |> poll.with_poll_emoji_name("\u{1f525}"),
        ),
      ),
    ])
    |> poll.with_duration(24)
    |> poll.with_allow_multiselect(False)
    |> poll.to_json
    |> json.to_string

  assert result
    == "{\"question\":{\"text\":\"Pick one\"},\"answers\":[{\"poll_media\":{\"text\":\"Option A\"}},{\"poll_media\":{\"text\":\"Option B\",\"emoji\":{\"name\":\"🔥\"}}}],\"duration\":24,\"allow_multiselect\":false}"
}

fn sample_poll() -> poll.Poll {
  poll.Poll(
    question: poll.PollQuestion(text: "Pick one"),
    answers: [
      poll.PollAnswer(poll_media: poll.PollMedia(
        text: option.Some("Option A"),
        emoji: option.None,
      )),
      poll.PollAnswer(poll_media: poll.PollMedia(
        text: option.Some("Option B"),
        emoji: option.Some(poll.PollEmoji(
          id: option.None,
          name: option.Some("🔥"),
        )),
      )),
    ],
    duration: option.Some(24),
    allow_multiselect: option.Some(False),
    layout_type: option.Some(1),
  )
}
