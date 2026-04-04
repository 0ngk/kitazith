import gleam/option.{type Option, None, Some}

import kitazith/internal/query_helper
import kitazith/snowflake

/// Learn more:
///   [Webhook Resource - Documentation - Discord > Edit Webhook Message > Query String Params](https://docs.discord.com/developers/resources/webhook#edit-webhook-message)
pub type EditQuery {
  EditQuery(
    thread_id: Option(snowflake.Snowflake),
    with_components: Option(Bool),
  )
}

pub fn new() -> EditQuery {
  EditQuery(thread_id: None, with_components: None)
}

pub fn with_thread_id(
  query: EditQuery,
  thread_id: snowflake.Snowflake,
) -> EditQuery {
  EditQuery(..query, thread_id: Some(thread_id))
}

pub fn with_components(query: EditQuery, with_components: Bool) -> EditQuery {
  EditQuery(..query, with_components: Some(with_components))
}

pub fn to_query(query: EditQuery) -> List(#(String, String)) {
  query_helper.list_omit_none([
    query_helper.optional("thread_id", query.thread_id, snowflake.to_string),
    query_helper.optional(
      "with_components",
      query.with_components,
      query_helper.bool,
    ),
  ])
}
