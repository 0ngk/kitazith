import gleam/json
import gleam/option.{type Option, None, Some}

import kitazith/internal/json_helper
import kitazith/snowflake

/// Learn more:
///   [Message Resource - Documentation - Discord > Allowed Mentions Object](https://docs.discord.com/developers/resources/message#allowed-mentions-object)
pub type AllowedMentions {
  AllowedMentions(
    parse: Option(List(AllowedMention)),
    /// Snowflake Role IDs that can be mentioned. Up to 100.
    roles: Option(List(snowflake.Snowflake)),
    /// Snowflake User IDs that can be mentioned. Up to 100.
    users: Option(List(snowflake.Snowflake)),
    replied_user: Option(Bool),
  )
}

/// Learn more:
///   [Message Resource - Documentation - Discord > Allowed Mentions Object > Allowed Mention Types](https://docs.discord.com/developers/resources/message#allowed-mentions-object-allowed-mention-types)
pub type AllowedMention {
  Roles
  Users
  Everyone
}

pub fn new() -> AllowedMentions {
  AllowedMentions(parse: None, roles: None, users: None, replied_user: None)
}

pub fn with_parse(
  mentions: AllowedMentions,
  parse: List(AllowedMention),
) -> AllowedMentions {
  AllowedMentions(..mentions, parse: Some(parse))
}

pub fn with_roles(
  mentions: AllowedMentions,
  roles: List(snowflake.Snowflake),
) -> AllowedMentions {
  AllowedMentions(..mentions, roles: Some(roles))
}

pub fn with_users(
  mentions: AllowedMentions,
  users: List(snowflake.Snowflake),
) -> AllowedMentions {
  AllowedMentions(..mentions, users: Some(users))
}

pub fn with_replied_user(
  mentions: AllowedMentions,
  replied_user: Bool,
) -> AllowedMentions {
  AllowedMentions(..mentions, replied_user: Some(replied_user))
}

pub fn to_json(m: AllowedMentions) -> json.Json {
  json_helper.object_omit_none([
    json_helper.optional("parse", m.parse, fn(parse) {
      json.array(parse, allowed_mention_to_json)
    }),
    json_helper.optional("roles", m.roles, fn(roles) {
      json.array(roles, snowflake.to_json)
    }),
    json_helper.optional("users", m.users, fn(users) {
      json.array(users, snowflake.to_json)
    }),
    json_helper.optional("replied_user", m.replied_user, json.bool),
  ])
}

fn allowed_mention_to_json(mention: AllowedMention) -> json.Json {
  case mention {
    Roles -> json.string("roles")
    Users -> json.string("users")
    Everyone -> json.string("everyone")
  }
}
