import kitazith/message_formatting/mention
import kitazith/snowflake

pub fn message_mention_format_test() {
  let id = snowflake.new("42")

  assert mention.user(id) == "<@42>"
  assert mention.role(id) == "<@&42>"
  assert mention.channel(id) == "<#42>"
  assert mention.command("ship", id) == "</ship:42>"
}
