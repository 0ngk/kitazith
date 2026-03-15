import gleam/dynamic

pub type Component {
  Component(raw: dynamic.Dynamic)
}

pub fn raw(data: dynamic.Dynamic) -> Component {
  Component(data)
}
