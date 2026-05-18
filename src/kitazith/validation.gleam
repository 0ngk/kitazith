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
  AggregateComponentLimitExceeded(max: Int, actual: Int)
  ComponentCountOutOfRange(min: Int, max: Int, actual: Int, item_label: String)
  NumericMaximumExceeded(max: Int, actual: Int, unit: String)
  NumericOutOfRange(min: Int, max: Int, actual: Int, unit: String)
  MissingAttachmentReference(filename: String)
  AttachmentReferenceMissingFilename
  AttachmentReferenceRequired
  DuplicateAttachmentFilename(filename: String, indexes: List(Int))
  DuplicateComponentId(id: Int, paths: List(String))
  MutuallyExclusiveWith(other_path: String)
  RequiresFlag(flag_name: String)
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

    AggregateComponentLimitExceeded(max:, ..) ->
      "must contain at most " <> int.to_string(max) <> " total components"

    ComponentCountOutOfRange(min:, max:, item_label:, ..) ->
      "must contain between "
      <> int.to_string(min)
      <> " and "
      <> int.to_string(max)
      <> " "
      <> item_label

    NumericMaximumExceeded(max:, unit:, ..) ->
      "must be at most " <> int.to_string(max) <> " " <> unit

    NumericOutOfRange(min:, max:, unit:, ..) ->
      "must be between "
      <> int.to_string(min)
      <> " and "
      <> int.to_string(max)
      <> " "
      <> unit

    MissingAttachmentReference(filename) ->
      "references attachment `"
      <> filename
      <> "` that is not present in attachments"

    AttachmentReferenceMissingFilename ->
      "must include a filename after `attachment://`"

    AttachmentReferenceRequired ->
      "must use an `attachment://<filename>` reference"

    DuplicateAttachmentFilename(filename:, indexes:) ->
      "contains duplicate attachment filename `"
      <> filename
      <> "` at indexes "
      <> indexes |> list.map(int.to_string) |> string.join(", ")

    DuplicateComponentId(id:, paths:) ->
      "contains duplicate component id `"
      <> int.to_string(id)
      <> "` at paths "
      <> string.join(paths, ", ")

    MutuallyExclusiveWith(other_path) ->
      "must not be used together with `" <> other_path <> "`"

    RequiresFlag(flag_name) -> "requires the `" <> flag_name <> "` flag"
  }
}
