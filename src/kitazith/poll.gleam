import gleam/json
import gleam/option.{type Option, None, Some}

import kitazith/internal/json_helper
import kitazith/snowflake

/// Learn more:
///   [Poll Resource - Documentation - Discord > Poll Create Request Object](https://docs.discord.com/developers/resources/poll#poll-create-request-object)
pub type Poll {
  Poll(
    question: PollQuestion,
    /// Up to 10 answers.
    answers: List(PollAnswer),
    /// Duration in hours. Up to 768 hours == 32 days.
    duration: Option(Int),
    allow_multiselect: Option(Bool),
    layout_type: Option(Int),
  )
}

/// Learn more:
///   [Poll Resource - Documentation - Discord > Poll Media Object](https://docs.discord.com/developers/resources/poll#poll-media-object)
///
/// Poll.question only supports text, while Poll.answers supports both text and emoji.
pub type PollQuestion {
  PollQuestion(
    /// At least 1 character and up to 300 characters.
    text: String,
  )
}

/// Learn more:
///   [Poll Resource - Documentation - Discord > Poll Answer Object](https://docs.discord.com/developers/resources/poll#poll-media-object)
pub type PollAnswer {
  PollAnswer(poll_media: PollMedia)
}

/// Learn more:
///   [Poll Resource - Documentation - Discord > Poll Media Object](https://docs.discord.com/developers/resources/poll#poll-media-object)
pub type PollMedia {
  PollMedia(
    /// If specified, at least 1 character and up to 55 characters for any answer.
    text: Option(String),
    emoji: Option(PollEmoji),
  )
}

/// Learn more: Partial
///   [Emoji Resource - Documentation - Discord > Emoji Object](https://docs.discord.com/developers/resources/emoji#emoji-object)
pub type PollEmoji {
  PollEmoji(
    /// Specify if custom emoji.
    id: Option(snowflake.Snowflake),
    /// Specify if default emoji.
    ///
    /// Example 1: `option.Option("🔥")`
    ///
    /// Example 2: `option.Option("\u{1f525}")`
    name: Option(String),
  )
}

pub fn new(
  question question: PollQuestion,
  answers answers: List(PollAnswer),
) -> Poll {
  Poll(
    question:,
    answers:,
    duration: None,
    allow_multiselect: None,
    layout_type: None,
  )
}

pub fn with_duration(poll: Poll, hours duration: Int) -> Poll {
  Poll(..poll, duration: Some(duration))
}

pub fn with_allow_multiselect(poll: Poll, allow_multiselect: Bool) -> Poll {
  Poll(..poll, allow_multiselect: Some(allow_multiselect))
}

pub fn with_layout_type(poll: Poll, layout_type: Int) -> Poll {
  Poll(..poll, layout_type: Some(layout_type))
}

pub fn new_poll_media() -> PollMedia {
  PollMedia(text: None, emoji: None)
}

pub fn with_poll_media_text(media: PollMedia, text: String) -> PollMedia {
  PollMedia(..media, text: Some(text))
}

pub fn with_poll_media_emoji(media: PollMedia, emoji: PollEmoji) -> PollMedia {
  PollMedia(..media, emoji: Some(emoji))
}

pub fn new_poll_emoji() -> PollEmoji {
  PollEmoji(id: None, name: None)
}

pub fn with_poll_emoji_id(
  emoji: PollEmoji,
  id: snowflake.Snowflake,
) -> PollEmoji {
  PollEmoji(..emoji, id: Some(id))
}

pub fn with_poll_emoji_name(emoji: PollEmoji, name: String) -> PollEmoji {
  PollEmoji(..emoji, name: Some(name))
}

pub fn to_json(p: Poll) -> json.Json {
  json_helper.object_omit_none([
    Some(#("question", poll_question_to_json(p.question))),
    Some(#("answers", json.array(p.answers, poll_answer_to_json))),
    json_helper.optional("duration", p.duration, json.int),
    json_helper.optional("allow_multiselect", p.allow_multiselect, json.bool),
    json_helper.optional("layout_type", p.layout_type, json.int),
  ])
}

fn poll_question_to_json(q: PollQuestion) -> json.Json {
  json.object([#("text", json.string(q.text))])
}

fn poll_answer_to_json(a: PollAnswer) -> json.Json {
  json.object([#("poll_media", poll_media_to_json(a.poll_media))])
}

fn poll_media_to_json(m: PollMedia) -> json.Json {
  json_helper.object_omit_none([
    json_helper.optional("text", m.text, json.string),
    json_helper.optional("emoji", m.emoji, poll_emoji_to_json),
  ])
}

fn poll_emoji_to_json(e: PollEmoji) -> json.Json {
  json_helper.object_omit_none([
    json_helper.optional("id", e.id, snowflake.to_json),
    json_helper.optional("name", e.name, json.string),
  ])
}
