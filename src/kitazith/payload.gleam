import gleam/json
import gleam/option.{type Option, None, Some}
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
    content: Option(String),
    username: Option(String),
    avatar_url: Option(String),
    tts: Option(Bool),
    /// Up to 10 embeds
    embeds: Option(List(embed.Embed)),
    allowed_mentions: Option(mentions.AllowedMentions),
    components: Option(List(component.Component)),
    attachments: Option(List(attachment.Attachment)),
    flags: Option(Int),
    thread_name: Option(String),
    /// Snowflake IDs of tags applied to the message
    applied_tags: Option(List(String)),
    poll: Option(poll.Poll),
  )
}

pub fn new_payload() -> Payload {
  Payload(
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
    poll: None,
  )
}

pub fn with_content(payload: Payload, content: String) -> Payload {
  Payload(..payload, content: Some(content))
}

pub fn with_username(payload: Payload, username: String) -> Payload {
  Payload(..payload, username: Some(username))
}

pub fn with_avatar_url(payload: Payload, avatar_url: String) -> Payload {
  Payload(..payload, avatar_url: Some(avatar_url))
}

pub fn with_tts(payload: Payload, tts: Bool) -> Payload {
  Payload(..payload, tts: Some(tts))
}

pub fn with_embeds(payload: Payload, embeds: List(embed.Embed)) -> Payload {
  Payload(..payload, embeds: Some(embeds))
}

pub fn with_allowed_mentions(
  payload: Payload,
  allowed_mentions: mentions.AllowedMentions,
) -> Payload {
  Payload(..payload, allowed_mentions: Some(allowed_mentions))
}

pub fn with_components(
  payload: Payload,
  components: List(component.Component),
) -> Payload {
  Payload(..payload, components: Some(components))
}

pub fn with_attachments(
  payload: Payload,
  attachments: List(attachment.Attachment),
) -> Payload {
  Payload(..payload, attachments: Some(attachments))
}

pub fn with_flags(payload: Payload, flags: Int) -> Payload {
  Payload(..payload, flags: Some(flags))
}

pub fn with_thread_name(payload: Payload, thread_name: String) -> Payload {
  Payload(..payload, thread_name: Some(thread_name))
}

pub fn with_applied_tags(
  payload: Payload,
  applied_tags: List(String),
) -> Payload {
  Payload(..payload, applied_tags: Some(applied_tags))
}

pub fn with_poll(payload: Payload, poll: poll.Poll) -> Payload {
  Payload(..payload, poll: Some(poll))
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
