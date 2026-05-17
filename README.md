# kitazith

[![Package Version](https://img.shields.io/hexpm/v/kitazith)](https://hex.pm/packages/kitazith)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/kitazith/)

## Description

kitazith is a Gleam library for building Discord incoming webhook payloads safely.

Further documentation can be found at <https://hexdocs.pm/kitazith>.

## Disclaimer

kitazith is an unofficial library and is **NOT** endorsed, maintained, or
guaranteed by Discord.

## Installation

```sh
gleam add kitazith
```

If you also want to send webhook requests as shown in the example below,
add an HTTP client as well:

```sh
gleam add gleam_http gleam_httpc
```

## Example

See [`kitazith_example`](https://github.com/0ngk/kitazith/tree/main/examples/kitazith_example) for more.

The payload construction and validation come from `kitazith`. The request
sending in this example uses `gleam_http` and `gleam_httpc`.

```gleam
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/result

import kitazith/color
import kitazith/embed
import kitazith/poll
import kitazith/webhook/execute

pub fn main() {
  let assert Ok(base_req) = request.to(webhook_url())
  let assert Ok(payload) = build_payload() |> execute.validate
  let req =
    base_req
    |> request.prepend_header("content-type", "application/json")
    |> request.set_method(http.Post)
    |> request.set_body(payload |> execute.to_string)
  use resp <- result.try(httpc.send(req))
  assert resp.status == 204
  Ok(resp)
}

pub fn webhook_url() -> String {
  // Replace this with your own Discord webhook URL.
  "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
}

pub fn build_payload() -> execute.ExecutePayload {
  execute.new()
  |> execute.with_username("A bot")
  |> execute.with_content("Hello from Gleam!")
  |> execute.with_embeds([
    embed.new()
    |> embed.with_title("Release Status")
    |> embed.with_description("The build is green and ready to ship.")
    |> embed.with_color(color.from_rgb(red: 87, green: 242, blue: 135))
    |> embed.with_fields([
      embed.new_field(name: "Status", value: "🟢 Green")
      |> embed.with_field_inline(True),
    ]),
  ])
  |> execute.with_poll(
    poll.new(question: poll.PollQuestion(text: "Ship it?"), answers: [
      poll.PollAnswer(
        poll_media: poll.new_poll_media()
        |> poll.with_poll_media_emoji(
          poll.new_poll_emoji() |> poll.with_poll_emoji_name("✅"),
        )
        |> poll.with_poll_media_text("Yes"),
      ),
      poll.PollAnswer(
        poll_media: poll.new_poll_media()
        |> poll.with_poll_media_emoji(
          poll.new_poll_emoji() |> poll.with_poll_emoji_name("⚠️"),
        )
        |> poll.with_poll_media_text("Need one more review"),
      ),
    ])
    |> poll.with_duration(hours: 24)
    |> poll.with_allow_multiselect(False),
  )
}
```

`kitazith/webhook/execute.validate` and `kitazith/webhook/edit.validate`
can be used before serialization to catch Discord payload constraint violations
such as oversized embeds, empty required strings, missing attachment
references, or duplicate attachment filenames.

Each error includes a `reason` for programmatic matching, and
`kitazith/validation.message` can be used to render a human-readable message.

If you are sending query string params such as `wait`, `thread_id`, or `with_components`,
use `kitazith/webhook/execute_query`, `kitazith/webhook/edit_query`,
`kitazith/webhook/delete_query`, and `kitazith/webhook/get_query`.
`execute.validate_with_query` also catches the Discord constraint that
`thread_id` and `thread_name` must **NOT** be used together.

## Non-Application-Owned Webhook Components

Discord only respects webhook `components` when `with_components=true` is set
in the query string. For non-application-owned webhooks, Discord only allows
non-interactive Components V2.

`kitazith/component/*` provides typed builders for:

- `Text Display`
- `Section` with a `Thumbnail` accessory
- `Media Gallery`
- `File`
- `Separator`
- `Container`

When using these typed components:

- set `execute_query.with_components(True)` or `edit_query.with_components(True)`
- include the `execute.IsComponentsV2` or `edit.IsComponentsV2` flag
- do not send `content`, `embeds`, or `poll` in the same payload

```gleam
import gleam/http
import gleam/http/request

import kitazith/color
import kitazith/component
import kitazith/component/container
import kitazith/component/media
import kitazith/component/section
import kitazith/component/separator
import kitazith/component/text_display
import kitazith/webhook/execute
import kitazith/webhook/execute_query

pub fn build_query() -> execute_query.ExecuteQuery {
  execute_query.new()
  |> execute_query.with_components(True)
}

pub fn build_payload() -> execute.ExecutePayload {
  let hero = section.new_thumbnail(media.new("https://example.com/release.webp"))

  execute.new()
  |> execute.with_components([
    component.text_display(text_display.new("# Release Notes")),
    component.section(section.new(
      components: [
        text_display.new("Version 7.3 is now live."),
        text_display.new("Maintenance completed without downtime."),
      ],
      accessory: hero,
    )),
    component.separator(separator.new()),
    component.container(
      container.new([
        container.text_display(text_display.new("Thanks for following the rollout.")),
      ])
      |> container.with_accent_color(
        color.from_rgb(red: 88, green: 101, blue: 242),
      ),
    ),
  ])
  |> execute.with_flags([execute.IsComponentsV2])
}

pub fn build_request() {
  let query = build_query()
  let payload = build_payload()
  let assert Ok(req) = request.to("YOUR_WEBHOOK_URL_HERE")

  req
  |> request.set_method(http.Post)
  |> request.set_query(execute_query.to_query(query))
  |> request.set_body(execute.to_string(payload))
}
```

`component.raw` remains available as an escape hatch for unsupported or
application-owned webhook component payloads.

## Using Attachments Within Embeds

Discord embeds can reference files uploaded in the same payload with the
`attachment://filename` syntax.

```gleam
import kitazith/attachment
import kitazith/embed
import kitazith/webhook/execute

pub fn build_payload_with_thumbnail() -> execute.ExecutePayload {
  let thumbnail = attachment.new(id: 0, filename: "thumb.png")

  execute.new()
  |> execute.with_attachments([thumbnail])
  |> execute.with_embeds([
    embed.new()
    |> embed.with_thumbnail(
      embed.EmbedThumbnail(url: attachment.to_embed_url(thumbnail)),
    ),
  ])
}
```

## Decoding Execute Webhook Responses

When `execute webhook` is called with `wait=true`, Discord returns a message
object.

```gleam
import gleam/http/request
import kitazith/webhook/execute_query


pub fn main() {
  let query =
    execute_query.new()
    |> execute_query.with_wait(True)

  let assert Ok(base_req) = request.to("YOUR_WEBHOOK_URL_HERE")

  let req =
    base_req
    |> request.set_query(query |> execute_query.to_query)
}
```

`kitazith/webhook/message` decodes the minimal subset needed to read the
created message IDs, timestamps, supported flags, and response attachment
metadata.

Response attachments are exposed as `message.MessageAttachment`, which is
separate from the request-side `kitazith/attachment.Attachment` type used by
`webhook/execute` and `webhook/edit`.

```gleam
import gleam/option
import kitazith/flag
import kitazith/snowflake
import kitazith/timestamp
import kitazith/webhook/message

pub fn parse_response() -> Nil {
  let body =
    "{\"id\":\"123\",\"channel_id\":\"456\",\"timestamp\":\"2026-03-15T09:30:00Z\",\"edited_timestamp\":null,\"webhook_id\":\"789\",\"flags\":4,\"attachments\":[{\"id\":\"987\",\"filename\":\"thumb.png\",\"size\":512,\"url\":\"https://cdn.discordapp.com/attachments/thumb.png\",\"proxy_url\":\"https://media.discordapp.net/attachments/thumb.png\"}]}"

  let assert Ok(decoded) = message.decode(body)
  let assert Ok(created_at) = timestamp.from_rfc3339("2026-03-15T09:30:00Z")

  assert decoded.id == snowflake.new("123")
  assert decoded.channel_id == snowflake.new("456")
  assert decoded.timestamp == created_at
  assert decoded.edited_timestamp == option.None
  assert decoded.webhook_id == option.Some(snowflake.new("789"))
  assert decoded.flags == option.Some([flag.SuppressEmbeds])
  assert decoded.attachments
    == [
      message.MessageAttachment(
        id: snowflake.new("987"),
        filename: "thumb.png",
        title: option.None,
        description: option.None,
        content_type: option.None,
        size: 512,
        url: "https://cdn.discordapp.com/attachments/thumb.png",
        proxy_url: "https://media.discordapp.net/attachments/thumb.png",
        height: option.None,
        width: option.None,
        ephemeral: option.None,
        duration_secs: option.None,
        waveform: option.None,
        flags: option.None,
      ),
    ]
}
```

## Building Get Webhook Message Queries

`Get Webhook Message` does not use a request body. If the target message is in
a thread, include `thread_id` in the query string and decode the response with
`kitazith/webhook/message`.

```gleam
import gleam/http/request
import gleam/httpc
import gleam/result

import kitazith/snowflake
import kitazith/webhook/get_query
import kitazith/webhook/message

pub fn get_message(webhook_url: String, message_id: String) {
  let query =
    get_query.new()
    |> get_query.with_thread_id(snowflake.new("1234567890"))

  let assert Ok(base_req) =
    request.to(webhook_url <> "/messages/" <> message_id)

  let req =
    base_req
    |> request.set_query(query |> get_query.to_query)

  use resp <- result.try(httpc.send(req))
  assert resp.status == 200

  let assert Ok(webhook_message) = message.decode(resp.body)
  echo webhook_message.id
  Ok(webhook_message)
}
```

## Building Delete Webhook Message Queries

`Delete Webhook Message` does not use a request body. If the target message is
in a thread, include `thread_id` in the query string.

```gleam
import gleam/http
import gleam/http/request
import gleam/result

import kitazith/snowflake
import kitazith/webhook/delete_query

pub fn delete_message(webhook_url: String, message_id: String) {
  let query =
    delete_query.new()
    |> delete_query.with_thread_id(snowflake.new("1234567890"))

  let assert Ok(base_req) =
    request.to(webhook_url <> "/messages/" <> message_id)

  let req =
    base_req
    |> request.set_method(http.Delete)
    |> request.set_query(query |> delete_query.to_query)

  use resp <- result.try(httpc.send(req))
  echo resp.body
  // Discord returns 204 No Content on success.
  assert resp.status == 204
  Ok(resp)
}
```

## Discord Message Formatting

`kitazith/timestamp` is for embed JSON timestamps.

Message content formatting helpers live under `kitazith/message_formatting`.

```gleam
import kitazith/message_formatting/emoji
import kitazith/message_formatting/guild_navigation
import kitazith/message_formatting/mention
import kitazith/message_formatting/timestamp as message_timestamp
import kitazith/snowflake

pub fn user_tag() -> String {
  mention.user(snowflake.new("1234567890"))
}

pub fn eta() -> String {
  message_timestamp.format(
    seconds: 1_773_654_660,
    style: message_timestamp.RelativeTime,
  )
}

pub fn party() -> String {
  emoji.animated(name: "blobdance", id: snowflake.new("1234567890"))
}

pub fn server_guide() -> String {
  guild_navigation.format(guild_navigation.Guide)
}
```

## Development

For runnable webhook flows, use
[`examples/kitazith_example`](https://github.com/0ngk/kitazith/tree/main/examples/kitazith_example).

```sh
gleam check  # Type-check the library
gleam test   # Run the tests
gleam format # Format the source
```
