//// This module provides functions to create mentions for users, roles, channels, and commands in Discord.
////
//// Each function takes a Snowflake (a unique identifier used by Discord) and returns a string formatted as a mention that can be used in messages.
////
//// Learn more:
////   [API Reference - Documentation - Discord > Message Formatting > Formats](https://docs.discord.com/developers/reference#message-formatting-formats)

import gleam/string

import kitazith/snowflake.{type Snowflake, to_string}

pub fn user(snowflake: Snowflake) -> String {
  string.concat(["<@", to_string(snowflake), ">"])
}

pub fn role(snowflake: Snowflake) -> String {
  string.concat(["<@&", to_string(snowflake), ">"])
}

pub fn channel(snowflake: Snowflake) -> String {
  string.concat(["<#", to_string(snowflake), ">"])
}

pub fn command(name name: String, id snowflake: Snowflake) -> String {
  string.concat(["</", name, ":", to_string(snowflake), ">"])
}
