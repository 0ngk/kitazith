import gleam/int
import gleam/list

pub type MessageFlag {
  SuppressEmbeds
  SuppressNotifications
  IsComponentsV2
}

/// Learn more: [Message Resource - Documentation - Discord > Message Object > Message Flags](https://docs.discord.com/developers/resources/message#message-object-message-flags)
///
/// Only `SUPPRESS_EMBEDS`, `SUPPRESS_NOTIFICATIONS`, and `IS_COMPONENTS_V2` are supported.
/// Source: [Webhook Resource - Documentation - Discord > ]()
pub fn to_int(message_flags: List(MessageFlag)) -> Int {
  message_flags
  |> list.map(fn(flag) {
    case flag {
      SuppressEmbeds -> int.bitwise_shift_left(1, 2)
      SuppressNotifications -> int.bitwise_shift_left(1, 12)
      IsComponentsV2 -> int.bitwise_shift_left(1, 15)
    }
  })
  |> list.fold(0, int.bitwise_or)
}
