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
