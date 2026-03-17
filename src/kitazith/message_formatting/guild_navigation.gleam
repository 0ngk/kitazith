/// Discord guild navigation link types.
/// https://docs.discord.com/developers/reference#message-formatting
pub type GuildNavigationType {
  /// Customize tab
  /// https://support.discord.com/hc/en-us/articles/11074987197975-Community-Onboarding-FAQ
  Customize
  /// Browse channel
  Browse
  /// Server Guide
  /// https://support.discord.com/hc/en-us/articles/13497665141655
  Guide
  /// Linked Roles
  /// https://support.discord.com/hc/en-us/articles/10388356626711
  LinkedRoles
}

/// Format a Discord guild navigation link.
pub fn format(navigation_type: GuildNavigationType) -> String {
  case navigation_type {
    Customize -> "<id:customize>"
    Browse -> "<id:browse>"
    Guide -> "<id:guide>"
    LinkedRoles -> "<id:linked-roles>"
  }
}
