import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string_tree.{type StringTree}

import kitazith/allowed_mentions
import kitazith/attachment
import kitazith/component
import kitazith/embed
import kitazith/flag
import kitazith/internal/json_helper

/// Represents the three possible states of a field in an edit request:
/// omit it, set it to a new value, or clear its current value.
///
/// Learn more: [Webhook Resource - Documentation - Discord > Edit Webhook Message](https://docs.discord.com/developers/resources/webhook#edit-webhook-message)
///
/// For Discord API v10 and later, `attachments` must contain all attachments that
/// should be present after the edit, including retained and new attachments.
pub type EditField(a) {
  /// Do not include the key in the request body.
  /// The current value is left unchanged.
  Omit
  /// Include the key in the request body with a new value.
  Set(a)
  /// Include the key in the request body as `null`
  /// to explicitly clear the current value.
  Clear
}

pub type EditPayload {
  EditPayload(
    /// Up to 2000 characters.
    content: EditField(String),
    /// Up to 10 embeds.
    ///
    /// Up to 6000 characters total across all `title`, `description`,
    /// `field.name`, `field.value`, `footer.text`, and `author.name` fields
    /// in all embeds per message.
    ///
    /// Source: [Message Resource - Documentation - Discord > Embed Object > Embed Limits](https://docs.discord.com/developers/resources/message#embed-object-embed-limits)
    embeds: EditField(List(embed.Embed)),
    attachments: EditField(List(attachment.Attachment)),
    components: EditField(List(component.Component)),
    allowed_mentions: EditField(allowed_mentions.AllowedMentions),
    flags: EditField(List(EditPayloadFlag)),
  )
}

/// Learn more:
pub type EditPayloadFlag {
  /// Include no embeds
  SuppressEmbeds
  IsComponentsV2
}

pub fn new_edit_payload() -> EditPayload {
  EditPayload(
    content: Omit,
    embeds: Omit,
    attachments: Omit,
    components: Omit,
    allowed_mentions: Omit,
    flags: Omit,
  )
}

pub fn with_content(payload: EditPayload, content: String) -> EditPayload {
  EditPayload(..payload, content: Set(content))
}

pub fn clear_content(payload: EditPayload) -> EditPayload {
  EditPayload(..payload, content: Clear)
}

pub fn with_embeds(
  payload: EditPayload,
  embeds: List(embed.Embed),
) -> EditPayload {
  EditPayload(..payload, embeds: Set(embeds))
}

pub fn clear_embeds(payload: EditPayload) -> EditPayload {
  EditPayload(..payload, embeds: Clear)
}

pub fn with_attachments(
  payload: EditPayload,
  attachments: List(attachment.Attachment),
) -> EditPayload {
  EditPayload(..payload, attachments: Set(attachments))
}

pub fn clear_attachments(payload: EditPayload) -> EditPayload {
  EditPayload(..payload, attachments: Clear)
}

pub fn with_components(
  payload: EditPayload,
  components: List(component.Component),
) -> EditPayload {
  EditPayload(..payload, components: Set(components))
}

pub fn clear_components(payload: EditPayload) -> EditPayload {
  EditPayload(..payload, components: Clear)
}

pub fn with_allowed_mentions(
  payload: EditPayload,
  mentions: allowed_mentions.AllowedMentions,
) -> EditPayload {
  EditPayload(..payload, allowed_mentions: Set(mentions))
}

pub fn clear_allowed_mentions(payload: EditPayload) -> EditPayload {
  EditPayload(..payload, allowed_mentions: Clear)
}

pub fn with_flags(
  payload: EditPayload,
  flags: List(EditPayloadFlag),
) -> EditPayload {
  EditPayload(..payload, flags: Set(flags))
}

pub fn clear_flags(payload: EditPayload) -> EditPayload {
  EditPayload(..payload, flags: Clear)
}

pub fn to_json(payload: EditPayload) -> json.Json {
  json_helper.object_omit_none([
    field("content", payload.content, json.string),
    field("embeds", payload.embeds, fn(embeds) {
      json.array(embeds, embed.to_json)
    }),
    field("attachments", payload.attachments, fn(attachments) {
      json.array(attachments, attachment.to_json)
    }),
    field("components", payload.components, fn(components) {
      json.array(components, component.to_json)
    }),
    field(
      "allowed_mentions",
      payload.allowed_mentions,
      allowed_mentions.to_json,
    ),
    field("flags", payload.flags, fn(flags) {
      flags
      |> list.map(edit_payload_flag_to_message_flag)
      |> flag.to_int
      |> json.int
    }),
  ])
}

pub fn to_string(payload: EditPayload) -> String {
  payload
  |> to_json
  |> json.to_string
}

pub fn to_string_tree(payload: EditPayload) -> StringTree {
  payload
  |> to_json
  |> json.to_string_tree
}

fn field(
  key: String,
  value: EditField(a),
  encoder: fn(a) -> json.Json,
) -> Option(#(String, json.Json)) {
  case value {
    Omit -> None
    Set(value) -> Some(#(key, encoder(value)))
    Clear -> Some(#(key, json.null()))
  }
}

fn edit_payload_flag_to_message_flag(
  edit_payload_flag: EditPayloadFlag,
) -> flag.MessageFlag {
  case edit_payload_flag {
    SuppressEmbeds -> flag.SuppressEmbeds
    IsComponentsV2 -> flag.IsComponentsV2
  }
}
