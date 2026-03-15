import gleam/json

pub type Component {
  Component(raw: json.Json)
}

pub fn raw(data: json.Json) -> Component {
  Component(data)
}

pub fn to_json(component: Component) -> json.Json {
  component.raw
}
