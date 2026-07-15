# Repo Verification Loop

Goal: Improve a repo so agents can confidently verify changes without human line-by-line review.

Trigger: manual or scheduled repo-health pass.

Inputs:

- `docs/VERIFY.md`,
- `scripts/self-test.sh`,
- existing test/build scripts,
- recent failed/blocked verification reports.

Verifier:

- at least one default self-test lane exists,
- user-facing surfaces have a browser, app, or Computer Use proof path,
- blocked proof reports name the missing tool/access/setup,
- proof artifact convention is documented.

Report:

- missing proof lanes that materially affect confidence, ordered by priority,
- smallest structural update for each,
- files changed,
- tests/proof run,
- residual risk.
