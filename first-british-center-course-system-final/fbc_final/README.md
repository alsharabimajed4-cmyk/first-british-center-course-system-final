# The First British Center — Online Course Distribution & Management System

Production-oriented PHP 8.2+/8.3 + MySQL 8/MariaDB web application for managing terms, courses, trainers, students, enrollments, OCR imports, smart scheduling, audit archives and printable schedules.

## Included
- HTTPS-ready deployment for Nginx + PHP-FPM and Apache/.htaccess.
- Google OAuth + username/email/password authentication.
- First-login profile completion.
- Role model: super_admin, admin, course_manager, data_entry, trainer, student, auditor.
- Personal activity archive and master audit archive.
- Login history.
- Admin-managed terms with automatic 20-teaching-day calculation.
- Friday exclusion and editable official/center holidays.
- Courses, levels, trainers, weekly trainer availability, students and enrollments.
- Country code / phone / WhatsApp fields and age calculation from date of birth.
- Smart distribution engine with:
  - trainer level eligibility;
  - trainer availability;
  - trainer conflict detection;
  - same-course repeat-gap rule (default 2 terms between assignments, so a Term 1 assignment is blocked in Term 2 and eligible again in Term 3);
  - workload balancing;
  - suspended-course exclusion;
  - simulation mode before writing a schedule;
  - proposed → approved → published workflow.
- Student conflict center.
- OCR upload for JPG/PNG/PDF with optional server-side Tesseract.
- Print/PDF-browser printing with the supplied First British Center logo.
- Reserved LiveKit environment settings for the online classroom integration phase.

## Project structure
```
public/                 web root only
  index.html
  css/app.css
  js/app.js
  api/index.php
  assets/logo.png
config/bootstrap.php    DB, sessions, CSRF, audit and scheduling helpers
database/schema.sql
install/seed.php
deploy/                 installer, Nginx, Certbot, Ubuntu bootstrap
storage/                private upload areas (never expose directly)
docs/
```

## Deployment
1. Copy the project to the VPS.
2. `cp .env.example .env`
3. Edit `.env` with database credentials and a strong admin password (16+ chars).
4. Create the MySQL/MariaDB database and user.
5. Run:
   `bash deploy/install.sh`
6. Configure Nginx document root to `.../public` using `deploy/nginx.conf.example`.
7. Obtain HTTPS:
   `sudo bash deploy/https-certbot.sh courses.example.com admin@example.com`
8. Visit the HTTPS URL and sign in.

## Google OAuth
Set these values in `.env`:
- GOOGLE_CLIENT_ID
- GOOGLE_CLIENT_SECRET
- GOOGLE_REDIRECT_URI=https://YOUR-DOMAIN/api/?action=google_callback

Register the exact HTTPS callback in Google Cloud Console. The application uses state validation for the OAuth flow.

## OCR
Install Tesseract on Ubuntu with `deploy/ubuntu-bootstrap.sh`, then set:
`TESSERACT_BIN=/usr/bin/tesseract`

The application stores uploads outside the public web root and requires a human review step conceptually before treating OCR text as authoritative. The included UI displays extracted text for review; importing structured records can be extended with field mapping rules for your exact forms.

## Scheduling policy
The default policy is:
- 20 teaching days per term.
- Friday excluded.
- Active Admin-entered holidays excluded.
- Same trainer + same course is blocked for the immediately following term and allowed again after one intervening term (minimum gap = 2 term positions). This is configurable in Settings but never below 2 through the scheduling endpoint.
- Trainers are eligible for levels within their configured min/max level order.
- Availability is required for assignment.
- Workload balancing is enabled by default.

The schedule is generated per teaching week. A course's `sessions_per_week` controls how many sessions are placed in each 5-teaching-day block, subject to its preferred weekday/time and trainer availability.

## Security notes
- Keep `.env` outside public web root (the package does so by default).
- Never commit production secrets.
- Use HTTPS.
- Keep database backups encrypted and restricted.
- Review audit logs regularly.
- The production installer does not create a demo trainer. Use install/seed_demo.php only for a test environment.

## Important production note
This is the complete deployable application package, but Google OAuth credentials, production database credentials, domain, TLS certificate and any external OCR/LiveKit credentials are environment-specific and therefore intentionally not embedded in the ZIP.
