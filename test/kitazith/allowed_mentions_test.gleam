import gleam/json
import gleam/option.{None, Some}

import kitazith/allowed_mentions
import kitazith/snowflake

pub fn builder_allowed_mentions_test() {
  let m =
    allowed_mentions.new_allowed_mentions()
    |> allowed_mentions.with_parse([allowed_mentions.Users])
    |> allowed_mentions.with_users([snowflake.new("42")])
    |> allowed_mentions.with_replied_user(False)

  assert m.parse == Some([allowed_mentions.Users])
  assert m.roles == None
  assert m.users == Some([snowflake.new("42")])
  assert m.replied_user == Some(False)
}

pub fn allowed_mentions_to_json_test() {
  let result =
    allowed_mentions.new_allowed_mentions()
    |> allowed_mentions.with_parse([
      allowed_mentions.Roles,
      allowed_mentions.Users,
      allowed_mentions.Everyone,
    ])
    |> allowed_mentions.with_users([snowflake.new("42")])
    |> allowed_mentions.with_replied_user(False)
    |> allowed_mentions.to_json
    |> json.to_string

  assert result
    == "{\"parse\":[\"roles\",\"users\",\"everyone\"],\"users\":[\"42\"],\"replied_user\":false}"
}
