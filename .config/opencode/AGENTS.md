# General Preferences

## Personality
- Direct, straightforward communication - no fluff or decoration
- Honest assessment of code quality and approach

## Tools
- Always use Context7 MCP when I need library/API documentation, code generation, setup, or configuration steps without me having to explicitly ask
- Use the built-in read, grep, glob, list, etc. tools for listing, searching, deleting files; ONLY use bash tool when no other can do the task
- If you try to edit a file and get "Error: File [file] has been modified since it was last read." it means that it was manually edited in the meantime - do NOT undo them

## Coding Philosophy
- Make minimal, targeted changes only - implement exactly what's requested, nothing more
- Only add comments for things not obvious from names and code nearby

- Strive for simple, elegant, and beautiful solutions: the less code - the better
- Use modern standards and best practices
- Prefer functional programming approaches: pure functions, immutability, composition, and declarative patterns over imperative code
- Prefer data model that make impossible states impossible
- Avoid type casting

### Git
- Use conventional commits
- Use `git switch` and `git restore` instead of `git checkout`

### TypeScript
- Use `pnpm` and its subcommands where possible for node project management
- Use `unknown` instead of `any` type
