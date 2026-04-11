## Commands

### Gleam

- Format: `gleam format`
- Type check only: `gleam check`
- Test: `gleam test`
- Build and validate: `gleam build`
- Install a package: `gleam add <package_name>`
- Generate docs: `gleam docs build`

Use `gleam build` as the default post-edit validation command in this repository. Use `gleam check` only when you explicitly want a quick type check without generating build artifacts.

### Running code

- The root package is a library and does not provide a default `gleam run` entrypoint.
- To run an executable module, use `gleam run -m <module_name>`.
- Projects under `examples/` are separate Gleam projects. Run their commands from each project's root directory, such as `examples/kitazith_example`.

## Code Style

### Standard libraries

- Prefer standard library functions or well-established third-party libraries when possible.
- Check the standard library and official package documentation before implementing.
- Avoid reinventing the wheel.

### Labeled arguments

- Labelled arguments are available.
- Prefer preposition-style labels such as `in`, `each`, `with`, `from`, `to`, `over`, and `apply` when they make calls read like natural English.
- Example: `replace(in: "A,B,C", each: ",", with: " ")`
- Due to language constraints, positional arguments must come before labelled arguments.
- Labels are optional, and callers may omit them.

### Imports

- Prefer qualified imports for functions, such as `list.map`. Unqualified function imports are discouraged.
- For types whose name matches the module name, unqualified type imports are conventional.
- Example: `import gleam/option.{type Option}`.

## Tests

- Test files must be located in the `test` directory.
- `gleeunit` test modules should use the `_test.gleam` suffix.
- Test functions should use the `_test` suffix.

## Editing Workflow

- Run `gleam format` after every code change in the package you edited.
- Run `gleam build` after every code change in the package you edited. Treat warnings as errors and fix issues such as unused imports immediately.
- Run `gleam test` after adding or changing functionality in the package you edited.
- If you edit files under `examples/`, run validation commands from the root directory of the example project you edited.
