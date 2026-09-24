# Repository constraints for agent-driven development

Research conducted September 17, 2026 (EDT), with six parallel source investigations. This is a recommendation, not an implementation or certification of any project's development process.

The strongest transferable pattern is: make the intended implementation easy, make important violations executable failures, and prevent the candidate change from deciding whether its own evidence is sufficient. Add autonomous orchestration after those contracts work.

## Starting point and evidence standard

[Ibrahim Ahmed's September 14 tweet](https://x.com/atbeme/status/2099547764505915402) advocates linters, compilers, type checkers, formatters, and a strong product test bed. It quotes [Guillermo Rauch's post](https://x.com/rauchg/status/2099540886409695346) about shadcn/lint and verifiers plus skills. The exact text was retrieved through X's public syndication endpoint after the normal page returned 403.

This matches the current [agent philosophy](../agent-philosophy.md) and [repo-setup skill](../../skills/repo-setup/SKILL.md): remove misleading paths; prefer structure, types and executable constraints; prove a guard rejects a realistic violation. Earlier context additionally prioritized actual user journeys over convenient settings smoke tests and assessing whether guidance helped before adding more.

Evidence is separated into:

- **Source:** implementation and workflow wiring inspected at pinned commits.
- **Executed:** selected lightweight checks or negative fixtures actually run during this research.
- **Deployment:** public branch rules or workflow history inspected, where stated.
- **Reported/design:** maintainer articles, prompts or specifications, without public executable proof of the full claim.

No full upstream builds, paid model evaluations, product GUI sessions, or remote workflows were run. Most findings establish mechanisms, not their measured effect on engineering quality. These are strong candidates, not an exhaustive ranking of the open-source frontier.

## Best references and what to copy

### OpenAI Codex: architecture rules and a real merge gate

Snapshot: `openai/codex@5492c2b06e9d3e1c09cf65e5923930a6b57b4e9e`.

- [TUI boundary check](https://github.com/openai/codex/blob/5492c2b06e9d3e1c09cf65e5923930a6b57b4e9e/.github/scripts/verify_tui_core_boundary.py): rejects direct TUI dependencies/imports of core and points developers toward the app-server interface.
- [Workspace manifest check](https://github.com/openai/codex/blob/5492c2b06e9d3e1c09cf65e5923930a6b57b4e9e/.github/scripts/verify_cargo_workspace_manifests.py) and [Cargo/Bazel lint parity](https://github.com/openai/codex/blob/5492c2b06e9d3e1c09cf65e5923930a6b57b4e9e/.github/scripts/verify_bazel_clippy_lints.py): stop new crates/build paths from silently escaping shared policy.
- [Semantic Clippy restrictions](https://github.com/openai/codex/blob/5492c2b06e9d3e1c09cf65e5923930a6b57b4e9e/codex-rs/clippy.toml): ban selected raw database APIs in favor of the canonical state wrapper, plus other reliability constraints.
- [Blocking CI](https://github.com/openai/codex/blob/5492c2b06e9d3e1c09cf65e5923930a6b57b4e9e/.github/workflows/blocking-ci.yml) aggregates seven workflow families into one `CI required` result. Its [result checker](https://github.com/openai/codex/blob/5492c2b06e9d3e1c09cf65e5923930a6b57b4e9e/.github/scripts/check_ci_results.py) rejects failed, skipped and cancelled dependencies.

The [active public ruleset](https://api.github.com/repos/openai/codex/rulesets/6735016) actually requires `CI required`, CLA and review/code-owner requirements. Up-to-date branches and dismissal of stale approvals were not enabled in the returned configuration; bypass actors were not established.

Executed: boundary and lint-parity checks passed; fan-in fixtures accepted success and rejected failure/skip/cancellation. A negative fixture exposed a boundary-check weakness: a Cargo alias for `codex-core` escaped detection. The manifest check also failed on a stale feature exception at the inspected HEAD. These are reasons to test guards themselves and resolve package identities, not merely match import spellings.

The [Codex issue labeler](https://github.com/openai/codex/blob/5492c2b06e9d3e1c09cf65e5923930a6b57b4e9e/.github/workflows/issue-labeler.yml) provides a separate AI pattern: read-only model inference produces structured output; a different job has write authority. This is AI-assisted operations, not evidence of autonomous production delivery.

### Deep Agents, LangChain and LangGraph: enforce and test policy

Snapshots: Deep Agents `dc2c8e7f788de04322f701774447a3764d794ca4`; LangChain `3ecff312901725b6b81529eabc778d3d7dd46666`; LangGraph `448a76377956534a85a56b7c2d8aed0e55d9ee44`.

- Deep Agents [tests the actual CI workflow](https://github.com/langchain-ai/deepagents/blob/dc2c8e7f788de04322f701774447a3764d794ca4/.github/scripts/tests/workflows/test_ci_workflow.py), including conditions and shell execution with stubbed commands. Checking for a string would miss changes to Boolean logic; these tests exercise behavior.
- Its [Markdown policy workflow](https://github.com/langchain-ai/deepagents/blob/dc2c8e7f788de04322f701774447a3764d794ca4/.github/workflows/markdown_file_check.yml) loads the detector from the trusted base SHA, preventing a PR from changing that detector to judge itself. Candidate content is data; privileged jobs must not execute candidate code.
- LangGraph's [AST checker](https://github.com/langchain-ai/langgraph/blob/448a76377956534a85a56b7c2d8aed0e55d9ee44/.github/scripts/check_sdk_methods.py) verifies sync/async method-name parity; its CI also checks generated schemas. The parity checker passed when executed here. It does not establish signature or semantic equivalence.
- LangChain's [async blocking-I/O fixture](https://github.com/langchain-ai/langchain/blob/3ecff312901725b6b81529eabc778d3d7dd46666/libs/core/tests/unit_tests/conftest.py) and [canary test](https://github.com/langchain-ai/langchain/blob/3ecff312901725b6b81529eabc778d3d7dd46666/libs/core/tests/unit_tests/test_setup.py) make a runtime architecture rule testable. Its [shared adapter tests](https://github.com/langchain-ai/langchain/blob/3ecff312901725b6b81529eabc778d3d7dd46666/libs/standard-tests/README.md) let implementations inherit a common behavioral contract.

Deep Agents also has a [scheduled documentation agent](https://github.com/langchain-ai/deepagents/blob/dc2c8e7f788de04322f701774447a3764d794ca4/.github/workflows/openwiki-update.yml) with constrained committed paths. However, its [behavioral eval workflow](https://github.com/langchain-ai/deepagents/blob/dc2c8e7f788de04322f701774447a3764d794ca4/.github/workflows/evals.yml) is manually dispatched, and AI failure analysis is advisory. Branch protection was not verified.

### Prime Agent: test shortcuts and independent behavioral acceptance

Snapshot: `PrimeIntellect-ai/prime-agent@126fe7010855379f774eddf82d57bcc7d15dd702`.

Its [test policy scanner](https://github.com/PrimeIntellect-ai/prime-agent/blob/126fe7010855379f774eddf82d57bcc7d15dd702/scripts/check-test-policy.mjs) ratchets against newly introduced disabled tests, retries, sleeps, environment-gated early exits, optional/vacuous assertions and fixed ports. Failures give repair advice. This directly addresses the shortcut of making the suite greener by weakening what it checks.

The [behavioral evaluation workflow](https://github.com/PrimeIntellect-ai/prime-agent/blob/126fe7010855379f774eddf82d57bcc7d15dd702/.github/workflows/behavioral-evals.yml) separates trusted evaluation from exact base/head builds in isolated sandboxes. A gold-patch oracle runs first. Results are checked against current head/base identities and invalidated when either changes. The [separate verifier](https://github.com/PrimeIntellect-ai/prime-agent/blob/126fe7010855379f774eddf82d57bcc7d15dd702/scripts/evals/short_swe/secure_harbor.py) prevents treating the candidate's own test report as the grader.

Deployment caveat: [public effective branch rules](https://api.github.com/repos/PrimeIntellect-ai/prime-agent/rules/branches/main) exposed no required-status-check rule; classic protection could not be read. Among the latest 100 inspected Behavioral Eval runs, 81 were skipped and 19 successful runs were push-triggered invalidations, not completed evaluations. Therefore this is a strong implementation reference, not verified operational merge enforcement.

The [thresholds](https://github.com/PrimeIntellect-ai/prime-agent/blob/126fe7010855379f774eddf82d57bcc7d15dd702/scripts/evals/short_swe/report.py) detect large regressions on 28 tasks with one rollout per side, not statistical equivalence. Do not copy the scanner's test-line/source-line ratio restriction: it can penalize a small fix with valuable regression coverage and encourage source padding.

Adjacent [Verifiers CI](https://github.com/PrimeIntellect-ai/verifiers/blob/fc9c8eddb7f0523fed50c4527098a2f4d3c88254/.github/workflows/test.yml) separates deterministic and conditional live lanes. [Prime-envs smoke tests](https://github.com/PrimeIntellect-ai/prime-envs/blob/a6fc0c66f8b2c2a278334bc768b1204937e45cff/tests/test_envs.py) install tasksets in clean virtual environments and exercise the CLI, but credential skips and completion-only assertions limit what a pass proves.

### Pi and OMP: dependency constraints and actual distribution tests

Canonical Pi is now `earendil-works/pi` (the old `badlogic/pi-mono` redirects); inspected commit `46c9de402bddf46b03c3b9f46487b777aaa41861`. OMP is `can1357/oh-my-pi@62a4aa98a4b52f829a3ae9a5247ca8db4e5f810c`.

Pi's [entry graph checker](https://github.com/earendil-works/pi/blob/46c9de402bddf46b03c3b9f46487b777aaa41861/scripts/check-entry-graphs.mjs) caps reachable files and forbids dependencies from narrow package exports. It passed during this research. The checker is regex-based, so copy the architectural intent while improving resolution for aliases and re-exports where necessary. Its [runtime dependency checker](https://github.com/earendil-works/pi/blob/46c9de402bddf46b03c3b9f46487b777aaa41861/scripts/check-runtime-deps.mjs) uses the TypeScript AST; [browser smoke](https://github.com/earendil-works/pi/blob/46c9de402bddf46b03c3b9f46487b777aaa41861/scripts/check-browser-smoke.mjs) inspects bundle metadata for unwanted providers, not browser interaction.

OMP's [installation suite](https://github.com/can1357/oh-my-pi/blob/62a4aa98a4b52f829a3ae9a5247ca8db4e5f810c/scripts/install-tests/run-ci.sh) tests binary, source and tarball installs in clean user directories, reproducing native optional-package topology. Its [session fixture](https://github.com/can1357/oh-my-pi/blob/62a4aa98a4b52f829a3ae9a5247ca8db4e5f810c/scripts/install-tests/settings-session.ts) tests two isolated sessions against a controlled provider. The [CI workflow](https://github.com/can1357/oh-my-pi/blob/62a4aa98a4b52f829a3ae9a5247ca8db4e5f810c/.github/workflows/ci.yml) gates release, but deliberately skips Rust validation on PRs and uses released native addons there. Native changes need later validation.

Pi's [issue-analysis workflow](https://github.com/earendil-works/pi/blob/46c9de402bddf46b03c3b9f46487b777aaa41861/.github/workflows/issue-analysis.yml) runs authorized investigations on selected operating systems and preserves resumable agent transcripts. OMP's [fix-issues instructions](https://github.com/can1357/oh-my-pi/blob/62a4aa98a4b52f829a3ae9a5247ca8db4e5f810c/.omp/commands/fix-issues.md) require reproduction and separate worktrees, but remain instructions rather than independent acceptance enforcement.

### shadcn/lint: make the correct repair easy, then evaluate shortcut resistance

Snapshot: `shadcn-ui/lint@bf89dcb7f66a306c7ac4943065298902afdbd969`. This is the concrete project behind the quoted tweet.

The [no-restyle rule](https://github.com/shadcn-ui/lint/blob/bf89dcb7f66a306c7ac4943065298902afdbd969/packages/lint/src/rules/no-restyle.ts#L31) gives repair advice grounded in existing component APIs: use the appropriate variant, size prop or layout owner. Its source explicitly avoids suggesting that the agent change the policy to fix the violation. [Unreadable dynamic classes](https://github.com/shadcn-ui/lint/blob/bf89dcb7f66a306c7ac4943065298902afdbd969/packages/lint/src/rules/require-static-classes.ts) on recognized components are themselves violations; inability to analyze is not a clean bill of health.

The [corpus check](https://github.com/shadcn-ui/lint/blob/bf89dcb7f66a306c7ac4943065298902afdbd969/packages/evals/scripts/check-corpus.mjs) ratchets per-rule counts against a pinned corpus and fails on empty input or parser errors. The [evaluation methodology](https://github.com/shadcn-ui/lint/blob/bf89dcb7f66a306c7ac4943065298902afdbd969/docs/evals.md) includes tasks that invite shortcuts, neutral tasks, sequential drift and rules-only controls. Independent lint/typechecking of generated results helps distinguish agent claims from observed compliance. These tools are present; reported performance was not reproduced here.

The [documented limits](https://github.com/shadcn-ui/lint/blob/bf89dcb7f66a306c7ac4943065298902afdbd969/docs/how-it-works.md) include CSS and configuration escape routes. Baselines can be updated. Zero findings is therefore neither proof of visual correctness nor proof that the agent complied with the intended architecture. Evaluate task fulfillment separately and protect baseline changes.

### Symphony: orchestrate work after acceptance is reliable

Snapshot: `openai/symphony@be10a1b79df723d6d7612b5651c8522704dafb2e`. Unlike the inspected official Attractor repository, this includes an executable Elixir implementation.

Its [workflow store](https://github.com/openai/symphony/blob/be10a1b79df723d6d7612b5651c8522704dafb2e/elixir/lib/symphony_elixir/workflow_store.ex) supports validated reload with the last good configuration; work runs in issue-specific workspaces. [One Makefile path](https://github.com/openai/symphony/blob/be10a1b79df723d6d7612b5651c8522704dafb2e/elixir/Makefile) collects verification used by CI, including an [AST spec checker](https://github.com/openai/symphony/blob/be10a1b79df723d6d7612b5651c8522704dafb2e/elixir/lib/symphony_elixir/specs_check.ex).

Its [PR body validator](https://github.com/openai/symphony/blob/be10a1b79df723d6d7612b5651c8522704dafb2e/elixir/lib/mix/tasks/pr_body.check.ex) validates structure, not evidence truth; unchecked checkboxes are accepted. Most importantly, [after_run hook failures are ignored](https://github.com/openai/symphony/blob/be10a1b79df723d6d7612b5651c8522704dafb2e/elixir/lib/symphony_elixir/workspace.ex#L234). Putting a mandatory test there would not make it a reliable acceptance gate. Human-review/merge instructions in WORKFLOW must be distinguished from independently enforced transition rules.

### GitHub Agentic Workflows and OpenHands: bounded AI operations and evidence

GitHub Agentic Workflows snapshot `6db2a82dc5a06df7bf4adc320fe5e75f1fedf676`: the [architecture guardian](https://github.com/github/gh-aw/blob/6db2a82dc5a06df7bf4adc320fe5e75f1fedf676/.github/workflows/architecture-guardian.md) collects deterministic metrics, then uses an agent to interpret them. Its [compiled workflow](https://github.com/github/gh-aw/blob/6db2a82dc5a06df7bf4adc320fe5e75f1fedf676/.github/workflows/architecture-guardian.lock.yml#L2243-L2258) separates inference/detection from a narrowly authorized output job. It is a scheduled reporter, not a pre-merge architecture gate. Calling a finding a blocker does not make it one.

OpenHands snapshot `32a96a19de59ebe2020a507ba3817685758eeb9a`: its [trusted-base PR validator](https://github.com/OpenHands/OpenHands/blob/32a96a19de59ebe2020a507ba3817685758eeb9a/.github/workflows/pr-description-check.yml) requires contribution metadata, issue readiness and relevant evidence. A claimed human section or video link does not authenticate who tested what. Its [mock-model product E2E workflow](https://github.com/OpenHands/OpenHands/blob/32a96a19de59ebe2020a507ba3817685758eeb9a/.github/workflows/mock-llm-e2e.yml) exercises the browser and propagates failures; [live E2E](https://github.com/OpenHands/OpenHands/blob/32a96a19de59ebe2020a507ba3817685758eeb9a/.github/workflows/ci.yml#L239-L278) has credential/fork conditions. Copy deterministic product journeys plus separately identified live coverage.

### StrongDM: useful factory design, limited public implementation evidence

The official [Attractor repository](https://github.com/strongdm/attractor/tree/fb57a55ed97372a27ac90102f436947e29f48426) contains natural-language specifications, not an executable implementation or CI. The [goal-gate specification](https://github.com/strongdm/attractor/blob/fb57a55ed97372a27ac90102f436947e29f48426/attractor-spec.md#L459-L482) describes bounded execution and acceptance before exit. The [factory narrative](https://factory.strongdm.ai/) motivates scenarios outside agent-editable tests. Copy independent behavioral acceptance where warranted; do not present the public spec as proof of the claimed factory's operation.

OpenAI's [harness-engineering article](https://openai.com/index/harness-engineering/) likewise describes an internal product, not necessarily controls present in openai/codex. Its actionable ideas are explicit dependency layers, actionable lint errors, per-worktree product/observability access, and small recurring cleanup changes. These remain reported practice unless separately established in public code.

## Our current position

Inspected the local working tree, including existing uncommitted user changes, without changing operating rules or application code.

- **agent-guards:** [CI](../../.github/workflows/validate-skills.yml) invokes [skill metadata validation](../../scripts/validate-skills.sh). It checks YAML, required fields and duplicate names. It passed for 12 skills. It does not evaluate skill behavior, sync behavior or bootstrap outcomes. [new-repo.sh](../../scripts/new-repo.sh) creates a verification scaffold but no CI workflow. The [self-test template](../../templates/self-test.sh) fails when no lane exists, but runs whichever lint/test/build scripts happen to exist; a passing result does not promise product coverage.
- **pi-gui:** current CI already includes types, driver tests, real Electron core tests, Linux package installation/proof and Windows packaging. Its verification skill explicitly separates real-provider conversation proof from supporting smoke and native/package coverage. Extend these assets rather than build another harness. This inspection did not execute those journeys or verify remote required-check settings.
- **computer-use-mcp:** hosted macOS CI explicitly limits itself to a non-GUI preflight; style checking is advisory. A native GUI/TCC proof is a different capability and must remain explicitly required or blocked for changes that need it.
- **openbench:** offline CI already validates task checkers against unsolved workspaces and golden solutions. Extend that pattern with adversarial shortcut controls and trusted evaluator provenance rather than adding another generic test runner.

## Proposed adoption, in order

| Priority | Change | First target | Observable acceptance |
|---|---|---|---|
| 1 | One explicit verification entrypoint and fail-closed CI aggregate | agent-guards bootstrap, then pi-gui | Missing, failed or cancelled required lane prevents acceptance; an explicitly irrelevant lane is represented as not required, not a silently skipped success |
| 1 | Test the guards with representative violations | Each new constraint | A prohibited import, vacuous assertion, missing artifact and altered condition fail; valid examples pass |
| 1 | Protect the grading policy | Required checks and test selection | Candidate cannot weaken its own required detector; trusted job treats candidate as data and has no unnecessary write authority |
| 2 | Resolve architecture boundaries and enforce canonical APIs | pi-gui renderer/driver/persistence boundaries | Direct forbidden import, alias and re-export fixtures all fail with a valid replacement path |
| 2 | Common backend/adapter conformance suites | session drivers and computer-use backends | Every implementation registers and passes shared semantics, including cancellation/isolation/error contracts |
| 2 | Bind product proof to the actual candidate | Existing pi-gui proof outputs | A report for another commit/profile/artifact is rejected; settings smoke cannot satisfy a conversation requirement |
| 3 | Small real-agent regression set | agent-guards skill changes and agent harness changes | Neutral and shortcut-inviting tasks are graded by external file/state assertions; pass/fail/blocked and cost are retained |
| 3 | Bounded automated maintenance | Repeated measured failure classes | Agent submits focused proposed changes; same independent gates apply; ineffective or noisy rules can be removed |

This sequence is a design recommendation, not authorization to alter every repository. Start with a small pilot and calibrate against actual failures. Do not copy rigid file-count budgets, test/source line ratios, or opaque LLM merge judgments wholesale.

### Concrete pilot: prevent a misleading pi-gui conversation pass

Use the existing conversation proof. Define its acceptance as send, observed streaming, thread switching, draft preservation and restart with the same isolated profile. Keep fixture-based UI checks and real-provider integration checks separately named.

The runner should emit a machine-produced record containing candidate revision (and dirty-tree identity when local), evaluator revision, scenario/version, artifact identity, environment and provider mode, required checkpoint outcomes, process exit status and evidence locations. CI should bind that record to its actual producer/run; an agent-authored JSON file or hash alone is not proof.

A policy checker then refuses a settings-only report, a stale revision, incomplete checkpoints, missing artifacts, an unavailable required provider, or an interrupted run. A clean pass on the prescribed lane succeeds. Product or coverage requirements can change in a separately reviewed policy change; agents should not be encouraged to weaken the checker to finish the current task.

For costly or desktop-dependent lanes, explicitly choose whether they block every PR, only affected changes, or release promotion. Do not silently convert unavailable infrastructure into a product pass. Test path-selection logic and widen coverage when the selector itself changes.

### Concrete pilot: make agent-guards prove its own operations

Keep the existing metadata validator. Add focused temporary-directory tests for sync pruning (only managed files), name collisions, complete skill support-file copying and bootstrap outputs. Execute the generated verification script in sample projects and prove its required-lane semantics. Run the same canonical command locally and in CI.

Initially enforce only a handful of observed failure classes. Use precise exceptions with owners/reasons and a check that removes stale exceptions. A local pre-commit hook is feedback, not the final authority; verify the remote required-check configuration too.

## What success would mean

Measure recurrence of the original mistakes, missed regressions, guard false positives, retries, CI latency/cost and human review effort. Agent throughput or a growing number of rules is not sufficient evidence of improvement.

The desired factory loop is: task acceptance criteria → isolated candidate → fast structural checks → product proof → independent evidence validation → review/promotion → measured feedback. The model can implement and repair; the repository makes the obligations observable and the promotion policy enforces them.
