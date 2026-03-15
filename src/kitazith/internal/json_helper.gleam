import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}

pub fn object_omit_none(fields: List(Option(#(String, Json)))) -> Json {
  fields
  |> list.filter_map(fn(field) {
    case field {
      Some(pair) -> Ok(pair)
      None -> Error(Nil)
    }
  })
  |> json.object
}

pub fn optional(
  key: String,
  value: Option(a),
  encoder: fn(a) -> Json,
) -> Option(#(String, Json)) {
  case value {
    Some(v) -> Some(#(key, encoder(v)))
    None -> None
  }
}
