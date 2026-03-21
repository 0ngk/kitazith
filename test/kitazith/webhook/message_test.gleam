import gleam/option.{None, Some}

import kitazith/flag
import kitazith/snowflake
import kitazith/webhook/message

pub fn decode_webhook_message_full_test() {
  let assert Ok(decoded) =
    message.decode(
      "{\"id\":\"123\",\"channel_id\":\"456\",\"webhook_id\":\"789\",\"flags\":36868}",
    )

  assert decoded
    == message.WebhookMessage(
      id: snowflake.new("123"),
      channel_id: snowflake.new("456"),
      webhook_id: Some(snowflake.new("789")),
      flags: Some([
        flag.SuppressEmbeds,
        flag.SuppressNotifications,
        flag.IsComponentsV2,
      ]),
    )
}

pub fn decode_webhook_message_missing_optional_fields_test() {
  let assert Ok(decoded) =
    message.decode("{\"id\":\"123\",\"channel_id\":\"456\"}")

  assert decoded.webhook_id == None
  assert decoded.flags == None
}

pub fn decode_webhook_message_ignores_unknown_flags_test() {
  let assert Ok(decoded) =
    message.decode("{\"id\":\"123\",\"channel_id\":\"456\",\"flags\":37380}")

  assert decoded.flags
    == Some([
      flag.SuppressEmbeds,
      flag.SuppressNotifications,
      flag.IsComponentsV2,
    ])
}

pub fn decode_webhook_message_unknown_only_flags_become_empty_list_test() {
  let assert Ok(decoded) =
    message.decode("{\"id\":\"123\",\"channel_id\":\"456\",\"flags\":512}")

  assert decoded.flags == Some([])
}

pub fn decode_webhook_message_requires_id_test() {
  let result = message.decode("{\"channel_id\":\"456\"}")
  let is_error = case result {
    Error(_) -> True
    Ok(_) -> False
  }

  assert is_error
}

pub fn decode_webhook_message_requires_string_channel_id_test() {
  let result = message.decode("{\"id\":\"123\",\"channel_id\":456}")
  let is_error = case result {
    Error(_) -> True
    Ok(_) -> False
  }

  assert is_error
}
