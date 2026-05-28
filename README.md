# Dependabot Auto Merge Action

A GitHub Composite Action that auto-merges Dependabot PRs with configurable strategies per semver level (patch / minor / major).

Uses [Claude Code Action](https://github.com/anthropics/claude-code-action) for AI-powered reviews.

## Strategies

| Strategy | Behavior |
|---|---|
| `auto-merge` | Approve and merge immediately |
| `review-and-merge` | AI reviews the PR — merges if approved |
| `review-only` | AI posts a review comment (no merge) |
| `none` | Do nothing |

### Defaults

| semver level | default strategy |
|---|---|
| patch | `auto-merge` |
| minor | `review-and-merge` |
| major | `review-only` |

## Usage

> **Note:** Dependabot PRs cannot access repository secrets with the `pull_request` event.
> Use `pull_request_target` instead.

```yaml
name: Dependabot Auto Merge
on:
  pull_request_target:
    types: [opened, reopened, ready_for_review]

permissions: {}

jobs:
  dependabot-automerge:
    if: github.event.pull_request.user.login == 'dependabot[bot]'
    runs-on: ubuntu-latest
    timeout-minutes: 15
    permissions:
      contents: read
      pull-requests: write
    steps:
      - name: Generate App Token
        id: app-token
        uses: actions/create-github-app-token@v3
        with:
          app-id: ${{ vars.BOT_APP_ID }}
          private-key: ${{ secrets.BOT_PRIVATE_KEY }}

      - uses: actions/checkout@v4

      - uses: daitasu/dependabot-automerge-action@v1
        with:
          github-token: ${{ steps.app-token.outputs.token }}
          anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
          claude-github-token: ${{ steps.app-token.outputs.token }}
          # patch-strategy: 'auto-merge'       # default
          # minor-strategy: 'review-and-merge'  # default
          # major-strategy: 'review-only'       # default
          reviewer-login: "my-bot[bot]"
```

### Patch-only auto-merge (no AI review)

```yaml
- uses: daitasu/dependabot-automerge-action@v1
  with:
    github-token: ${{ steps.app-token.outputs.token }}
    patch-strategy: "auto-merge"
    minor-strategy: "none"
    major-strategy: "none"
```

### AI review + merge for all levels

```yaml
- uses: daitasu/dependabot-automerge-action@v1
  with:
    github-token: ${{ steps.app-token.outputs.token }}
    anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
    claude-github-token: ${{ steps.app-token.outputs.token }}
    patch-strategy: "review-and-merge"
    minor-strategy: "review-and-merge"
    major-strategy: "review-and-merge"
    reviewer-login: "my-bot[bot]"
```

### Japanese review comments

```yaml
- uses: daitasu/dependabot-automerge-action@v1
  with:
    github-token: ${{ steps.app-token.outputs.token }}
    anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
    claude-github-token: ${{ steps.app-token.outputs.token }}
    review-language: "ja"
    reviewer-login: "my-bot[bot]"
```

## Inputs

| Name | Required | Default | Description |
|---|---|---|---|
| `patch-strategy` | No | `auto-merge` | Strategy for patch updates |
| `minor-strategy` | No | `review-and-merge` | Strategy for minor updates |
| `major-strategy` | No | `review-only` | Strategy for major updates |
| `github-token` | **Yes** | - | GitHub token for approve/merge (e.g. GitHub App token or PAT) |
| `anthropic-api-key` | No | `""` | Anthropic API key (required for review strategies) |
| `claude-github-token` | No | `""` | GitHub token for Claude Code Action (required for review strategies) |
| `claude-model` | No | `sonnet` | Claude model for AI review |
| `reviewer-login` | No | `""` | Bot login name to check for approval (`review-and-merge` only) |
| `review-language` | No | `en` | Language for AI review comments (`en`, `ja`, etc.) |

## Outputs

| Name | Description |
|---|---|
| `strategy` | The strategy that was applied |
| `update-type` | The semver update level (`patch`, `minor`, `major`) |

## Required Permissions

### GitHub App

- **Pull requests**: Read & Write (approve, review comments)
- **Contents**: Read & Write (read repository, merge PRs)

> **Note:** You can pass the same token to both `github-token` and `claude-github-token` — a single GitHub App is sufficient.
> Use separate Apps if you want to isolate permissions.

### Workflow permissions

```yaml
permissions:
  contents: read
  pull-requests: write
```

> These only apply to `GITHUB_TOKEN`. GitHub App tokens use their own permission set.

## License

MIT
