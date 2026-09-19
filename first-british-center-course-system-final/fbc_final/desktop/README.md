# Windows installer

The Windows package bundles the application, PHP and MariaDB. The installer places everything under the current user's local application data directory, so administrator permissions are not required.

On first launch, `launch.ps1` creates a local database on port `3307`, imports `database/schema.sql`, creates the administrator account, starts PHP on port `8787`, and opens the application in the default browser.

The administrator password is generated on first launch and written to the local application's `.env` file. Change it after signing in.

The installer is built by the `build-windows-installer.yml` GitHub Actions workflow. Run it manually from the Actions tab and download the `FirstBritishCenter-Setup` artifact.