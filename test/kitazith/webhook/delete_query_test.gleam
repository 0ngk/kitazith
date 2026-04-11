import gleam/option.{None, Some}

import kitazith/snowflake
import kitazith/webhook/delete_query

pub fn new_starts_empty_test() {
  let query = delete_query.new()

  assert query.thread_id == None
}

pub fn builder_delete_query_test() {
  let query =
    delete_query.new()
    |> delete_query.with_thread_id(snowflake.new("1234567890"))

  assert query.thread_id == Some(snowflake.new("1234567890"))
}

pub fn delete_query_empty_to_query_test() {
  let result = delete_query.new() |> delete_query.to_query

  assert result == []
}

pub fn delete_query_full_to_query_test() {
  let result =
    delete_query.new()
    |> delete_query.with_thread_id(snowflake.new("1234567890"))
    |> delete_query.to_query

  assert result == [#("thread_id", "1234567890")]
}
