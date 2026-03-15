import gleam/option
import kitazith/attachment
import kitazith/component
import kitazith/embed
import kitazith/mentions
import kitazith/poll

pub type Payload {
  Payload(
    content: option.Option(String),
    username: option.Option(String),
    avatar_url: option.Option(String),
    tts: option.Option(Bool),
    embeds: option.Option(List(embed.Embed)),
    allowed_mentions: option.Option(mentions.AllowedMentions),
    components: option.Option(List(component.Component)),
    attachments: option.Option(List(attachment.Attachment)),
    flags: option.Option(Int),
    thread_name: option.Option(String),
    applied_tags: option.Option(List(String)),
    poll: option.Option(poll.Poll),
  )
}

pub fn new_payload() -> Payload {
  Payload(
    content: option.None,
    username: option.None,
    avatar_url: option.None,
    tts: option.None,
    embeds: option.None,
    allowed_mentions: option.None,
    components: option.None,
    attachments: option.None,
    flags: option.None,
    thread_name: option.None,
    applied_tags: option.None,
    poll: option.None,
  )
}
