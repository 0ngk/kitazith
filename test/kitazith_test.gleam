import gleam/json
import gleam/option.{None, Some}
import gleeunit

import kitazith/allowed_mentions
import kitazith/attachment
import kitazith/component
import kitazith/embed
import kitazith/message_formatting/emoji
import kitazith/message_formatting/guild_navigation
import kitazith/message_formatting/mention
import kitazith/message_formatting/timestamp as message_timestamp
import kitazith/payload
import kitazith/poll
import kitazith/snowflake
import kitazith/timestamp

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn new_payload_starts_empty_test() {
  let webhook_payload = payload.new_payload()

  assert webhook_payload.content == None
  assert webhook_payload.username == None
  assert webhook_payload.avatar_url == None
  assert webhook_payload.tts == None
  assert webhook_payload.embeds == None
  assert webhook_payload.allowed_mentions == None
  assert webhook_payload.components == None
  assert webhook_payload.attachments == None
  assert webhook_payload.flags == None
  assert webhook_payload.thread_name == None
  assert webhook_payload.applied_tags == None
  assert webhook_payload.poll == None
}

pub fn poll_only_payload_test() {
  let webhook_payload =
    payload.Payload(
      content: None,
      username: None,
      avatar_url: None,
      tts: None,
      embeds: None,
      allowed_mentions: None,
      components: None,
      attachments: None,
      flags: None,
      thread_name: None,
      applied_tags: None,
      poll: Some(sample_poll()),
    )

  assert webhook_payload.content == None
  assert webhook_payload.poll == Some(sample_poll())
}

pub fn payload_supports_all_submodules_test() {
  let webhook_payload =
    payload.Payload(
      content: None,
      username: Some("kitazith"),
      avatar_url: None,
      tts: Some(False),
      embeds: Some([sample_embed()]),
      allowed_mentions: Some(sample_allowed_mentions()),
      components: Some([sample_component()]),
      attachments: Some([sample_attachment()]),
      flags: Some(0),
      thread_name: Some("release-notes"),
      applied_tags: Some([snowflake.new("1234567890")]),
      poll: Some(sample_poll()),
    )

  assert webhook_payload.username == Some("kitazith")
  assert webhook_payload.embeds == Some([sample_embed()])
  assert webhook_payload.allowed_mentions == Some(sample_allowed_mentions())
  assert webhook_payload.components == Some([sample_component()])
  assert webhook_payload.attachments == Some([sample_attachment()])
  assert webhook_payload.poll == Some(sample_poll())
}

fn sample_attachment() -> attachment.Attachment {
  attachment.Attachment(
    id: "0",
    filename: "banner.png",
    description: Some("Release banner"),
  )
}

fn sample_component() -> component.Component {
  component.raw(json.object([#("type", json.int(1))]))
}

fn sample_embed() -> embed.Embed {
  embed.Embed(
    title: Some("Release"),
    description: Some("The build is ready."),
    url: None,
    timestamp: Some(sample_timestamp()),
    color: Some(5_792_266),
    footer: Some(embed.EmbedFooter(
      text: "kitazith",
      icon_url: Some("https://example.com/footer.png"),
    )),
    image: Some(embed.EmbedImage(url: "https://example.com/image.png")),
    thumbnail: Some(embed.EmbedThumbnail(url: "https://example.com/thumb.png")),
    author: Some(embed.EmbedAuthor(
      name: "Deployment Bot",
      url: None,
      icon_url: Some("https://example.com/avatar.png"),
    )),
    fields: Some([
      embed.EmbedField(name: "Status", value: "Green", inline: Some(True)),
    ]),
  )
}

fn sample_allowed_mentions() -> allowed_mentions.AllowedMentions {
  allowed_mentions.AllowedMentions(
    parse: Some([allowed_mentions.Users]),
    roles: Some([]),
    users: Some([snowflake.new("42")]),
    replied_user: Some(False),
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
    |> payload.with_allowed_mentions(sample_allowed_mentions())
    |> payload.with_components([sample_component()])
    |> payload.with_attachments([sample_attachment()])
    |> payload.with_flags(0)
    |> payload.with_thread_name("release-notes")
    |> payload.with_applied_tags([snowflake.new("1234567890")])
    |> payload.with_poll(sample_poll())

  assert webhook_payload.content == Some("Hello")
  assert webhook_payload.username == Some("kitazith")
  assert webhook_payload.avatar_url == Some("https://example.com/avatar.png")
  assert webhook_payload.tts == Some(False)
  assert webhook_payload.embeds == Some([sample_embed()])
  assert webhook_payload.allowed_mentions == Some(sample_allowed_mentions())
  assert webhook_payload.components == Some([sample_component()])
  assert webhook_payload.attachments == Some([sample_attachment()])
  assert webhook_payload.flags == Some(0)
  assert webhook_payload.thread_name == Some("release-notes")
  assert webhook_payload.applied_tags == Some([snowflake.new("1234567890")])
  assert webhook_payload.poll == Some(sample_poll())
}

pub fn builder_embed_test() {
  let e =
    embed.new_embed()
    |> embed.with_title("Release")
    |> embed.with_description("The build is ready.")
    |> embed.with_url("https://example.com")
    |> embed.with_timestamp(sample_timestamp())
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

  assert p.duration == Some(24)
  assert p.allow_multiselect == Some(False)
  assert p.layout_type == Some(1)
}

pub fn builder_allowed_mentions_test() {
  let m =
    allowed_mentions.new_allowed_mentions()
    |> allowed_mentions.with_parse([allowed_mentions.Users])
    |> allowed_mentions.with_users([snowflake.new("42")])
    |> allowed_mentions.with_replied_user(False)

  assert m.parse == Some([allowed_mentions.Users])
  assert m.roles == None
  assert m.users == Some([snowflake.new("42")])
  assert m.replied_user == Some(False)
}

pub fn message_mention_format_test() {
  let id = snowflake.new("42")

  assert mention.user(id) == "<@42>"
  assert mention.role(id) == "<@&42>"
  assert mention.channel(id) == "<#42>"
  assert mention.command("ship", id) == "</ship:42>"
}

pub fn message_custom_emoji_format_test() {
  assert emoji.custom("mmLol", snowflake.new("216154654256398347"))
    == "<:mmLol:216154654256398347>"
  assert emoji.animated("b1nzy", snowflake.new("392938283556143104"))
    == "<a:b1nzy:392938283556143104>"
}

pub fn message_guild_navigation_format_test() {
  assert guild_navigation.format(guild_navigation.Customize) == "<id:customize>"
  assert guild_navigation.format(guild_navigation.Browse) == "<id:browse>"
  assert guild_navigation.format(guild_navigation.Guide) == "<id:guide>"
  assert guild_navigation.format(guild_navigation.LinkedRoles)
    == "<id:linked-roles>"
}

pub fn message_timestamp_format_test() {
  let seconds = 1_773_654_660

  assert message_timestamp.default(seconds) == "<t:1773654660>"
  assert message_timestamp.format(seconds, message_timestamp.ShortDate)
    == "<t:1773654660:d>"
  assert message_timestamp.format(seconds, message_timestamp.LongDate)
    == "<t:1773654660:D>"
  assert message_timestamp.format(seconds, message_timestamp.ShortTime)
    == "<t:1773654660:t>"
  assert message_timestamp.format(seconds, message_timestamp.MediumTime)
    == "<t:1773654660:T>"
  assert message_timestamp.format(seconds, message_timestamp.LongDateShortTime)
    == "<t:1773654660:f>"
  assert message_timestamp.format(seconds, message_timestamp.FullDateShortTime)
    == "<t:1773654660:F>"
  assert message_timestamp.format(seconds, message_timestamp.ShortDateShortTime)
    == "<t:1773654660:s>"
  assert message_timestamp.format(
      seconds,
      message_timestamp.ShortDateMediumTime,
    )
    == "<t:1773654660:S>"
  assert message_timestamp.format(seconds, message_timestamp.RelativeTime)
    == "<t:1773654660:R>"
}

pub fn builder_attachment_test() {
  let a =
    attachment.new_attachment("0", "banner.png")
    |> attachment.with_description("Release banner")

  assert a.id == "0"
  assert a.filename == "banner.png"
  assert a.description == Some("Release banner")
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
      allowed_mentions.new_allowed_mentions()
      |> allowed_mentions.with_parse([allowed_mentions.Users]),
    )
    |> payload.with_components([
      component.raw(json.object([#("type", json.int(1))])),
    ])
    |> payload.with_attachments([
      attachment.new_attachment("0", "banner.png"),
    ])
    |> payload.with_flags(0)
    |> payload.with_thread_name("release-notes")
    |> payload.with_applied_tags([snowflake.new("1234567890")])
    |> payload.to_string

  assert result
    == "{\"content\":\"Hello\",\"username\":\"kitazith\",\"tts\":false,\"embeds\":[{\"title\":\"Release\"}],\"allowed_mentions\":{\"parse\":[\"users\"]},\"components\":[{\"type\":1}],\"attachments\":[{\"id\":\"0\",\"filename\":\"banner.png\"}],\"flags\":0,\"thread_name\":\"release-notes\",\"applied_tags\":[\"1234567890\"]}"
}

pub fn embed_to_json_test() {
  let result =
    embed.new_embed()
    |> embed.with_title("Release")
    |> embed.with_description("The build is ready.")
    |> embed.with_timestamp(sample_timestamp())
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

pub fn allowed_mentions_to_json_test() {
  let result =
    allowed_mentions.new_allowed_mentions()
    |> allowed_mentions.with_parse([
      allowed_mentions.Roles,
      allowed_mentions.Users,
      allowed_mentions.Everyone,
    ])
    |> allowed_mentions.with_users([snowflake.new("42")])
    |> allowed_mentions.with_replied_user(False)
    |> allowed_mentions.to_json
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

pub fn snowflake_to_json_test() {
  let result =
    snowflake.new("123456789012345678")
    |> snowflake.to_json
    |> json.to_string

  assert result == "\"123456789012345678\""
}

fn sample_timestamp() -> timestamp.Timestamp {
  let assert Ok(ts) = timestamp.from_rfc3339("2026-03-15T09:30:00Z")
  ts
}

fn sample_poll() -> poll.Poll {
  poll.Poll(
    question: poll.PollQuestion(text: "Pick one"),
    answers: [
      poll.PollAnswer(poll_media: poll.PollMedia(
        text: Some("Option A"),
        emoji: None,
      )),
      poll.PollAnswer(poll_media: poll.PollMedia(
        text: Some("Option B"),
        emoji: Some(poll.PollEmoji(id: None, name: Some("🔥"))),
      )),
    ],
    duration: Some(24),
    allow_multiselect: Some(False),
    layout_type: Some(1),
  )
}

pub fn timestamp_from_rfc3339_valid_test() {
  let result = timestamp.from_rfc3339("2026-03-15T09:30:00Z")
  let assert Ok(ts) = result
  let str = timestamp.to_string(ts)
  assert str == "2026-03-15T09:30:00Z"
}

pub fn timestamp_from_rfc3339_invalid_test() {
  let result = timestamp.from_rfc3339("not-a-timestamp")
  assert result == Error(Nil)
}

pub fn timestamp_from_unix_seconds_test() {
  let ts = timestamp.from_unix_seconds(0)
  let str = timestamp.to_string(ts)
  assert str == "1970-01-01T00:00:00Z"
}

pub fn timestamp_offset_normalized_to_utc_test() {
  let assert Ok(ts) = timestamp.from_rfc3339("2026-03-15T18:30:00+09:00")
  let str = timestamp.to_string(ts)
  assert str == "2026-03-15T09:30:00Z"
}

pub fn timestamp_to_json_test() {
  let assert Ok(ts) = timestamp.from_rfc3339("2026-03-15T09:30:00Z")
  let result = ts |> timestamp.to_json |> json.to_string
  assert result == "\"2026-03-15T09:30:00Z\""
}
