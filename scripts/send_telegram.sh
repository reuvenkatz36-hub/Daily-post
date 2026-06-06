#!/usr/bin/env bash
#
# send_telegram.sh — push a finished post package to the brand's Telegram bot.
#
# Usage:
#   scripts/send_telegram.sh <post_dir>
#
#   <post_dir> is a folder like "posts/2026-06-06-market-selloff" containing:
#     - post.md            (required; caption is derived from its title + one-liner)
#     - image: EITHER image.png (local file)  OR  image.url (a text file with an https URL)
#     - video: EITHER video.mp4 / video.gif   OR  video.url (a text file with an https URL)
#
# Media delivery — two supported modes (the script auto-detects):
#   1. BY URL (preferred in this environment): put the media's https URL in image.url /
#      video.url. Telegram's servers fetch it directly, so this environment only needs
#      egress to api.telegram.org (Canva's export CDN does NOT need to be allowlisted).
#   2. BY FILE: drop image.png / video.mp4 in the folder and the script uploads them.
#
# Required environment variables (set as secrets in the Claude Code web env):
#   TELEGRAM_BOT_TOKEN   token from @BotFather, e.g. 123456:ABC-DEF...
#   TELEGRAM_CHAT_ID     destination chat/channel id, e.g. 987654321 or @mychannel
#
# Behavior:
#   - If the secrets are missing, prints "skipped (no secrets)" and exits 0 so a
#     scheduled run still succeeds and the package is committed to the repo.

set -uo pipefail

POST_DIR="${1:-}"
if [[ -z "$POST_DIR" ]]; then
  echo "usage: $0 <post_dir>" >&2
  exit 2
fi
if [[ ! -d "$POST_DIR" ]]; then
  echo "error: post dir not found: $POST_DIR" >&2
  exit 2
fi

if [[ -z "${TELEGRAM_BOT_TOKEN:-}" || -z "${TELEGRAM_CHAT_ID:-}" ]]; then
  echo "Telegram: skipped (no secrets) — set TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID to enable auto-send."
  exit 0
fi

API="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}"

# Build a short caption: H1 title + one-liner, trimmed to Telegram's caption limit (1024).
POST_MD="${POST_DIR}/post.md"
CAPTION=""
if [[ -f "$POST_MD" ]]; then
  TITLE=$(grep -m1 '^# ' "$POST_MD" | sed 's/^# //')
  ONELINER=$(grep -m1 '^\*\*One-liner:\*\*' "$POST_MD" | sed 's/^\*\*One-liner:\*\* //')
  CAPTION="${TITLE}"
  [[ -n "$ONELINER" ]] && CAPTION="${CAPTION}"$'\n\n'"${ONELINER}"
fi
CAPTION="${CAPTION:0:1000}"

post_api() { local method="$1"; shift; curl -sS --fail-with-body --max-time 90 "${API}/${method}" "$@"; }

# Resolve media source: prefer a *.url file (send by URL), else a local file (upload).
img_url=""; img_file=""
[[ -f "${POST_DIR}/image.url" ]] && img_url="$(tr -d ' \t\r\n' < "${POST_DIR}/image.url")"
[[ -f "${POST_DIR}/image.png" ]] && img_file="${POST_DIR}/image.png"

vid_url=""; vid_file=""; vid_is_gif=0
if   [[ -f "${POST_DIR}/video.url" ]]; then vid_url="$(tr -d ' \t\r\n' < "${POST_DIR}/video.url")"
fi
if   [[ -f "${POST_DIR}/video.mp4" ]]; then vid_file="${POST_DIR}/video.mp4"
elif [[ -f "${POST_DIR}/video.gif" ]]; then vid_file="${POST_DIR}/video.gif"; vid_is_gif=1
fi

send_ok=0

# --- video first (richest asset) ---
if   [[ -n "$vid_url" ]]; then
  post_api sendVideo --data-urlencode chat_id="${TELEGRAM_CHAT_ID}" \
    --data-urlencode video="${vid_url}" --data-urlencode caption="${CAPTION}" >/dev/null && send_ok=1
elif [[ -n "$vid_file" && "$vid_is_gif" -eq 1 ]]; then
  post_api sendAnimation -F chat_id="${TELEGRAM_CHAT_ID}" -F animation=@"${vid_file}" \
    -F caption="${CAPTION}" >/dev/null && send_ok=1
elif [[ -n "$vid_file" ]]; then
  post_api sendVideo -F chat_id="${TELEGRAM_CHAT_ID}" -F video=@"${vid_file}" \
    -F caption="${CAPTION}" >/dev/null && send_ok=1
# --- else image ---
elif [[ -n "$img_url" ]]; then
  post_api sendPhoto --data-urlencode chat_id="${TELEGRAM_CHAT_ID}" \
    --data-urlencode photo="${img_url}" --data-urlencode caption="${CAPTION}" >/dev/null && send_ok=1
elif [[ -n "$img_file" ]]; then
  post_api sendPhoto -F chat_id="${TELEGRAM_CHAT_ID}" -F photo=@"${img_file}" \
    -F caption="${CAPTION}" >/dev/null && send_ok=1
fi

# If no media sent (or it failed), deliver the caption as text so nothing is lost.
if [[ "$send_ok" -ne 1 ]]; then
  post_api sendMessage --data-urlencode chat_id="${TELEGRAM_CHAT_ID}" \
    --data-urlencode text="${CAPTION}" >/dev/null && send_ok=1
fi

# Always send the full post.md as a document so the user has every platform's copy.
if [[ -f "$POST_MD" ]]; then
  post_api sendDocument -F chat_id="${TELEGRAM_CHAT_ID}" -F document=@"${POST_MD}" >/dev/null || true
fi

if [[ "$send_ok" -eq 1 ]]; then
  echo "Telegram: sent ${POST_DIR}"
  exit 0
else
  echo "Telegram: send failed for ${POST_DIR} (check token/chat id/network policy)" >&2
  exit 1
fi
