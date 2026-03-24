import gleam/json
import gleam/option.{Some}

import kitazith/poll

pub fn builder_poll_test() {
  let p =
    poll.new_poll(question: poll.PollQuestion(text: "Pick one"), answers: [
      poll.PollAnswer(
        poll_media: poll.new_poll_media()
        |> poll.with_poll_media_text("Option A"),
      ),
      poll.PollAnswer(
        poll_media: poll.new_poll_media()
        |> poll.with_poll_media_text("Option B")
        |> poll.with_poll_media_emoji(
          poll.new_poll_emoji()
          |> poll.with_poll_emoji_name("\u{1f525}"),
        ),
      ),
    ])
    |> poll.with_duration(hours: 24)
    |> poll.with_allow_multiselect(False)
    |> poll.with_layout_type(1)

  assert p.duration == Some(24)
  assert p.allow_multiselect == Some(False)
  assert p.layout_type == Some(1)
}

pub fn poll_to_json_test() {
  let result =
    poll.new_poll(question: poll.PollQuestion(text: "Pick one"), answers: [
      poll.PollAnswer(
        poll_media: poll.new_poll_media()
        |> poll.with_poll_media_text("Option A"),
      ),
      poll.PollAnswer(
        poll_media: poll.new_poll_media()
        |> poll.with_poll_media_text("Option B")
        |> poll.with_poll_media_emoji(
          poll.new_poll_emoji()
          |> poll.with_poll_emoji_name("\u{1f525}"),
        ),
      ),
    ])
    |> poll.with_duration(hours: 24)
    |> poll.with_allow_multiselect(False)
    |> poll.to_json
    |> json.to_string

  assert result
    == "{\"question\":{\"text\":\"Pick one\"},\"answers\":[{\"poll_media\":{\"text\":\"Option A\"}},{\"poll_media\":{\"text\":\"Option B\",\"emoji\":{\"name\":\"🔥\"}}}],\"duration\":24,\"allow_multiselect\":false}"
}
