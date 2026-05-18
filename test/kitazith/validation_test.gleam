import kitazith/validation

pub fn validation_message_test() {
  assert validation.message(validation.ValidationError(
      path: "username",
      reason: validation.StringLengthOutOfRange(min: 1, max: 80, actual: 0),
    ))
    == "must be between 1 and 80 characters"

  assert validation.message(validation.ValidationError(
      path: "attachments",
      reason: validation.DuplicateAttachmentFilename(
        filename: "thumb.png",
        indexes: [0, 2],
      ),
    ))
    == "contains duplicate attachment filename `thumb.png` at indexes 0, 2"

  assert validation.message(validation.ValidationError(
      path: "components",
      reason: validation.DuplicateComponentId(id: 7, paths: [
        "components[0].id",
        "components[1].accessory.id",
      ]),
    ))
    == "contains duplicate component id `7` at paths components[0].id, components[1].accessory.id"

  assert validation.message(validation.ValidationError(
      path: "embeds[0].thumbnail.url",
      reason: validation.AttachmentReferenceMissingFilename,
    ))
    == "must include a filename after `attachment://`"

  assert validation.message(validation.ValidationError(
      path: "query.thread_id",
      reason: validation.MutuallyExclusiveWith("thread_name"),
    ))
    == "must not be used together with `thread_name`"

  assert validation.message(validation.ValidationError(
      path: "components",
      reason: validation.AggregateComponentLimitExceeded(max: 40, actual: 41),
    ))
    == "must contain at most 40 total components"

  assert validation.message(validation.ValidationError(
      path: "components[0].items",
      reason: validation.ComponentCountOutOfRange(
        min: 1,
        max: 10,
        actual: 0,
        item_label: "media gallery items",
      ),
    ))
    == "must contain between 1 and 10 media gallery items"

  assert validation.message(validation.ValidationError(
      path: "components[0].file.url",
      reason: validation.AttachmentReferenceRequired,
    ))
    == "must use an `attachment://<filename>` reference"

  assert validation.message(validation.ValidationError(
      path: "flags",
      reason: validation.RequiresFlag("IsComponentsV2"),
    ))
    == "requires the `IsComponentsV2` flag"
}
