#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/youhs4554/hybrid-image-svg-skill.git"
SKILL_DIR="${HOME}/.agents/skills/hybrid-image-svg"

mkdir -p "${HOME}/.agents/skills"

if [ -d "${SKILL_DIR}/.git" ]; then
  git -C "${SKILL_DIR}" pull --ff-only
elif [ -e "${SKILL_DIR}" ]; then
  echo "Install target already exists but is not a git repository: ${SKILL_DIR}" >&2
  echo "Move or remove it, then run this installer again." >&2
  exit 1
else
  git clone "${REPO_URL}" "${SKILL_DIR}"
fi

test -f "${SKILL_DIR}/SKILL.md"
test -f "${SKILL_DIR}/scripts/embed_crops.py"

echo "Installed hybrid-image-svg skill at ${SKILL_DIR}"
echo "Restart your agent session so the skill list reloads."
