import gleam/int
import gleam/list
import gleam/string

import kitazith/validation

pub fn validate_with_query(
  payload: a,
  query: b,
  validate: fn(a) -> Result(a, List(validation.ValidationError)),
  validate_query: fn(b, a) -> List(validation.ValidationError),
) -> Result(a, List(validation.ValidationError)) {
  let errors =
    list.flatten([
      case validate(payload) {
        Ok(_) -> []
        Error(errors) -> errors
      },
      validate_query(query, payload),
    ])

  case errors {
    [] -> Ok(payload)
    _ -> Error(errors)
  }
}

pub fn validate_string_length(
  path: String,
  value: String,
  min min: Int,
  max max: Int,
) -> List(validation.ValidationError) {
  let length = string.length(value)

  case length >= min && length <= max {
    True -> []
    False -> [
      error(path, validation.StringLengthOutOfRange(min:, max:, actual: length)),
    ]
  }
}

pub fn validate_string_max_length(
  path: String,
  value: String,
  max max: Int,
) -> List(validation.ValidationError) {
  let length = string.length(value)

  case length <= max {
    True -> []
    False -> [
      error(path, validation.StringLengthExceeded(max:, actual: length)),
    ]
  }
}

pub fn validate_list_max_length(
  path: String,
  items: List(a),
  max max: Int,
  noun noun: String,
) -> List(validation.ValidationError) {
  let count = list.length(items)

  case count <= max {
    True -> []
    False -> [
      error(
        path,
        validation.ListLengthExceeded(max:, actual: count, item_label: noun),
      ),
    ]
  }
}

pub fn join_path(base: String, suffix: String) -> String {
  base <> "." <> suffix
}

pub fn indexed_path(base: String, index: Int) -> String {
  string.concat([base, "[", int.to_string(index), "]"])
}

pub fn error(
  path: String,
  reason: validation.ValidationReason,
) -> validation.ValidationError {
  validation.ValidationError(path:, reason:)
}
