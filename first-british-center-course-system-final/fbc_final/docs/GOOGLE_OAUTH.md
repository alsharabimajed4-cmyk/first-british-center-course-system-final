# Google OAuth setup

1. Create/select a Google Cloud project.
2. Configure the OAuth consent screen.
3. Create an OAuth Web Application client.
4. Add your HTTPS origin as an authorized JavaScript origin if needed by your broader deployment.
5. Add the exact redirect URI:
   `https://YOUR-DOMAIN/api/?action=google_callback`
6. Put the client ID and secret into `.env`.
7. Test Google login over HTTPS.

The callback validates an OAuth state value stored in the server session and fetches the OpenID user profile from Google's userinfo endpoint.
