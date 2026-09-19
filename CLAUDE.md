# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Personal portfolio for Ritik Sharma (AI/ML Engineer), deployed on Netlify at https://myportfolio0027.netlify.app/.

It is a plain static site: no package.json, no build step, no bundler, no tests, no linter. Every page is hand-written HTML with Tailwind pulled in at runtime from the play CDN (`https://cdn.tailwindcss.com`) — there is no Tailwind config or compiled CSS, so any Tailwind feature that requires a config file is unavailable.

## Running locally

`projects.html` fetches `assets/data/projects.json`, which `file://` blocks. Serve the repo root over HTTP:

```sh
python3 -m http.server 5501        # then open http://localhost:5501/index.html
```

The repo is set up for the VS Code Live Server extension on port 5501 (`.vscode/settings.json`).

`auto.sh` is a personal shortcut that runs `git add . && git commit -m "2" && git push` — hence the repeated `2` commit messages in history. Don't use it for real commits.

## Asset layout

All non-HTML files live under `assets/`, referenced by paths relative to the repo root (all HTML sits at the root, so `assets/...` resolves from every page):

```
assets/css/      style.css — used only by index.html; its url()s are ../images/...
assets/data/     projects.json
assets/docs/     RitikSharma_Resume.pdf, certificates/ (certificates are unreferenced)
assets/icons/    svg/png logos + favicon.ico
assets/images/   profile.jpg, backgrounds, projects/ (project card screenshots)
assets/media/    .mp4 files embedded in the skills page
```

## Page flow

- `index.html` — splash screen; the only page that uses `style.css`. Links to `landing_page.html`.
- `landing_page.html` — the real homepage: hero, about, **experience** (`#experience`), education, inline contact form, resume download. Sidebar nav on desktop plus a separate top nav on mobile — both must be updated together when adding a section.
- `skills.html` — technical skill groups, coding profiles, interests, YouTube embeds.
- `projects.html` — data-driven project grid (see below).
- `contact.html` — standalone contact page. Currently **orphaned**: the nav link to it is commented out in `skills.html` and no page links to it. Its form duplicates the one in `landing_page.html`.

There is no templating or shared include mechanism. The nav, footer, contact form, Google Fonts links and inline `body { font-family: "Edu NSW ACT Foundation" }` block are copy-pasted into each page — a change to any of them must be applied to every page by hand.

## Hero card

The landing page hero is a single centred card: circular avatar in a gradient ring, location pill, name, role, three specialism pills, one-line blurb, and a single "Download Resume" call to action. There is deliberately no Projects button — the projects page is reached through the nav.

The avatar uses `object-cover object-top` because `assets/images/profile.jpg` is a 1180x2096 portrait; top-anchoring keeps the face in frame. If the photo is swapped for a square or landscape headshot, `object-center` will usually frame better.

## Responsive conventions

The site targets 320px and up; there is no horizontal scroll at any width. When editing layout, keep to these patterns:

- **Gutters** — every container carries `px-4 sm:px-5` (or `px-4 sm:px-6`) so content never touches the screen edge.
- **Columns** — split at `sm:` for two-up (education cards, form fields, project grid) and `lg:` for three-up or side-by-side media. Avoid bare `w-1/2` / `lg:w-1/3`; write `w-full sm:w-1/2`.
- **Landing page navs** — the desktop sidebar (`lg:` and up, `w-32` fixed) and the mobile top bar (`lg:hidden`, `h-20`) are separate markup. A new section must be added to **both**. The mobile bar uses `text-[10px] sm:text-sm` with `shrink-0` items, short labels and `overflow-x-auto` as a safety net; the sidebar uses `justify-center gap-4` (the old `-mb-32` negative-margin spacing was removed — don't reintroduce it).
- **Content offset** — pages with the fixed sidebar use `lg:pl-40` on their containers to clear it. Content is therefore centred within the area *beside* the sidebar, not the whole viewport; a measured offset of ~64px at desktop widths is correct, not a bug.
- **Buttons in a row** — use `flex flex-wrap justify-center gap-4` rather than `ml-4` on the second button, so they wrap instead of overflowing.

Text is centred at section level (headings, hero, about, skill cards). Prose that runs long stays left-aligned — experience bullets and form labels — because centring multi-line body copy hurts readability.

`index.html` is the only page with hand-written CSS. It centres with flexbox on `section`; the `padding-bottom` reserves room for the wave band via the `--wave-height` variable, and the wave tile stays 1000px wide at every breakpoint so the keyframe loop (`background-position-x: 0 -> 1000px`) stays seamless when the height changes.

### Verifying layout changes

Headless Chrome clamps its window to a 500px minimum, so `--window-size=390,844` silently renders at 500px wide and screenshots come out clipped and apparently off-centre. Render the page inside an iframe of the target width instead, and measure text with a `Range` bounding box (the element box is full-width; only the range gives the real ink extent).

## Content source of truth

Page copy (headline, about, experience bullets, skill groups, education) is transcribed from `assets/docs/RitikSharma_Resume.pdf`. When the resume changes, those sections should be re-synced rather than edited ad hoc.

The resume PDF uses subset fonts with per-font `ToUnicode` CMaps, and different subsets map the *same* code to different glyphs. Text extraction must resolve each string against the CMap of the font active at that `Tf` operator — merging all CMaps silently corrupts digits (years, metrics, model versions).

## Projects data

`assets/data/projects.json` is the single source of truth for the project grid. Each entry:

```json
{ "title": "...", "image": "assets/images/projects/x.png", "link": "https://...", "category": "ml" }
```

`projects.html` fetches it, renders cards, and filters by category. **The `category` value must match a filter button's id** — the buttons are hardcoded as `id="btn-<category>"` with `onclick="filterProjects('<category>')"`. Existing categories: `python`, `ml`, `js`, `html` (plus the special `all`). Adding a new category means adding both the JSON entries and a matching button.

This page carries personal/open-source work only; employer projects live in the experience section of `landing_page.html`, since they have no public links.

## Contact form

Both `landing_page.html` and `contact.html` POST their `FormData` to the same Google Apps Script endpoint (`scriptURL` in the inline script at the bottom of each page), which appends rows to a Google Sheet. The script looks the form up via `document.forms["submit-to-google-sheet"]`, so the `<form name="submit-to-google-sheet">` attribute and the `id="msg"` status span must be preserved. If the endpoint changes, update it in both files.

The phone number in the resume is deliberately kept off the HTML pages; it is only in the downloadable PDF.
