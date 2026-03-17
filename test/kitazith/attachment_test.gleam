import gleam/json
import gleam/option.{Some}

import kitazith/attachment

pub fn builder_attachment_test() {
  let a =
    attachment.new_attachment("0", "banner.png")
    |> attachment.with_description("Release banner")

  assert a.id == "0"
  assert a.filename == "banner.png"
  assert a.description == Some("Release banner")
}

pub fn attachment_to_json_test() {
  let result =
    attachment.new_attachment("0", "banner.png")
    |> attachment.with_description("Release banner")
    |> attachment.to_json
    |> json.to_string

  assert result
    == "{\"id\":\"0\",\"filename\":\"banner.png\",\"description\":\"Release banner\"}"
}
