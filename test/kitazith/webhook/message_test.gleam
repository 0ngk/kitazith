import gleam/option.{None, Some}

import kitazith/flag
import kitazith/snowflake
import kitazith/timestamp
import kitazith/webhook/message

pub fn decode_webhook_message_full_test() {
  let assert Ok(message_timestamp) =
    timestamp.from_rfc3339("2026-03-15T09:30:00Z")
  let assert Ok(edited_timestamp) =
    timestamp.from_rfc3339("2026-03-15T10:00:00Z")
  let assert Ok(decoded) =
    message.decode(
      "{\"id\":\"123\",\"channel_id\":\"456\",\"timestamp\":\"2026-03-15T09:30:00Z\",\"edited_timestamp\":\"2026-03-15T10:00:00Z\",\"webhook_id\":\"789\",\"flags\":36868,\"attachments\":[{\"id\":\"987\",\"filename\":\"voice-message.ogg\",\"title\":\"Voice memo\",\"description\":\"A short voice note\",\"content_type\":\"audio/ogg\",\"size\":1024,\"url\":\"https://cdn.discordapp.com/attachments/voice-message.ogg\",\"proxy_url\":\"https://media.discordapp.net/attachments/voice-message.ogg\",\"height\":null,\"width\":null,\"ephemeral\":false,\"duration_secs\":1.5,\"waveform\":\"AQID\",\"flags\":4}]}",
    )

  assert decoded
    == message.WebhookMessage(
      id: snowflake.new("123"),
      channel_id: snowflake.new("456"),
      timestamp: message_timestamp,
      edited_timestamp: Some(edited_timestamp),
      webhook_id: Some(snowflake.new("789")),
      flags: Some([
        flag.SuppressEmbeds,
        flag.SuppressNotifications,
        flag.IsComponentsV2,
      ]),
      attachments: [
        message.MessageAttachment(
          id: snowflake.new("987"),
          filename: "voice-message.ogg",
          title: Some("Voice memo"),
          description: Some("A short voice note"),
          content_type: Some("audio/ogg"),
          size: 1024,
          url: "https://cdn.discordapp.com/attachments/voice-message.ogg",
          proxy_url: "https://media.discordapp.net/attachments/voice-message.ogg",
          height: None,
          width: None,
          ephemeral: Some(False),
          duration_secs: Some(1.5),
          waveform: Some("AQID"),
          flags: Some(4),
        ),
      ],
    )
}

pub fn decode_webhook_message_missing_optional_fields_test() {
  let assert Ok(message_timestamp) =
    timestamp.from_rfc3339("2026-03-15T09:30:00Z")
  let assert Ok(decoded) =
    message.decode(
      "{\"id\":\"123\",\"channel_id\":\"456\",\"timestamp\":\"2026-03-15T09:30:00Z\"}",
    )

  assert decoded.timestamp == message_timestamp
  assert decoded.edited_timestamp == None
  assert decoded.webhook_id == None
  assert decoded.flags == None
  assert decoded.attachments == []
}

pub fn decode_webhook_message_null_edited_timestamp_test() {
  let assert Ok(decoded) =
    message.decode(
      "{\"id\":\"123\",\"channel_id\":\"456\",\"timestamp\":\"2026-03-15T09:30:00Z\",\"edited_timestamp\":null}",
    )

  assert decoded.edited_timestamp == None
}

pub fn decode_webhook_message_attachment_null_optional_fields_test() {
  let assert Ok(decoded) =
    message.decode(
      "{\"id\":\"123\",\"channel_id\":\"456\",\"timestamp\":\"2026-03-15T09:30:00Z\",\"attachments\":[{\"id\":\"987\",\"filename\":\"image.png\",\"title\":null,\"description\":null,\"content_type\":null,\"size\":2048,\"url\":\"https://cdn.discordapp.com/attachments/image.png\",\"proxy_url\":\"https://media.discordapp.net/attachments/image.png\",\"height\":null,\"width\":null,\"ephemeral\":null,\"duration_secs\":null,\"waveform\":null,\"flags\":null}]}",
    )

  assert decoded.attachments
    == [
      message.MessageAttachment(
        id: snowflake.new("987"),
        filename: "image.png",
        title: None,
        description: None,
        content_type: None,
        size: 2048,
        url: "https://cdn.discordapp.com/attachments/image.png",
        proxy_url: "https://media.discordapp.net/attachments/image.png",
        height: None,
        width: None,
        ephemeral: None,
        duration_secs: None,
        waveform: None,
        flags: None,
      ),
    ]
}

pub fn decode_webhook_message_ignores_unknown_flags_test() {
  let assert Ok(decoded) =
    message.decode(
      "{\"id\":\"123\",\"channel_id\":\"456\",\"timestamp\":\"2026-03-15T09:30:00Z\",\"flags\":37380}",
    )

  assert decoded.flags
    == Some([
      flag.SuppressEmbeds,
      flag.SuppressNotifications,
      flag.IsComponentsV2,
    ])
}

pub fn decode_webhook_message_unknown_only_flags_become_empty_list_test() {
  let assert Ok(decoded) =
    message.decode(
      "{\"id\":\"123\",\"channel_id\":\"456\",\"timestamp\":\"2026-03-15T09:30:00Z\",\"flags\":512}",
    )

  assert decoded.flags == Some([])
}

pub fn decode_webhook_message_requires_id_test() {
  let result =
    message.decode(
      "{\"channel_id\":\"456\",\"timestamp\":\"2026-03-15T09:30:00Z\"}",
    )
  let is_error = case result {
    Error(_) -> True
    Ok(_) -> False
  }

  assert is_error
}

pub fn decode_webhook_message_requires_timestamp_test() {
  let result = message.decode("{\"id\":\"123\",\"channel_id\":\"456\"}")
  let is_error = case result {
    Error(_) -> True
    Ok(_) -> False
  }

  assert is_error
}

pub fn decode_webhook_message_requires_string_channel_id_test() {
  let result =
    message.decode(
      "{\"id\":\"123\",\"channel_id\":456,\"timestamp\":\"2026-03-15T09:30:00Z\"}",
    )
  let is_error = case result {
    Error(_) -> True
    Ok(_) -> False
  }

  assert is_error
}

pub fn decode_webhook_message_rejects_invalid_timestamp_test() {
  let result =
    message.decode(
      "{\"id\":\"123\",\"channel_id\":\"456\",\"timestamp\":\"not-a-timestamp\"}",
    )
  let is_error = case result {
    Error(_) -> True
    Ok(_) -> False
  }

  assert is_error
}

pub fn decode_webhook_message_rejects_invalid_edited_timestamp_test() {
  let result =
    message.decode(
      "{\"id\":\"123\",\"channel_id\":\"456\",\"timestamp\":\"2026-03-15T09:30:00Z\",\"edited_timestamp\":\"not-a-timestamp\"}",
    )
  let is_error = case result {
    Error(_) -> True
    Ok(_) -> False
  }

  assert is_error
}

pub fn decode_webhook_message_rejects_invalid_attachment_required_field_test() {
  let result =
    message.decode(
      "{\"id\":\"123\",\"channel_id\":\"456\",\"timestamp\":\"2026-03-15T09:30:00Z\",\"attachments\":[{\"id\":\"987\",\"filename\":\"image.png\",\"size\":\"2048\",\"url\":\"https://cdn.discordapp.com/attachments/image.png\",\"proxy_url\":\"https://media.discordapp.net/attachments/image.png\"}]}",
    )
  let is_error = case result {
    Error(_) -> True
    Ok(_) -> False
  }

  assert is_error
}
