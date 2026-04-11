import gleam/json

import kitazith/timestamp

pub fn timestamp_from_rfc3339_valid_test() {
  let result = timestamp.from_rfc3339("2026-03-15T09:30:00Z")
  let assert Ok(ts) = result
  let str = timestamp.to_string(ts)
  assert str == "2026-03-15T09:30:00Z"
}

pub fn timestamp_from_rfc3339_invalid_test() {
  let result = timestamp.from_rfc3339("not-a-timestamp")
  assert result == Error(Nil)
}

pub fn timestamp_from_unix_seconds_test() {
  let ts = timestamp.from_unix_seconds(0)
  let str = timestamp.to_string(ts)
  assert str == "1970-01-01T00:00:00Z"
}

pub fn timestamp_offset_normalized_to_utc_test() {
  let assert Ok(ts) = timestamp.from_rfc3339("2026-03-15T18:30:00+09:00")
  let str = timestamp.to_string(ts)
  assert str == "2026-03-15T09:30:00Z"
}

pub fn timestamp_to_json_test() {
  let assert Ok(ts) = timestamp.from_rfc3339("2026-03-15T09:30:00Z")
  let result = ts |> timestamp.to_json |> json.to_string
  assert result == "\"2026-03-15T09:30:00Z\""
}
