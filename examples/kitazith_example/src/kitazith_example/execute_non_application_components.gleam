import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/result

import kitazith/color
import kitazith/component
import kitazith/component/container
import kitazith/component/media
import kitazith/component/section
import kitazith/component/separator
import kitazith/component/text_display
import kitazith/webhook/execute
import kitazith/webhook/execute_query

pub fn main() {
  let assert Ok(base_req) = request.to(webhook_url())
  let query =
    execute_query.new()
    |> execute_query.with_components(True)
  let assert Ok(payload) = build_payload() |> execute.validate
  let req =
    base_req
    |> request.prepend_header("content-type", "application/json")
    |> request.set_method(http.Post)
    |> request.set_query(execute_query.to_query(query))
    |> request.set_body(payload |> execute.to_string)
  use resp <- result.try(httpc.send(req))
  assert resp.status == 204
  Ok(resp)
}

pub fn webhook_url() -> String {
  "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
}

pub fn build_payload() -> execute.ExecutePayload {
  let hero =
    section.new_thumbnail(media.new("https://example.com/release.webp"))

  execute.new()
  |> execute.with_components([
    component.text_display(text_display.new("# Release Notes")),
    component.section(section.new(
      components: [
        text_display.new("Version 7.3 is now live."),
        text_display.new("Maintenance completed without downtime."),
      ],
      accessory: hero,
    )),
    component.separator(separator.new()),
    component.container(
      container.new([
        container.text_display(text_display.new(
          "Thanks for following the rollout.",
        )),
      ])
      |> container.with_accent_color(color.from_rgb(88, 101, 242)),
    ),
  ])
  |> execute.with_flags([execute.IsComponentsV2])
}
