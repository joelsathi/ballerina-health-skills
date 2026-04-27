#!/usr/bin/env bash
# install.sh — install one or more Ballerina healthcare skills for Claude Code.
#
# Usage:
#   ./install.sh <skill-name> [<skill-name>...]
#   ./install.sh --all
#   ./install.sh --project <skill-name>...
#   ./install.sh --list
#
# Flags:
#   --all       Install every skill in the repo.
#   --project   Install into ./.claude/skills/ (current directory) instead of ~/.claude/skills/.
#   --list      Print every available skill name and exit.
#   --help      Print this message.
#
# Can be piped from curl:
#   curl -fsSL https://raw.githubusercontent.com/joelsathi/ballerina-healthcare-skills/main/scripts/install.sh \
#     | bash -s fhir-r4-development hl7-v2-integration

set -euo pipefail

REPO_URL="https://github.com/joelsathi/ballerina-healthcare-skills.git"
REPO_RAW_BASE="https://raw.githubusercontent.com/joelsathi/ballerina-healthcare-skills/main"
DEST="${HOME}/.claude/skills"
ALL=0
LIST=0

ALL_SKILLS=(
    skill-router
    configuration-best-practices
    fhir-r4-development
    fhir-r5-development
    implementation-guides
    parser-and-validator
    terminology-services
    hl7-v2-integration
    ccda-documents
    dicom-integration
    data-transformation
    clinical-decision-support
    emr-ehr-connectivity
    security-and-authz
    privacy-and-deidentification
    healthcare-api-development
    health-tool-cli
    prebuilt-services
)

usage() {
    sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

# Parse flags
SKILLS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)     ALL=1; shift ;;
        --project) DEST="$(pwd)/.claude/skills"; shift ;;
        --list)    LIST=1; shift ;;
        --help|-h) usage 0 ;;
        --*)       echo "Unknown flag: $1" >&2; usage 1 ;;
        *)         SKILLS+=("$1"); shift ;;
    esac
done

if [[ $LIST -eq 1 ]]; then
    printf '%s\n' "${ALL_SKILLS[@]}"
    exit 0
fi

if [[ $ALL -eq 1 ]]; then
    SKILLS=("${ALL_SKILLS[@]}")
fi

if [[ ${#SKILLS[@]} -eq 0 ]]; then
    echo "No skills specified." >&2
    usage 1
fi

# Validate each requested skill
for skill in "${SKILLS[@]}"; do
    found=0
    for known in "${ALL_SKILLS[@]}"; do
        [[ "$skill" == "$known" ]] && { found=1; break; }
    done
    if [[ $found -eq 0 ]]; then
        echo "Unknown skill: $skill" >&2
        echo "Run with --list to see available skills." >&2
        exit 1
    fi
done

mkdir -p "$DEST"
echo "Installing into: $DEST"

# Per-skill direct download via raw.githubusercontent — no git, no sparse-checkout
for skill in "${SKILLS[@]}"; do
    target="$DEST/$skill"
    mkdir -p "$target"
    if curl -fsSL "$REPO_RAW_BASE/skills/$skill/SKILL.md" -o "$target/SKILL.md"; then
        echo "  installed: $skill"
    else
        echo "  FAILED: $skill (could not fetch SKILL.md)" >&2
        exit 1
    fi
done

echo
echo "Done. Restart Claude Code so it picks up the new skills."
echo "Verify with: ls $DEST"
