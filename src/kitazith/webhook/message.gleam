import gleam/dynamic/decode as dynamic_decode
import gleam/json
import gleam/option.{type Option, None}

import kitazith/flag
import kitazith/snowflake.{type Snowflake}
import kitazith/timestamp

/// Attachment metadata returned in Discord message objects.
///
/// Unlike `kitazith/attachment.Attachment`, this models the response attachment
/// object returned by webhook execute/edit endpoints.
///
/// Learn more:
///   [Message Resource - Documentation - Discord > Attachment Object](https://docs.discord.com/developers/resources/message#attachment-object)
pub type MessageAttachment {
  MessageAttachment(
    id: Snowflake,
    filename: String,
    title: Option(String),
    /// Up to 1024 characters.
    description: Option(String),
    content_type: Option(String),
    /// Size of the file in bytes
    size: Int,
    url: String,
    proxy_url: String,
    /// Height of the image file
    height: Option(Int),
    /// Width of the image file
    width: Option(Int),
    ephemeral: Option(Bool),
    /// Duration of the voice message
    duration_secs: Option(Float),
    /// Base64-encoded bytearray of the voice message
    waveform: Option(String),
    flags: Option(Int),
  )
}

/// A minimal subset of Discord's message object returned by webhook endpoints.
///
/// Includes IDs, timestamps, supported flags, and attachment metadata commonly
/// needed after `execute webhook` or `edit webhook` responses.
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
    attachments: List(MessageAttachment),
  )
}

/// Decode a message object returned from
///   [`execute webhook` with the Query String Param `wait` set to `true`](https://docs.discord.com/developers/resources/webhook#execute-webhook).
pub fn decode(body: String) -> Result(WebhookMessage, json.DecodeError) {
  json.parse(from: body, using: webhook_message_decoder())
}

fn webhook_message_decoder() -> dynamic_decode.Decoder(WebhookMessage) {
  let snowflake_decoder = snowflake_decoder()
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
    use attachments <- dynamic_decode.optional_field(
      "attachments",
      [],
      dynamic_decode.list(message_attachment_decoder()),
    )
    dynamic_decode.success(WebhookMessage(
      id:,
      channel_id:,
      timestamp: message_timestamp,
      edited_timestamp:,
      webhook_id:,
      flags:,
      attachments:,
    ))
  }
}

fn message_attachment_decoder() -> dynamic_decode.Decoder(MessageAttachment) {
  let snowflake_decoder = snowflake_decoder()

  {
    use id <- dynamic_decode.field("id", snowflake_decoder)
    use filename <- dynamic_decode.field("filename", dynamic_decode.string)
    use title <- dynamic_decode.optional_field(
      "title",
      None,
      dynamic_decode.optional(dynamic_decode.string),
    )
    use description <- dynamic_decode.optional_field(
      "description",
      None,
      dynamic_decode.optional(dynamic_decode.string),
    )
    use content_type <- dynamic_decode.optional_field(
      "content_type",
      None,
      dynamic_decode.optional(dynamic_decode.string),
    )
    use size <- dynamic_decode.field("size", dynamic_decode.int)
    use url <- dynamic_decode.field("url", dynamic_decode.string)
    use proxy_url <- dynamic_decode.field("proxy_url", dynamic_decode.string)
    use height <- dynamic_decode.optional_field(
      "height",
      None,
      dynamic_decode.optional(dynamic_decode.int),
    )
    use width <- dynamic_decode.optional_field(
      "width",
      None,
      dynamic_decode.optional(dynamic_decode.int),
    )
    use ephemeral <- dynamic_decode.optional_field(
      "ephemeral",
      None,
      dynamic_decode.optional(dynamic_decode.bool),
    )
    use duration_secs <- dynamic_decode.optional_field(
      "duration_secs",
      None,
      dynamic_decode.optional(dynamic_decode.float),
    )
    use waveform <- dynamic_decode.optional_field(
      "waveform",
      None,
      dynamic_decode.optional(dynamic_decode.string),
    )
    use flags <- dynamic_decode.optional_field(
      "flags",
      None,
      dynamic_decode.optional(dynamic_decode.int),
    )
    dynamic_decode.success(MessageAttachment(
      id:,
      filename:,
      title:,
      description:,
      content_type:,
      size:,
      url:,
      proxy_url:,
      height:,
      width:,
      ephemeral:,
      duration_secs:,
      waveform:,
      flags:,
    ))
  }
}

fn snowflake_decoder() -> dynamic_decode.Decoder(Snowflake) {
  dynamic_decode.string
  |> dynamic_decode.map(snowflake.new)
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
