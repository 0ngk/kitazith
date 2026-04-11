import kitazith/flag

fn expected_message_flags() -> List(flag.MessageFlag) {
  [
    flag.Crossposted,
    flag.IsCrosspost,
    flag.SuppressEmbeds,
    flag.SourceMessageDeleted,
    flag.Urgent,
    flag.HasThread,
    flag.Ephemeral,
    flag.Loading,
    flag.FailedToMentionSomeRolesInThread,
    flag.SuppressNotifications,
    flag.IsVoiceMessage,
    flag.HasSnapshot,
    flag.IsComponentsV2,
  ]
}

fn full_message_flag_bits() -> Int {
  61_951
}

pub fn message_flags_to_int_test() {
  let result = flag.to_int(expected_message_flags())

  assert result == full_message_flag_bits()
}

pub fn message_flags_from_int_test() {
  let result = flag.from_int(full_message_flag_bits())

  assert result == expected_message_flags()
}

pub fn message_flags_from_int_ignores_unknown_bits_test() {
  let unknown_message_flag_bits = 512
  let result =
    flag.from_int(full_message_flag_bits() + unknown_message_flag_bits)

  assert result == expected_message_flags()
}
