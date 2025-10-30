# Pingo

![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg) ![iOS 17](https://img.shields.io/badge/iOS-17-blue.svg)

> Replace the placeholder CI badge with your workflow status once configured.

![CI](https://img.shields.io/badge/CI-pending-lightgrey.svg)

Pingo is a SwiftUI application that showcases a Clean Architecture approach for consuming the Rick and Morty API. The project highlights separation between networking, repositories, use cases, and presentation layers.

## Getting Started
- Open the project with `open Pingo.xcodeproj` to explore or run the app in Xcode.
- Run `xcodebuild -scheme Pingo -configuration Debug build` to verify the command-line build.

## Environment Setup
- Requires Xcode 15+ with Swift 5.9 toolchain; confirm via `xcodebuild -version`.
- Use the iOS 17 simulator (e.g., iPhone 15) to mirror CI runs called out in `xcodebuild test`.
- No API key is needed; the project targets the public Rick and Morty API, so ensure the simulator has network access for live data.
- Review the [Rick and Morty API docs](https://rickandmortyapi.com/documentation) for model schemas and query parameters when extending data access.

## Architecture Overview
- Core layers follow Clean Architecture: networking feeds repositories, repositories wrap use cases, and SwiftUI views react via observable view models.
- The diagram below outlines the primary data flow and dependency direction.

```mermaid
flowchart TD
    API[Rick and Morty API]
    NetworkService --> API
    NetworkService --> FeedRepository
    FeedRepository --> FeedUseCase
    FeedUseCase --> FeedViewModel
    FeedViewModel --> SwiftUIViews[SwiftUI Views]
    PingoApp --> SwiftUIViews
```

### Key Flow: Feed Refresh
```mermaid
sequenceDiagram
    participant View as FeedView
    participant VM as FeedViewModel
    participant UseCase as FeedUseCase
    participant Repo as FeedRepository
    participant Net as NetworkService
    participant API as Rick and Morty API
    View->>VM: onAppear()
    VM->>UseCase: loadCharacters()
    UseCase->>Repo: fetchCharacters()
    Repo->>Net: requestCharacters()
    Net->>API: GET /character
    API-->>Net: JSON payload
    Net-->>Repo: [CharacterResponse]
    Repo-->>UseCase: [CharacterEntity]
    UseCase-->>VM: [CharacterResponse]
    VM-->>View: update characters
```

### Key Flow: Character Detail
```mermaid
sequenceDiagram
    participant List as CharacterListView
    participant Detail as CharacterDetailView
    participant VM as CharacterDetailViewModel
    participant UseCase as CharacterDetailUseCase
    participant Repo as CharacterRepository
    participant Net as NetworkService
    participant Cache as LocalStore
    participant API as Rick and Morty API
    List->>Detail: user selects character(id)
    Detail->>VM: onAppear(id)
    VM->>UseCase: loadCharacter(id)
    UseCase->>Cache: cachedCharacter?(id)
    Cache-->>UseCase: optional Character
    alt cache hit
        UseCase-->>VM: cached Character
    else cache miss
        UseCase->>Repo: fetchCharacter(id)
        Repo->>Net: requestCharacter(id)
        Net->>API: GET /character/{id}
        API-->>Net: Character JSON
        Net-->>Repo: CharacterResponse
        Repo-->>UseCase: CharacterEntity
        UseCase->>Cache: persist CharacterEntity
        UseCase-->>VM: CharacterEntity
    end
    VM-->>Detail: render character
```

### Key Flow: Offline Cache Sync
```mermaid
sequenceDiagram
    participant App as PingoApp
    participant Scheduler as SyncScheduler
    participant Repo as FeedRepository
    participant Cache as LocalStore
    participant Net as NetworkService
    participant API as Rick and Morty API
    App->>Scheduler: applicationDidBecomeActive
    Scheduler->>Repo: refreshIfStale()
    Repo->>Cache: lastSyncedAt()
    alt stale data
        Repo->>Net: requestCharacters(page=1)
        Net->>API: GET /character?page=1
        API-->>Net: Character list
        Net-->>Repo: [CharacterResponse]
        Repo->>Cache: upsertCharacters([CharacterResponse])
        Repo-->>Scheduler: sync complete
    else fresh data
        Repo-->>Scheduler: no-op
    end
```

## Feature Roadmap
- **Episode Browser**: Expose an `EpisodeRepository` and SwiftUI list to explore episodes with pagination.
- **Character Detail**: Extend `FeedUseCase` to fetch rich character data, with a dedicated detail view sharing the view model through dependency injection.
- **Offline Cache**: Introduce persistence via Core Data or SQLite, abstracted behind repository protocols to keep use cases storage-agnostic.

## Contributor Guide
For detailed contribution standards, including structure, style, and testing expectations, see [Repository Guidelines](AGENTS.md).

## Continuous Integration
- Plan to publish CI status via a GitHub Actions workflow badge, for example `![CI](https://github.com/<org>/<repo>/actions/workflows/ci.yml/badge.svg)`.
- Ensure the workflow runs `xcodebuild -scheme Pingo build` and `xcodebuild test -scheme Pingo -destination 'platform=iOS Simulator,name=iPhone 15'` to mirror local verification.
