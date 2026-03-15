import gleam/option

/// https://docs.discord.com/developers/resources/poll#poll-create-request-object
pub type Poll {
  Poll(
    question: PollQuestion,
    answers: List(PollAnswer),
    duration: option.Option(Int),
    allow_multiselect: option.Option(Bool),
    layout_type: option.Option(Int),
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
  PollMedia(text: option.Option(String), emoji: option.Option(PollEmoji))
}

/// partial https://docs.discord.com/developers/resources/emoji#emoji-object
pub type PollEmoji {
  PollEmoji(id: option.Option(String), name: option.Option(String))
}

pub fn new_poll(question: PollQuestion, answers: List(PollAnswer)) -> Poll {
  Poll(
    question: question,
    answers: answers,
    duration: option.None,
    allow_multiselect: option.None,
    layout_type: option.None,
  )
}

pub fn with_duration(poll: Poll, duration: Int) -> Poll {
  Poll(..poll, duration: option.Some(duration))
}

pub fn with_allow_multiselect(poll: Poll, allow_multiselect: Bool) -> Poll {
  Poll(..poll, allow_multiselect: option.Some(allow_multiselect))
}

pub fn with_layout_type(poll: Poll, layout_type: Int) -> Poll {
  Poll(..poll, layout_type: option.Some(layout_type))
}

pub fn new_poll_media() -> PollMedia {
  PollMedia(text: option.None, emoji: option.None)
}

pub fn with_poll_media_text(media: PollMedia, text: String) -> PollMedia {
  PollMedia(..media, text: option.Some(text))
}

pub fn with_poll_media_emoji(media: PollMedia, emoji: PollEmoji) -> PollMedia {
  PollMedia(..media, emoji: option.Some(emoji))
}

pub fn new_poll_emoji() -> PollEmoji {
  PollEmoji(id: option.None, name: option.None)
}

pub fn with_poll_emoji_id(emoji: PollEmoji, id: String) -> PollEmoji {
  PollEmoji(..emoji, id: option.Some(id))
}

pub fn with_poll_emoji_name(emoji: PollEmoji, name: String) -> PollEmoji {
  PollEmoji(..emoji, name: option.Some(name))
}
