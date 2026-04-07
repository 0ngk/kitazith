/// Converts RGB components to a single color integer for Discord color fields.
///
/// ## Examples
///
/// ```gleam
/// from_rgb(red: 255, green: 0, blue: 0)
/// // -> 0xFF0000 (== 16711680)
/// ```
pub fn from_rgb(red red: Int, green green: Int, blue blue: Int) -> Int {
  red * 65_536 + green * 256 + blue
}
