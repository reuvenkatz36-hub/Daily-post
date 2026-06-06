# Media assets — June 5 market sell-off

Created in Canva. Because this environment's network policy does not allowlist Canva's
export CDN, the rendered PNG/MP4 binaries are **not committed to the repo** — they live in
the Canva account and are delivered to Telegram **by URL** (Telegram fetches them
server-side). The `image.url` / `video.url` files hold the latest signed export links.

## Canva design (permanent)
- Design ID: `DAHLztCYMZ8`
- View: https://www.canva.com/d/_mCtSg6QXUCWBSo
- Edit: https://www.canva.com/d/uLR5wqBxVwcVIaG
- Format: Instagram post, 1080×1350 (4:5)

## Exports
- `image.url` — PNG export (pro quality)
- `video.url` — MP4 export (vertical_1080p)

> ⚠️ Signed export URLs expire after several hours. To re-deliver later, re-run
> `export-design` on design `DAHLztCYMZ8` (PNG + MP4), overwrite `image.url` / `video.url`,
> then run `scripts/send_telegram.sh posts/2026-06-06-market-selloff`.
