# codex-remote-control Review Focus

Review as a LAN-exposed remote-control and Realtime voice prototype.

- Treat token URLs, demo routes, static assets, SSE, SDP exchange, and WebRTC endpoints as trust boundaries.
- Check that unauthenticated demo surfaces cannot expose control, local paths, secrets, session state, or command capability.
- Watch for stale retained notifications satisfying future waits, especially SDP, error, and closed events.
- Realtime model names and API contracts can drift; enable web search or check official docs when the finding depends on current OpenAI behavior.
- Balance prototype framing with concrete risk: report exploitable or user-visible issues, not generic "network is dangerous" claims.
