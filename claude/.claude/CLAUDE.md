# Global instructions

These apply to every session and every project unless a more specific project
instruction overrides them.

## Git

- Do not run `git commit` unless I explicitly tell you to in that message.
  Staging, diffing, and verifying changes is fine at any time; committing is
  not. "Commit that", "go ahead and commit", or similar is the signal.
- Do not run `git push`, open PRs, or do anything that publishes work unless I
  explicitly tell you to.
- When work is ready, stage it and stop. Tell me it is ready to commit and let
  me decide.

## Scratch docs written into a repo

- Any file you create for my benefit rather than the project's - plans, notes,
  investigation write-ups, PR description drafts, migration checklists, ticket
  breakdowns - must be named `tony-doc-<whatever>.md` and left untracked. My
  global gitignore (`~/.config/git/ignore`, symlinked from `~/dotfiles`) has
  `tony-doc-*`, so the prefix is what keeps these out of a commit when I run
  `git add .`.
- This applies wherever the file lands, repo root or a subdirectory.
- It does NOT apply to files the project itself owns: `README.md`, `AGENTS.md`,
  `CLAUDE.md`, `CONTRIBUTING.md`, docs under a committed `docs/` tree, or
  anything already tracked. Never rename or re-prefix a tracked file.
- If you rename existing scratch docs, rewrite the cross-references between them
  in the same pass. They tend to link to each other heavily, and a bare rename
  leaves dead links.

## Dev servers

- Do not start a long-running dev server yourself (`pnpm start`, `pnpm start:*`,
  `ng serve`, `nx serve`, `nx run <app>:serve`, watch-mode builds). I usually
  already have one running, typically on port 4200.
- If you need a running server to verify something, ask me to start it and wait
  for me to confirm it is up. Say what you need it for and which port or route.
- Do not kill or restart a server I am running without asking first, even if it
  looks stale or is serving an old build. Tell me what you observed and let me
  decide.
- Short-lived commands are fine without asking: tests, typechecks, one-shot
  builds, linters, formatters.

## Writing style (all output)

- Never use em-dashes, en-dashes, curly quotes, or any non-ASCII character in
  anything you produce: chat responses, code, comments, commit messages, PR
  descriptions, docs, and planning files. Use a plain hyphen or reword.
- Keep to plain ASCII (0x00 to 0x7F) everywhere.
- Never reference a Figma node, node id, frame name, or Figma URL in descriptive
  prose - code comments, commit messages, PR descriptions, tickets, docs. Nobody
  reading it will go and look the node up, so it costs a line and says nothing.
  Describe what the code or the design does instead. "Matched to the design's own
  offsets" is fine; "matched to Figma 15750-176993" is not. This does not stop you
  reading Figma or discussing it with me in chat. 

## PR descriptions and tickets

- Do not hard-wrap paragraphs or bullets in PR descriptions, Jira tickets,
  GitHub issues, or similar prose. Write each paragraph or bullet as one line
  and let GitHub or Jira handle the wrapping. Blank lines between paragraphs,
  headings, and list items are fine; manual line breaks inside a paragraph are
  not.

## Code comments

- Do not add comments whose purpose is to explain the generated code to me.
  Comments exist only for future maintainers of the codebase and must match the
  surrounding code's conventions and density.
- If there is extra context I should understand about the code you generated,
  put it in your response to me after the code, not in a comment.
- The test for keeping one: would a maintainer break something without it? If
  so, state the constraint, ideally as an instruction ("do not add a flush
  between these two lines"). Otherwise delete it. A comment that is merely true
  is not worth its line.
- Specific smells I keep having to strip out afterwards, all variants of writing
  for the diff rather than the file:
  - **Arguing a choice against the alternative** - "`concatMap`, not
    `mergeMap`, because...". The reader never saw the alternative and does not
    need it argued away. Say what the code guarantees, or say nothing.
  - **Documenting a review response** - a comment that exists because a
    reviewer asked for the change, or that explains why I declined their
    suggestion. That belongs in the PR thread.
  - **Pre-empting a reviewer** - a comment written to win an argument I expect
    to have. It justifies the choice instead of describing the code, and the
    PR thread is where it belongs. Describing this smell has not been enough to
    stop me writing it, so treat it as a procedure instead: **when a change is
    a response to review findings, write it with zero comments, then re-read
    the diff and add back only what a maintainer would break something
    without.** Test names and assertions usually carry the explanation
    already.
  - **Restating the code** - the name, the type, or the literal data already
    says it. Especially bad on small classes and on test-fixture constants.
  - **Defending a shape against a design that was never built**, or noting what
    is "deliberately absent".
  - **Planning-doc voice** - ticket numbers, "explicit backend ask", "before
    4.1". Describe the code, not the project.
- Trimming is not the same as deleting. Where a real constraint is buried in
  four lines of rationale, keep the constraint and cut the rationale.