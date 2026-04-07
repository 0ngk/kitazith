import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/string

import kitazith/allowed_mentions
import kitazith/attachment
import kitazith/component
import kitazith/component/file as component_file
import kitazith/component/media
import kitazith/component/media_gallery
import kitazith/component/section
import kitazith/component/separator
import kitazith/component/text_display
import kitazith/embed
import kitazith/poll
import kitazith/snowflake
import kitazith/test_fixtures
import kitazith/validation
import kitazith/webhook/execute
import kitazith/webhook/execute_query

pub fn new_starts_empty_test() {
  let execute_payload = execute.new()

  assert execute_payload.content == None
  assert execute_payload.username == None
  assert execute_payload.avatar_url == None
  assert execute_payload.tts == None
  assert execute_payload.embeds == None
  assert execute_payload.allowed_mentions == None
  assert execute_payload.components == None
  assert execute_payload.attachments == None
  assert execute_payload.flags == None
  assert execute_payload.thread_name == None
  assert execute_payload.applied_tags == None
  assert execute_payload.poll == None
}

pub fn poll_only_execute_payload_test() {
  let execute_payload =
    execute.ExecutePayload(
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

  assert execute_payload.content == None
  assert execute_payload.poll == Some(test_fixtures.sample_poll())
}

pub fn execute_payload_supports_all_submodules_test() {
  let execute_payload =
    execute.ExecutePayload(
      content: None,
      username: Some("kitazith"),
      avatar_url: None,
      tts: Some(False),
      embeds: Some([test_fixtures.sample_embed()]),
      allowed_mentions: Some(test_fixtures.sample_allowed_mentions()),
      components: Some([test_fixtures.sample_component()]),
      attachments: Some([test_fixtures.sample_attachment()]),
      flags: Some([execute.SuppressEmbeds]),
      thread_name: Some("release-notes"),
      applied_tags: Some([snowflake.new("1234567890")]),
      poll: Some(test_fixtures.sample_poll()),
    )

  assert execute_payload.username == Some("kitazith")
  assert execute_payload.embeds == Some([test_fixtures.sample_embed()])
  assert execute_payload.allowed_mentions
    == Some(test_fixtures.sample_allowed_mentions())
  assert execute_payload.components == Some([test_fixtures.sample_component()])
  assert execute_payload.attachments
    == Some([test_fixtures.sample_attachment()])
  assert execute_payload.poll == Some(test_fixtures.sample_poll())
}

pub fn builder_execute_payload_test() {
  let execute_payload =
    execute.new()
    |> execute.with_content("Hello")
    |> execute.with_username("kitazith")
    |> execute.with_avatar_url("https://example.com/avatar.png")
    |> execute.with_tts(False)
    |> execute.with_embeds([test_fixtures.sample_embed()])
    |> execute.with_allowed_mentions(test_fixtures.sample_allowed_mentions())
    |> execute.with_components([test_fixtures.sample_component()])
    |> execute.with_attachments([test_fixtures.sample_attachment()])
    |> execute.with_flags([execute.SuppressEmbeds])
    |> execute.with_thread_name("release-notes")
    |> execute.with_applied_tags([snowflake.new("1234567890")])
    |> execute.with_poll(test_fixtures.sample_poll())

  assert execute_payload.content == Some("Hello")
  assert execute_payload.username == Some("kitazith")
  assert execute_payload.avatar_url == Some("https://example.com/avatar.png")
  assert execute_payload.tts == Some(False)
  assert execute_payload.embeds == Some([test_fixtures.sample_embed()])
  assert execute_payload.allowed_mentions
    == Some(test_fixtures.sample_allowed_mentions())
  assert execute_payload.components == Some([test_fixtures.sample_component()])
  assert execute_payload.attachments
    == Some([test_fixtures.sample_attachment()])
  assert execute_payload.flags == Some([execute.SuppressEmbeds])
  assert execute_payload.thread_name == Some("release-notes")
  assert execute_payload.applied_tags == Some([snowflake.new("1234567890")])
  assert execute_payload.poll == Some(test_fixtures.sample_poll())
}

pub fn execute_payload_empty_to_json_test() {
  let result = execute.new() |> execute.to_string
  assert result == "{}"
}

pub fn execute_payload_none_fields_omitted_test() {
  let result =
    execute.new()
    |> execute.with_content("Hello")
    |> execute.to_string

  assert result == "{\"content\":\"Hello\"}"
}

pub fn execute_payload_falsy_values_preserved_test() {
  let result =
    execute.new()
    |> execute.with_tts(False)
    |> execute.with_flags([])
    |> execute.with_embeds([])
    |> execute.to_string

  assert result == "{\"tts\":false,\"embeds\":[],\"flags\":0}"
}

pub fn execute_payload_full_to_json_test() {
  let result =
    execute.new()
    |> execute.with_content("Hello")
    |> execute.with_username("kitazith")
    |> execute.with_tts(False)
    |> execute.with_embeds([
      embed.new()
      |> embed.with_title("Release"),
    ])
    |> execute.with_allowed_mentions(
      allowed_mentions.new()
      |> allowed_mentions.with_parse([allowed_mentions.Users]),
    )
    |> execute.with_components([
      component.raw(json.object([#("type", json.int(1))])),
    ])
    |> execute.with_attachments([
      attachment.new(id: 0, filename: "banner.png"),
    ])
    |> execute.with_flags([])
    |> execute.with_thread_name("release-notes")
    |> execute.with_applied_tags([snowflake.new("1234567890")])
    |> execute.to_string

  assert result
    == "{\"content\":\"Hello\",\"username\":\"kitazith\",\"tts\":false,\"embeds\":[{\"title\":\"Release\"}],\"allowed_mentions\":{\"parse\":[\"users\"]},\"components\":[{\"type\":1}],\"attachments\":[{\"id\":0,\"filename\":\"banner.png\"}],\"flags\":0,\"thread_name\":\"release-notes\",\"applied_tags\":[\"1234567890\"]}"
}

pub fn execute_payload_validate_success_test() {
  let payload =
    execute.new()
    |> execute.with_content("Hello")
    |> execute.with_username("kitazith")
    |> execute.with_embeds([
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
    |> execute.with_attachments([
      attachment.new(id: 0, filename: "thumb.png"),
    ])
    |> execute.with_poll(test_fixtures.sample_poll())

  assert execute.validate(payload) == Ok(payload)
}

pub fn execute_payload_validate_with_query_success_test() {
  let payload =
    execute.new()
    |> execute.with_content("Hello")

  let query =
    execute_query.new()
    |> execute_query.with_wait(True)
    |> execute_query.with_components(False)

  assert execute.validate_with_query(payload, query) == Ok(payload)
}

pub fn execute_payload_validate_with_query_thread_conflict_test() {
  let result =
    execute.new()
    |> execute.with_thread_name("release-notes")
    |> execute.validate_with_query(
      execute_query.new()
      |> execute_query.with_thread_id(snowflake.new("1234567890")),
    )

  assert result
    == Error([
      validation.ValidationError(
        path: "query.thread_id",
        reason: validation.MutuallyExclusiveWith("thread_name"),
      ),
    ])
}

pub fn execute_payload_validate_direct_constructor_error_test() {
  let result =
    execute.ExecutePayload(
      content: None,
      username: Some(""),
      avatar_url: None,
      tts: None,
      embeds: None,
      allowed_mentions: None,
      components: None,
      attachments: None,
      flags: None,
      thread_name: None,
      applied_tags: None,
      poll: None,
    )
    |> execute.validate

  assert result
    == Error([
      validation.ValidationError(
        path: "username",
        reason: validation.StringLengthOutOfRange(min: 1, max: 80, actual: 0),
      ),
    ])
}

pub fn execute_payload_validate_attachment_reference_error_test() {
  let result =
    execute.new()
    |> execute.with_embeds([
      embed.new()
      |> embed.with_thumbnail(embed.EmbedThumbnail(
        url: "attachment://thumb.png",
      )),
    ])
    |> execute.validate

  assert result
    == Error([
      validation.ValidationError(
        path: "embeds[0].thumbnail.url",
        reason: validation.MissingAttachmentReference("thumb.png"),
      ),
    ])
}

pub fn execute_payload_validate_embed_total_character_limit_test() {
  let result =
    execute.new()
    |> execute.with_embeds([
      embed.new()
        |> embed.with_description(string.repeat("a", times: 4000)),
      embed.new()
        |> embed.with_description(string.repeat("b", times: 2001)),
    ])
    |> execute.validate

  assert result
    == Error([
      validation.ValidationError(
        path: "embeds",
        reason: validation.AggregateCharacterLimitExceeded(
          limit_label: "embed_total_characters",
          max: 6000,
          actual: 6001,
        ),
      ),
    ])
}

pub fn execute_payload_validate_poll_constraints_test() {
  let result =
    execute.new()
    |> execute.with_poll(poll.Poll(
      question: poll.PollQuestion(text: ""),
      answers: [
        poll.PollAnswer(poll_media: poll.PollMedia(
          text: Some("Option A"),
          emoji: None,
        )),
      ],
      duration: Some(769),
      allow_multiselect: Some(False),
      layout_type: None,
    ))
    |> execute.validate

  assert result
    == Error([
      validation.ValidationError(
        path: "poll.question.text",
        reason: validation.StringLengthOutOfRange(min: 1, max: 300, actual: 0),
      ),
      validation.ValidationError(
        path: "poll.duration",
        reason: validation.NumericMaximumExceeded(
          max: 768,
          actual: 769,
          unit: "hours",
        ),
      ),
    ])
}

pub fn execute_payload_validate_duplicate_attachment_filename_test() {
  let result =
    execute.new()
    |> execute.with_attachments([
      attachment.new(id: 0, filename: "thumb.png"),
      attachment.new(id: 1, filename: "thumb.png"),
    ])
    |> execute.validate

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

pub fn execute_payload_v2_components_to_json_test() {
  let result =
    execute.new()
    |> execute.with_components([
      component.text_display(test_fixtures.sample_text_display()),
      component.section(test_fixtures.sample_section()),
      component.media_gallery(test_fixtures.sample_media_gallery()),
      component.file(test_fixtures.sample_file()),
      component.separator(test_fixtures.sample_separator()),
    ])
    |> execute.with_attachments([
      attachment.new(id: 0, filename: "thumb.png"),
      attachment.new(id: 1, filename: "gallery.png"),
      attachment.new(id: 2, filename: "release-notes.pdf"),
    ])
    |> execute.with_flags([execute.IsComponentsV2])
    |> execute.to_string

  assert result
    == "{\"components\":[{\"type\":10,\"content\":\"# Release\"},{\"type\":9,\"components\":[{\"type\":10,\"content\":\"# Release\"},{\"type\":10,\"content\":\"The build is ready.\"}],\"accessory\":{\"type\":11,\"media\":{\"url\":\"attachment://thumb.png\"}}},{\"type\":12,\"items\":[{\"media\":{\"url\":\"attachment://gallery.png\"},\"description\":\"Gallery preview\"}]},{\"type\":13,\"file\":{\"url\":\"attachment://release-notes.pdf\"}},{\"type\":14,\"divider\":true,\"spacing\":1}],\"attachments\":[{\"id\":0,\"filename\":\"thumb.png\"},{\"id\":1,\"filename\":\"gallery.png\"},{\"id\":2,\"filename\":\"release-notes.pdf\"}],\"flags\":32768}"
}

pub fn execute_payload_validate_v2_components_success_test() {
  let payload =
    execute.new()
    |> execute.with_components([
      component.section(test_fixtures.sample_section()),
      component.media_gallery(test_fixtures.sample_media_gallery()),
      component.file(test_fixtures.sample_file()),
    ])
    |> execute.with_attachments([
      attachment.new(id: 0, filename: "thumb.png"),
      attachment.new(id: 1, filename: "gallery.png"),
      attachment.new(id: 2, filename: "release-notes.pdf"),
    ])
    |> execute.with_flags([execute.IsComponentsV2])

  assert execute.validate(payload) == Ok(payload)
}

pub fn execute_payload_validate_v2_components_require_flag_test() {
  let result =
    execute.new()
    |> execute.with_components([
      component.text_display(test_fixtures.sample_text_display()),
    ])
    |> execute.validate

  assert result
    == Error([
      validation.ValidationError(
        path: "flags",
        reason: validation.RequiresFlag("IsComponentsV2"),
      ),
    ])
}

pub fn execute_payload_validate_v2_components_conflict_test() {
  let result =
    execute.new()
    |> execute.with_content("Hello")
    |> execute.with_embeds([test_fixtures.sample_embed()])
    |> execute.with_poll(test_fixtures.sample_poll())
    |> execute.with_components([
      component.text_display(test_fixtures.sample_text_display()),
    ])
    |> execute.with_flags([execute.IsComponentsV2])
    |> execute.validate

  assert result
    == Error([
      validation.ValidationError(
        path: "content",
        reason: validation.MutuallyExclusiveWith("flags[IsComponentsV2]"),
      ),
      validation.ValidationError(
        path: "embeds",
        reason: validation.MutuallyExclusiveWith("flags[IsComponentsV2]"),
      ),
      validation.ValidationError(
        path: "poll",
        reason: validation.MutuallyExclusiveWith("flags[IsComponentsV2]"),
      ),
    ])
}

pub fn execute_payload_validate_v2_component_constraints_test() {
  let result =
    execute.new()
    |> execute.with_components([
      component.section(section.new(
        components: [],
        accessory: test_fixtures.sample_thumbnail(),
      )),
      component.media_gallery(
        media_gallery.new(list.repeat(
          media_gallery.new_item(media.new("attachment://gallery.png")),
          times: 11,
        )),
      ),
      component.file(
        component_file.new(media.new("https://example.com/file.pdf")),
      ),
      component.separator(
        separator.new()
        |> separator.with_spacing(separator.Large),
      ),
    ])
    |> execute.with_attachments([
      attachment.new(id: 0, filename: "gallery.png"),
    ])
    |> execute.with_flags([execute.IsComponentsV2])
    |> execute.validate

  assert result
    == Error([
      validation.ValidationError(
        path: "components[0].components",
        reason: validation.ComponentCountOutOfRange(
          min: 1,
          max: 3,
          actual: 0,
          item_label: "text display components",
        ),
      ),
      validation.ValidationError(
        path: "components[0].accessory.media.url",
        reason: validation.MissingAttachmentReference("thumb.png"),
      ),
      validation.ValidationError(
        path: "components[1].items",
        reason: validation.ComponentCountOutOfRange(
          min: 1,
          max: 10,
          actual: 11,
          item_label: "media gallery items",
        ),
      ),
      validation.ValidationError(
        path: "components[2].file.url",
        reason: validation.AttachmentReferenceRequired,
      ),
    ])
}

pub fn execute_payload_validate_v2_component_total_limit_test() {
  let result =
    execute.new()
    |> execute.with_components(list.repeat(
      component.text_display(text_display.new("x")),
      times: 41,
    ))
    |> execute.with_flags([execute.IsComponentsV2])
    |> execute.validate

  assert result
    == Error([
      validation.ValidationError(
        path: "components",
        reason: validation.AggregateComponentLimitExceeded(max: 40, actual: 41),
      ),
    ])
}
