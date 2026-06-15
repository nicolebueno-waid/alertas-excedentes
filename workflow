
---

**Arquivo 2 — Workflow** (agenda e executa o Claude todo dia)
**Caminho:** `.github/workflows/alerta-excedentes.yml`

```yaml
name: Alerta diário de excedentes

on:
  schedule:
    - cron: "0 12 * * *"
  workflow_dispatch: {}

jobs:
  alerta-excedentes:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: "20"

      - name: Instalar Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Configurar MCPs (Supabase + Slack)
        run: |
          cat > .mcp.json << EOF
          {
            "mcpServers": {
              "supabase": {
                "command": "npx",
                "args": ["-y", "@supabase/mcp-server-supabase@latest", "--read-only",
                         "--project-ref=aqmbaycbwljiohdjputq"],
                "env": { "SUPABASE_ACCESS_TOKEN": "${SUPABASE_ACCESS_TOKEN}" }
              },
              "slack": {
                "command": "npx",
                "args": ["-y", "@modelcontextprotocol/server-slack"],
                "env": {
                  "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}",
                  "SLACK_TEAM_ID": "${SLACK_TEAM_ID}"
                }
              }
            }
          }
          EOF
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
          SLACK_TEAM_ID: ${{ secrets.SLACK_TEAM_ID }}

      - name: Executar rotina
        run: |
          claude -p "/alerta-excedentes" \
            --permission-mode bypassPermissions \
            --mcp-config .mcp.json
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
          SLACK_TEAM_ID: ${{ secrets.SLACK_TEAM_ID }}
