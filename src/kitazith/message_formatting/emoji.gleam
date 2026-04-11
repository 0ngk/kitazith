import gleam/string

import kitazith/snowflake.{type Snowflake, to_string}

/// Format a Discord custom emoji for message content.
///
/// Learn more:
///   [API Reference - Documentation - Discord > Message Formatting > Formats](https://docs.discord.com/developers/reference#message-formatting)
pub fn custom(name name: String, id id: Snowflake) -> String {
  string.concat(["<:", name, ":", to_string(id), ">"])
}

/// Format a Discord animated custom emoji for message content.
///
/// Learn more:
///   [API Reference - Documentation - Discord > Message Formatting > Formats](https://docs.discord.com/developers/reference#message-formatting)
pub fn animated(name name: String, id id: Snowflake) -> String {
  string.concat(["<a:", name, ":", to_string(id), ">"])
}
