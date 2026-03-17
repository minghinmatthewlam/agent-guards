# Skill Categories

Skills cluster into 9 recurring categories. The best skills fit cleanly into one. Skills that straddle multiple are often trying to do too much and should be split.

## 1. Library & API Reference

Skills that explain how to correctly use a library, CLI, or SDK. Could be internal or external libraries the agent sometimes struggles with. Often include reference code snippets and a gotchas list.

**Signals:** Mentions specific libraries, APIs, SDKs, or CLIs. Contains usage examples, function signatures, or "don't do X, do Y" patterns.

**Examples:** billing-lib usage guide, internal CLI wrapper docs, design system reference

## 2. Product Verification

Skills that describe how to test or verify that code is working. Often paired with external tools (playwright, tmux, simulators, etc.) for doing the verification.

These are extremely high-value — having an engineer spend dedicated time making verification skills excellent pays off across every future agent run.

**Signals:** References test tools, describes verification steps, includes assertions or expected states, mentions recording output for review.

**Examples:** signup flow driver, checkout verifier, CLI TTY testing

## 3. Data Fetching & Analysis

Skills that connect to data and monitoring stacks. May include libraries to fetch data with credentials, dashboard IDs, common query workflows.

**Signals:** References databases, dashboards, event sources, metrics, SQL, or analytics tools.

**Examples:** funnel query helper, cohort comparison, Grafana dashboard lookup

## 4. Business Process & Team Automation

Skills that automate repetitive workflows into one command. Usually fairly simple instructions but may depend on other skills or MCPs. Storing previous results in log files helps the agent stay consistent.

**Signals:** References team tools (Slack, ticket systems, calendars), aggregates data from multiple sources, produces formatted output for humans.

**Examples:** standup post, ticket creation, weekly recap

## 5. Code Scaffolding & Templates

Skills that generate framework boilerplate for specific functions in a codebase. May combine with scripts that can be composed. Especially useful when scaffolding has natural-language requirements that pure code templates can't cover.

**Signals:** Creates new files from templates, references project conventions, sets up boilerplate structure.

**Examples:** new service/workflow scaffolder, migration template, new app creator with auth/logging pre-wired

## 6. Code Quality & Review

Skills that enforce code quality and help review code. Can include deterministic scripts for maximum robustness. Good candidates for running automatically as hooks or in CI.

**Signals:** Reviews diffs, checks for patterns/anti-patterns, spawns review subagents, references style guides.

**Examples:** adversarial review, code style enforcement, testing practice guidelines

## 7. CI/CD & Deployment

Skills that help fetch, push, and deploy code. May reference other skills to collect data.

**Signals:** Interacts with CI systems, monitors PRs, handles deployments, manages branches, resolves merge conflicts.

**Examples:** PR babysitter, deploy with rollback, cherry-pick to prod

## 8. Runbooks

Skills that take a symptom (alert, error, Slack thread) and walk through a multi-tool investigation to produce a structured report.

**Signals:** Starts from a symptom/error, follows investigation steps, queries multiple systems, produces a findings report.

**Examples:** service debugging guide, oncall runner, log correlator

## 9. Infrastructure Operations

Skills that perform routine maintenance and operational procedures, some involving destructive actions that benefit from guardrails.

**Signals:** Manages cloud resources, handles cleanup/maintenance, involves potentially destructive operations, references infrastructure systems.

**Examples:** orphan resource cleanup, dependency management workflow, cost investigation
