# Hostinger-style shared hosting deployment

If your plan provides PHP + MySQL but not Nginx root control:

1. Put the application outside `public_html` if your account allows it.
2. Expose only the `public` directory as the domain/subdomain document root.
3. If the panel cannot change the document root, copy the contents of `public/` into the subdomain web root and adjust the API bootstrap path from `../../config/bootstrap.php` to the actual private config location. Prefer a document-root setting instead of exposing the private project directories.
4. Create the MySQL database/user in the hosting panel.
5. Edit `.env` with the database values.
6. Run `php install/seed.php` via SSH if available.
7. Enable HTTPS from the hosting panel.
8. Set Google OAuth redirect to the exact HTTPS domain.
