# Deploying a new IGH website

Use this runbook when creating a GitHub repository and hosting a new IGH project
on the existing cPanel account. The [Service Menu deployment](DEPLOYMENT.md)
is the first implementation of this pattern.

1. Confirm the requested URL, repository name and visibility, production branch,
   framework, and intended document root. Inspect cPanel Domains and File Manager
   to identify an unused destination with no overlap with existing deployments.
2. Create the GitHub repository under the approved owner. Add the website source,
   build or validation steps, `.github/workflows/deploy.yml`, `DEPLOYMENT.md`,
   `AGENTS.md`, and `CLAUDE.md`. All assistants follow the same pull-request
   process. Keep repository visibility and credentials documented separately.
3. Package only website output. For a static site, validate local links and
   assets. For a compiled site, pin the build runtime and use its lockfile. Test
   the result at the site's actual URL prefix and verify rewrite rules.
4. Give each site its own release reference, publisher, and server-side
   destination. For public repositories, cPanel can pull a validated release
   over HTTPS without credentials. For private repositories, arrange a
   repository-scoped read-only credential for cPanel or a host-supported
   restricted delivery identity. Keep secrets outside Git and the web root.
   Never expose private releases through the Service Menu repository.
5. Install the publisher outside the web root and test staging with manual
   approval before enabling production. Rehearse rollback, verify the public
   URL and mobile layout, and record the exact hosting path and activation
   status in the new repository's deployment guide.
6. In normal operation, review the pull request, merge the approved changes,
   and check GitHub Actions and the public site. If publication fails, inspect
   the publisher log and use the project's documented rollback procedure.
