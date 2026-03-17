import gleam/json
import gleam/time/calendar
import gleam/time/timestamp as time_timestamp

/// A type-safe RFC 3339 timestamp backed by `gleam_time`.
///
/// Learn more: [API Reference - Documentation - Discord > ISO8601 Date/Time](https://docs.discord.com/developers/reference#iso8601-date%2Ftime)
pub opaque type Timestamp {
  Timestamp(inner: time_timestamp.Timestamp)
}

/// Parse an RFC 3339 string into a `Timestamp`.
pub fn from_rfc3339(input: String) -> Result(Timestamp, Nil) {
  case time_timestamp.parse_rfc3339(input) {
    Ok(ts) -> Ok(Timestamp(ts))
    Error(Nil) -> Error(Nil)
  }
}

/// Create a `Timestamp` from Unix seconds.
pub fn from_unix_seconds(seconds: Int) -> Timestamp {
  Timestamp(time_timestamp.from_unix_seconds(seconds))
}

/// Convert a `Timestamp` to an RFC 3339 string in UTC.
pub fn to_string(ts: Timestamp) -> String {
  time_timestamp.to_rfc3339(ts.inner, calendar.utc_offset)
}

/// Serialize a `Timestamp` to JSON as an RFC 3339 string.
pub fn to_json(ts: Timestamp) -> json.Json {
  json.string(to_string(ts))
}
