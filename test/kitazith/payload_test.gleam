import gleam/json
import gleam/option.{None, Some}

import kitazith/allowed_mentions
import kitazith/attachment
import kitazith/component
import kitazith/embed
import kitazith/payload
import kitazith/snowflake
import kitazith/test_fixtures

pub fn new_payload_starts_empty_test() {
  let webhook_payload = payload.new_payload()

  assert webhook_payload.content == None
  assert webhook_payload.username == None
  assert webhook_payload.avatar_url == None
  assert webhook_payload.tts == None
  assert webhook_payload.embeds == None
  assert webhook_payload.allowed_mentions == None
  assert webhook_payload.components == None
  assert webhook_payload.attachments == None
  assert webhook_payload.flags == None
  assert webhook_payload.thread_name == None
  assert webhook_payload.applied_tags == None
  assert webhook_payload.poll == None
}

pub fn poll_only_payload_test() {
  let webhook_payload =
    payload.Payload(
      content: None,
      username: None,
      avatar_url: None,
      tts: None,
      embeds: None,
      allowed_mentions: None,
      components: None,
      attachments: None,
      flags: None,
      thread_name: None,
      applied_tags: None,
      poll: Some(test_fixtures.sample_poll()),
    )

  assert webhook_payload.content == None
  assert webhook_payload.poll == Some(test_fixtures.sample_poll())
}

pub fn payload_supports_all_submodules_test() {
  let webhook_payload =
    payload.Payload(
      content: None,
      username: Some("kitazith"),
      avatar_url: None,
      tts: Some(False),
      embeds: Some([test_fixtures.sample_embed()]),
      allowed_mentions: Some(test_fixtures.sample_allowed_mentions()),
      components: Some([test_fixtures.sample_component()]),
      attachments: Some([test_fixtures.sample_attachment()]),
      flags: Some(0),
      thread_name: Some("release-notes"),
      applied_tags: Some([snowflake.new("1234567890")]),
      poll: Some(test_fixtures.sample_poll()),
    )

  assert webhook_payload.username == Some("kitazith")
  assert webhook_payload.embeds == Some([test_fixtures.sample_embed()])
  assert webhook_payload.allowed_mentions
    == Some(test_fixtures.sample_allowed_mentions())
  assert webhook_payload.components == Some([test_fixtures.sample_component()])
  assert webhook_payload.attachments
    == Some([test_fixtures.sample_attachment()])
  assert webhook_payload.poll == Some(test_fixtures.sample_poll())
}

pub fn builder_payload_test() {
  let webhook_payload =
    payload.new_payload()
    |> payload.with_content("Hello")
    |> payload.with_username("kitazith")
    |> payload.with_avatar_url("https://example.com/avatar.png")
    |> payload.with_tts(False)
    |> payload.with_embeds([test_fixtures.sample_embed()])
    |> payload.with_allowed_mentions(test_fixtures.sample_allowed_mentions())
    |> payload.with_components([test_fixtures.sample_component()])
    |> payload.with_attachments([test_fixtures.sample_attachment()])
    |> payload.with_flags(0)
    |> payload.with_thread_name("release-notes")
    |> payload.with_applied_tags([snowflake.new("1234567890")])
    |> payload.with_poll(test_fixtures.sample_poll())

  assert webhook_payload.content == Some("Hello")
  assert webhook_payload.username == Some("kitazith")
  assert webhook_payload.avatar_url == Some("https://example.com/avatar.png")
  assert webhook_payload.tts == Some(False)
  assert webhook_payload.embeds == Some([test_fixtures.sample_embed()])
  assert webhook_payload.allowed_mentions
    == Some(test_fixtures.sample_allowed_mentions())
  assert webhook_payload.components == Some([test_fixtures.sample_component()])
  assert webhook_payload.attachments
    == Some([test_fixtures.sample_attachment()])
  assert webhook_payload.flags == Some(0)
  assert webhook_payload.thread_name == Some("release-notes")
  assert webhook_payload.applied_tags == Some([snowflake.new("1234567890")])
  assert webhook_payload.poll == Some(test_fixtures.sample_poll())
}

pub fn payload_empty_to_json_test() {
  let result = payload.new_payload() |> payload.to_string
  assert result == "{}"
}

pub fn payload_none_fields_omitted_test() {
  let result =
    payload.new_payload()
    |> payload.with_content("Hello")
    |> payload.to_string

  assert result == "{\"content\":\"Hello\"}"
}

pub fn payload_falsy_values_preserved_test() {
  let result =
    payload.new_payload()
    |> payload.with_tts(False)
    |> payload.with_flags(0)
    |> payload.with_embeds([])
    |> payload.to_string

  assert result == "{\"tts\":false,\"embeds\":[],\"flags\":0}"
}

pub fn payload_full_to_json_test() {
  let result =
    payload.new_payload()
    |> payload.with_content("Hello")
    |> payload.with_username("kitazith")
    |> payload.with_tts(False)
    |> payload.with_embeds([
      embed.new_embed()
      |> embed.with_title("Release"),
    ])
    |> payload.with_allowed_mentions(
      allowed_mentions.new_allowed_mentions()
      |> allowed_mentions.with_parse([allowed_mentions.Users]),
    )
    |> payload.with_components([
      component.raw(json.object([#("type", json.int(1))])),
    ])
    |> payload.with_attachments([
      attachment.new_attachment("0", "banner.png"),
    ])
    |> payload.with_flags(0)
    |> payload.with_thread_name("release-notes")
    |> payload.with_applied_tags([snowflake.new("1234567890")])
    |> payload.to_string

  assert result
    == "{\"content\":\"Hello\",\"username\":\"kitazith\",\"tts\":false,\"embeds\":[{\"title\":\"Release\"}],\"allowed_mentions\":{\"parse\":[\"users\"]},\"components\":[{\"type\":1}],\"attachments\":[{\"id\":\"0\",\"filename\":\"banner.png\"}],\"flags\":0,\"thread_name\":\"release-notes\",\"applied_tags\":[\"1234567890\"]}"
}
