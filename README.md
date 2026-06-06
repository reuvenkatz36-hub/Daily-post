# Daily-Post Autopilot

An all-day content engine for a media brand covering **stocks, investing, business,
entrepreneurship, wealth building, productivity, and mindset**.

It scans the last 24 hours of news, picks the stories that clear a high bar, and for each
one builds a publish-ready **package** — platform text (X, LinkedIn, Instagram, Facebook,
newsletter) + a branded **image** + a short **animated graphic** — then delivers it to
your **Telegram bot** and commits it to this repo. Up to **5 posts/day**.

## How it works

The brain is a reusable skill: [`.claude/skills/daily-post-scan/SKILL.md`](.claude/skills/daily-post-scan/SKILL.md).
Each time it runs it: scans → scores & dedupes → verifies facts → writes every platform's
copy → generates media in Canva → sends to Telegram → saves the package and commits.

```
posts/<YYYY-MM-DD>-<slug>/
  post.md            # analysis + all platform text + image prompt + scores + sources
  image.png          # branded image (Canva)
  video.mp4 / .gif   # animated graphic (Canva)
scripts/
  send_telegram.sh   # pushes a package to the Telegram bot
  posted-log.md      # dedupe ledger — what's already been posted
```

## One-time setup

### 1. Create your Telegram bot
1. In Telegram, message **@BotFather**, send `/newbot`, and follow the prompts.
2. Copy the **bot token** it gives you (looks like `123456:ABC-DEF...`).
3. Get your **chat ID**: start a chat with your bot (send it any message), then visit
   `https://api.telegram.org/bot<TOKEN>/getUpdates` and read `chat.id`. For a channel,
   add the bot as admin and use `@yourchannel`.

### 2. Add secrets to the environment
In Claude Code on the web, open your environment settings and add:
- `TELEGRAM_BOT_TOKEN` — the BotFather token
- `TELEGRAM_CHAT_ID` — your chat or channel id

Until these are set, the engine still runs and commits packages to the repo; the Telegram
step just prints `skipped (no secrets)`.

### 3. Allow network egress
The engine needs outbound access to **`api.telegram.org`**. Make sure the environment's
**network policy** permits it (in this environment it already does). See
https://code.claude.com/docs/en/claude-code-on-the-web for the available policies.

> Note: media is delivered to Telegram **by URL** — Telegram's servers fetch the Canva
> export directly — so Canva's export CDN does **not** need to be allowlisted. For that
> reason the rendered PNG/MP4 binaries are not committed to the repo; each post folder
> keeps `image.url` / `video.url` plus permanent Canva links in `media.md`.

### 4. Schedule it (the "all-day" part)
A single chat session is ephemeral, so all-day coverage comes from a **scheduled trigger**.
In Claude Code on the web, create a schedule (suggested: **every 2 hours**, plus a
pre-open ~8:30am ET and post-close ~4:15pm ET sweep on US trading days) that runs this
prompt:

> Run the `daily-post-scan` skill: scan the last 24h of markets/business/startup/economics
> news, score and dedupe against `scripts/posted-log.md`, and for up to 5 stories that
> clear the bar, build the full package (all platform text + Canva image + Canva animated
> graphic), send each to Telegram via `scripts/send_telegram.sh`, append to the posted log,
> commit, and push to `claude/daily-content-creation-tWWdb`. Verify all facts; never invent
> stats, quotes, or sources.

## Running it manually
Just ask in a session: **"Run the daily-post-scan skill"** (or "make today's posts").

To deliver one already-built package to Telegram:
```bash
scripts/send_telegram.sh posts/2026-06-06-market-selloff
```

## Quality rules
Verify facts before publishing. Never invent statistics, quotes, or sources. Cross-check
numbers across at least two reputable outlets. Prefer educational insight over hype.

## Notes & limits
- **Video:** no true AI video generator is connected; the "video" is a Canva animated
  graphic (MP4/GIF), with a static PNG fallback if motion export isn't available.
- **Not financial advice.** All content is educational.
