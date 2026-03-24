import gleam/json

import kitazith/allowed_mentions
import kitazith/attachment
import kitazith/component
import kitazith/embed
import kitazith/test_fixtures
import kitazith/webhook/edit

pub fn new_edit_payload_starts_empty_test() {
  let edit_payload = edit.new_edit_payload()

  assert edit_payload.content == edit.Omit
  assert edit_payload.embeds == edit.Omit
  assert edit_payload.attachments == edit.Omit
  assert edit_payload.components == edit.Omit
  assert edit_payload.allowed_mentions == edit.Omit
  assert edit_payload.flags == edit.Omit
}

pub fn edit_payload_supports_all_submodules_test() {
  let edit_payload =
    edit.EditPayload(
      content: edit.Set("Hello"),
      embeds: edit.Set([test_fixtures.sample_embed()]),
      attachments: edit.Set([test_fixtures.sample_attachment()]),
      components: edit.Set([test_fixtures.sample_component()]),
      allowed_mentions: edit.Set(test_fixtures.sample_allowed_mentions()),
      flags: edit.Set([edit.SuppressEmbeds]),
    )

  assert edit_payload.content == edit.Set("Hello")
  assert edit_payload.embeds == edit.Set([test_fixtures.sample_embed()])
  assert edit_payload.attachments
    == edit.Set([
      test_fixtures.sample_attachment(),
    ])
  assert edit_payload.components == edit.Set([test_fixtures.sample_component()])
  assert edit_payload.allowed_mentions
    == edit.Set(test_fixtures.sample_allowed_mentions())
  assert edit_payload.flags == edit.Set([edit.SuppressEmbeds])
}

pub fn builder_edit_payload_test() {
  let edit_payload =
    edit.new_edit_payload()
    |> edit.with_content("Hello")
    |> edit.with_embeds([test_fixtures.sample_embed()])
    |> edit.with_attachments([test_fixtures.sample_attachment()])
    |> edit.with_components([test_fixtures.sample_component()])
    |> edit.with_allowed_mentions(test_fixtures.sample_allowed_mentions())
    |> edit.with_flags([edit.SuppressEmbeds])

  assert edit_payload.content == edit.Set("Hello")
  assert edit_payload.embeds == edit.Set([test_fixtures.sample_embed()])
  assert edit_payload.attachments
    == edit.Set([
      test_fixtures.sample_attachment(),
    ])
  assert edit_payload.components == edit.Set([test_fixtures.sample_component()])
  assert edit_payload.allowed_mentions
    == edit.Set(test_fixtures.sample_allowed_mentions())
  assert edit_payload.flags == edit.Set([edit.SuppressEmbeds])
}

pub fn clear_builder_edit_payload_test() {
  let edit_payload =
    edit.new_edit_payload()
    |> edit.clear_content()
    |> edit.clear_embeds()
    |> edit.clear_attachments()
    |> edit.clear_components()
    |> edit.clear_allowed_mentions()
    |> edit.clear_flags()

  assert edit_payload.content == edit.Clear
  assert edit_payload.embeds == edit.Clear
  assert edit_payload.attachments == edit.Clear
  assert edit_payload.components == edit.Clear
  assert edit_payload.allowed_mentions == edit.Clear
  assert edit_payload.flags == edit.Clear
}

pub fn edit_payload_empty_to_json_test() {
  let result = edit.new_edit_payload() |> edit.to_string
  assert result == "{}"
}

pub fn edit_payload_omitted_fields_stay_omitted_test() {
  let result =
    edit.new_edit_payload()
    |> edit.with_content("Hello")
    |> edit.to_string

  assert result == "{\"content\":\"Hello\"}"
}

pub fn edit_payload_clear_fields_encode_to_null_test() {
  let result =
    edit.new_edit_payload()
    |> edit.clear_content()
    |> edit.clear_embeds()
    |> edit.clear_attachments()
    |> edit.clear_components()
    |> edit.clear_allowed_mentions()
    |> edit.clear_flags()
    |> edit.to_string

  assert result
    == "{\"content\":null,\"embeds\":null,\"attachments\":null,\"components\":null,\"allowed_mentions\":null,\"flags\":null}"
}

pub fn edit_payload_clear_and_empty_array_are_distinct_test() {
  let clear_result =
    edit.new_edit_payload()
    |> edit.clear_embeds()
    |> edit.to_string

  let empty_result =
    edit.new_edit_payload()
    |> edit.with_embeds([])
    |> edit.to_string

  assert clear_result == "{\"embeds\":null}"
  assert empty_result == "{\"embeds\":[]}"
}

pub fn edit_payload_falsy_values_preserved_test() {
  let result =
    edit.new_edit_payload()
    |> edit.with_embeds([])
    |> edit.with_flags([])
    |> edit.to_string

  assert result == "{\"embeds\":[],\"flags\":0}"
}

pub fn edit_payload_full_to_json_test() {
  let result =
    edit.new_edit_payload()
    |> edit.with_content("Hello")
    |> edit.with_embeds([
      embed.new_embed()
      |> embed.with_title("Release"),
    ])
    |> edit.with_attachments([
      attachment.new_attachment(id: "0", filename: "banner.png"),
    ])
    |> edit.with_components([
      component.raw(json.object([#("type", json.int(1))])),
    ])
    |> edit.with_allowed_mentions(
      allowed_mentions.new_allowed_mentions()
      |> allowed_mentions.with_parse([allowed_mentions.Users]),
    )
    |> edit.with_flags([])
    |> edit.to_string

  assert result
    == "{\"content\":\"Hello\",\"embeds\":[{\"title\":\"Release\"}],\"attachments\":[{\"id\":\"0\",\"filename\":\"banner.png\"}],\"components\":[{\"type\":1}],\"allowed_mentions\":{\"parse\":[\"users\"]},\"flags\":0}"
}
