# kitazith_example

This example project shows two Discord webhook flows built with `kitazith`.

## Examples

### `kitazith_example/execute`

Sends a webhook message with the existing rich payload example:

- custom username
- content
- embed
- poll

Run it with:

```sh
gleam run -m kitazith_example/execute
```

### `kitazith_example/execute_then_edit`

Sends the same rich payload, waits for Discord to return the created message,
extracts the message ID, and then edits that message.

Run it with:

```sh
gleam run -m kitazith_example/execute_then_edit
```

## Setup

Before running either example, replace
`https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN` in
`src/kitazith_example/execute.gleam` with your own Discord webhook URL.

The edit example uses `wait=true` on the initial execute request because
Discord only returns the created message body when that query parameter is set:
[Webhook Resource - Documentation - Discord > Execute Webhook](https://docs.discord.com/developers/resources/webhook#execute-webhook)

## Development

```sh
gleam format
gleam test
```
