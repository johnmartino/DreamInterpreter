# Repository Guidelines

## Project Structure & Module Organization
`DreamInterpreter` is a SwiftUI iOS app organized as an Xcode project. App entry and root state live in `DreamInterpreter/DreamInterpreterApp.swift`, `ContentView.swift`, and `ContentViewModel.swift`. Feature folders group related code: `AI/` wraps FoundationModels and dream interpretation, `Dreams/` contains interpretation models and dream UI, `Dictation/` handles speech input, `CrystalBall/` contains the Metal visual effect, and `Information/` contains archetype reference data. Assets live in `Assets.xcassets`, `launch.png`, `Launch.storyboard`, `Dreams/Astro-ZLzx.ttf`, and `Information/Archetypes.json`.

## Build, Test, and Development Commands
Open the project in Xcode for day-to-day development:

```bash
open DreamInterpreter.xcodeproj
```

Build from the command line with:

```bash
xcodebuild -project DreamInterpreter.xcodeproj \
  -scheme DreamInterpreter \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build
```

The app depends on Apple Intelligence through `FoundationModels`; AI flows require a supported device or simulator with Apple Intelligence enabled. There is no Swift Package manifest, `Makefile`, or separate CLI tooling.

## Coding Style & Naming Conventions
Use standard Swift formatting with 4-space indentation and concise SwiftUI view composition. Keep feature code in the existing folder boundaries rather than adding broad shared abstractions. Name SwiftUI views with a `View` suffix, observable state types with `ViewModel` or manager-style names, and model records consistently with existing SwiftData types such as `DreamInterpretation`, `DreamRecord`, and `ArchetypeRecord`. Preserve iOS 26 APIs such as `.glassEffect()` and `.buttonStyle(.glassProminent)`; this project does not carry fallback paths for older iOS versions.

## Testing Guidelines
No test target is currently present. Before changing behavior, run the Xcode build above and manually exercise dream entry, dictation, save/delete history, sharing, and the archetype information sheet. When adding tests, create an Xcode test target and use names that mirror the feature under test, for example `DreamEngineTests` or `DreamInfoViewModelTests`.

## Commit & Pull Request Guidelines
Recent commits use short, imperative or descriptive lowercase messages, for example `glowing crystal ball` and `fixed minor model issues`. Keep commits focused on one user-visible or technical change. Pull requests should include a brief summary, manual test notes, linked issues when applicable, and screenshots or screen recordings for visual UI changes.

## Agent-Specific Instructions
Do not overwrite user work. Check current files before editing, keep changes scoped, and update this guide if project commands, targets, or test structure change.
