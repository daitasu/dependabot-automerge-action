# Dependabot Auto Merge Action

Dependabot PR を semver レベル（patch / minor / major）ごとに設定可能な戦略で自動マージする GitHub Composite Action。

AI レビューには [Claude Code Action](https://github.com/anthropics/claude-code-action) を使用。

## Strategies

| 戦略 | 動作 |
|---|---|
| `auto-merge` | approve して即 auto-merge |
| `review-and-merge` | AI がレビュー → approve したら auto-merge |
| `review-only` | AI がレビューコメントを投稿（マージしない） |
| `none` | 何もしない |

### デフォルト設定

| semver level | default strategy |
|---|---|
| patch | `auto-merge` |
| minor | `review-and-merge` |
| major | `review-only` |

## Usage

```yaml
name: Dependabot Auto Merge
on:
  pull_request:
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

### patch のみ auto-merge（AI レビューなし）

```yaml
- uses: daitasu/dependabot-automerge-action@v1
  with:
    github-token: ${{ steps.app-token.outputs.token }}
    patch-strategy: "auto-merge"
    minor-strategy: "none"
    major-strategy: "none"
```

### 全レベルで AI レビュー + auto-merge

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

## Inputs

| Name | Required | Default | Description |
|---|---|---|---|
| `patch-strategy` | No | `auto-merge` | patch 更新の戦略 |
| `minor-strategy` | No | `review-and-merge` | minor 更新の戦略 |
| `major-strategy` | No | `review-only` | major 更新の戦略 |
| `github-token` | **Yes** | - | approve/merge 用の GitHub token |
| `anthropic-api-key` | No | `""` | Anthropic API key（review 系戦略で必須） |
| `claude-github-token` | No | `""` | Claude Code Action 用 GitHub token（review 系戦略で必須） |
| `claude-model` | No | `sonnet` | AI レビューに使用する Claude モデル |
| `reviewer-login` | No | `""` | AI レビュアーの bot login 名（`review-and-merge` 時に approve 確認で使用） |

## Outputs

| Name | Description |
|---|---|
| `strategy` | 適用された戦略名 |
| `update-type` | semver 更新種別（`patch`, `minor`, `major`） |

## Required Permissions

### GitHub App に必要な権限

- **Pull requests**: Read & Write（approve, merge, レビューコメント投稿）
- **Contents**: Read（リポジトリ読み取り）

> **Note:** `github-token` と `claude-github-token` に同じトークンを渡せば GitHub App は1つで OK です。
> 権限を分離したい場合は別々の App を使うこともできます。

### ワークフローの permissions

```yaml
permissions:
  contents: read
  pull-requests: write
```

## License

MIT
