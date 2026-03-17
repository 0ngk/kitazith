import gleam/json

import kitazith/snowflake

pub fn snowflake_to_json_test() {
  let result =
    snowflake.new("123456789012345678")
    |> snowflake.to_json
    |> json.to_string

  assert result == "\"123456789012345678\""
}
