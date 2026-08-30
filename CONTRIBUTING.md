# Contributing to Fanne Linux

Thank you for helping build Fanne Linux.

## Ground rules

- Use English for source code, documentation, commit messages, and user-facing
  text.
- Keep changes focused and explain the reason behind them.
- Do not add packages only because they are popular; describe the user need
  they solve and their image-size impact.
- Never commit generated ISO images, build directories, credentials, or
  proprietary files that cannot be redistributed.
- Run `make check` before submitting a change.

## Development workflow

1. Create a branch from `main`.
2. Make and validate the change.
3. Build and boot-test the ISO when changing packages, hooks, or live-build
   configuration.
4. Open a pull request describing the test environment and result.

The architecture and scope are documented in [`docs/architecture.md`](docs/architecture.md).
