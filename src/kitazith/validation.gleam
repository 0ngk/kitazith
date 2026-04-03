import gleam/int
import gleam/list
import gleam/string

/// A structured validation error for webhook payload builders.
pub type ValidationError {
  ValidationError(path: String, reason: ValidationReason)
}

/// The reason a webhook payload validation failed.
pub type ValidationReason {
  StringLengthOutOfRange(min: Int, max: Int, actual: Int)
  StringLengthExceeded(max: Int, actual: Int)
  ListLengthExceeded(max: Int, actual: Int, item_label: String)
  AggregateCharacterLimitExceeded(limit_label: String, max: Int, actual: Int)
  NumericMaximumExceeded(max: Int, actual: Int, unit: String)
  MissingAttachmentReference(filename: String)
  AttachmentReferenceMissingFilename
  DuplicateAttachmentFilename(filename: String, indexes: List(Int))
  MutuallyExclusiveWith(other_path: String)
}

pub fn message(error: ValidationError) -> String {
  case error.reason {
    StringLengthOutOfRange(min:, max:, ..) ->
      "must be between "
      <> int.to_string(min)
      <> " and "
      <> int.to_string(max)
      <> " characters"

    StringLengthExceeded(max:, ..) ->
      "must be at most " <> int.to_string(max) <> " characters"

    ListLengthExceeded(max:, item_label:, ..) ->
      "must contain at most " <> int.to_string(max) <> " " <> item_label

    AggregateCharacterLimitExceeded(limit_label:, max:, ..) ->
      case limit_label {
        "embed_total_characters" ->
          "must contain at most "
          <> int.to_string(max)
          <> " total characters across titles, descriptions, field names, field values, footer texts, and author names"

        _ -> "must be at most " <> int.to_string(max) <> " for " <> limit_label
      }

    NumericMaximumExceeded(max:, unit:, ..) ->
      "must be at most " <> int.to_string(max) <> " " <> unit

    MissingAttachmentReference(filename) ->
      "references attachment `"
      <> filename
      <> "` that is not present in attachments"

    AttachmentReferenceMissingFilename ->
      "must include a filename after `attachment://`"

    DuplicateAttachmentFilename(filename:, indexes:) ->
      "contains duplicate attachment filename `"
      <> filename
      <> "` at indexes "
      <> indexes |> list.map(int.to_string) |> string.join(", ")

    MutuallyExclusiveWith(other_path) ->
      "must not be used together with `" <> other_path <> "`"
  }
}
