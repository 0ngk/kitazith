import gleam/option.{type Option, None, Some}

import kitazith/internal/query_helper
import kitazith/snowflake

/// Learn more:
///   [Webhook Resource - Documentation - Discord > Get Webhook Message](https://docs.discord.com/developers/resources/webhook#get-webhook-message)
pub type GetQuery {
  GetQuery(thread_id: Option(snowflake.Snowflake))
}

pub fn new() -> GetQuery {
  GetQuery(thread_id: None)
}

pub fn with_thread_id(
  query: GetQuery,
  thread_id: snowflake.Snowflake,
) -> GetQuery {
  let GetQuery(..) = query
  GetQuery(thread_id: Some(thread_id))
}

pub fn to_query(query: GetQuery) -> List(#(String, String)) {
  query_helper.list_omit_none([
    query_helper.optional("thread_id", query.thread_id, snowflake.to_string),
  ])
}
