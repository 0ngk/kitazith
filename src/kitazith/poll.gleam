import gleam/json
import gleam/option.{type Option, None, Some}

import kitazith/internal/json_helper
import kitazith/snowflake

/// https://docs.discord.com/developers/resources/poll#poll-create-request-object
pub type Poll {
  Poll(
    question: PollQuestion,
    answers: List(PollAnswer),
    duration: Option(Int),
    allow_multiselect: Option(Bool),
    layout_type: Option(Int),
  )
}

/// https://docs.discord.com/developers/resources/poll#poll-media-object
/// Poll.question only supports text, while Poll.answers supports both text and emoji.
pub type PollQuestion {
  PollQuestion(text: String)
}

/// https://docs.discord.com/developers/resources/poll#poll-media-object
pub type PollAnswer {
  PollAnswer(poll_media: PollMedia)
}

/// https://docs.discord.com/developers/resources/poll#poll-media-object
pub type PollMedia {
  PollMedia(text: Option(String), emoji: Option(PollEmoji))
}

/// partial https://docs.discord.com/developers/resources/emoji#emoji-object
pub type PollEmoji {
  PollEmoji(id: Option(snowflake.Snowflake), name: Option(String))
}

pub fn new_poll(question: PollQuestion, answers: List(PollAnswer)) -> Poll {
  Poll(
    question: question,
    answers: answers,
    duration: None,
    allow_multiselect: None,
    layout_type: None,
  )
}

pub fn with_duration(poll: Poll, duration: Int) -> Poll {
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
