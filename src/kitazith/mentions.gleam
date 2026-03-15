import gleam/option

pub type AllowedMentions {
  AllowedMentions(
    parse: List(AllowedMention),
    roles: List(String),
    users: List(String),
    replied_user: option.Option(Bool),
  )
}

pub type AllowedMention {
  Roles
  Users
  Everyone
}

pub fn new_allowed_mentions() -> AllowedMentions {
  AllowedMentions(parse: [], roles: [], users: [], replied_user: option.None)
}

pub fn with_parse(
  mentions: AllowedMentions,
  parse: List(AllowedMention),
) -> AllowedMentions {
  AllowedMentions(..mentions, parse: parse)
}

pub fn with_roles(
  mentions: AllowedMentions,
  roles: List(String),
) -> AllowedMentions {
  AllowedMentions(..mentions, roles: roles)
}

pub fn with_users(
  mentions: AllowedMentions,
  users: List(String),
) -> AllowedMentions {
  AllowedMentions(..mentions, users: users)
}

pub fn with_replied_user(
  mentions: AllowedMentions,
  replied_user: Bool,
) -> AllowedMentions {
  AllowedMentions(..mentions, replied_user: option.Some(replied_user))
}
