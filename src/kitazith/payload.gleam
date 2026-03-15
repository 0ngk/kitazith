import gleam/json
import gleam/option
import gleam/string_tree.{type StringTree}

import kitazith/attachment
import kitazith/component
import kitazith/embed
import kitazith/internal/json_helper
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

pub fn to_json(payload: Payload) -> json.Json {
  json_helper.object_omit_none([
    json_helper.optional("content", payload.content, json.string),
    json_helper.optional("username", payload.username, json.string),
    json_helper.optional("avatar_url", payload.avatar_url, json.string),
    json_helper.optional("tts", payload.tts, json.bool),
    json_helper.optional("embeds", payload.embeds, fn(embeds) {
      json.array(embeds, embed.to_json)
    }),
    json_helper.optional(
      "allowed_mentions",
      payload.allowed_mentions,
      mentions.to_json,
    ),
    json_helper.optional("components", payload.components, fn(components) {
      json.array(components, component.to_json)
    }),
    json_helper.optional("attachments", payload.attachments, fn(attachments) {
      json.array(attachments, attachment.to_json)
    }),
    json_helper.optional("flags", payload.flags, json.int),
    json_helper.optional("thread_name", payload.thread_name, json.string),
    json_helper.optional("applied_tags", payload.applied_tags, fn(tags) {
      json.array(tags, json.string)
    }),
    json_helper.optional("poll", payload.poll, poll.to_json),
  ])
}

pub fn to_string(payload: Payload) -> String {
  payload
  |> to_json
  |> json.to_string
}

pub fn to_string_tree(payload: Payload) -> StringTree {
  payload
  |> to_json
  |> json.to_string_tree
}
