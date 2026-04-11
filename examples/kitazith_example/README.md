# kitazith_example

This example project shows three Discord webhook flows built with `kitazith`.

## Examples

### `kitazith_example/execute`

Sends a webhook message with the existing rich payload example:

- custom username
- content
- embed
- poll

The payload is built in `src/kitazith_example/execute.gleam` and reused by the
edit example.

Run it with:

```sh
gleam run -m kitazith_example/execute
```

### `kitazith_example/execute_then_edit`

Sends the same rich payload, waits for Discord to return the created message,
extracts the message ID, and then edits that message.

The initial execute payload is validated before the request is sent.

Run it with:

```sh
gleam run -m kitazith_example/execute_then_edit
```

### `kitazith_example/execute_non_application_components`

Sends a non-application-owned webhook message using non-interactive
Components V2:

- `with_components=true` query param
- `IsComponentsV2` message flag
- typed `Text Display`, `Section`, `Separator`, and `Container`
- shared RGB color helper via `kitazith/color.from_rgb`

Run it with:

```sh
gleam run -m kitazith_example/execute_non_application_components
```

## Setup

Before running any example, replace
`https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN` in
`src/kitazith_example/execute.gleam` with your own Discord webhook URL.

The edit example uses `kitazith/webhook/execute_query` to set `wait=true` on
the initial execute request, because Discord only returns the created message
body when that query parameter is set:
[Webhook Resource - Documentation - Discord > Execute Webhook](https://docs.discord.com/developers/resources/webhook#execute-webhook)

## Development

```sh
gleam format
gleam test
```
