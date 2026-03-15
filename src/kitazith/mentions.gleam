import gleam/json
import gleam/option

import kitazith/internal/json_helper

/// https://docs.discord.com/developers/resources/message#allowed-mentions-object
pub type AllowedMentions {
  AllowedMentions(
    parse: option.Option(List(AllowedMention)),
    /// Snowflake IDs that can be mentioned. Up to 100.
    roles: option.Option(List(String)),
    /// Snowflake User IDs that can be mentioned. Up to 100.
    users: option.Option(List(String)),
    replied_user: option.Option(Bool),
  )
}

/// https://docs.discord.com/developers/resources/message#allowed-mentions-object-allowed-mention-types
pub type AllowedMention {
  Roles
  Users
  Everyone
}

pub fn new_allowed_mentions() -> AllowedMentions {
  AllowedMentions(
    parse: option.None,
    roles: option.None,
    users: option.None,
    replied_user: option.None,
  )
}

pub fn with_parse(
  mentions: AllowedMentions,
  parse: List(AllowedMention),
) -> AllowedMentions {
  AllowedMentions(..mentions, parse: option.Some(parse))
}

pub fn with_roles(
  mentions: AllowedMentions,
  roles: List(String),
) -> AllowedMentions {
  AllowedMentions(..mentions, roles: option.Some(roles))
}

pub fn with_users(
  mentions: AllowedMentions,
  users: List(String),
) -> AllowedMentions {
  AllowedMentions(..mentions, users: option.Some(users))
}

pub fn with_replied_user(
  mentions: AllowedMentions,
  replied_user: Bool,
) -> AllowedMentions {
  AllowedMentions(..mentions, replied_user: option.Some(replied_user))
}

pub fn to_json(m: AllowedMentions) -> json.Json {
  json_helper.object_omit_none([
    json_helper.optional("parse", m.parse, fn(parse) {
      json.array(parse, allowed_mention_to_json)
    }),
    json_helper.optional("roles", m.roles, fn(roles) {
      json.array(roles, json.string)
    }),
    json_helper.optional("users", m.users, fn(users) {
      json.array(users, json.string)
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
