import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/string

import kitazith/allowed_mentions
import kitazith/attachment
import kitazith/component
import kitazith/embed
import kitazith/snowflake
import kitazith/test_fixtures
import kitazith/validation
import kitazith/webhook/edit
import kitazith/webhook/edit_query

pub fn new_starts_empty_test() {
  let edit_payload = edit.new()

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
    edit.new()
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
    edit.new()
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
  let result = edit.new() |> edit.to_string
  assert result == "{}"
}

pub fn edit_payload_omitted_fields_stay_omitted_test() {
  let result =
    edit.new()
    |> edit.with_content("Hello")
    |> edit.to_string

  assert result == "{\"content\":\"Hello\"}"
}

pub fn edit_payload_clear_fields_encode_to_null_test() {
  let result =
    edit.new()
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
    edit.new()
    |> edit.clear_embeds()
    |> edit.to_string

  let empty_result =
    edit.new()
    |> edit.with_embeds([])
    |> edit.to_string

  assert clear_result == "{\"embeds\":null}"
  assert empty_result == "{\"embeds\":[]}"
}

pub fn edit_payload_falsy_values_preserved_test() {
  let result =
    edit.new()
    |> edit.with_embeds([])
    |> edit.with_flags([])
    |> edit.to_string

  assert result == "{\"embeds\":[],\"flags\":0}"
}

pub fn edit_payload_full_to_json_test() {
  let result =
    edit.new()
    |> edit.with_content("Hello")
    |> edit.with_embeds([
      embed.new()
      |> embed.with_title("Release"),
    ])
    |> edit.with_attachments([
      attachment.new(id: 0, filename: "banner.png"),
    ])
    |> edit.with_components([
      component.raw(json.object([#("type", json.int(1))])),
    ])
    |> edit.with_allowed_mentions(
      allowed_mentions.new()
      |> allowed_mentions.with_parse([allowed_mentions.Users]),
    )
    |> edit.with_flags([])
    |> edit.to_string

  assert result
    == "{\"content\":\"Hello\",\"embeds\":[{\"title\":\"Release\"}],\"attachments\":[{\"id\":0,\"filename\":\"banner.png\"}],\"components\":[{\"type\":1}],\"allowed_mentions\":{\"parse\":[\"users\"]},\"flags\":0}"
}

pub fn edit_payload_validate_success_test() {
  let payload =
    edit.new()
    |> edit.with_embeds([
      embed.new()
      |> embed.with_thumbnail(
        embed.EmbedThumbnail(
          url: attachment.to_embed_url(attachment.new(
            id: 0,
            filename: "thumb.png",
          )),
        ),
      ),
    ])
    |> edit.with_attachments([
      attachment.new(id: 0, filename: "thumb.png"),
    ])

  assert edit.validate(payload) == Ok(payload)
}

pub fn edit_payload_validate_with_query_success_test() {
  let payload =
    edit.new()
    |> edit.with_content("Hello")

  let query =
    edit_query.new()
    |> edit_query.with_thread_id(snowflake.new("1234567890"))
    |> edit_query.with_components(False)

  assert edit.validate_with_query(payload, query) == Ok(payload)
}

pub fn edit_payload_validate_attachment_reference_after_clear_test() {
  let result =
    edit.new()
    |> edit.clear_attachments()
    |> edit.with_embeds([
      embed.new()
      |> embed.with_thumbnail(embed.EmbedThumbnail(
        url: "attachment://thumb.png",
      )),
    ])
    |> edit.validate

  assert result
    == Error([
      validation.ValidationError(
        path: "embeds[0].thumbnail.url",
        reason: validation.MissingAttachmentReference("thumb.png"),
      ),
    ])
}

pub fn edit_payload_validate_embed_and_mentions_constraints_test() {
  let result =
    edit.new()
    |> edit.with_embeds([
      embed.new()
      |> embed.with_footer(embed.EmbedFooter(text: "", icon_url: None))
      |> embed.with_description(string.repeat("a", times: 4097)),
    ])
    |> edit.with_allowed_mentions(allowed_mentions.AllowedMentions(
      parse: None,
      roles: None,
      users: Some(list.repeat(snowflake.new("42"), times: 101)),
      replied_user: None,
    ))
    |> edit.validate

  assert result
    == Error([
      validation.ValidationError(
        path: "embeds[0].description",
        reason: validation.StringLengthExceeded(max: 4096, actual: 4097),
      ),
      validation.ValidationError(
        path: "embeds[0].footer.text",
        reason: validation.StringLengthOutOfRange(min: 1, max: 2048, actual: 0),
      ),
      validation.ValidationError(
        path: "allowed_mentions.users",
        reason: validation.ListLengthExceeded(
          max: 100,
          actual: 101,
          item_label: "user ids",
        ),
      ),
    ])
}

pub fn edit_payload_validate_duplicate_attachment_filename_test() {
  let result =
    edit.new()
    |> edit.with_attachments([
      attachment.new(id: 0, filename: "thumb.png"),
      attachment.new(id: 1, filename: "thumb.png"),
    ])
    |> edit.validate

  assert result
    == Error([
      validation.ValidationError(
        path: "attachments",
        reason: validation.DuplicateAttachmentFilename(
          filename: "thumb.png",
          indexes: [0, 1],
        ),
      ),
    ])
}
