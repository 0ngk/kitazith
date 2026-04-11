import gleam/int
import gleam/list

/// Learn more:
///   [Message Resource - Documentation - Discord > Message Object > Message Flags](https://docs.discord.com/developers/resources/message#message-object-message-flags)
pub type MessageFlag {
  Crossposted
  IsCrosspost
  SuppressEmbeds
  SourceMessageDeleted
  Urgent
  HasThread
  Ephemeral
  Loading
  FailedToMentionSomeRolesInThread
  SuppressNotifications
  IsVoiceMessage
  HasSnapshot
  IsComponentsV2
}

/// Encode the supported message flags into a Discord message flag bitfield.
///
/// Learn more:
///   [Message Resource - Documentation - Discord > Message Object > Message Flags](https://docs.discord.com/developers/resources/message#message-object-message-flags)
pub fn to_int(message_flags: List(MessageFlag)) -> Int {
  message_flags
  |> list.map(message_flag_bit)
  |> list.fold(0, int.bitwise_or)
}

/// Decode a Discord message flag bitfield into the supported message flags.
///
/// Unknown bits are ignored.
///
/// Learn more:
///   [Message Resource - Documentation - Discord > Message Object > Message Flags](https://docs.discord.com/developers/resources/message#message-object-message-flags)
pub fn from_int(bits: Int) -> List(MessageFlag) {
  supported_message_flags()
  |> list.filter_map(fn(message_flag) {
    case int.bitwise_and(bits, message_flag_bit(message_flag)) == 0 {
      True -> Error(Nil)
      False -> Ok(message_flag)
    }
  })
}

// This list defines the canonical decode order for supported message flags.
// Keep it in sync with `MessageFlag` when adding a new variant.
// `message_flag_bit` remains exhaustive, so new variants still require an
//   explicit bit mapping.
fn supported_message_flags() -> List(MessageFlag) {
  [
    Crossposted,
    IsCrosspost,
    SuppressEmbeds,
    SourceMessageDeleted,
    Urgent,
    HasThread,
    Ephemeral,
    Loading,
    FailedToMentionSomeRolesInThread,
    SuppressNotifications,
    IsVoiceMessage,
    HasSnapshot,
    IsComponentsV2,
  ]
}

fn message_flag_bit(message_flag: MessageFlag) -> Int {
  case message_flag {
    Crossposted -> int.bitwise_shift_left(1, 0)
    IsCrosspost -> int.bitwise_shift_left(1, 1)
    SuppressEmbeds -> int.bitwise_shift_left(1, 2)
    SourceMessageDeleted -> int.bitwise_shift_left(1, 3)
    Urgent -> int.bitwise_shift_left(1, 4)
    HasThread -> int.bitwise_shift_left(1, 5)
    Ephemeral -> int.bitwise_shift_left(1, 6)
    Loading -> int.bitwise_shift_left(1, 7)
    FailedToMentionSomeRolesInThread -> int.bitwise_shift_left(1, 8)
    SuppressNotifications -> int.bitwise_shift_left(1, 12)
    IsVoiceMessage -> int.bitwise_shift_left(1, 13)
    HasSnapshot -> int.bitwise_shift_left(1, 14)
    IsComponentsV2 -> int.bitwise_shift_left(1, 15)
  }
}
