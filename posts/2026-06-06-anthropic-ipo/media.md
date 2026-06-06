# Media assets — Anthropic IPO

Created in Canva. Binaries are delivered to Telegram **by URL** (this environment's network
policy doesn't allowlist Canva's export CDN for local download), so the rendered PNG/MP4 are
not committed; `image.url` / `video.url` hold the latest signed export links.

## Canva design (permanent)
- Design ID: `DAHLz3H5uPc`
- View: https://www.canva.com/d/1PvxqNu8hXdHBkQ
- Edit: https://www.canva.com/d/cTK7o_WJU2B0cy4
- Format: Instagram post, 1080x1350 (4:5)

## Exports
- `image.url` — PNG export (pro quality)
- `video.url` — MP4 export (vertical_1080p)

> Signed export URLs expire after several hours. To re-deliver, re-run `export-design` on
> design `DAHLz3H5uPc`, overwrite the .url files, then run
> `scripts/send_telegram.sh posts/2026-06-06-anthropic-ipo`.
