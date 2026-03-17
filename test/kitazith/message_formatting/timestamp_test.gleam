import kitazith/message_formatting/timestamp

pub fn message_timestamp_format_test() {
  let seconds = 1_773_654_660

  assert timestamp.default(seconds) == "<t:1773654660>"
  assert timestamp.format(seconds, timestamp.ShortDate) == "<t:1773654660:d>"
  assert timestamp.format(seconds, timestamp.LongDate) == "<t:1773654660:D>"
  assert timestamp.format(seconds, timestamp.ShortTime) == "<t:1773654660:t>"
  assert timestamp.format(seconds, timestamp.MediumTime) == "<t:1773654660:T>"
  assert timestamp.format(seconds, timestamp.LongDateShortTime)
    == "<t:1773654660:f>"
  assert timestamp.format(seconds, timestamp.FullDateShortTime)
    == "<t:1773654660:F>"
  assert timestamp.format(seconds, timestamp.ShortDateShortTime)
    == "<t:1773654660:s>"
  assert timestamp.format(seconds, timestamp.ShortDateMediumTime)
    == "<t:1773654660:S>"
  assert timestamp.format(seconds, timestamp.RelativeTime) == "<t:1773654660:R>"
}
