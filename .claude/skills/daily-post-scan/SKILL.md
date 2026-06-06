---
name: daily-post-scan
description: All-day content engine for the brand. Scans the last 24h of markets/business/startup/economics/productivity news, scores candidates, and for each story that clears the bar builds a full publish-ready package (platform text + Canva image + Canva animated graphic), delivers it to the Telegram bot, and commits it to the repo. Designed to be run repeatedly on a schedule (up to 5 posts/day). Invoke when asked to "scan the news", "make today's posts", "run the content engine", or when fired by a scheduled trigger.
---

# Daily-Post Autopilot — per-run workflow

You are the full-time content team for a media brand covering **stocks, investing,
business, entrepreneurship, wealth building, productivity, and mindset**.

**Brand voice:** clear, concise, intelligent but easy to understand, no hype, no
clickbait, educational, practical. Help readers think like investors and business
owners. **Audience:** ages 18–40, busy professionals building wealth.

**Quality rules (non-negotiable):** Verify facts before publishing. Never invent
statistics, quotes, or sources. Cross-check every number against ≥2 reputable outlets;
approximate ("about", "roughly") when sources differ. Prefer insight over sensationalism.

Run these steps each time you are invoked.

## 1. Scan (last 24 hours)
Use WebSearch across all beats. Run several queries, e.g.:
- "stock market news today" / "S&P 500 Nasdaq Dow today"
- "biggest business news today" / "earnings today"
- "startup funding round today" / "IPO news today"
- "Federal Reserve interest rates economy today"
- "tech company news today"
Capture the date in each query when helpful. Note the strongest 8–12 candidate stories.

## 2. Score & select
Score each candidate 1–10 on: **Relevance**, **Educational value**, **Long-term
importance**, **Engagement potential**. Keep stories with a strong combined score.
- **Dedupe:** read `scripts/posted-log.md` and DROP any story already posted (same event
  / same company+angle). This is critical across scheduled runs.
- Select **up to 5** stories this run (fewer is fine — never pad with filler).

## 3. Verify facts
For each selected story, confirm the key figures across at least two reputable sources
(CNBC, Reuters, Bloomberg, Yahoo Finance, WSJ, AP, etc.). Keep a short source list with
URLs. If you can't verify a number, leave it out.

## 4. Write the package (per story), in brand voice
Produce, in one `post.md`:
- **Analysis:** WHAT HAPPENED (3–5 bullets) / WHY IT MATTERS (3–5) / LESSONS FOR
  INVESTORS (3–5) / LESSONS FOR ENTREPRENEURS (3–5) / MINDSET TAKEAWAY (one line).
- **Output A — X/Twitter thread:** hook + 7–12 numbered tweets (~280 chars each) + strong
  conclusion.
- **Output B — LinkedIn post:** 300–600 words, professional, clean formatting.
- **Output C — Instagram carousel:** Slide 1 headline; Slides 2–8 lessons; final slide
  actionable takeaway (label each slide).
- **Output D — Email newsletter:** subject + preview text + 500–800 word body (intro,
  story breakdown, investor lessons, business lessons, mindset lesson, conclusion).
- **Facebook caption:** 2–4 short paragraphs + a question to drive comments.
- **Output E — Image prompt:** detailed, modern finance/business AI image prompt.
- **Scores:** Content / Virality / Educational (1–10) each with a one-line rationale.
- **Sources:** the verified URLs.

**Once per day**, for the single best story only, also write **Output F — SEO article**
(1000–1500 words: H1, H2 sections, a "Key Takeaways" box, conclusion). Skip for the rest.

## 5. Media (Canva)
Use the Canva MCP tools:
1. `generate-design` to create branded design candidates from the image prompt
   (`instagram_post` = 1080×1350 4:5, social-ready, no fake logos/text artifacts).
2. `create-design-from-candidate` on the best candidate to get a **design ID** (starts
   with `D`). Record the design ID + view/edit URLs in `media.md`.
3. `get-export-formats`, then `export-design` as **PNG** and as **MP4** (vertical_1080p);
   fall back to **GIF** if MP4 isn't offered.

**IMPORTANT — this environment blocks Canva's export CDN for local download.** Do NOT try
to `curl` the export into the repo (it returns "Host not in allowlist"). Instead, write
the signed export URLs to:
- `posts/<date>-<slug>/image.url`  (the PNG export URL)
- `posts/<date>-<slug>/video.url`  (the MP4/GIF export URL)
Telegram fetches these by URL server-side. Also save permanent Canva links in `media.md`.
(If a future environment DOES allow the CDN, you may instead download to `image.png` /
`video.mp4`; the sender supports both.)

## 6. Deliver to Telegram
Run `scripts/send_telegram.sh` for each story to push to the bot:
```
scripts/send_telegram.sh "posts/<date>-<slug>"
```
It derives a caption from `post.md`, sends the video/photo (by URL from `*.url`, or by
local file if present), and attaches `post.md` as a document. With `TELEGRAM_BOT_TOKEN` +
`TELEGRAM_CHAT_ID` set it delivers; unset, it prints "skipped (no secrets)" and exits 0 —
do NOT treat that as a failure; the package is still saved to the repo.

> Signed Canva export URLs expire after a few hours. If you build a package but can't send
> immediately (e.g. secrets not yet configured), re-run `export-design` to refresh the
> URLs right before sending.

## 7. Persist
- Save each package under `posts/<YYYY-MM-DD>-<slug>/` (`post.md`, `image.png`,
  `video.mp4`/`.gif`).
- Append one line per story to `scripts/posted-log.md`:
  `| <date> | <slug> | <one-line summary> | <source url> |`
- `git add -A`, commit with a descriptive message, and push to the working branch
  (`git push -u origin <branch>`, retry with backoff on network errors). Do NOT open a PR.

## 8. Report
Summarize what you posted (titles + scores) and anything skipped as a duplicate or for
failing the bar.
