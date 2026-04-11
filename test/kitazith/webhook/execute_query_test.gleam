import gleam/option.{None, Some}

import kitazith/snowflake
import kitazith/webhook/execute_query

pub fn new_starts_empty_test() {
  let query = execute_query.new()

  assert query.wait == None
  assert query.thread_id == None
  assert query.with_components == None
}

pub fn builder_execute_query_test() {
  let query =
    execute_query.new()
    |> execute_query.with_wait(True)
    |> execute_query.with_thread_id(snowflake.new("1234567890"))
    |> execute_query.with_components(False)

  assert query.wait == Some(True)
  assert query.thread_id == Some(snowflake.new("1234567890"))
  assert query.with_components == Some(False)
}

pub fn execute_query_empty_to_query_test() {
  let result = execute_query.new() |> execute_query.to_query

  assert result == []
}

pub fn execute_query_to_query_omits_none_test() {
  let result =
    execute_query.new()
    |> execute_query.with_wait(True)
    |> execute_query.to_query

  assert result == [#("wait", "true")]
}

pub fn execute_query_false_values_preserved_test() {
  let result =
    execute_query.new()
    |> execute_query.with_wait(False)
    |> execute_query.with_components(False)
    |> execute_query.to_query

  assert result == [#("wait", "false"), #("with_components", "false")]
}

pub fn execute_query_full_to_query_test() {
  let result =
    execute_query.new()
    |> execute_query.with_wait(True)
    |> execute_query.with_thread_id(snowflake.new("1234567890"))
    |> execute_query.with_components(True)
    |> execute_query.to_query

  assert result
    == [
      #("wait", "true"),
      #("thread_id", "1234567890"),
      #("with_components", "true"),
    ]
}
