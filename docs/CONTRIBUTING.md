# Contributing

All contributes are always welcome.
That said, we require some guidelines to be followed, in order for PRs to be merged.

> The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
> NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and
> "OPTIONAL" in this document are to be interpreted as described in
> RFC 2119.

## Before Contributing

- For **bugfixes** only, you MUST open a new [**issue**](https://github.com/sbertix/Swiftagram/issues), if one on the topic does not exist already, before submitting your pull request.
   - You SHOULD rely on provided issue templates.
- For **enhancements** only, you SHOULD open a new [**discussion**](https://github.com/sbertix/Swiftagram/discussions), if one on the topic does not exist already, before submitting your pull request.
   - Discussions for small additive implementations are OPTIONAL.
   - Discussions for breaking changes are REQUIRED.
   - Wait for feedback before embarking on time-consuming projects.
   - Understand that consistency _always_ comes first.

## When Writing your Code

- You MUST write your code so that it runs on `Swift 5.3`.
- You MUST lint your code using [`swiftlint`](https://github.com/realm/SwiftLint).

## When Contributing

- Your commits SHOULD be [signed](https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/signing-commits).
   - **Commits pushing new features and CI implementations MUST be signed**.
   - Commits pushing bugfixes SHOULD be signed.
   - Other commits MAY be signed.
- **Your commits MUST follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.2/) guidelines**.
   - The message MUST start with one of the following types: `chore`, `ci`, `feat`, `fix`, `perf` or `test`.
   - The message type MAY be immediately followed by a scope, in brackets, e.g. `(endpoints)`, `(docs)`, etc.
   - A non-empty message description MUST follow type and (optional) scope, begin with a lowercase character and always start with subjunctive verbs, e.g. _update_, _fix_, _add_, with no period at the end.
   - Commits MAY contain a single paragraph body, using regular word capitalization, but no period at the end.
   - Commits with breaking changes MUST contain a footer, separated from the body by a newline, if it exists, and describe the changes using the message format, preceded by `BREAKING CHANGE: `, e.g. `BREAKING CHANGE: remove upload endpoints`
   - Commits fixing a bug MUST contain a footer, separated from the body by a newline, if it exists, referencing the number of the issue their closing, preceded by `Closes `, e.g. `Closes #123`.
- You SHOULD open `draft` pull requests as soon as you start working on them, in order to let the community know of your plans and avoid duplication.
- **You MUST leave the pull request body empty**, as it will be populated automatically.
   - You MAY add an additional comment for context.
- **Pull requests SHOULD only solve one problem: stick to the minimal set of changes**.
- New code SHOULD come with new tests.
- **Pull requests MUST always target `main` latest commit**.
- Pull requests SHOULD have a linear commit history.
- You SHOULD ask for a review as soon as you are done with your changes.
