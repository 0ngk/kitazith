import gleam/option.{None, Some}

import kitazith/snowflake
import kitazith/webhook/edit_query

pub fn new_edit_query_starts_empty_test() {
  let query = edit_query.new_edit_query()

  assert query.thread_id == None
  assert query.with_components == None
}

pub fn builder_edit_query_test() {
  let query =
    edit_query.new_edit_query()
    |> edit_query.with_thread_id(snowflake.new("1234567890"))
    |> edit_query.with_components(False)

  assert query.thread_id == Some(snowflake.new("1234567890"))
  assert query.with_components == Some(False)
}

pub fn edit_query_empty_to_query_test() {
  let result = edit_query.new_edit_query() |> edit_query.to_query

  assert result == []
}

pub fn edit_query_false_values_preserved_test() {
  let result =
    edit_query.new_edit_query()
    |> edit_query.with_components(False)
    |> edit_query.to_query

  assert result == [#("with_components", "false")]
}

pub fn edit_query_full_to_query_test() {
  let result =
    edit_query.new_edit_query()
    |> edit_query.with_thread_id(snowflake.new("1234567890"))
    |> edit_query.with_components(True)
    |> edit_query.to_query

  assert result == [#("thread_id", "1234567890"), #("with_components", "true")]
}
