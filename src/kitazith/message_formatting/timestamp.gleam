import gleam/int
import gleam/string

/// Discord message timestamp display styles.
///
/// Learn more:
///   [API Reference - Documentation - Discord > Message Formatting > Timestamp Styles](https://docs.discord.com/developers/reference#message-formatting-timestamp-styles)
pub type Style {
  Default
  ShortTime
  MediumTime
  ShortDate
  LongDate
  LongDateShortTime
  FullDateShortTime
  ShortDateShortTime
  ShortDateMediumTime
  RelativeTime
}

/// Format Unix seconds as a Discord message timestamp.
pub fn format(seconds: Int, style: Style) -> String {
  case style {
    Default -> string.concat(["<t:", int.to_string(seconds), ">"])
    _ ->
      string.concat([
        "<t:",
        int.to_string(seconds),
        ":",
        style_code(style),
        ">",
      ])
  }
}

/// Format Unix seconds using Discord's default timestamp rendering.
pub fn default(seconds: Int) -> String {
  format(seconds, Default)
}

fn style_code(style: Style) -> String {
  case style {
    Default -> ""
    ShortTime -> "t"
    MediumTime -> "T"
    ShortDate -> "d"
    LongDate -> "D"
    LongDateShortTime -> "f"
    FullDateShortTime -> "F"
    ShortDateShortTime -> "s"
    ShortDateMediumTime -> "S"
    RelativeTime -> "R"
  }
}
