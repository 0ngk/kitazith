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
import kitazith/internal/validation_helper
import kitazith/poll
import kitazith/snowflake
import kitazith/validation
import kitazith/webhook/execute_query

/// Learn more:
///   [Webhook Resource - Documentation - Discord > Execute Webhook > JSON/Form Params](https://docs.discord.com/developers/resources/webhook#execute-webhook-json/form-params)
pub type ExecutePayload {
  ExecutePayload(
    /// Up to 2000 characters.
    content: Option(String),
    /// At least 1 character and up to 80 characters.
    username: Option(String),
    avatar_url: Option(String),
    tts: Option(Bool),
    /// Up to 10 embeds.
    ///
    /// Up to 6000 characters total across all `title`, `description`,
    /// `field.name`, `field.value`, `footer.text`, and `author.name` fields
    /// in all embeds per message.
    ///
    /// Source: [Message Resource - Documentation - Discord > Embed Object > Embed Limits](https://docs.discord.com/developers/resources/message#embed-object-embed-limits)
    embeds: Option(List(embed.Embed)),
    allowed_mentions: Option(allowed_mentions.AllowedMentions),
    components: Option(List(component.Component)),
    attachments: Option(List(attachment.Attachment)),
    flags: Option(List(ExecutePayloadFlag)),
    /// If specified, at least 1 character and up to 100 characters.
    thread_name: Option(String),
    /// Snowflake IDs of tags applied to the message
    applied_tags: Option(List(snowflake.Snowflake)),
    poll: Option(poll.Poll),
  )
}

/// Learn more:
pub type ExecutePayloadFlag {
  /// Include no embeds
  SuppressEmbeds
  /// Do not trigger a notification
  SuppressNotifications
  IsComponentsV2
}

pub fn new() -> ExecutePayload {
  ExecutePayload(
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

pub fn with_content(payload: ExecutePayload, content: String) -> ExecutePayload {
  ExecutePayload(..payload, content: Some(content))
}

pub fn with_username(
  payload: ExecutePayload,
  username: String,
) -> ExecutePayload {
  ExecutePayload(..payload, username: Some(username))
}

pub fn with_avatar_url(
  payload: ExecutePayload,
  avatar_url: String,
) -> ExecutePayload {
  ExecutePayload(..payload, avatar_url: Some(avatar_url))
}

pub fn with_tts(payload: ExecutePayload, tts: Bool) -> ExecutePayload {
  ExecutePayload(..payload, tts: Some(tts))
}

pub fn with_embeds(
  payload: ExecutePayload,
  embeds: List(embed.Embed),
) -> ExecutePayload {
  ExecutePayload(..payload, embeds: Some(embeds))
}

pub fn with_allowed_mentions(
  payload: ExecutePayload,
  mentions: allowed_mentions.AllowedMentions,
) -> ExecutePayload {
  ExecutePayload(..payload, allowed_mentions: Some(mentions))
}

pub fn with_components(
  payload: ExecutePayload,
  components: List(component.Component),
) -> ExecutePayload {
  ExecutePayload(..payload, components: Some(components))
}

pub fn with_attachments(
  payload: ExecutePayload,
  attachments: List(attachment.Attachment),
) -> ExecutePayload {
  ExecutePayload(..payload, attachments: Some(attachments))
}

pub fn with_flags(
  payload: ExecutePayload,
  flags: List(ExecutePayloadFlag),
) -> ExecutePayload {
  ExecutePayload(..payload, flags: Some(flags))
}

pub fn with_thread_name(
  payload: ExecutePayload,
  thread_name: String,
) -> ExecutePayload {
  ExecutePayload(..payload, thread_name: Some(thread_name))
}

pub fn with_applied_tags(
  payload: ExecutePayload,
  applied_tags: List(snowflake.Snowflake),
) -> ExecutePayload {
  ExecutePayload(..payload, applied_tags: Some(applied_tags))
}

pub fn with_poll(payload: ExecutePayload, poll: poll.Poll) -> ExecutePayload {
  ExecutePayload(..payload, poll: Some(poll))
}

pub fn validate(
  payload: ExecutePayload,
) -> Result(ExecutePayload, List(validation.ValidationError)) {
  let attachment_filenames = case payload.attachments {
    Some(attachments) -> validation_helper.attachment_filenames(attachments)
    None -> []
  }
  let components_require_v2 = case payload.components {
    Some(components) -> validation_helper.components_require_v2_flag(components)
    None -> False
  }
  let has_components_v2_flag = has_is_components_v2_flag(payload.flags)

  let errors =
    list.flatten([
      case payload.content {
        Some(content) ->
          validation_helper.validate_string_max_length(
            "content",
            content,
            max: 2000,
          )

        None -> []
      },
      case payload.username {
        Some(username) ->
          validation_helper.validate_string_length(
            "username",
            username,
            min: 1,
            max: 80,
          )

        None -> []
      },
      case payload.thread_name {
        Some(thread_name) ->
          validation_helper.validate_string_length(
            "thread_name",
            thread_name,
            min: 1,
            max: 100,
          )

        None -> []
      },
      case payload.embeds {
        Some(embeds) ->
          validation_helper.validate_embeds(
            "embeds",
            embeds,
            attachment_filenames: Some(attachment_filenames),
          )

        None -> []
      },
      case payload.allowed_mentions {
        Some(allowed_mentions) ->
          validation_helper.validate_allowed_mentions(
            "allowed_mentions",
            allowed_mentions,
          )

        None -> []
      },
      case payload.components {
        Some(components) ->
          validation_helper.validate_components(
            "components",
            components,
            attachment_filenames: Some(attachment_filenames),
          )

        None -> []
      },
      case payload.attachments {
        Some(attachments) ->
          validation_helper.validate_attachments("attachments", attachments)

        None -> []
      },
      case payload.poll {
        Some(poll) -> validation_helper.validate_poll("poll", poll)
        None -> []
      },
      case components_require_v2 && !has_components_v2_flag {
        True -> [
          validation.ValidationError(
            path: "flags",
            reason: validation.RequiresFlag("IsComponentsV2"),
          ),
        ]

        False -> []
      },
      case has_components_v2_flag {
        True -> components_v2_conflict_errors(payload)
        False -> []
      },
    ])

  case errors {
    [] -> Ok(payload)
    _ -> Error(errors)
  }
}

pub fn validate_with_query(
  payload: ExecutePayload,
  query: execute_query.ExecuteQuery,
) -> Result(ExecutePayload, List(validation.ValidationError)) {
  validation_helper.validate_with_query(
    payload,
    query,
    validate,
    validate_query,
  )
}

pub fn to_json(payload: ExecutePayload) -> json.Json {
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
      allowed_mentions.to_json,
    ),
    json_helper.optional("components", payload.components, fn(components) {
      json.array(components, component.to_json)
    }),
    json_helper.optional("attachments", payload.attachments, fn(attachments) {
      json.array(attachments, attachment.to_json)
    }),
    json_helper.optional("flags", payload.flags, fn(flags) {
      flags
      |> list.map(execute_payload_flag_to_message_flag)
      |> flag.to_int
      |> json.int
    }),
    json_helper.optional("thread_name", payload.thread_name, json.string),
    json_helper.optional("applied_tags", payload.applied_tags, fn(tags) {
      json.array(tags, snowflake.to_json)
    }),
    json_helper.optional("poll", payload.poll, poll.to_json),
  ])
}

pub fn to_string(payload: ExecutePayload) -> String {
  payload
  |> to_json
  |> json.to_string
}

pub fn to_string_tree(payload: ExecutePayload) -> StringTree {
  payload
  |> to_json
  |> json.to_string_tree
}

fn execute_payload_flag_to_message_flag(
  execute_payload_flag: ExecutePayloadFlag,
) -> flag.MessageFlag {
  case execute_payload_flag {
    SuppressEmbeds -> flag.SuppressEmbeds
    SuppressNotifications -> flag.SuppressNotifications
    IsComponentsV2 -> flag.IsComponentsV2
  }
}

fn validate_query(
  query: execute_query.ExecuteQuery,
  with payload: ExecutePayload,
) -> List(validation.ValidationError) {
  case query.thread_id, payload.thread_name {
    Some(_), Some(_) -> [
      validation.ValidationError(
        path: "query.thread_id",
        reason: validation.MutuallyExclusiveWith("thread_name"),
      ),
    ]

    _, _ -> []
  }
}

fn has_is_components_v2_flag(flags: Option(List(ExecutePayloadFlag))) -> Bool {
  case flags {
    Some(flags) -> contains_execute_payload_flag(flags, IsComponentsV2)
    None -> False
  }
}

fn contains_execute_payload_flag(
  flags: List(ExecutePayloadFlag),
  target: ExecutePayloadFlag,
) -> Bool {
  case flags {
    [] -> False
    [flag, ..rest] ->
      flag == target || contains_execute_payload_flag(rest, target)
  }
}

fn components_v2_conflict_errors(
  payload: ExecutePayload,
) -> List(validation.ValidationError) {
  list.flatten([
    case payload.content {
      Some(_) -> [
        validation.ValidationError(
          path: "content",
          reason: validation.MutuallyExclusiveWith("flags[IsComponentsV2]"),
        ),
      ]

      None -> []
    },
    case payload.embeds {
      Some(_) -> [
        validation.ValidationError(
          path: "embeds",
          reason: validation.MutuallyExclusiveWith("flags[IsComponentsV2]"),
        ),
      ]

      None -> []
    },
    case payload.poll {
      Some(_) -> [
        validation.ValidationError(
          path: "poll",
          reason: validation.MutuallyExclusiveWith("flags[IsComponentsV2]"),
        ),
      ]

      None -> []
    },
  ])
}
