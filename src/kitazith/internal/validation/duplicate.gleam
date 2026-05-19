import gleam/list

pub type Occurrence(value, path) {
  Occurrence(value: value, path: path)
}

pub type Duplicate(value, path) {
  Duplicate(value: value, paths: List(path))
}

pub fn find(
  occurrences: List(Occurrence(value, path)),
) -> List(Duplicate(value, path)) {
  collect_duplicates(occurrences, seen_values: [])
}

fn collect_duplicates(
  occurrences: List(Occurrence(value, path)),
  seen_values seen_values: List(value),
) -> List(Duplicate(value, path)) {
  case occurrences {
    [] -> []
    [Occurrence(value:, path:), ..rest] ->
      case contains(in: seen_values, target: value) {
        True -> collect_duplicates(rest, seen_values: seen_values)

        False -> {
          let paths = [path, ..collect_paths(rest, value)]

          let duplicates = case list.length(paths) > 1 {
            True -> [Duplicate(value:, paths:)]
            False -> []
          }

          list.append(
            duplicates,
            collect_duplicates(rest, seen_values: [value, ..seen_values]),
          )
        }
      }
  }
}

fn collect_paths(
  occurrences: List(Occurrence(value, path)),
  target_value: value,
) -> List(path) {
  occurrences
  |> list.filter_map(fn(occurrence) {
    case occurrence.value == target_value {
      True -> Ok(occurrence.path)
      False -> Error(Nil)
    }
  })
}

fn contains(in items: List(value), target target: value) -> Bool {
  case items {
    [] -> False
    [item, ..rest] -> item == target || contains(in: rest, target:)
  }
}
