import gleam/json
import gleam/option.{type Option, None, Some}

import kitazith/internal/json_helper

/// Learn more:
///   [Components > Separator](https://docs.discord.com/developers/components/reference#separator)
pub type SeparatorSpacing {
  Small
  Large
}

/// Learn more:
///   [Components > Separator](https://docs.discord.com/developers/components/reference#separator)
pub type Separator {
  Separator(
    id: Option(Int),
    divider: Option(Bool),
    /// `Small` for compact spacing, `Large` for wider spacing.
    spacing: Option(SeparatorSpacing),
  )
}

pub fn new() -> Separator {
  Separator(id: None, divider: None, spacing: None)
}

pub fn with_id(separator: Separator, id: Int) -> Separator {
  Separator(..separator, id: Some(id))
}

pub fn with_divider(separator: Separator, divider: Bool) -> Separator {
  Separator(..separator, divider: Some(divider))
}

pub fn with_spacing(
  separator: Separator,
  spacing: SeparatorSpacing,
) -> Separator {
  Separator(..separator, spacing: Some(spacing))
}

pub fn to_json(separator: Separator) -> json.Json {
  json_helper.object_omit_none([
    Some(#("type", json.int(14))),
    json_helper.optional("id", separator.id, json.int),
    json_helper.optional("divider", separator.divider, json.bool),
    json_helper.optional("spacing", separator.spacing, spacing_to_json),
  ])
}

fn spacing_to_json(spacing: SeparatorSpacing) -> json.Json {
  case spacing {
    Small -> json.int(1)
    Large -> json.int(2)
  }
}
