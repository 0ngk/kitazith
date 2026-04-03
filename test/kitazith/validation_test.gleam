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
      path: "embeds[0].thumbnail.url",
      reason: validation.AttachmentReferenceMissingFilename,
    ))
    == "must include a filename after `attachment://`"

  assert validation.message(validation.ValidationError(
      path: "query.thread_id",
      reason: validation.MutuallyExclusiveWith("thread_name"),
    ))
    == "must not be used together with `thread_name`"
}
