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
