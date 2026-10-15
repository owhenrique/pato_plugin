#!/usr/bin/env bash
# Pato — instala/atualiza as skills e os commands no OpenCode global (~/.config/opencode).
#
# Skills:   ~/.config/opencode/skills/<skill>  -> <repo>/skills/<skill>
# Commands: ~/.config/opencode/commands/pato   -> <repo>/commands   (viram /pato/spec, /pato/implement, /pato/close-spec)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OC_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"

mkdir -p "$OC_DIR/skills" "$OC_DIR/commands"

# Commands: /pato/spec, /pato/implement, /pato/close-spec
ln -sfn "$REPO_DIR/commands" "$OC_DIR/commands/pato"
echo "commands: /pato/* -> $REPO_DIR/commands"

# Skills: spec, implement, close-spec
for skill_dir in "$REPO_DIR"/skills/*/; do
  skill_dir="${skill_dir%/}"
  skill_name="$(basename "$skill_dir")"
  ln -sfn "$skill_dir" "$OC_DIR/skills/$skill_name"
  echo "skill: $skill_name -> $skill_dir"
done

# Graphify (opcional): o /pato/spec oferece instalar na primeira vez
if command -v graphify >/dev/null 2>&1; then
  echo "graphify: encontrado"
else
  echo "graphify: não encontrado (o /pato/spec vai oferecer instalar na primeira vez)"
fi

echo
echo "Pato instalado. No OpenCode: /pato/spec, /pato/implement, /pato/verify, /pato/close-spec"
