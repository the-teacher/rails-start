# Rails Production Commands

Simple reference for `Makefiles/300_Rails-Production.mk` commands in logical usage order.

**Note**: These commands delegate to `__RailsApp__/Makefiles/300_Production.mk` inside the container for maximum code reuse.

## Available Commands

<table width="100%">
<tr><th>Command</th><th>Description</th></tr>

<tr><td colspan="2"><strong>Help & Setup</strong></td></tr>
<tr><td><code>make rails-production-help</code></td><td>Show production Rails commands help</td></tr>
<tr><td><code>make rails-production-setup</code></td><td>Full production setup (delegated)</td></tr>

<tr><td colspan="2"><strong>Bundle Management</strong></td></tr>
<tr><td><code>make rails-production-bundle</code></td><td>Install production dependencies</td></tr>
<tr><td><code>make rails-production-bundle-reset</code></td><td>Reset bundle config for development</td></tr>

<tr><td colspan="2"><strong>Container Management</strong></td></tr>
<tr><td><code>make rails-production-up</code></td><td>Start production containers (detached)</td></tr>
<tr><td><code>make rails-production-down</code></td><td>Stop production containers</td></tr>
<tr><td><code>make rails-production-restart</code></td><td>Restart production containers</td></tr>

<tr><td colspan="2"><strong>Work with Database</strong></td></tr>
<tr><td><code>make rails-production-db-create</code></td><td>Create production database</td></tr>
<tr><td><code>make rails-production-db-migrate</code></td><td>Migrate production database</td></tr>
<tr><td><code>make rails-production-db-seed</code></td><td>Seed production database</td></tr>
<tr><td><code>make rails-production-db-setup</code></td><td>Setup production database (create + migrate + seed)</td></tr>
<tr><td><code>make rails-production-db-reset</code></td><td>Reset production database (with confirmation)</td></tr>
<tr><td><code>make rails-production-db-rollback</code></td><td>Rollback production database migration</td></tr>

<tr><td colspan="2"><strong>Assets Management</strong></td></tr>
<tr><td><code>make rails-production-assets</code></td><td>Precompile assets for production</td></tr>
<tr><td><code>make rails-production-precompile</code></td><td>Precompile assets (alias)</td></tr>
<tr><td><code>make rails-production-assets-clean</code></td><td>Clean production assets</td></tr>

<tr><td colspan="2"><strong>Server Management</strong></td></tr>
<tr><td><code>make rails-production-server</code></td><td>Start Rails server (interactive mode)</td></tr>
<tr><td><code>make rails-production-server-daemon</code></td><td>Start Rails server (daemon mode)</td></tr>
<tr><td><code>make rails-production-start</code></td><td>Full setup + start server in daemon mode</td></tr>
<tr><td><code>make rails-production-stop</code></td><td>Stop Rails production server</td></tr>

<tr><td colspan="2"><strong>Console & Access</strong></td></tr>
<tr><td><code>make rails-production-console</code></td><td>Open production Rails console</td></tr>
<tr><td><code>make rails-production-bash</code></td><td>Access bash in production container</td></tr>

<tr><td colspan="2"><strong>Logs</strong></td></tr>
<tr><td><code>make rails-production-log-tail</code></td><td>Tail production application log</td></tr>
<tr><td><code>make rails-production-logs</code></td><td>Tail production application log (alias)</td></tr>
<tr><td><code>make rails-production-log-clear</code></td><td>Clear production application log</td></tr>
<tr><td><code>make rails-production-docker-logs</code></td><td>View Docker container logs</td></tr>

<tr><td colspan="2"><strong>Combined Workflows</strong></td></tr>
<tr><td><code>make rails-production-full-start</code></td><td>Complete startup (containers + setup + server)</td></tr>

</table>
