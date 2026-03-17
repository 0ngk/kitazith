import gleam/string

import kitazith/snowflake.{type Snowflake, to_string}

/// Format a Discord custom emoji for message content.
/// https://docs.discord.com/developers/reference#message-formatting
pub fn custom(name: String, id: Snowflake) -> String {
  string.concat(["<:", name, ":", to_string(id), ">"])
}

/// Format a Discord animated custom emoji for message content.
/// https://docs.discord.com/developers/reference#message-formatting
pub fn animated(name: String, id: Snowflake) -> String {
  string.concat(["<a:", name, ":", to_string(id), ">"])
}
