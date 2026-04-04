import gleam/option.{None, Some}

import kitazith/snowflake
import kitazith/webhook/get_query

pub fn new_starts_empty_test() {
  let query = get_query.new()

  assert query.thread_id == None
}

pub fn builder_get_query_test() {
  let query =
    get_query.new()
    |> get_query.with_thread_id(snowflake.new("1234567890"))

  assert query.thread_id == Some(snowflake.new("1234567890"))
}

pub fn get_query_empty_to_query_test() {
  let result = get_query.new() |> get_query.to_query

  assert result == []
}

pub fn get_query_full_to_query_test() {
  let result =
    get_query.new()
    |> get_query.with_thread_id(snowflake.new("1234567890"))
    |> get_query.to_query

  assert result == [#("thread_id", "1234567890")]
}
