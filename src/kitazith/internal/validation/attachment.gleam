import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

import kitazith/attachment
import kitazith/internal/validation/common
import kitazith/validation

pub fn attachment_filenames(
  attachments: List(attachment.Attachment),
) -> List(String) {
  attachments |> list.map(fn(attachment) { attachment.filename })
}

pub fn validate_attachments(
  path: String,
  attachments: List(attachment.Attachment),
) -> List(validation.ValidationError) {
  list.flatten([
    attachments
      |> list.index_map(fn(attachment, index) {
        case attachment.description {
          Some(description) ->
            common.validate_string_length(
              common.join_path(common.indexed_path(path, index), "description"),
              description,
              min: 1,
              max: 1024,
            )

          None -> []
        }
      })
      |> list.flatten,
    duplicate_attachment_filename_errors(path, attachments),
  ])
}

pub fn validate_attachment_reference(
  path: String,
  url: String,
  attachment_filenames attachment_filenames: Option(List(String)),
) -> List(validation.ValidationError) {
  case attachment_reference_filename(url), attachment_filenames {
    Some(filename), Some(attachment_filenames) ->
      case filename == "" {
        True -> [
          common.error(path, validation.AttachmentReferenceMissingFilename),
        ]

        False ->
          case contains_string(in: attachment_filenames, target: filename) {
            True -> []
            False -> [
              common.error(
                path,
                validation.MissingAttachmentReference(filename),
              ),
            ]
          }
      }

    _, _ -> []
  }
}

pub fn attachment_reference_filename(url: String) -> Option(String) {
  let prefix = "attachment://"

  case string.starts_with(url, prefix) {
    True ->
      Some(string.slice(
        from: url,
        at_index: string.length(prefix),
        length: string.length(url) - string.length(prefix),
      ))

    False -> None
  }
}

fn contains_string(in items: List(String), target target: String) -> Bool {
  case items {
    [] -> False
    [item, ..rest] -> item == target || contains_string(in: rest, target:)
  }
}

fn duplicate_attachment_filename_errors(
  path: String,
  attachments: List(attachment.Attachment),
) -> List(validation.ValidationError) {
  attachments
  |> list.index_map(fn(attachment, index) { #(attachment.filename, index) })
  |> collect_duplicate_attachment_filename_errors(path, seen_filenames: [])
}

fn collect_duplicate_attachment_filename_errors(
  indexed_filenames: List(#(String, Int)),
  path: String,
  seen_filenames seen_filenames: List(String),
) -> List(validation.ValidationError) {
  case indexed_filenames {
    [] -> []
    [#(filename, index), ..rest] ->
      case contains_string(in: seen_filenames, target: filename) {
        True ->
          collect_duplicate_attachment_filename_errors(
            rest,
            path,
            seen_filenames: seen_filenames,
          )

        False -> {
          let indexes = [
            index,
            ..collect_attachment_filename_indexes(rest, filename)
          ]

          let duplicates = case list.length(indexes) > 1 {
            True -> [
              common.error(
                path,
                validation.DuplicateAttachmentFilename(filename:, indexes:),
              ),
            ]

            False -> []
          }

          list.append(
            duplicates,
            collect_duplicate_attachment_filename_errors(
              rest,
              path,
              seen_filenames: [filename, ..seen_filenames],
            ),
          )
        }
      }
  }
}

fn collect_attachment_filename_indexes(
  indexed_filenames: List(#(String, Int)),
  filename: String,
) -> List(Int) {
  indexed_filenames
  |> list.filter_map(fn(indexed_filename) {
    let #(candidate_filename, candidate_index) = indexed_filename
    case candidate_filename == filename {
      True -> Ok(candidate_index)
      False -> Error(Nil)
    }
  })
}
