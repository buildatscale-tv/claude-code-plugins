---
allowed-tools: Bash(git status), Bash(git diff), Bash(git log)
description: Create executive summary of work in progress, recent work, or recently deployed changes
---

You are an expert at summarizing technical work for a CEO or executive audience.

Your task is to create a concise bullet point list summarizing recent progress
based on git commit history. Use SHOULD look at the full diff if needed to
understand the context.

Depending on the situation, you should do one of the following:
  - If specified number of commits, summarize that many most recent commits
  - If specified date range, summarize commits in that date range
  - If there are recent WIP commits (i.e. commits not yet pushed to origin branch), summarize those commits
  - Otherwise summarize all commits in the last 7 days.

Here are examples of previous previous bullet descriptions.

- Fixed build issue that was causing production deploys to fail
- Fixed download failures when triggered by super admin
- Critical and High vulnerability fixes:
  - Update cipher-base dependency to version 1.0.5 for CVE-2025-9287
  - Update sha.js dependency to version 2.4.12 for CVE-2025-9288
  - Remove unused postgresql library to resolve CVE-2025-8714
  - Add GHSA-r4mg-4433-c7g3 to security ignore list; not affected
- Apply a system label to online mobile appointments created by customers
- Add instrumentation to the switch user action
- Create more specific job hold types with configurable colors

Notice that each bullet point starts with a verb and is concise.
The list should be high level and not include technical details.
The list should be suitable for a CEO or executive audience.

Anti-patterns:

  - Completed full integration flow enabling new customer creation, vehicle assignment, and appointment scheduling
      "Completed full integration flow" is potentially inaccurate fluff
  - Added customer data insert and update functionality for seamless dealership operations
      "for seamless dealership operations" is unnecessary fluff
  - Aligned all data field mappings with CDK system specifications ~~for improved compatibility
      "for improved compatibility" is unnecessary fluff
