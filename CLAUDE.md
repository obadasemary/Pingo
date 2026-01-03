# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pingo is a SwiftUI application that demonstrates Clean Architecture principles using the Rick and Morty API. The architecture follows a strict layered approach: NetworkService → Repository → UseCase → ViewModel → SwiftUI Views.

**Target Platform:** iOS 17+ with Swift 5.9 (requires Xcode 15+)

## Development Commands

### Building and Testing
```bash
# Open project in Xcode
open Pingo.xcodeproj

# Build from command line
xcodebuild -scheme Pingo -configuration Debug build

# Run all tests (uses iPhone 15 simulator)
xcodebuild test -scheme Pingo -destination 'platform=iOS Simulator,name=iPhone 15'

# Verify Xcode version
xcodebuild -version
```

### Single Test Execution
To run a single test, open the project in Xcode and use the test navigator (⌘+6), or use the diamond icon next to individual test functions in the source editor.

## Architecture

### Layer Responsibilities

1. **NetworkService** (`NetworkService.swift`)
   - Generic HTTP execution layer
   - Protocol: `NetworkServiceProtocol`
   - Handles URLSession calls, status code validation, and JSON decoding
   - Never contains business logic or UI state

2. **Repository** (`FeedRepository.swift`)
   - Data gateway abstraction between networking and business logic
   - Protocol: `FeedRepositoryProtocol`
   - Translates network responses to domain entities
   - Future persistence (Core Data/SQLite) will be added here

3. **UseCase** (`FeedUseCase.swift`)
   - Business logic orchestration
   - Protocol: `FeedUseCaseProtocol`
   - Coordinates repository calls
   - Remains storage-agnostic

4. **ViewModel** (`FeedViewModel.swift`)
   - Presentation state management
   - Always marked `final` and uses `@Observable`
   - Dependencies injected via initializer
   - Exposes collections as `private(set)` read-only properties
   - Marked with `@MainActor` for UI thread safety

5. **Views** (SwiftUI)
   - Pure presentation layer
   - Observes view model state changes
   - No direct network or repository access

### Dependency Injection

The `FeedBuilder.swift` demonstrates the DI pattern used throughout:
- Creates the dependency graph from bottom (NetworkService) to top (View)
- Supports mock injection via `usingMock` parameter for testing
- All production dependencies assembled in `PingoApp.swift`

### Key Files Reference

- `Pingo/FeedViewModel.swift` — View model pattern with DI
- `Pingo/FeedUseCase.swift` — Business logic layer
- `Pingo/FeedRepository.swift` — Data gateway
- `Pingo/NetworkService.swift` — HTTP abstraction
- `Pingo/MockFeedRepository.swift` — Test double for repositories
- `Pingo/FeedBuilder.swift` — DI container example
- `ImageCache/` — Shared image caching utilities

## Testing Strategy

### Test Framework
Uses Swift Testing framework (not XCTest) with the `@Test` macro and `#expect` for assertions.

### Naming Convention
```swift
@Test("Human-readable test description")
func methodName_condition_expectedOutcome() async throws {
    // test implementation
}
```

Example from the codebase:
```swift
@Test("Fetch Characters On Success")
func fetchCharacters_onSuccess() async throws {
    let makeSut = { MockPingoFeedUseCase(result: .success(...)) }
    let viewModel = FeedViewModel(feedUseCase: makeSut())
    await viewModel.loadData()
    #expect(viewModel.characters == expectedResponse)
}
```

### Mock Pattern
See `PingoFeedViewModelTests.swift` for the standard mock pattern:
- Create nested private mock classes that conform to protocols (e.g., `private final class MockPingoFeedUseCase: FeedUseCaseProtocol`)
- Use `Result<Success, Error>` for controllable outcomes
- Mock at the protocol boundary (e.g., `FeedUseCaseProtocol`, not concrete classes)
- Keep mocks private to test files when test-specific using `private extension`

Shared mocks like `MockFeedRepository` live in the main `Pingo/` directory for reuse across test suites.

## Coding Conventions

### Style
- **Indentation:** 4 spaces (no tabs)
- **Trailing newline:** Required
- **Naming:**
  - Types/Protocols: `UpperCamelCase`
  - Members: `lowerCamelCase`
  - Protocols: Suffix with `Protocol` when used as explicit interfaces
- **Type Choices:**
  - `struct` for value models (e.g., `FeedEntity`, `CharacterResponse`)
  - `enum` for error types (e.g., `NetworkError`)
  - `final class` for view models and stateful services

### SwiftUI View Model Pattern
```swift
@MainActor
@Observable
final class FeatureViewModel {
    private let useCase: FeatureUseCaseProtocol
    private(set) var data: [Model] = []

    init(useCase: FeatureUseCaseProtocol) {
        self.useCase = useCase
    }
}
```

## Adding New Features

### Step-by-Step Process

1. **Create feature directory** (optional, for complex features):
   ```
   Pingo/Episode/
   ```

2. **Define layers in order:**
   - Repository protocol and implementation
   - UseCase protocol and implementation
   - ViewModel with `@Observable` and `@MainActor`
   - SwiftUI views

3. **Create corresponding mocks:**
   - Mock repository for use case tests
   - Mock use case for view model tests

4. **Add tests:**
   - Create `PingoTests/FeatureViewModelTests.swift`
   - Create `PingoTests/FeatureUseCaseTests.swift`
   - Create `PingoTests/FeatureRepositoryTests.swift`
   - Follow existing test naming: `@Test("Description")` with `methodName_condition_expectedOutcome()`

5. **Update DI:**
   - Create or update builder if needed
   - Wire into `PingoApp.swift` for production use

### Example: Adding Episode Feature
```swift
// 1. Repository
protocol EpisodeRepositoryProtocol {
    func fetchEpisodes() async throws -> [Episode]
}

// 2. UseCase
protocol EpisodeUseCaseProtocol {
    func loadEpisodes() async throws -> [Episode]
}

// 3. ViewModel
@MainActor
@Observable
final class EpisodeViewModel {
    private let useCase: EpisodeUseCaseProtocol
    private(set) var episodes: [Episode] = []

    init(useCase: EpisodeUseCaseProtocol) {
        self.useCase = useCase
    }
}

// 4. View
struct EpisodeView: View {
    @Bindable var viewModel: EpisodeViewModel

    var body: some View {
        List(viewModel.episodes) { episode in
            Text(episode.name)
        }
    }
}
```

## Common Pitfalls

1. **Changing DI wiring:** Always verify tests still pass when modifying `PingoApp.swift` or builder classes
2. **Breaking layer boundaries:** Never import UIKit/SwiftUI in UseCase or Repository layers
3. **NetworkService changes:** Update corresponding tests in `NetworkServiceTests.swift`
4. **Test simulator mismatch:** CI uses iPhone 15 simulator—match it locally

## API Integration

The app uses the public [Rick and Morty API](https://rickandmortyapi.com/documentation):
- **Base URL:** `https://rickandmortyapi.com/api`
- **No authentication required**
- **Pagination:** Uses `info.pages` and `info.count` in responses
- Ensure simulator has network access for live data

## CI/CD Notes

- CI workflow should run the same commands as local development
- Commands to include:
  ```bash
  xcodebuild -scheme Pingo build
  xcodebuild test -scheme Pingo -destination 'platform=iOS Simulator,name=iPhone 15'
  ```

## Additional Documentation

- **Architecture diagrams:** See README.md for Mermaid sequence diagrams showing data flow
- **Detailed guidelines:** See AGENTS.md for commit style, PR checklist, and repository-wide decisions
- **Copilot instructions:** See .github/copilot-instructions.md for AI-specific coding guidance
