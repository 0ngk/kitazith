import gleam/json

import kitazith/component

pub fn component_to_json_passthrough_test() {
  let data =
    json.object([#("type", json.int(1)), #("label", json.string("Click"))])
  let result =
    component.raw(data)
    |> component.to_json
    |> json.to_string

  assert result == "{\"type\":1,\"label\":\"Click\"}"
}
