import gleam/list
import gleam/option.{None, Some}

import kitazith/allowed_mentions
import kitazith/internal/validation/common
import kitazith/validation

pub fn validate_allowed_mentions(
  path: String,
  mentions: allowed_mentions.AllowedMentions,
) -> List(validation.ValidationError) {
  list.flatten([
    case mentions.roles {
      Some(roles) ->
        common.validate_list_max_length(
          common.join_path(path, "roles"),
          roles,
          max: 100,
          noun: "role ids",
        )

      None -> []
    },
    case mentions.users {
      Some(users) ->
        common.validate_list_max_length(
          common.join_path(path, "users"),
          users,
          max: 100,
          noun: "user ids",
        )

      None -> []
    },
  ])
}
