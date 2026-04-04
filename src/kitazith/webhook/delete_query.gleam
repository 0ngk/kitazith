import gleam/option.{type Option, None, Some}

import kitazith/internal/query_helper
import kitazith/snowflake

/// Learn more:
///   [Webhook Resource - Documentation - Discord > Delete Webhook Message](https://docs.discord.com/developers/resources/webhook#delete-webhook-message)
pub type DeleteQuery {
  DeleteQuery(thread_id: Option(snowflake.Snowflake))
}

pub fn new() -> DeleteQuery {
  DeleteQuery(thread_id: None)
}

pub fn with_thread_id(
  query: DeleteQuery,
  thread_id: snowflake.Snowflake,
) -> DeleteQuery {
  let DeleteQuery(..) = query
  DeleteQuery(thread_id: Some(thread_id))
}

pub fn to_query(query: DeleteQuery) -> List(#(String, String)) {
  query_helper.list_omit_none([
    query_helper.optional("thread_id", query.thread_id, snowflake.to_string),
  ])
}
