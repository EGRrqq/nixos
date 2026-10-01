# talkin

Source of truth for this project. If chat context is lost or something gets
misunderstood, read these files first and trust them over recollection.

## Files

- `context.md` - the machine, the repos, the decisions behind them
- `history.md` - what was done, with commits and why
- `todos.md` - current task list, what is next and what is blocked
- `ai-models.md` - the local AI task, raw requirements as the user wrote them

## How to keep this working

- Update `todos.md` when the plan changes, not only when something gets done
- Write down decisions and the reasoning, not just the result. Later sessions
  need to know why something is the way it is
- Record hardware facts only when they were verified with a command, and say
  how they were verified
- No em dashes, no long dashes, no AI-ish filler. Plain sentences, like a
  person would write for themselves
- Secrets never go in these files. Credentials stay in `rclone config` and the
  user's own password manager
