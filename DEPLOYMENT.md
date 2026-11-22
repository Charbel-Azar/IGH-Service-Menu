# Service Menu deployment

The standalone menu is served at https://www.ighclinic.com/Services-Menu/ from
`/home/ighclinic/public_html/Services-Menu/`. Its production source is `master`.
The main clinic homepage and its `/services` route belong to a different repository.

This site ships static HTML and PNGs. No compilation is required. Preview it
with `python3 -m http.server 8000` from the repository root and open
`http://localhost:8000/`. Check narrow and wide viewports, the service links,
and the logo, favicon, and treatment icons.

GitHub Actions checks pull requests and pushes to `master`. After validation
on `master`, Actions advances `cpanel-release`. The cPanel cron job runs the
installed copy of `ops/pull-service-menu.sh`, downloads that branch over HTTPS,
and publishes only the ten explicitly listed website files. The public release
branch requires no cPanel credentials in GitHub. Keep the installed publisher
and its allowlist under separate review when adding assets or changing paths.

The installed publisher accepts `stage` or `production`. Staging writes to
`/home/ighclinic/.igh-service-menu-deploy/staging/` outside the web root.
Production runs only when the hosting administrator points the scheduled job
at `production`. Consult `/home/ighclinic/.igh-service-menu-deploy/deploy.log`
for confirmed file changes. After a run, verify the public HTTPS page and
assets, the requested content, and the main clinic homepage and services route.


## Last verified on 22 November 2026

**Production publishing enabled.** The first production cron run returned
successfully at 16:30 Beirut time. The initial GitHub baseline was taken from
the live site, and the production check preserved that content.

In [cPanel](https://ighclinic.com/cpanel), open **Advanced → Cron Jobs** and
look for the job below. Its schedule is `*/5 * * * *`.

```sh
/bin/bash /home/ighclinic/igh-service-menu-publisher.sh production >> /home/ighclinic/igh-service-menu-cron.log 2>&1 && /usr/bin/touch /home/ighclinic/.igh-service-menu-deploy/production-ok
```

The installed script corresponds to [the repository publisher](ops/pull-service-menu.sh).
In cPanel File Manager, check the timestamp on `production-ok` to confirm
a successful scheduled run, including a run where the files already match.
Check `/home/ighclinic/igh-service-menu-cron.log` for errors. The publisher's
`deploy.log` records runs that changed files. Then verify the public menu
and assets against the approved release.

For the main clinic site and new IGH projects, start with
[IGH-HOSTING.md](IGH-HOSTING.md).

## Rollback

Revert the affected commit through a pull request to `master` and allow the
normal workflow to release the revert. For an urgent rollback, pause the cron
job and restore only the affected files from the corresponding timestamped
directory under `/home/ighclinic/.igh-service-menu-deploy/rollback/`. Verify the
restored files and public URL before resuming scheduled publication. The
pre-connection archive is `/home/ighclinic/igh-service-menu-predeploy-20261122.zip`.
