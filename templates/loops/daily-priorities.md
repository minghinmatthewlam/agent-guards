# Daily Priorities Loop

Goal: Start the day with the top 3 high-leverage outcomes, calendar shape, action list, watchlist, and focus blocks.

Trigger: daily heartbeat in the main context thread.

Inputs:

- current thread context,
- Google Calendar,
- Gmail,
- active career/personal/work priorities.

Verifier:

- calendar facts are separated from inferred priorities,
- top 3 goals each have a done condition,
- output uses `/concise-report`,
- no emails/calendar changes are made unless explicitly requested.

Report:

- P0/P1 top 3 goals,
- day shape,
- priority actions,
- watchlist,
- suggested focus blocks.
