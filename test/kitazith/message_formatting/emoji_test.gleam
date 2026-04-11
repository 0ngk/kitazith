import kitazith/message_formatting/emoji
import kitazith/snowflake

pub fn message_custom_emoji_format_test() {
  assert emoji.custom(name: "mmLol", id: snowflake.new("216154654256398347"))
    == "<:mmLol:216154654256398347>"
  assert emoji.animated(name: "b1nzy", id: snowflake.new("392938283556143104"))
    == "<a:b1nzy:392938283556143104>"
}
