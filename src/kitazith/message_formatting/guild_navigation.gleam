/// Discord guild navigation link types.
///
/// Learn more:
///   [API Reference - Documentation - Discord > Message Formatting > Guild Navigation Types](https://docs.discord.com/developers/reference#message-formatting)
pub type GuildNavigationType {
  /// Customize tab
  ///
  /// Learn more:
  ///   [Community Onboarding FAQ – Discord](https://support.discord.com/hc/en-us/articles/11074987197975-Community-Onboarding-FAQ)
  Customize

  /// Browse channel
  Browse

  /// Server Guide
  ///
  /// Learn more:
  ///   [Server Guide FAQ – Discord](https://support.discord.com/hc/en-us/articles/13497665141655-Server-Guide-FAQ)
  Guide

  /// Linked Roles
  ///
  /// Learn more:
  ///   [Connections & Linked Roles: Admins – Discord](https://support.discord.com/hc/en-us/articles/10388356626711-Connections-Linked-Roles-Admins)
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
