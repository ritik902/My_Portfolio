# My_Portfolio

Personal portfolio of **Ritik Sharma** — AI/ML Engineer working on Computer Vision,
Generative AI and Edge Deployment. Currently GenAI Engineer II at HCL Tech, Pune.

**Live:** https://myportfolio0027.netlify.app/

## Pages

| Page | Purpose |
| --- | --- |
| `index.html` | Splash screen |
| `landing_page.html` | Main page — about, experience, education, contact |
| `skills.html` | Technical skills, coding profiles, interests |
| `projects.html` | Personal projects, filterable by category |
| `contact.html` | Standalone contact form |

## Layout

```
assets/
  css/      style.css
  data/     projects.json      — source of truth for the projects grid
  docs/     resume PDF + certificates/
  icons/    svg/png logos, favicon
  images/   photos, backgrounds, projects/
  media/    video files
```

## Running locally

Assets are referenced relative to the repo root and `projects.html` fetches
`assets/data/projects.json`, so the site needs to be served over HTTP:

```sh
python3 -m http.server 5501
# http://localhost:5501/index.html
```

The repo is also set up for the VS Code Live Server extension on port 5501.

## Contact

ritik004sharma@gmail.com · [LinkedIn](https://www.linkedin.com/in/ritik-sharma-487240243/) · [GitHub](https://github.com/ritik902)
