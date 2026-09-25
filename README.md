# JEBS — Production School Website + Secure Admin

This package is a production-oriented static school website connected to **Supabase** for authentication, PostgreSQL data, Row Level Security (RLS) and image storage.

It is designed for **Jyoti English Boarding School, Krishnapur-5, Kanchanpur** and uses the school's blue/gold visual direction. Replace the placeholder logo/photos/content from Admin.

## What this version fixes

- Real online database instead of browser `localStorage`
- Supabase email/password authentication
- Admin/staff authorization using a protected `profiles` table
- PostgreSQL RLS on every application table
- Private student records
- Private student image bucket
- Public school media bucket for hero/gallery/facilities/teacher/achievement photos
- Admin-editable school settings
- Hero slider management
- Facilities with photo + detailed information
- Teacher photo/name/position/subject/phone/email/bio
- Private student records: name/class/address/parent/parent phone/notes
- Gallery and achievement management
- Notices and calendar/events
- Admission enquiry inbox
- Contact-message inbox
- Facebook / YouTube / Instagram / TikTok / X / Messenger links
- Admin-editable Google Maps embed URL
- Password change from Admin
- Security headers for Netlify
- `robots.txt` disallowing the admin page from search engines
- Responsive public website and responsive admin dashboard

## Important security truth

No website can honestly promise that “nothing can ever happen.” Security is a process. This project provides a strong baseline, but the school must still use strong passwords, keep accounts private, update dependencies, back up data and monitor the service.

**Never put a Supabase `service_role` / secret key in `config.js` or in any browser code.** Only the publishable/anon key is allowed there. RLS is the security boundary.

For a public production launch, also consider enabling a CAPTCHA/Turnstile challenge for public Admission and Contact forms to reduce automated spam.

---

# STEP 1 — Create Supabase project

1. Open Supabase and create a new project.
2. Choose a strong database password and keep it private.
3. Wait until the project is ready.
4. Open **SQL Editor**.
5. Open this package's `supabase-schema.sql`.
6. Paste the complete SQL into Supabase SQL Editor.
7. Run it.

The SQL creates the database tables, RLS policies, public/private storage buckets and initial sample records.

## STEP 2 — Create the first Admin account

Do this in **Supabase → Authentication → Users → Add user**.

Create an email/password account for the school's administrator.

Then copy that user's UUID.

In SQL Editor run:

```sql
insert into public.profiles (id, full_name, role)
values ('PASTE-USER-UUID-HERE', 'School Administrator', 'admin');
```

Replace the UUID with the actual user UUID.

Do not create the profile with `role='admin'` for ordinary staff accounts. Use `staff` for staff who need content management but should not have admin-only deletion/profile-management powers.

## STEP 3 — Configure the website

Open `config.js`.

Replace:

```js
window.JEBS_CONFIG = {
  SUPABASE_URL: 'https://YOUR-PROJECT.supabase.co',
  SUPABASE_ANON_KEY: 'YOUR-PUBLISHABLE-ANON-KEY'
};
```

with the values from:

**Supabase → Project Settings → API**

Use the project's **publishable/anon key**.

### Never use

- service_role key
- secret key
- database password
- JWT secret

inside `config.js`.

It is normal for the publishable/anon key to be visible in a browser website. The database must be protected by RLS.

## STEP 4 — Test locally

Use VS Code.

Recommended:

1. Install the **Live Server** extension.
2. Open the project folder.
3. Right-click `index.html`.
4. Select **Open with Live Server**.
5. Open `/admin.html`.
6. Login with the Supabase Admin account you created.

Test:

- Add a hero slide.
- Upload a hero photo.
- Add a teacher.
- Add a gallery photo.
- Publish a notice.
- Add an event.
- Change school contact/social links.
- Add the Google Maps embed URL.
- Submit the public admission form.
- Confirm the admission appears in Admin → Admission Inbox.
- Submit the Contact form.
- Confirm the message appears in Admin → Messages.
- Change the admin password.
- Sign out and sign back in.

## STEP 5 — Upload the real school logo

The site currently includes a safe placeholder `assets/school-logo.svg`.

For the actual school launch, either:

- upload the real logo to a public image host/storage and put its URL in **Admin → School Settings → Logo URL**, or
- replace the placeholder asset before deployment.

For a polished final site, use a transparent PNG/SVG of the actual school logo.

## STEP 6 — Add real school photos

From Admin:

- Hero Slider → upload school building/hero photos
- Facilities → upload Science Lab, Computer Lab, Library, Sports & Playground, Transportation and Classroom photos
- Gallery → upload school events/photos
- Teachers → upload teacher portraits
- Achievements → upload certificates/award/event photos

Images are limited to 5 MB by the dashboard and accepted as JPG, PNG, WebP or SVG.

## STEP 7 — Google Maps

1. Open Google Maps.
2. Search for the school.
3. Choose **Share → Embed a map**.
4. Copy the URL inside the iframe `src="..."`.
5. Open **Admin → School Settings**.
6. Paste that URL into **Google Maps Embed URL**.
7. Save.

Do not paste arbitrary HTML into the map field. This version intentionally stores only the iframe URL.

## STEP 8 — Social media

Admin → School Settings:

- Facebook Page URL
- YouTube Channel URL
- Instagram URL
- TikTok URL
- X/Twitter URL
- Messenger URL

Use the school's actual page/channel URLs. The YouTube field is intended for the **school's channel**, not a generic YouTube homepage.

## STEP 9 — Domain + hosting

For a beginner-friendly public launch, use **Netlify** or **Vercel** with HTTPS enabled.

Netlify is particularly simple for this package because `_headers` and `netlify.toml` are already included.

### Netlify basic flow

1. Create a Netlify account.
2. Choose **Add new site → Deploy manually** for a quick test, or connect a GitHub repository for ongoing updates.
3. Upload the complete project folder.
4. Make sure `config.js` contains the real Supabase URL + publishable key.
5. Open the Netlify URL.
6. Test the public site.
7. Open `/admin.html` and test Admin.
8. Connect the school's domain from Netlify's Domain settings.
9. Enable HTTPS / certificate.

For long-term maintenance, GitHub → Netlify automatic deployment is recommended.

## STEP 10 — Production security checklist

Before giving the site to the school:

- [ ] Real Admin account created in Supabase Auth
- [ ] Admin profile has `role='admin'`
- [ ] No service_role/secret key in project files
- [ ] Default/demo credentials are not used
- [ ] Strong unique admin password set
- [ ] HTTPS working
- [ ] RLS enabled on all tables
- [ ] Student table is not publicly readable
- [ ] Student storage bucket is private
- [ ] Public bucket contains only intentionally public images
- [ ] Admission form works
- [ ] Contact form works
- [ ] Admin inbox works
- [ ] Social links point to official school accounts
- [ ] Google Maps points to the correct school
- [ ] School email/phone/address verified
- [ ] Real logo installed
- [ ] Real hero/facility/gallery photos installed
- [ ] Notice/calendar tested
- [ ] Mobile phone tested
- [ ] Admin logout tested
- [ ] Password change tested
- [ ] Database backup/retention plan configured in Supabase
- [ ] CAPTCHA/Turnstile considered for public forms

## Student privacy

Student information such as address and parent phone is intentionally kept in a private database table and private storage bucket. Do not publish student lists or personal information on the public site unless the school has an appropriate reason and permission.

## Automatic SMS / Messenger

The secure base package stores Admission and Contact submissions in the Admin Inbox.

A website cannot silently send an SMS or Messenger message just because a visitor submitted a form. Automatic notifications require a server-side integration with the relevant provider/API.

The safe architecture is:

`Public Form → protected server endpoint → notification provider → Admin`

Do not put provider secret/API keys in frontend JavaScript.

## Future upgrades

Recommended next upgrades after the first successful launch:

1. Cloudflare Turnstile on public forms
2. Admin activity/audit log
3. Scheduled database backups
4. Automatic email notification to school office
5. SMS notification using a server-side SMS provider
6. WhatsApp/Meta integration where officially supported
7. Staff account management through a protected server-side function
8. Nepali calendar/date support
9. SEO/Open Graph images
10. School-specific favicon and PWA manifest

## Files

- `index.html` — public website
- `public.js` — public data loading/forms
- `app.css` — public design
- `admin.html` — secure admin shell
- `admin.js` — authentication + dashboard + CRUD
- `admin.css` — admin design
- `config.js` — Supabase project configuration
- `config.example.js` — configuration template
- `supabase-schema.sql` — database + RLS + storage setup
- `_headers` / `netlify.toml` — security headers for Netlify
- `robots.txt` — search crawler rules
- `assets/` — placeholder logo/facility graphics
