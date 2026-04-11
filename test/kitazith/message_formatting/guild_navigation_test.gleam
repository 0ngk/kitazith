import kitazith/message_formatting/guild_navigation

pub fn message_guild_navigation_format_test() {
  assert guild_navigation.format(guild_navigation.Customize) == "<id:customize>"
  assert guild_navigation.format(guild_navigation.Browse) == "<id:browse>"
  assert guild_navigation.format(guild_navigation.Guide) == "<id:guide>"
  assert guild_navigation.format(guild_navigation.LinkedRoles)
    == "<id:linked-roles>"
}
