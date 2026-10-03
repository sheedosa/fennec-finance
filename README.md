# Fennec Finance

A single-file web app for tracking production finances. Works on phone and desktop. Free to run.

- `index.html` — the whole app. Opens in demo mode with sample data until you connect a database.
- `schema.sql` — creates the tables in your Supabase project.

## Set up (about 15 minutes)

1. **Create a Supabase project** at supabase.com (free tier). Any region; Frankfurt is closest to Libya.
2. **Run the schema.** Dashboard → SQL Editor → New query → paste `schema.sql` → Run.
3. **Turn off public sign-ups.** Dashboard → Authentication → Sign In / Providers → switch off *Allow new users to sign up*. **Do not skip this:** the schema gives every signed-in user full access, and with sign-ups on, anyone who finds the page can create an account with the anon key and read your books.
4. **Add a user.** Dashboard → Authentication → Users → Add user → email + password. Repeat for each team member.
5. **Get the keys.** Dashboard → Project Settings → API. Copy the *Project URL* and the *anon public* key. (Never the service_role key.)
6. **Host `index.html`.** Any static host works and all have a free tier:
   - Netlify: drag the `fennec-finance` folder onto app.netlify.com/drop
   - Vercel, GitHub Pages, or Cloudflare Pages work the same way
   - For testing, you can also just double-click the file to open it locally
7. **Connect.** Open the app → Settings → paste the URL and key → Connect → sign in.

Add the page to your phone's home screen (Share → Add to Home Screen) and it behaves like an app.

## Moving to a different Supabase account later

Create the new project, run `schema.sql` there, then in the app go to Settings → Disconnect and connect with the new URL and key. To carry data across, export each table as CSV from the old project (Table Editor → Export) and import it in the new one.

## Notes

- All reporting is in LYD. Foreign-currency entries store the rate you confirmed at the time, so history doesn't shift when you update rates in Settings.
- Invoice "Paid" and "Balance" come from transactions linked to that invoice.
- The anon key is safe to put in the page; Row Level Security in the schema means nothing is readable without signing in — provided public sign-ups are off (step 3).

## Deploy to Vercel from GitHub

1. Create an empty repository on GitHub (e.g. `fennec-finance`); private is fine.
2. In this folder:
   ```
   git remote add origin https://github.com/YOUR-USER/fennec-finance.git
   git push -u origin main
   ```
3. On vercel.com: Add New → Project → Import the repo → Deploy. No build settings needed; it's a static site.
4. Open the Vercel URL → Settings → connect your Supabase project → sign in.

Every push to `main` redeploys automatically.
