# kitazith

[![Package Version](https://img.shields.io/hexpm/v/kitazith)](https://hex.pm/packages/kitazith)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/kitazith/)

## Description

kitazith is a focused Gleam library for building Discord webhook payloads safely.

## Installation

```sh
gleam add kitazith
```

## Example

```gleam
import gleam/option
import kitazith/payload
import kitazith/poll

pub fn main() -> Nil {
  let release_poll =
    poll.Poll(
      question: poll.PollQuestion(text: "Ship it?"),
      answers: [
        poll.PollAnswer(
          poll_media: poll.PollMedia(
            text: option.Some("Yes"),
            emoji: option.None,
          ),
        ),
      ],
      duration: 24,
      allow_multiselect: False,
      layout_type: option.Some(1),
    )

  let webhook_payload =
    payload.Payload(
      content: option.None,
      username: option.Some("kitazith"),
      avatar_url: option.None,
      tts: option.None,
      embeds: option.None,
      allowed_mentions: option.None,
      components: option.None,
      files: option.None,
      attachments: option.None,
      flags: option.None,
      thread_name: option.None,
      applied_tags: option.None,
      poll: option.Some(release_poll),
    )

  webhook_payload
}
```

Further documentation can be found at <https://hexdocs.pm/kitazith>.

## Discord Message Formatting

`kitazith/timestamp` is for embed JSON timestamps. Message content formatting
helpers live under `kitazith/message_formatting`.

```gleam
import kitazith/message_formatting/mention
import kitazith/message_formatting/timestamp as message_timestamp
import kitazith/snowflake

pub fn user_tag() -> String {
  mention.user(snowflake.new("1234567890"))
}

pub fn eta() -> String {
  message_timestamp.format(1_773_654_660, message_timestamp.RelativeTime)
}
```

## Development

```sh
gleam run    # Run the project
gleam test   # Run the tests
gleam format # Format the source
```
