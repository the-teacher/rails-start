# Rails Production Commands (Container Level)

Simple reference for `__RailsApp__/Makefiles/300_Production.mk` commands executed inside the container.

**Note**: These commands are executed inside the Rails container and are designed for production environment.

## Available Commands

<table width="100%">
<tr><th>Command</th><th>Description</th></tr>

<tr><td colspan="2"><strong>Help</strong></td></tr>
<tr><td><code>make production-help</code></td><td>Show production Rails commands help</td></tr>

<tr><td colspan="2"><strong>Production Setup</strong></td></tr>
<tr><td><code>make production-setup</code></td><td>Setup production environment (bundle + db-create + db-migrate + assets-precompile)</td></tr>

<tr><td colspan="2"><strong>Bundle Management</strong></td></tr>
<tr><td><code>make production-bundle</code></td><td>Install production dependencies</td></tr>
<tr><td><code>make production-bundle-reset</code></td><td>Reset bundle config (for dev mode)</td></tr>

<tr><td colspan="2"><strong>Work with Database</strong></td></tr>
<tr><td><code>make production-db-create</code></td><td>Create production database</td></tr>
<tr><td><code>make production-db-migrate</code></td><td>Run production database migrations</td></tr>
<tr><td><code>make production-db-seed</code></td><td>Seed production database</td></tr>
<tr><td><code>make production-db-reset</code></td><td>Reset production database (with confirmation)</td></tr>
<tr><td><code>make production-db-rollback</code></td><td>Rollback production database migration</td></tr>

<tr><td colspan="2"><strong>Assets Management</strong></td></tr>
<tr><td><code>make production-assets-precompile</code></td><td>Precompile assets for production</td></tr>
<tr><td><code>make production-precompile</code></td><td>Precompile assets for production (alias)</td></tr>
<tr><td><code>make production-assets-clean</code></td><td>Clean production assets</td></tr>

<tr><td colspan="2"><strong>Server Management</strong></td></tr>
<tr><td><code>make production-server</code></td><td>Start Rails production server</td></tr>
<tr><td><code>make production-start</code></td><td>Start Rails production server (alias)</td></tr>
<tr><td><code>make production-stop</code></td><td>Stop Rails production server</td></tr>

<tr><td colspan="2"><strong>Console</strong></td></tr>
<tr><td><code>make production-console</code></td><td>Open Rails production console</td></tr>

<tr><td colspan="2"><strong>Logs</strong></td></tr>
<tr><td><code>make production-log-tail</code></td><td>Tail production log</td></tr>
<tr><td><code>make production-logs</code></td><td>Tail production log (alias)</td></tr>
<tr><td><code>make production-log-clear</code></td><td>Clear production log</td></tr>

</table>
