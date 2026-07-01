# Contributing to Lentago Labs

Thanks for your interest. These are the org-wide defaults for every
[Lentago Labs](https://github.com/lentago) repository; an individual repo's own
`CONTRIBUTING.md`, if present, takes precedence.

## What these repos are

Lentago Labs is a one-operator infrastructure practice. Most repos here are
live homelab infrastructure, portfolio/demo platforms, or the tooling that
operates them — not community projects with a roadmap looking for maintainers.
External contributions are welcome, but scope them accordingly: small, focused
changes land easily; large ones need a conversation first.

The code is co-written with [Claude](https://claude.com/claude-code)
(Anthropic): the operator directs the work and owns every merge, Claude writes
most of the code. Each repo discloses this in its README.

## How to contribute

1. **Open an issue first** for anything beyond a typo or doc fix. Work in
   these repos is issue-driven; a PR that arrives with no issue and a large
   diff is hard to review cold.
2. **Fork and branch.** Branch from `main`; keep branches short-lived.
3. **Keep PRs scoped.** One concern per PR. If you notice an adjacent
   problem, file it as its own issue rather than folding it in.
4. **Write a neutral, factual PR body** — what changed and why, for a reader
   months later. Reference the issue (`Closes #N`).
5. **Squash merges only.** The PR body becomes the merge commit message, so
   commit messages on the branch can stay light. Required status checks gate
   the merge.

## Conventions

- **Attribution:** commits authored or co-authored by an AI agent carry a
  `Co-Authored-By:` trailer naming it. Human contributors don't need one.
- **No secrets, ever** — no credentials, tokens, private keys, or LAN
  topology in code, config, tests, or fixtures. See [SECURITY.md](SECURITY.md)
  for reporting anything that slipped through.
- **License:** everything here is MIT unless a repo says otherwise. By
  contributing you agree your contribution is licensed the same way.

## Questions

Open a discussion or issue in the relevant repo, or email
**chris@lentago.dev**.
