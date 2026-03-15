import gleam/option

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
