# Fennec Finance

Production finance for Fennec Productions: a ledger of money in and out, productions with budgets, and invoices with payments. One HTML file, works on phone and desktop, free to run.

- `index.html` — the whole app, with the Fennec Supabase project built in.
- `schema.sql` — creates the tables in a Supabase project.
- `vercel.json` — tells Vercel to serve the folder as a static site.
- Brand assets, all derived from the official Fennec Productions wordmark:
  - `logo.png` — the wordmark on a transparent background (sidebar and sign-in; inverted automatically in dark mode).
  - `og.png` — 1200×630 preview image shown when the link is shared on WhatsApp, Slack, X, LinkedIn, etc.
  - `icon-192.png`, `icon-512.png`, `apple-touch-icon.png` — the "F" app icon for the browser tab, Android and iPhone home screens; listed in `manifest.webmanifest`.

  To refresh them from a new logo file, re-run the generator (a short Playwright script that
  traces the logo onto a transparent canvas and renders the icons and preview image; it lives
  outside the repo). The share-preview tags in `index.html` (`og:url`, `og:image`,
  `twitter:image`, `canonical`) carry the absolute production URL; change those four lines if
  the site moves to a custom domain.

Live at the Vercel URL; every push to `main` redeploys.

## Using it

Open the site and sign in. Accounts are created by the owner in the Supabase dashboard (**Authentication → Users → Add user**), not from the app.

On a phone, use **Share → Add to Home Screen** and it opens like an app.

### What it does

- **Home** — net position, cash in hand, bank balance, what clients owe, spend by department.
- **Ledger** — every entry, grouped by day, with search and filters by production and direction.
- **Productions** — each with a budget; spent, received and profit so far update from the ledger.
- **Invoices** — open one and tap **Record payment** when a client pays; the unpaid amount updates and the invoice is marked paid once settled.
- **Settings** — exchange rates, categories, payees, light/dark theme, and database connection.

All reporting is in LYD. Foreign-currency entries keep the rate confirmed at the time, so updating rates in Settings never changes history.

## Owner setup checklist (Supabase dashboard)

The database is already connected. Two things must be done in the dashboard before real data goes in:

1. **Turn off public sign-ups.** **Authentication → Sign In / Providers → Allow new users to sign up → off.** The schema gives every signed-in user full access, and sign-ups are on by default, so without this anyone who finds the page could create an account and read the books.
2. **Create the team's accounts.** **Authentication → Users → Add user**, email + password, one per person. Remove any accounts you don't recognise.

Optional: **Authentication → Settings → Leaked password protection → on.**

## Connecting a different Supabase project

1. Create the project at supabase.com (free tier; Frankfurt is closest to Libya).
2. **SQL Editor → New query**, paste `schema.sql`, Run.
3. Do the owner checklist above in that project.
4. **Project Settings → API**: copy the *Project URL* and the *anon public* key (never the service_role key).
5. In the app: **Settings → Use a different Supabase project**, paste both, **Test & connect**. The choice is per browser; **Use default database** switches back.

To make a new project the built-in default for everyone, change `DEFAULT_SB` near the top of the script in `index.html` and push.

The anon key is safe to put in the page: Row Level Security in the schema means nothing is readable without signing in — provided public sign-ups are off.

## Development

No build step. Open `index.html` locally, or push to `main` to deploy. If the database library can't be loaded the app runs offline and says so; nothing is saved in that mode.
