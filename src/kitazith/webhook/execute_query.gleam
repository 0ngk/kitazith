import gleam/option.{type Option, None, Some}

import kitazith/internal/query_helper
import kitazith/snowflake

/// Learn more:
///   [Webhook Resource - Documentation - Discord > Execute Webhook > Query String Params](https://docs.discord.com/developers/resources/webhook#execute-webhook)
pub type ExecuteQuery {
  ExecuteQuery(
    wait: Option(Bool),
    thread_id: Option(snowflake.Snowflake),
    with_components: Option(Bool),
  )
}

pub fn new() -> ExecuteQuery {
  ExecuteQuery(wait: None, thread_id: None, with_components: None)
}

pub fn with_wait(query: ExecuteQuery, wait: Bool) -> ExecuteQuery {
  ExecuteQuery(..query, wait: Some(wait))
}

pub fn with_thread_id(
  query: ExecuteQuery,
  thread_id: snowflake.Snowflake,
) -> ExecuteQuery {
  ExecuteQuery(..query, thread_id: Some(thread_id))
}

pub fn with_components(
  query: ExecuteQuery,
  with_components: Bool,
) -> ExecuteQuery {
  ExecuteQuery(..query, with_components: Some(with_components))
}

pub fn to_query(query: ExecuteQuery) -> List(#(String, String)) {
  query_helper.list_omit_none([
    query_helper.optional("wait", query.wait, query_helper.bool),
    query_helper.optional("thread_id", query.thread_id, snowflake.to_string),
    query_helper.optional(
      "with_components",
      query.with_components,
      query_helper.bool,
    ),
  ])
}
