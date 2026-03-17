Purpose: fetch UiThub repo context for a GitHub project without cloning.

Inputs
- `$REPO_URL` (required): GitHub URL or `owner/repo` slug.
- `$CONTEXT` (optional): focus areas/questions to guide which files to fetch.

Flow
1. Validate `$REPO_URL`. If missing or invalid, ask the user for a correct value.
2. Normalize to `<owner>/<repo>` and extract any path hints from `$REPO_URL`.
3. Determine the repository’s default branch (e.g., `curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/<owner>/<repo> | jq -r '.default_branch'`). If discovery fails, fall back to `main` but mention the assumption.
4. Fetch structure only:  
   `curl "https://uithub.com/<owner>/<repo>?accept=text/plain&omitFiles=true" > tree.txt`
5. Pull key docs (adjust lines) using the discovered branch:  
   `curl "https://uithub.com/<owner>/<repo>/tree/$BRANCH/README.md?accept=text/plain&plain=1&lines=200" > readme.txt`  
   - Fetch other docs (`CONTRIBUTING.md`, `docs/overview.md`, etc.) when `$CONTEXT` suggests.
   - After each `curl`, check the output (status code, byte size). Retry with `plain=1`, `?path=...`, or `https://raw.githubusercontent.com/<owner>/<repo>/$BRANCH/...` if the response is empty or a 404.
6. Capture code slices guided by `$CONTEXT`:  
   - Start with `curl "https://uithub.com/<owner>/<repo>/tree/$BRANCH/<path>?accept=text/plain&plain=1&lines=200"` for targeted files.  
   - For larger sections, use `curl "https://uithub.com/<owner>/<repo>?accept=text/plain&path=<path>"`, then trim locally.  
   - If UiThub still returns nothing, fall back to `https://raw.githubusercontent.com/<owner>/<repo>/$BRANCH/<path>`.
7. Summarize what each artifact reveals and note gaps needing further UiThub pulls or a full clone, explicitly tying the findings back to `$CONTEXT`.
