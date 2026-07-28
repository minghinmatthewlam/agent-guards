---
name: ios-dev
description: "Develop and debug iOS apps with the xcodebuildmcp CLI using simulator-first build, test, run, log, UI-inspection, and device workflows. Use for ordinary iOS development, build or test failures, runtime crashes, simulator problems, and iterative fix/verify work."
---

# iOS Development

Use `xcodebuildmcp` for a fast simulator-first development loop. Prefer explicit project, scheme, and simulator flags so agent runs do not depend on hidden configuration.

Read `references/commands.md` when selecting exact discovery, simulator, device, logging, debugging, or Swift package commands.

## Workflow

1. Discover the project or workspace, schemes, and available simulators.
2. Establish the smallest failing build, test, launch, or interaction.
3. Fix one failure class at a time.
4. Re-run the focused command.
5. For runtime or UI behavior, reproduce in the running app and capture logs plus visible evidence.
6. Run broader relevant tests after the focused path passes.

Use simulator-first unless hardware, signing, sensors, performance, or another device-specific contract requires a physical device.

## Failure Triage

- **Build/test:** verify project, scheme, destination, configuration, and build settings before cleaning.
- **Runtime:** start focused log capture, reproduce, stop capture, and inspect the resulting logs.
- **UI:** inspect the accessibility snapshot and capture a screenshot or recording of the real interaction.
- **Simulator state:** verify boot and app state before considering reset.
- **Device:** confirm the exact device identifier and signing prerequisites.

Run `xcodebuildmcp doctor` when command availability or environment health is unclear.

## Gotchas

- Cleaning is not a diagnosis; first capture the original failure.
- Simulator success does not prove device-only behavior.
- Build success does not prove launch or UI behavior.
- Ask before erasing a simulator or removing user data.
- Tool output and screenshots should identify the simulator/device and app state being proven.
- Verify current CLI help when a command or flag is rejected; tool interfaces can drift.

## Closeout

Report the failing surface, root cause evidence, change made, exact verification commands or interaction, resulting state, and any device-only or signing risk that remains.
