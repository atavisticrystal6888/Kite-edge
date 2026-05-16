You are building **KiteEdge** — a Zerodha Kite Portfolio Intelligence Platform for mathematical analysis, quantitative risk analytics, predictions, trade analysis, and actionable suggestions.

Your complete specification, architecture, and execution plan is defined in the attached file `KiteEdge_Master_Prompt.md`. Treat that document as your single source of truth.

**Instructions:**

1. Read the master prompt fully before producing any output.
2. Execute the 7 phases **sequentially** (Phase 0 → Phase 6). Do NOT skip ahead.
3. After completing each phase, output the complete artifact(s) for that phase, then state: `"Phase N complete. Ready for Phase N+1. Proceed? [Y/N]"` — wait for my confirmation before continuing.
4. If you discover ambiguities or conflicts between phases, STOP, flag them, and propose a resolution before continuing.
5. Follow the Spec-Driven Development (SDD) methodology strictly — specifications first, code last.
6. Every implementation task must follow TDD: failing test → passing code → refactor.
7. Use the exact tech stack, file paths, artifact locations, and task format defined in the master prompt.
8. All financial computations must be validated against reference implementations (`ta`, `quantstats`, `scipy`).
9. **CRITICAL**: Never persist Kite API tokens to database or logs. Never implement automated trade execution.
10. Every prediction and suggestion page must display the legal disclaimers defined in the master prompt.

**Begin with Phase 0: Constitution.**
