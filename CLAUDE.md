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
- `skills.html` — technical skill groups, coding profiles, interests, YouTube embeds. Instead of a nav bar it has two `fixed` glass buttons: a circular back arrow (top left, to `landing_page.html`) and a Projects pill (top right). They are plain anchors, not a `<nav>`.
- `projects.html` — data-driven project grid (see below). Uses the same `fixed` glass back arrow as `skills.html`, top left.
- `contact.html` — standalone contact page. Currently **orphaned**: no page links to it. Its form duplicates the one in `landing_page.html`.

There is no templating or shared include mechanism. The nav, footer, contact form, Google Fonts links and inline `body { font-family: "Edu NSW ACT Foundation" }` block are copy-pasted into each page — a change to any of them must be applied to every page by hand.

## Space theme

Every page is dark, on a shared starfield backdrop.

- `assets/css/space.css` is linked by all five pages and is the single source of the background. It sets `html { background-color: #05070f }`, makes `body` transparent, and paints `assets/images/space-bg.svg` on a fixed `body::before` layer at `z-index: -1`. The fixed pseudo-element is deliberate: `background-attachment: fixed` renders badly on iOS Safari.
- `assets/images/space-bg.svg` is the backdrop for every page **except the splash** — generated, not downloaded: a 1920x1080 viewBox with 300 stars and two very faint depth gradients. 21 KB raw, and it rasterizes at 1920x1080 in ~10 ms.
- The splash photograph ships in **two orientations**, used only by `index.html` via `body.splash::before`:
  - `milky-way.jpg` — 1125x2000, 480 KB, portrait. Default.
  - `milky-way-wide.jpg` — 2200x1237, 563 KB, the same shot rotated 90 degrees. Served under `@media (orientation: landscape)`.
  The source is a portrait photo, so a wide viewport cropped it to a narrow vertical strip and looked heavily zoomed. The rotated copy fixes that; the band sweeps horizontally instead. Only the matching media query's image is downloaded — verified, a landscape viewport fetches just the wide one and a portrait viewport just the tall one.
- Both were generated from the **original 2085x3706 / 2.6 MB source**, not from each other — rotating an already-compressed copy would stack JPEG loss. Commands: `sips --rotate 90` then `--resampleWidth 2200` for the wide one, `--resampleHeight 2000` for the tall one, both `--setProperty formatOptions 55`.
- Sizing was chosen so `background-size: cover` **downscales at every realistic viewport** (0.32x on a 320px phone up to 0.87x at 1920x1080), which is what keeps it sharp; only a 2560px display upscales, and only by 1.16x. If either image is ever shrunk further, recheck that ratio — upscaling is what made the first attempt look blurry.
- There was previously a procedural `feTurbulence` nebula in `space-bg.svg`. It was removed. Worth knowing if it is ever reinstated: it cost **405 ms** to rasterize at 1920x1080 versus ~10 ms for the plain starfield, and it was bright enough to require a 0.62 scrim over every page to keep body text readable.
- **The scrim now applies only to the splash** (`body.splash::after`, `rgba(5,7,15,0.3)`), because the photograph has bright regions that would otherwise swallow the hollow heading. Content pages have no scrim — the plain starfield does not need one.
- Content surfaces are dark glass (`bg-white/10 backdrop-blur-* border-white/20`) — the hero card and the eight skill cards. The light-coloured skill pills inside them are intentional: they carry the only saturated colour on the page.
- Two things are light-on-purpose and must stay that way: the form inputs (dark text on light fields) and the project filter buttons (`bg-white text-black`).
- The splash (`index.html`) carries **two stars**, pure CSS in `style.css` — no images, no JS. Both sit at `z-index: 1`, behind the splash text at `z-index: 10`, and are clipped by `overflow: hidden` on `section`.
  - **Sirius A** (`.star.sirius`) — blue-white, lower left at `17% / 70%`, 120s drift.
  - **The Sun** (`.star.sun`) — warm orange-red, lower right at `82% / 78%`, so it sits below Sirius; 165s drift in its own direction so the two do not slide across the sky in lockstep.

  `.star` is the shared skeleton: positioning, the core and the halo, and the twinkle/breathe animations. Each star scales from **one custom property, `--core`** — the halo and the wrapper are multiples of it, so a modifier that sets `--core` rescales that star coherently. The Sun sets `1.35x` Sirius's value, which holds at every width because both are `clamp()`s of `vw`. A modifier must come *after* `.star` in the file: same specificity, so source order decides which `--core` wins. Sirius's glow was dialled back once the photographic backdrop arrived, since it no longer has to carry the sky on its own.
- **Splash typography** is Orbitron (loaded only by `index.html`), not the site's handwriting face. The `h1` is hollow: `color: transparent` plus `-webkit-text-stroke`, inside an `@supports` guard so browsers without text-stroke get a normal filled heading instead of invisible text. The stroke width is set in **`em`, not `px`** — a fixed pixel stroke closes up the counters at phone sizes and looks like a hairline on desktop. The page-wide white `text-shadow` is nulled on the `h1`, or it ghost-fills the hollow letters.

## Launch button blast

Pressing **Launch** on the splash sets off a neutron-star blast that doubles as the page transition into `landing_page.html`. Pure CSS and ~30 lines of inline JS — no images, no canvas, no library.

Layers, all in `style.css`: `.blast-core` (the flash), two `.blast-ring` shock fronts, and `.flash` (a full-screen wash). The JS writes `--bx`/`--by` on `<html>` at click time so the blast originates at the button rather than the centre of the screen.

Four things are easy to break:

- **The `.blast`/`.flash` divs live outside `<section>`.** `section` is `overflow: hidden`, so anything inside it gets clipped part-way through the expansion.
- **The rings animate `width`/`height`, not `transform: scale()`** — deliberately, against the usual advice. `scale()` multiplies the border thickness too, so a 2px shell became a ~7vmax slab by the time it crossed the screen and read as a spreading blob. Growing the box keeps the front a constant 2px. It costs layout on two elements for 800ms, which is the right trade here.
- **`.flash` ends on `filter: brightness(0.04)`, not on white.** It peaks bright, then darkens to near-black before navigating, so arriving at the dark landing page is seamless instead of a white-to-black cut.
- **Navigation is driven by `animationend` on `.flash`, with a 1600 ms `setTimeout` fallback** — `animationend` never fires in a background tab, and without the fallback the button would simply stop working. A `gone` flag stops the two paths from navigating twice.

The handler bails out early — letting the plain link work — for modified clicks (cmd/ctrl/shift/middle, so "open in new tab" still works) and for `prefers-reduced-motion`, where the CSS also sets `display: none` on both layers.

**Everything animates `opacity` or `transform`, except the rings.** That is deliberate. An earlier version faded out by animating `filter: brightness()` on the full-screen `.flash`; `filter` cannot be composited, so the last 430 ms repainted the whole viewport every frame — exactly while the browser was starting the next page, and it was visibly janky. The fade is now two stacked elements (`.flash` bright, `.blackout` solid `#05070f`) that animate opacity only. **Do not reintroduce an animated `filter`, `box-shadow` or `background` here.** `.blackout` matches the site background so the handover to the next page is invisible, and because it finishes last it — not `.flash` — owns the `animationend` that triggers navigation.

The rings are the one exception: they animate `width`/`height`, which costs layout. They are capped at 500 ms (590 ms for the trailing one) so they finish before `.flash` reaches full opacity at 480 ms and hides them — past that point the work is invisible as well as expensive. Their glow is a fixed `12px` blur, not the `4vmax` one they used to carry: blur radius is in device pixels, so a vmax blur on a box growing to 200vmax means re-rasterising an ~80px-soft edge around a 4000px circle every frame.

**A bfcache restore has to undo two things, or Back breaks.** The overlays finish with fill `forwards`, so the page is left frozen under an opaque layer; the browser restores that DOM verbatim and the splash looks blank until a refresh. But a bfcache'd page is *frozen, not destroyed* — **its pending timers pause and resume on restore**. Clearing the `gone` re-entry flag without also calling `clearTimeout` on the fallback timer re-arms a stale `go()`, which fires about a second after the restore and throws the visitor forward to the landing page again, so Back appears to do nothing at all. That was a real regression, introduced by a first pass at this fix that reset the flag alone. The handler must clear the timer, detach the `animationend` listener, drop the `fire` classes and reset `gone`.

A bfcache restore fires **no `load` and no `DOMContentLoaded`** — `pageshow` is the only hook, so the reset has to live there.

## Launch button

The button is a spacecraft hull, not a rectangle: nose to the right, notched tail, engine burn at the back.

Both layers share one `--hull` `clip-path` — `.btn` is the lit hull edge (a gradient showing through 2px of padding) and `.btn-face` is the dark cockpit it frames. Consequences of that clip worth knowing before editing:

- **`clip-path` clips descendants and pseudo-elements too.** The thruster therefore burns through the *inside* of the tail; anything positioned outside the hull to make an exhaust trail is simply cut away.
- **Glow must be `filter: drop-shadow`, not `box-shadow`.** `filter` is applied after the clip so the halo follows the hull outline; a `box-shadow` is clipped off with the corners.
- The layout is `flex` with asymmetric padding (`46px` right, `40px` left) because the nose cone eats more interior room than the tail notch. Centring still measures 0.0px at 320–1440px; re-measure if the polygon changes.
- `.btn-text` sets its own `text-shadow`, overriding the page-wide white one that otherwise muddies it.

The button is an `<a class="btn">`, not a `<button>` inside an `<a>`: that nesting was invalid HTML. `.btn` therefore needs `display: inline-block` and `text-decoration: none`. `index.html` also carries `<link rel="prefetch" href="landing_page.html">` so the next page is cached by the time the blast finishes.

## Hero card

The landing page hero is a single centred card: circular avatar in a gradient ring, location pill, name, role, three specialism pills, one-line blurb, and a single "Download Resume" call to action. There is deliberately no Projects button — the projects page is reached through the nav.

The card is glass, and **it deliberately carries no `backdrop-blur`.** That is not an oversight. The backdrop is a starfield of roughly 1px points, and a Gaussian blur spreads one such point over its whole kernel: measured through the card, the brightest star reads 143 with no blur, 49 at 1px, 40 at 1.5px and 24 — i.e. gone — at the `backdrop-blur-lg` (16px) this used to have. An empty strip inside the card measured a standard deviation of 0.23, mathematically flat. Any frosted-glass blur here erases the sky it is supposed to be showing, so "blurry" and "see-through" cannot both be had over a starfield.

What sells the glass instead is the **rim and the sheen**, not a blur and not the fill: `border-white/30`, `ring-1 ring-inset ring-white/15`, and a diagonal `bg-gradient-to-br from-white/[0.10] via-white/[0.03] to-white/[0.08]` reading as light catching a pane. Drop the border or the ring and the card dissolves into the page; raise the fill much past `white/10` and it goes back to looking like a solid slab. Current state measures 142 brightest / 1.49 stddev through the card, against 24 / 0.23 before.

The avatar uses `object-cover object-top` because `assets/images/profile.jpg` is a 1180x2096 portrait; top-anchoring keeps the face in frame. If the photo is swapped for a square or landscape headshot, `object-center` will usually frame better.

## Responsive conventions

The site targets 320px and up; there is no horizontal scroll at any width. When editing layout, keep to these patterns:

- **Gutters** — every container carries `px-4 sm:px-5` (or `px-4 sm:px-6`) so content never touches the screen edge.
- **Columns** — split at `sm:` for two-up (education cards, form fields, project grid) and `lg:` for three-up or side-by-side media. Avoid bare `w-1/2` / `lg:w-1/3`; write `w-full sm:w-1/2`.
- **Landing page navs** — the desktop sidebar (`lg:` and up, `w-32` fixed) and the mobile top bar (`lg:hidden`, `h-20`) are separate markup carrying the same six items. A new section must be added to **both**. The sidebar uses `justify-center gap-4` (the old `-mb-32` negative-margin spacing was removed — don't reintroduce it). The top bar is deliberately styled to match it: `bg-black/50 backdrop-blur-md` with white type, not the light bar it used to be. Its icons are sized by class (`h-6 w-6 sm:h-7 sm:w-7`) rather than by each SVG's own `width`/`height`, and it carries no `animate-bounce`, so all six labels share one baseline — the sidebar keeps its original per-icon sizes and its one bouncing icon.
- **The mobile bar is at capacity.** Six items fit exactly at 320px with nothing to spare (`overflow-x-auto` is there as a safety net, not as normal behaviour). A seventh item, or a longer label than "Experience", will start it scrolling — shorten labels instead.
- **Clearing the floating back arrow** — on `skills.html` and `projects.html` the back arrow is `fixed` and out of flow, so the first heading needs its own top padding to sit below it. The arrow's bottom edge lands at 60px (mobile) / 72px (desktop); the headings are set so their top clears that with ~12-20px to spare. Shrinking that padding without re-measuring will overlap the button on narrow screens.
- **Content offset** — pages with the fixed sidebar use `lg:pl-40` on their containers to clear it. Content is therefore centred within the area *beside* the sidebar, not the whole viewport; a measured offset of ~64px at desktop widths is correct, not a bug.
- **Buttons in a row** — use `flex flex-wrap justify-center gap-4` rather than `ml-4` on the second button, so they wrap instead of overflowing.

Text is centred at section level (headings, hero, about, skill cards). Prose that runs long stays left-aligned — experience bullets and form labels — because centring multi-line body copy hurts readability.

`index.html` is the only page with hand-written CSS (`assets/css/style.css`). It centres with flexbox on `section`. Sirius A scales from one custom property, `--core` on `.sirius`; the halo and wrapper are sized as multiples of it, so changing that single value rescales the star coherently. Every animation there is disabled under `prefers-reduced-motion`.

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

Both `landing_page.html` and `contact.html` submit to **Netlify Forms**. There is no backend and no third-party endpoint — Netlify detects the form at deploy time by scanning the deployed HTML.

Four things are load-bearing and must survive any edit to either form:

- `data-netlify="true"` on the `<form>` — this is what makes Netlify register it at all.
- `<input type="hidden" name="form-name" value="contact">` inside the form — Netlify routes the submission by this, and an AJAX post without it is rejected.
- `netlify-honeypot="bot-field"` plus the matching `<p style="display: none">` wrapping `<input name="bot-field">`. The wrapper is styled **inline, not with Tailwind's `hidden` class** — Tailwind arrives from the play CDN asynchronously, so a class-based rule would let the decoy field flash visible on a slow connection.
- The `id="msg"` status span.

Both forms share `name="contact"`, so Netlify merges them into one submission inbox. Renaming one splits the inbox in two.

The inline script is progressive enhancement only: it intercepts submit, posts url-encoded to `/`, and writes the status inline. With JS disabled the plain HTML form still posts normally and lands on Netlify's own confirmation page.

It **must** keep checking `res.ok`. `fetch` rejects only on network failure, never on a 4xx/5xx, and the previous Google Apps Script version omitted that check — when that endpoint started returning 403, the form went on reporting "Message Sent Successfully!" and messages were lost silently for an unknown stretch of time. On failure the form is deliberately *not* reset, so the visitor does not lose what they typed, and the error offers a `mailto:` fallback.

Netlify's free tier allows 100 submissions/month. Submissions are visible under Forms in the Netlify dashboard; email notification is configured there, not in this repo.

The phone number in the resume is deliberately kept off the HTML pages; it is only in the downloadable PDF.
