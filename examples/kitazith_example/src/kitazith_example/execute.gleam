import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/result

import kitazith/embed
import kitazith/poll
import kitazith/webhook/execute

pub fn main() {
  let assert Ok(base_req) = request.to(webhook_url())
  let req =
    base_req
    |> request.prepend_header("content-type", "application/json")
    |> request.set_method(http.Post)
    |> request.set_body(build_payload() |> execute.to_string)
  use resp <- result.try(httpc.send(req))
  assert resp.status == 204
  Ok(resp)
}

pub fn webhook_url() -> String {
  // Replace this with your own Discord webhook URL.
  "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
}

pub fn build_payload() -> execute.ExecutePayload {
  execute.new_execute_payload()
  |> execute.with_username("A bot")
  |> execute.with_content("Hello from Gleam!")
  |> execute.with_embeds([
    embed.new_embed()
    |> embed.with_title("Release Status")
    |> embed.with_description("The build is green and ready to ship.")
    |> embed.with_color(embed.color_from_rgb(87, 242, 135))
    |> embed.with_fields([
      embed.new_field("Status", "🟢 Green")
      |> embed.with_field_inline(True),
    ]),
  ])
  |> execute.with_poll(
    poll.new_poll(question: poll.PollQuestion(text: "Ship it?"), answers: [
      poll.PollAnswer(
        poll_media: poll.new_poll_media()
        |> poll.with_poll_media_emoji(
          poll.new_poll_emoji() |> poll.with_poll_emoji_name("✅"),
        )
        |> poll.with_poll_media_text("Yes"),
      ),
      poll.PollAnswer(
        poll_media: poll.new_poll_media()
        |> poll.with_poll_media_emoji(
          poll.new_poll_emoji() |> poll.with_poll_emoji_name("⚠️"),
        )
        |> poll.with_poll_media_text("Need one more review"),
      ),
    ])
    |> poll.with_duration(24)
    |> poll.with_allow_multiselect(False),
  )
}
