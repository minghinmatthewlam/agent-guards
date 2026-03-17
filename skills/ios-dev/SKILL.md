---
name: ios-dev
description: "Develop iOS apps with a fast simulator-first loop using the xcodebuildmcp CLI: discover project/schemes, build/test/run, capture logs, and triage failures. Use when: (1) normal iOS development, (2) simulator/device build issues, (3) runtime crashes or UI issues, (4) iterative fix/verify loops."
---

# iOS Dev

## Goal
Use one skill for day-to-day iOS development and debugging with a single streamlined workflow.

## Tooling
`xcodebuildmcp` CLI (installed via Homebrew, zero idle cost — no persistent process).

All commands follow the pattern: `xcodebuildmcp <workflow> <tool> [--flags]`

## Inputs
- Repo root path
- `.xcodeproj` or `.xcworkspace`
- Scheme
- Simulator name or UDID
- Optional device UDID for on-device work

## 0) Discovery (always first)
```bash
xcodebuildmcp simulator discover-projects
xcodebuildmcp simulator list-schemes --project-path ./MyApp.xcodeproj
xcodebuildmcp simulator list
```

## 1) Configuration
The CLI reads `.xcodebuildmcp/config.yaml` if present. Create one with:
```bash
xcodebuildmcp setup
```

Or pass explicit flags on every call (recommended for agents — no hidden state):
```
--scheme MyApp --project-path ./MyApp.xcodeproj --simulator-name "iPhone 17 Pro"
```

## 2) Core simulator dev loop
```bash
# Build only
xcodebuildmcp simulator build --scheme MyApp --project-path ./MyApp.xcodeproj

# Run tests
xcodebuildmcp simulator test --scheme MyAppTests --project-path ./MyApp.xcodeproj

# Build + install + launch (single step)
xcodebuildmcp simulator build-and-run --scheme MyApp --project-path ./MyApp.xcodeproj
```

Useful adjuncts:
```bash
xcodebuildmcp simulator snapshot-ui --simulator-id <UDID>
xcodebuildmcp simulator screenshot --simulator-id <UDID>
xcodebuildmcp simulator stop --simulator-id <UDID>
```

## 3) Failure triage loop
### Build or test failures
1. Get settings and verify scheme/config:
```bash
xcodebuildmcp simulator show-build-settings --scheme MyApp --project-path ./MyApp.xcodeproj
```
2. Clean and rebuild:
```bash
xcodebuildmcp simulator clean --platform "iOS Simulator"
xcodebuildmcp simulator build --scheme MyApp --project-path ./MyApp.xcodeproj
```
3. Re-run focused tests after fixing.

### Runtime crash or behavior issues
1. Start simulator log capture:
```bash
xcodebuildmcp logging start-simulator-log-capture --simulator-id <UDID> --bundle-id <BUNDLE_ID>
```
2. Reproduce in app.
3. Stop capture and inspect output:
```bash
xcodebuildmcp logging stop-simulator-log-capture --session-id <SESSION_ID>
```
4. Capture UI evidence:
```bash
xcodebuildmcp simulator snapshot-ui --simulator-id <UDID>
xcodebuildmcp simulator screenshot --simulator-id <UDID>
```

### Simulator state problems
- Boot/open simulator:
```bash
xcodebuildmcp simulator open
xcodebuildmcp simulator boot --simulator-name "iPhone 17 Pro"
```
- Reset only with user approval (destructive to simulator contents):
```bash
xcodebuildmcp simulator erase --shutdown-first
```

## 4) Device builds
Device workflow tools are available via the `device` workflow group:
```bash
xcodebuildmcp device build --scheme MyApp --project-path ./MyApp.xcodeproj
xcodebuildmcp device build-and-run --scheme MyApp --project-path ./MyApp.xcodeproj
xcodebuildmcp device install --simulator-id <DEVICE_UDID> --app-path ./build/MyApp.app
xcodebuildmcp device launch --device-id <DEVICE_UDID> --bundle-id <BUNDLE_ID>
xcodebuildmcp device test --scheme MyAppTests --project-path ./MyApp.xcodeproj
```

List connected devices:
```bash
xcodebuildmcp device list
```

## 5) Other useful commands
```bash
# LLDB debugging
xcodebuildmcp debugging attach --simulator-id <UDID> --bundle-id <BUNDLE_ID>
xcodebuildmcp debugging add-breakpoint --file MyFile.swift --line 42
xcodebuildmcp debugging variables
xcodebuildmcp debugging stack
xcodebuildmcp debugging continue
xcodebuildmcp debugging detach

# Swift packages
xcodebuildmcp swift-package build --package-path ./MyPackage
xcodebuildmcp swift-package test --package-path ./MyPackage
xcodebuildmcp swift-package run --package-path ./MyPackage --target MyTarget

# Diagnostics
xcodebuildmcp doctor
xcodebuildmcp daemon status
```

## 6) Output contract for each iteration
Always report:
- failing command and its exit code/output
- error class (`build`, `test`, `runtime`, `simulator`, `signing`)
- key log lines proving root cause
- exact fix applied
- verification command(s) and outcome

## Guardrails
- Prefer simulator-first for speed unless device-specific behavior is required.
- Ask before destructive cleanup (`erase`) or actions that remove user data.
- Keep loops short: fix one failure class, re-run, then continue.
- Each CLI command is independent — no session state to manage.
