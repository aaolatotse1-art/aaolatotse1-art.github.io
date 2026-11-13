# Portfolio redesign — setup

## What's in this folder

| File | What it is |
|---|---|
| `index.html` | The public portfolio. Playfair Display, white→grey background, gradient cards, Anime.js motion, live GitHub, live résumé, anonymous visit tracking. |
| `admin.html` | Your private dashboard. Shows nothing until you sign in with your own email. Has a **Preview with sample data** button so you can see it before setup. |
| `supabase/setup.sql` | Creates the visits table and the security rules. Run once. |
| `files/Aobakwe_Olatotse_Resume.pdf` | Your updated résumé (the download and "View PDF" buttons point here). |

Copy your existing assets next to these files, keeping their paths: `profile.jpeg`, `images/` (thumbs, fulls, certificates), `videos/`. Missing images fall back to icons, so nothing breaks while you gather them.

## Editing content

- **Résumé:** edit the `window.RESUME` block near the bottom of `index.html` (experience, skills, certifications…). Change `updated:` to today's date. Replace the PDF in `files/` when you update it.
- **Contact / GitHub / LinkedIn:** edit `window.PORTFOLIO_CONFIG` in `index.html`. LinkedIn stays hidden until you add its URL.
- **GitHub section:** loads automatically from `api.github.com` for `aaolatotse1-art`. Add a description to each repo on GitHub and it will show here. GitHub allows about 60 requests an hour per visitor's network without a token; results are cached for 10 minutes, and a saved snapshot is shown if the limit is hit.

## Turning on the private dashboard (Supabase, free tier)

Supabase menu names change from time to time — if a label below doesn't match exactly, look for the nearest equivalent.

1. **Create a project** at supabase.com.
2. **Run the SQL:** SQL Editor → New query → paste `supabase/setup.sql` → Run. If you'll sign in with a different email, change it on the first `create function` line before running.
3. **Create your login:** Authentication → Users → Add user → enter your email (the same one as in the SQL).
4. **Block other sign-ups:** Authentication → Sign In / Providers → turn off "Allow new users to sign up".
5. **Allow the sign-in link to return to your site:** Authentication → URL Configuration → set Site URL to your site, and add `https://YOUR-SITE/admin.html` to Redirect URLs.
6. **Copy your keys:** Project Settings → API (or API Keys). Copy the **Project URL** and the **anon / publishable** key. Paste both into:
   - `index.html` → `window.PORTFOLIO_CONFIG.supabaseUrl` and `supabaseAnonKey`
   - `admin.html` → `window.ADMIN_CONFIG.supabaseUrl` and `supabaseAnonKey`
   Never paste the `service_role` / secret key anywhere in these files.
7. **Publish** and open `https://YOUR-SITE/admin.html`. Enter your email, click the link in your inbox, and you're in.

### How the privacy works

- The anon key in the page can only **add** visit rows. Reading them requires signing in as the email in `setup.sql`; this is enforced by the database (Row Level Security), not by hiding the page. Other signed-in accounts see zero rows.
- `admin.html` is marked `noindex` and isn't linked from the portfolio.
- Your own visits: after you sign in once, that browser stops being counted (toggle at the bottom of the dashboard).
- Visitors with Do Not Track or Global Privacy Control switched on are not recorded. No IP addresses, names or cookies are stored; location is estimated from the browser's time zone only.

### What the dashboard shows

Visitors, new visitors, page views, average time on page, résumé opens, GitHub clicks (each compared with the previous period) · traffic over time with a table view · how far down the page people scroll (section reach) · referrers and campaign links (`?utm_source=cv-email`) · what they clicked · approximate country · device / browser / OS · a live activity feed — select a visitor ID to follow one visit from arrival to exit · CSV export.

## Hosting

Any static host works (GitHub Pages, Netlify, Cloudflare Pages). For GitHub Pages: create a repo named `aaolatotse1-art.github.io`, upload the folder, and enable Pages. That repo and your profile-README repo are hidden from the GitHub section by `githubHideRepos`.
