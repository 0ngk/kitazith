import gleam/option
import kitazith/attachment
import kitazith/component
import kitazith/embed
import kitazith/mentions
import kitazith/poll

/// https://docs.discord.com/developers/resources/webhook#execute-webhook-json/form-params
pub type Payload {
  Payload(
    content: option.Option(String),
    username: option.Option(String),
    avatar_url: option.Option(String),
    tts: option.Option(Bool),
    /// Up to 10 embeds
    embeds: option.Option(List(embed.Embed)),
    allowed_mentions: option.Option(mentions.AllowedMentions),
    components: option.Option(List(component.Component)),
    attachments: option.Option(List(attachment.Attachment)),
    flags: option.Option(Int),
    thread_name: option.Option(String),
    /// Snowflake IDs of tags applied to the message
    applied_tags: option.Option(List(String)),
    poll: option.Option(poll.Poll),
  )
}

pub fn new_payload() -> Payload {
  Payload(
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
    poll: option.None,
  )
}

pub fn with_content(payload: Payload, content: String) -> Payload {
  Payload(..payload, content: option.Some(content))
}

pub fn with_username(payload: Payload, username: String) -> Payload {
  Payload(..payload, username: option.Some(username))
}

pub fn with_avatar_url(payload: Payload, avatar_url: String) -> Payload {
  Payload(..payload, avatar_url: option.Some(avatar_url))
}

pub fn with_tts(payload: Payload, tts: Bool) -> Payload {
  Payload(..payload, tts: option.Some(tts))
}

pub fn with_embeds(payload: Payload, embeds: List(embed.Embed)) -> Payload {
  Payload(..payload, embeds: option.Some(embeds))
}

pub fn with_allowed_mentions(
  payload: Payload,
  allowed_mentions: mentions.AllowedMentions,
) -> Payload {
  Payload(..payload, allowed_mentions: option.Some(allowed_mentions))
}

pub fn with_components(
  payload: Payload,
  components: List(component.Component),
) -> Payload {
  Payload(..payload, components: option.Some(components))
}

pub fn with_attachments(
  payload: Payload,
  attachments: List(attachment.Attachment),
) -> Payload {
  Payload(..payload, attachments: option.Some(attachments))
}

pub fn with_flags(payload: Payload, flags: Int) -> Payload {
  Payload(..payload, flags: option.Some(flags))
}

pub fn with_thread_name(payload: Payload, thread_name: String) -> Payload {
  Payload(..payload, thread_name: option.Some(thread_name))
}

pub fn with_applied_tags(
  payload: Payload,
  applied_tags: List(String),
) -> Payload {
  Payload(..payload, applied_tags: option.Some(applied_tags))
}

pub fn with_poll(payload: Payload, poll: poll.Poll) -> Payload {
  Payload(..payload, poll: option.Some(poll))
}
