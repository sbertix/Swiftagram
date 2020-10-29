# Contributing

All contributes are always welcome.\
That said, we require some guidelines to be followed, in order for PRs to be merged.

## Process

- **Bugfixes** should always refer to a `bug` **issue**. Open one before (or when) you submit your pull request.
  - Do not close your issue manually, instead write `Fix #123`, replacing "123" with the reference number. It will be closed automatically on completion.
- If you are planning **bigger changes**, always open an `enhancement` **issue** before spending a lot of time writing code.
- All changes are made by submitting a pull request.
- Ask for a review as soon as you are done with your changes.
- PRs merged into `development` will be then considered for the next release, and merged into `main` with a new PR.

## Pull Requests

- PR should always be compared against the `development` branch. All PRs intending to merge directly into `main`, excluding the ones involving releases, will be closed.
- Create a `draft` PR as early as possible, in order to avoid duplicated work, and seek collaborators.
- PR should only "solve" one problem. Always stick to the minimal set of changes.
- Describe what you want to accomplish in the PR: **do not leave the comment section empty**.
- New code needs to come with new tests.
- [`swiftlint`](https://github.com/realm/SwiftLint) your code before the final commit, as we are enforcing it strictely (warning = error).

## Setup

Write your code so that it runs on `Swift 5.1`.\
If you are using a newer version of Xcode, download the appropriate toolchains [here](https://swift.org/download/)
