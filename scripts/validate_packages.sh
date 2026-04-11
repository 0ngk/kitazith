#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_format_check() {
  local package_dir="$1"
  local -a format_paths=("src")

  if [[ -d "${package_dir}/test" ]]; then
    format_paths+=("test")
  fi

  (
    cd "$package_dir"
    gleam format --check "${format_paths[@]}"
  )
}

run_package_checks() {
  local package_dir="$1"
  local package_name="$2"
  local javascript_target="${3:-false}"

  echo "::group::${package_name}: format"
  run_format_check "$package_dir"
  echo "::endgroup::"

  echo "::group::${package_name}: deps"
  (
    cd "$package_dir"
    gleam deps download
  )
  echo "::endgroup::"

  echo "::group::${package_name}: check (Erlang)"
  (
    cd "$package_dir"
    gleam check --target erlang
  )
  echo "::endgroup::"

  if [[ "$javascript_target" == "true" ]]; then
    echo "::group::${package_name}: check (JavaScript)"
    (
      cd "$package_dir"
      gleam check --target javascript
    )
    echo "::endgroup::"
  fi

  echo "::group::${package_name}: test (Erlang)"
  (
    cd "$package_dir"
    gleam test --target erlang
  )
  echo "::endgroup::"

  if [[ "$javascript_target" == "true" ]]; then
    echo "::group::${package_name}: test (JavaScript)"
    (
      cd "$package_dir"
      gleam test --target javascript
    )
    echo "::endgroup::"
  fi
}

cd "$repo_root"

run_package_checks "." "root" "true"

while IFS= read -r manifest_path; do
  example_dir="$(dirname "$manifest_path")"
  example_name="${example_dir#./}"
  run_package_checks "$example_dir" "$example_name"
done < <(find examples -mindepth 2 -maxdepth 2 -name gleam.toml | sort)
