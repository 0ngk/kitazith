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
import kitazith/internal/validation/allowed_mentions as allowed_mentions_validation
import kitazith/internal/validation/attachment as attachment_validation
import kitazith/internal/validation/common as common_validation
import kitazith/internal/validation/component as component_validation
import kitazith/internal/validation/embed as embed_validation
import kitazith/validation
import kitazith/webhook/edit_query

/// Represents the three possible states of a field in an edit request:
/// omit it, set it to a new value, or clear its current value.
///
/// Learn more:
///   [Webhook Resource - Documentation - Discord > Edit Webhook Message](https://docs.discord.com/developers/resources/webhook#edit-webhook-message)
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
///   [Webhook Resource - Documentation - Discord > Edit Webhook Message > JSON/Form Params](https://docs.discord.com/developers/resources/webhook#edit-webhook-message-json/form-params)
pub type EditPayloadFlag {
  /// Include no embeds
  SuppressEmbeds
  IsComponentsV2
}

pub fn new() -> EditPayload {
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

pub fn validate(
  payload: EditPayload,
) -> Result(EditPayload, List(validation.ValidationError)) {
  let attachment_filenames = case payload.attachments {
    Set(attachments) ->
      Some(attachment_validation.attachment_filenames(attachments))
    Clear -> Some([])
    Omit -> None
  }
  let components_require_v2 = case payload.components {
    Set(components) ->
      component_validation.components_require_v2_flag(components)
    _ -> False
  }
  let explicitly_has_components_v2_flag = case payload.flags {
    Set(flags) -> contains_edit_payload_flag(flags, IsComponentsV2)
    _ -> False
  }

  let errors =
    list.flatten([
      case payload.content {
        Set(content) ->
          common_validation.validate_string_max_length(
            "content",
            content,
            max: 2000,
          )

        _ -> []
      },
      case payload.embeds {
        Set(embeds) ->
          embed_validation.validate_embeds(
            "embeds",
            embeds,
            attachment_filenames: attachment_filenames,
          )

        _ -> []
      },
      case payload.attachments {
        Set(attachments) ->
          attachment_validation.validate_attachments("attachments", attachments)

        _ -> []
      },
      case payload.components {
        Set(components) ->
          component_validation.validate_components(
            "components",
            components,
            attachment_filenames: attachment_filenames,
          )

        _ -> []
      },
      case payload.allowed_mentions {
        Set(allowed_mentions) ->
          allowed_mentions_validation.validate_allowed_mentions(
            "allowed_mentions",
            allowed_mentions,
          )

        _ -> []
      },
      case payload.flags {
        Set(_) -> []
        Clear -> []
        Omit -> []
      },
      case components_require_v2, payload.flags {
        True, Set(_) ->
          case explicitly_has_components_v2_flag {
            True -> []
            False -> [
              validation.ValidationError(
                path: "flags",
                reason: validation.RequiresFlag("IsComponentsV2"),
              ),
            ]
          }

        _, _ -> []
      },
      case explicitly_has_components_v2_flag {
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
  payload: EditPayload,
  query: edit_query.EditQuery,
) -> Result(EditPayload, List(validation.ValidationError)) {
  common_validation.validate_with_query(
    payload,
    query,
    validate,
    validate_query,
  )
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

fn validate_query(
  _query: edit_query.EditQuery,
  with _payload: EditPayload,
) -> List(validation.ValidationError) {
  // The result is always empty as no validation is needed
  //   for Query String Params for the Edit Webhook Message endpoint.
  //
  // Learn more:
  //   [Webhook Resource - Documentation - Discord > Edit Webhook Message](https://docs.discord.com/developers/resources/webhook#edit-webhook-message)
  []
}

fn contains_edit_payload_flag(
  flags: List(EditPayloadFlag),
  target: EditPayloadFlag,
) -> Bool {
  case flags {
    [] -> False
    [flag, ..rest] -> flag == target || contains_edit_payload_flag(rest, target)
  }
}

fn components_v2_conflict_errors(
  payload: EditPayload,
) -> List(validation.ValidationError) {
  list.flatten([
    case payload.content {
      Set(_) -> [
        validation.ValidationError(
          path: "content",
          reason: validation.MutuallyExclusiveWith("flags[IsComponentsV2]"),
        ),
      ]

      _ -> []
    },
    case payload.embeds {
      Set(_) -> [
        validation.ValidationError(
          path: "embeds",
          reason: validation.MutuallyExclusiveWith("flags[IsComponentsV2]"),
        ),
      ]

      _ -> []
    },
  ])
}
