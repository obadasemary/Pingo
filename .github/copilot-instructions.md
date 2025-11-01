<!-- .github/copilot-instructions.md generated/updated for the Pingo repo -->
# Copilot instructions for contributors and AI assistants

Purpose: give AI coding agents the minimal, high-value orientation needed to be productive in this SwiftUI + Clean Architecture codebase.

- Project snapshot (one-liner): Pingo is a SwiftUI app that follows Clean Architecture: NetworkService -> Repositories -> UseCases -> ViewModels -> SwiftUI Views.

- Quick dev commands (macOS / zsh):
  - Open in Xcode: `open Pingo.xcodeproj`
  - Build from CLI: `xcodebuild -scheme Pingo -configuration Debug build`
  - Run tests headless: `xcodebuild test -scheme Pingo -destination 'platform=iOS Simulator,name=iPhone 15'`

- Key files / directories to reference when coding:
  - `Pingo/FeedViewModel.swift` — pattern for final view models + DI
  - `Pingo/FeedUseCase.swift` — business logic / orchestration
  - `Pingo/FeedRepository.swift` — data gateway abstraction
  - `Pingo/NetworkService.swift` — HTTP layer, single point for requests
  - `Pingo/MockFeedRepository.swift` — test double used extensively in `PingoTests/`
  - `ImageCache/` — shared image caching utilities

- Important conventions (do not invent alternatives):
  - 4-space indentation and trailing newline.
  - Types/protocols: `UpperCamelCase`. Members: `lowerCamelCase`.
  - Protocols end with `Protocol` when used as explicit interfaces.
  - View models are `final`, dependencies injected via initializer, and expose read-only collections with `private(set)`.
  - Prefer `struct` for value models and `enum` for error types.

- Architecture & patterns to preserve in changes:
  - Keep a single responsibility per layer: Networking (NetworkService) never contains UI logic; repositories translate network models to entities; use cases coordinate repository calls; view models prepare presentation state.
  - Add new features by creating a new subfolder under `Pingo/` and mirroring the layers (Repository, UseCase, ViewModel, Views) so tests and mocks can be colocated.

- Tests and naming: use XCTest and name tests `test_<behavior>_<expectation>` (see `PingoFeedViewModelTests`). Use `MockFeedRepository` to isolate upstream calls.

- Examples (how to extend the codebase):
  - Add a new feature `Episode`: create `Pingo/EpisodeRepository.swift`, `Pingo/EpisodeUseCase.swift`, `Pingo/EpisodeViewModel.swift`, and SwiftUI views in `Pingo/`.
  - For network models, add mapping code in the repository layer to convert responses to app entities (follow `FeedRepository` patterns).

- Integration notes & pitfalls for AI suggestions:
  - Do not change public app wiring (App entry is `PingoApp.swift`) without verifying DI and tests.
  - When changing networking behavior, update and run unit tests that mock `NetworkService` or `MockFeedRepository`.
  - Keep `xcodebuild` commands in documentation and CI aligned with local test commands.

- PR checklist for automated edits by agents:
  - Keep changes scoped and single-purpose.
  - Add/adjust unit tests in `PingoTests/` for any public behavior change.
  - Run `xcodebuild test` before suggesting a merge; include failing output in comments if tests fail.

- Where to find more detailed guidelines: `AGENTS.md` contains fuller repository guidelines (coding style, build commands, and architecture diagrams). Use it for larger, repository-wide decisions.

- Feedback: If anything here is unclear or you want more examples (e.g., a template for creating a new UseCase + tests), tell me which area to expand and I'll iterate.
