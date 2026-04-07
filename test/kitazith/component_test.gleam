import gleam/json

import kitazith/component
import kitazith/component/file as component_file
import kitazith/component/media_gallery
import kitazith/component/section
import kitazith/component/separator
import kitazith/component/text_display
import kitazith/test_fixtures

pub fn component_to_json_passthrough_test() {
  let data =
    json.object([#("type", json.int(1)), #("label", json.string("Click"))])
  let result =
    component.raw(data)
    |> component.to_json
    |> json.to_string

  assert result == "{\"type\":1,\"label\":\"Click\"}"
}

pub fn text_display_component_to_json_test() {
  let result =
    text_display.new("# Release")
    |> text_display.with_id(7)
    |> component.text_display
    |> component.to_json
    |> json.to_string

  assert result == "{\"type\":10,\"id\":7,\"content\":\"# Release\"}"
}

pub fn section_component_to_json_test() {
  let result =
    test_fixtures.sample_section()
    |> section.with_id(8)
    |> component.section
    |> component.to_json
    |> json.to_string

  assert result
    == "{\"type\":9,\"id\":8,\"components\":[{\"type\":10,\"content\":\"# Release\"},{\"type\":10,\"content\":\"The build is ready.\"}],\"accessory\":{\"type\":11,\"media\":{\"url\":\"attachment://thumb.png\"}}}"
}

pub fn media_gallery_component_to_json_test() {
  let result =
    test_fixtures.sample_media_gallery()
    |> media_gallery.with_id(9)
    |> component.media_gallery
    |> component.to_json
    |> json.to_string

  assert result
    == "{\"type\":12,\"id\":9,\"items\":[{\"media\":{\"url\":\"attachment://gallery.png\"},\"description\":\"Gallery preview\"}]}"
}

pub fn file_component_to_json_test() {
  let result =
    test_fixtures.sample_file()
    |> component_file.with_id(10)
    |> component_file.with_spoiler(True)
    |> component.file
    |> component.to_json
    |> json.to_string

  assert result
    == "{\"type\":13,\"id\":10,\"file\":{\"url\":\"attachment://release-notes.pdf\"},\"spoiler\":true}"
}

pub fn separator_component_to_json_test() {
  let result =
    test_fixtures.sample_separator()
    |> separator.with_id(11)
    |> component.separator
    |> component.to_json
    |> json.to_string

  assert result == "{\"type\":14,\"id\":11,\"divider\":true,\"spacing\":1}"
}

pub fn separator_large_spacing_component_to_json_test() {
  let result =
    separator.new()
    |> separator.with_spacing(separator.Large)
    |> component.separator
    |> component.to_json
    |> json.to_string

  assert result == "{\"type\":14,\"spacing\":2}"
}
