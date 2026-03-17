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

pub fn command(name: String, snowflake: Snowflake) -> String {
  string.concat(["</", name, ":", to_string(snowflake), ">"])
}
