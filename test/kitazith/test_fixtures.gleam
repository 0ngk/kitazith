import gleam/json
import gleam/option.{None, Some}

import kitazith/allowed_mentions
import kitazith/attachment
import kitazith/component
import kitazith/embed
import kitazith/poll
import kitazith/snowflake
import kitazith/timestamp

pub fn sample_attachment() -> attachment.Attachment {
  attachment.Attachment(
    id: "0",
    filename: "banner.png",
    description: Some("Release banner"),
  )
}

pub fn sample_component() -> component.Component {
  component.raw(json.object([#("type", json.int(1))]))
}

pub fn sample_embed() -> embed.Embed {
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

pub fn sample_allowed_mentions() -> allowed_mentions.AllowedMentions {
  allowed_mentions.AllowedMentions(
    parse: Some([allowed_mentions.Users]),
    roles: Some([]),
    users: Some([snowflake.new("42")]),
    replied_user: Some(False),
  )
}

pub fn sample_timestamp() -> timestamp.Timestamp {
  let assert Ok(ts) = timestamp.from_rfc3339("2026-03-15T09:30:00Z")
  ts
}

pub fn sample_poll() -> poll.Poll {
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
