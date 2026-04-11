import gleam/list
import gleam/option.{type Option, None, Some}

pub fn list_omit_none(
  fields: List(Option(#(String, String))),
) -> List(#(String, String)) {
  fields
  |> list.filter_map(fn(field) {
    case field {
      Some(pair) -> Ok(pair)
      None -> Error(Nil)
    }
  })
}

pub fn optional(
  key: String,
  value: Option(a),
  encoder: fn(a) -> String,
) -> Option(#(String, String)) {
  case value {
    Some(value) -> Some(#(key, encoder(value)))
    None -> None
  }
}

pub fn bool(value: Bool) -> String {
  case value {
    True -> "true"
    False -> "false"
  }
}
