import gleam/json

/// A Discord Snowflake ID.
///
/// Learn more:
///   [API Reference - Documentation - Discord > Snowflakes](https://docs.discord.com/developers/reference#snowflakes)
pub opaque type Snowflake {
  Snowflake(String)
}

pub fn new(value: String) -> Snowflake {
  Snowflake(value)
}

pub fn to_string(s: Snowflake) -> String {
  let Snowflake(value) = s
  value
}

pub fn to_json(s: Snowflake) -> json.Json {
  let Snowflake(value) = s
  json.string(value)
}
