import gleam/option

pub type Poll {
  Poll(
    question: PollQuestion,
    answers: List(PollAnswer),
    duration: option.Option(Int),
    allow_multiselect: option.Option(Bool),
    layout_type: option.Option(Int),
  )
}

pub type PollQuestion {
  PollQuestion(text: String)
}

pub type PollAnswer {
  PollAnswer(poll_media: PollMedia)
}

pub type PollMedia {
  PollMedia(text: option.Option(String), emoji: option.Option(PollEmoji))
}

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
