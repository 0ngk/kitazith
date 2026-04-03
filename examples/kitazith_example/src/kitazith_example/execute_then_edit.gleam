import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/result

import kitazith/embed
import kitazith/snowflake
import kitazith/webhook/edit
import kitazith/webhook/execute
import kitazith/webhook/message

import kitazith_example/execute as execute_example

pub fn main() {
  let assert Ok(initial_payload) =
    execute_example.build_payload() |> execute.validate

  let assert Ok(base_req) = request.to(execute_example.webhook_url())
  let initial_req =
    base_req
    |> request.prepend_header("content-type", "application/json")
    |> request.set_method(http.Post)
    |> request.set_query([#("wait", "true")])
    |> request.set_body(initial_payload |> execute.to_string)
  use initial_resp <- result.try(httpc.send(initial_req))
  assert initial_resp.status == 200

  let assert Ok(webhook_message) = message.decode(initial_resp.body)

  let edit_payload =
    edit.new_edit_payload()
    |> edit.with_content("Edited after the initial execute call.")
    |> edit.with_embeds([
      embed.new_embed()
      |> embed.with_title("Release Status")
      |> embed.with_description("ℹ️ The message was updated with edit.")
      |> embed.with_color(embed.color_from_rgb(88, 101, 242)),
    ])

  let assert Ok(edit_req_base) =
    request.to(
      execute_example.webhook_url()
      <> "/messages/"
      <> snowflake.to_string(webhook_message.id),
    )
  let edit_req =
    edit_req_base
    |> request.prepend_header("content-type", "application/json")
    |> request.set_method(http.Patch)
    |> request.set_body(edit_payload |> edit.to_string)
  use edit_resp <- result.try(httpc.send(edit_req))
  assert edit_resp.status == 200
  Ok(edit_resp)
}
