# Media assets — SpaceX IPO

Created in Canva. Binaries are delivered to Telegram **by URL** (this environment's network
policy doesn't allowlist Canva's export CDN for local download), so the rendered PNG/MP4 are
not committed; `image.url` / `video.url` hold the latest signed export links.

## Canva design (permanent)
- Design ID: `DAHLz4viOs8`
- View: https://www.canva.com/d/KGBa2jjGXrsjWbj
- Edit: https://www.canva.com/d/OHq_c2lYm-Bid9z
- Format: Instagram post, 1080x1350 (4:5)

## Exports
- `image.url` — PNG export (pro quality)
- `video.url` — MP4 export (vertical_1080p)

> Signed export URLs expire after several hours. To re-deliver, re-run `export-design` on
> design `DAHLz4viOs8`, overwrite the .url files, then run
> `scripts/send_telegram.sh posts/2026-06-06-spacex-ipo`.
