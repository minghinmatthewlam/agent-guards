# xcodebuildmcp Commands

Load this reference when choosing concrete iOS development commands. Confirm current syntax with `xcodebuildmcp --help` or the relevant subcommand help when needed.

## Discovery And Configuration

```bash
xcodebuildmcp simulator discover-projects
xcodebuildmcp simulator list-schemes --project-path ./MyApp.xcodeproj
xcodebuildmcp simulator list
xcodebuildmcp setup
```

Prefer explicit flags:

```text
--scheme MyApp --project-path ./MyApp.xcodeproj --simulator-name "iPhone 17 Pro"
```

## Simulator Loop

```bash
xcodebuildmcp simulator build --scheme MyApp --project-path ./MyApp.xcodeproj
xcodebuildmcp simulator test --scheme MyAppTests --project-path ./MyApp.xcodeproj
xcodebuildmcp simulator build-and-run --scheme MyApp --project-path ./MyApp.xcodeproj
xcodebuildmcp simulator snapshot-ui --simulator-id <UDID>
xcodebuildmcp simulator screenshot --simulator-id <UDID>
```

Build settings and environment:

```bash
xcodebuildmcp simulator show-build-settings --scheme MyApp --project-path ./MyApp.xcodeproj
xcodebuildmcp simulator open
xcodebuildmcp simulator boot --simulator-name "iPhone 17 Pro"
xcodebuildmcp doctor
```

Destructive reset, with explicit approval:

```bash
xcodebuildmcp simulator erase --shutdown-first
```

## Logs

```bash
xcodebuildmcp logging start-simulator-log-capture \
  --simulator-id <UDID> --bundle-id <BUNDLE_ID>
xcodebuildmcp logging stop-simulator-log-capture --session-id <SESSION_ID>
```

## Device

```bash
xcodebuildmcp device list
xcodebuildmcp device build --scheme MyApp --project-path ./MyApp.xcodeproj
xcodebuildmcp device build-and-run --scheme MyApp --project-path ./MyApp.xcodeproj
xcodebuildmcp device install --simulator-id <DEVICE_UDID> --app-path ./build/MyApp.app
xcodebuildmcp device launch --device-id <DEVICE_UDID> --bundle-id <BUNDLE_ID>
xcodebuildmcp device test --scheme MyAppTests --project-path ./MyApp.xcodeproj
```

## Debugging And Packages

```bash
xcodebuildmcp debugging attach --simulator-id <UDID> --bundle-id <BUNDLE_ID>
xcodebuildmcp debugging add-breakpoint --file MyFile.swift --line 42
xcodebuildmcp debugging variables
xcodebuildmcp debugging stack
xcodebuildmcp debugging continue
xcodebuildmcp debugging detach
xcodebuildmcp swift-package build --package-path ./MyPackage
xcodebuildmcp swift-package test --package-path ./MyPackage
```
