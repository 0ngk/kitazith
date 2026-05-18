import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

import kitazith/attachment
import kitazith/internal/validation/common
import kitazith/internal/validation/duplicate
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
  case attachment_reference_filename(url) {
    Some(filename) ->
      case filename == "" {
        True -> [
          common.error(path, validation.AttachmentReferenceMissingFilename),
        ]

        False ->
          case attachment_filenames {
            Some(attachment_filenames) ->
              case contains_string(in: attachment_filenames, target: filename) {
                True -> []
                False -> [
                  common.error(
                    path,
                    validation.MissingAttachmentReference(filename),
                  ),
                ]
              }

            None -> []
          }
      }

    None -> []
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
  |> list.index_map(fn(attachment, index) {
    duplicate.Occurrence(value: attachment.filename, path: index)
  })
  |> duplicate.find
  |> list.map(fn(duplicate) {
    common.error(
      path,
      validation.DuplicateAttachmentFilename(
        filename: duplicate.value,
        indexes: duplicate.paths,
      ),
    )
  })
}
