import gleam/list
import gleam/option.{None, Some}

import kitazith/internal/validation/common
import kitazith/poll
import kitazith/validation

pub fn validate_poll(
  path: String,
  poll: poll.Poll,
) -> List(validation.ValidationError) {
  let max_poll_duration_hours = 24 * 32

  list.flatten([
    common.validate_string_length(
      common.join_path(path, "question.text"),
      poll.question.text,
      min: 1,
      max: 300,
    ),
    common.validate_list_max_length(
      common.join_path(path, "answers"),
      poll.answers,
      max: 10,
      noun: "answers",
    ),
    case poll.duration {
      Some(duration) ->
        case duration > max_poll_duration_hours {
          True -> [
            common.error(
              common.join_path(path, "duration"),
              validation.NumericMaximumExceeded(
                max: max_poll_duration_hours,
                actual: duration,
                unit: "hours",
              ),
            ),
          ]

          False -> []
        }

      None -> []
    },
    poll.answers
      |> list.index_map(fn(answer, index) {
        validate_poll_answer(
          common.indexed_path(common.join_path(path, "answers"), index),
          answer,
        )
      })
      |> list.flatten,
  ])
}

fn validate_poll_answer(
  path: String,
  answer: poll.PollAnswer,
) -> List(validation.ValidationError) {
  case answer.poll_media.text {
    Some(text) ->
      common.validate_string_length(
        common.join_path(path, "poll_media.text"),
        text,
        min: 1,
        max: 55,
      )

    None -> []
  }
}
