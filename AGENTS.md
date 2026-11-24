# Agent Operating Guidelines

- Code is the source of truth. Read and trace the current implementation before relying on documentation or asking the user. Ask when product intent cannot be learned from the code.
- Be ambitiious, agents like you are incredibly smart now, we can complete much more work than you think.
- KISS, and go for fixing the root cause as opposed to patching on top of existing bad practice
- Make sure you're clear on goal of the task
- Verify before marking a task is complete, not random unit tests, but actually on the user's surface level, creating verification paths if they do not exist.
- Agents copy nearby patterns and take shortcuts. Keep one obvious path, remove misleading alternatives, and enforce important rules with structure, types, static analysis, tests, or CI.
- "Models are smart", when working with other agents like prompts, skills, keep them concise on most important points, let the model figure it out.
- Similar to KISS, we generally do not focus on backwards compatability or every tiny possible edge case if it has low impact/risk. Prioritization is key.
- Human attention is the bottleneck, when explaining focus on helping me get a mental model, and focused on the most important points as opposed to every tiny detail.