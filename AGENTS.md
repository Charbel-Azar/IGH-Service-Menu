# IGH Service Menu

This repository owns the standalone menu at
https://www.ighclinic.com/Services-Menu/. Follow [DEPLOYMENT.md](DEPLOYMENT.md).

Make edits on a topic branch, preview the static page, and open a pull request
to `master`. Check local links and images, and review a narrow and a wide
viewport. Merge once approved and the checks pass. GitHub Actions and cPanel
handle publication from `master`; verify the public page afterward.

Keep deployment credentials outside Git. Review changes to the publisher and
its explicit file allowlist before adding files to the live release.
