# Repository Guidelines

## Project Structure & Module Organization
- `Pingo/` hosts SwiftUI sources grouped by Clean Architecture roles (`FeedViewModel`, `FeedUseCase`, `FeedRepository`, models, networking). Keep new features in their own folder and mirror this separation.
- `PingoTests/` contains XCTest specs for use cases and view models; colocate new unit tests with the feature they validate and share mocks such as `MockFeedRepository`.
- `PingoUITests/` handles UI automation; reuse shared helpers to avoid duplication.

## Build, Test, and Development Commands
- `open Pingo.xcodeproj` launches the workspace in Xcode for interactive development.
- `xcodebuild -scheme Pingo -configuration Debug build` builds the app from the command line; use before pushing to ensure deterministic builds.
- `xcodebuild test -scheme Pingo -destination 'platform=iOS Simulator,name=iPhone 15'` runs the XCTest suite headlessly; match the destination to the simulator you have installed.

## Coding Style & Naming Conventions
- Follow 4-space indentation, trailing newline, and Swift API Design Guidelines. Types/protocols use `UpperCamelCase`, members use `lowerCamelCase`, and protocols keep the `Protocol` suffix.
- Keep view models `final`, inject dependencies via initializers, and expose read-only collections with `private(set)` as in `FeedViewModel`.
- Prefer `struct` for value models (`FeedEntity`, `CharacterResponse`) and `enum` for error cases. Use Xcode’s “Editor ▸ Structure ▸ Re-Indent” before committing.

## Testing Guidelines
- Tests rely on XCTest. Name methods with the pattern `test_<behavior>_<expectation>` to clarify intent (see `PingoFeedViewModelTests`).
- Mock upstream services with `MockFeedRepository` to isolate scenarios, and run `xcodebuild test ...` locally before submitting changes.

## Commit & Pull Request Guidelines
- Follow the conventional-commit style seen in history (`chore: fix ...`). Keep scope short and actionable.
- One logical change per commit; include rationale or links to issues in the body when behavior shifts.
- Pull requests should summarize intent, list affected modules, and attach screenshots or simulator recordings when UI changes occur. Reference related issues with `Fixes #id` where applicable.

## Architecture Notes
- The app layers follow Clean Architecture: networking feeds repositories, repositories wrap use cases, and SwiftUI views observe view models. Preserve this direction when introducing new features.
- Introduce new services by defining a protocol, providing a concrete implementation under `Pingo/`, and injecting it through the initializer chain so tests can override dependencies.

## Architecture Diagrams
- Keep the Mermaid diagrams in `README.md` aligned with the implementation. Update the feed refresh, character detail, and offline-sync flows whenever dependencies or data paths change.
