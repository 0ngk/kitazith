import kitazith/flag

pub fn message_flags_to_int_test() {
  let result =
    flag.to_int([
      flag.SuppressEmbeds,
      flag.SuppressNotifications,
      flag.IsComponentsV2,
    ])

  assert result == 36_868
}
