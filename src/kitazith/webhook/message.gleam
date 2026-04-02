import gleam/dynamic/decode as dynamic_decode
import gleam/json
import gleam/option.{type Option, None}

import kitazith/flag
import kitazith/snowflake.{type Snowflake}
import kitazith/timestamp

/// A minimal subset of Discord's message object returned by webhook endpoints.
///
/// Includes IDs, timestamps, and supported flags commonly needed after
/// `execute webhook` or `edit webhook` responses.
///
/// Learn more:
///   [Message Resource - Documentation - Discord > Message Object](https://docs.discord.com/developers/resources/message#message-object)
pub type WebhookMessage {
  WebhookMessage(
    id: Snowflake,
    channel_id: Snowflake,
    timestamp: timestamp.Timestamp,
    edited_timestamp: Option(timestamp.Timestamp),
    webhook_id: Option(Snowflake),
    flags: Option(List(flag.MessageFlag)),
  )
}

/// Decode a message object returned from
///   [`execute webhook` with the Query String Param `wait` set to `true`](https://docs.discord.com/developers/resources/webhook#execute-webhook).
pub fn decode(body: String) -> Result(WebhookMessage, json.DecodeError) {
  json.parse(from: body, using: webhook_message_decoder())
}

fn webhook_message_decoder() -> dynamic_decode.Decoder(WebhookMessage) {
  let snowflake_decoder =
    dynamic_decode.string
    |> dynamic_decode.map(snowflake.new)
  let timestamp_decoder = message_timestamp_decoder()

  {
    use id <- dynamic_decode.field("id", snowflake_decoder)
    use channel_id <- dynamic_decode.field("channel_id", snowflake_decoder)
    use message_timestamp <- dynamic_decode.field(
      "timestamp",
      timestamp_decoder,
    )
    use edited_timestamp <- dynamic_decode.optional_field(
      "edited_timestamp",
      None,
      dynamic_decode.optional(timestamp_decoder),
    )
    use webhook_id <- dynamic_decode.optional_field(
      "webhook_id",
      None,
      dynamic_decode.optional(snowflake_decoder),
    )
    use flags <- dynamic_decode.optional_field(
      "flags",
      None,
      dynamic_decode.optional(
        dynamic_decode.int
        |> dynamic_decode.map(flag.from_int),
      ),
    )
    dynamic_decode.success(WebhookMessage(
      id:,
      channel_id:,
      timestamp: message_timestamp,
      edited_timestamp:,
      webhook_id:,
      flags:,
    ))
  }
}

fn message_timestamp_decoder() -> dynamic_decode.Decoder(timestamp.Timestamp) {
  dynamic_decode.string
  |> dynamic_decode.then(fn(value) {
    case timestamp.from_rfc3339(value) {
      Ok(parsed) -> dynamic_decode.success(parsed)
      Error(Nil) ->
        dynamic_decode.failure(
          timestamp.from_unix_seconds(0),
          expected: "RFC3339 timestamp",
        )
    }
  })
}
