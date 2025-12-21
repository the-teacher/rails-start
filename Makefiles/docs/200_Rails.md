# Rails Development Commands

Simple reference for `Makefiles/200_Rails.mk` commands in logical usage order.

**Note**: These commands delegate to `__RailsApp__/Makefiles/200_Rails.mk` inside the container for maximum code reuse.

## Available Commands

<table width="100%">
<tr><th>Command</th><th>Description</th></tr>

<tr><td colspan="2"><strong>Help & Setup</strong></td></tr>
<tr><td><code>make rails-help</code></td><td>Show Rails development commands help</td></tr>
<tr><td><code>make rails-setup</code></td><td>Full development setup (delegated)</td></tr>

<tr><td colspan="2"><strong>Bundle Management</strong></td></tr>
<tr><td><code>make rails-bundle</code></td><td>Install development dependencies</td></tr>

<tr><td colspan="2"><strong>Work with Database</strong></td></tr>
<tr><td><code>make rails-db-create</code></td><td>Create development database</td></tr>
<tr><td><code>make rails-db-migrate</code></td><td>Run development database migrations</td></tr>
<tr><td><code>make rails-db-seed</code></td><td>Seed development database</td></tr>

<tr><td colspan="2"><strong>Server Management</strong></td></tr>
<tr><td><code>make rails-server</code></td><td>Start Rails server (interactive mode)</td></tr>
<tr><td><code>make rails-server-daemon</code></td><td>Start Rails server (daemon mode)</td></tr>
<tr><td><code>make rails-start</code></td><td>Full setup + start server in daemon mode</td></tr>
<tr><td><code>make rails-stop</code></td><td>Stop Rails development server</td></tr>

<tr><td colspan="2"><strong>Console & Access</strong></td></tr>
<tr><td><code>make rails-console</code></td><td>Open development Rails console</td></tr>
<tr><td><code>make rails-bash</code></td><td>Access bash in development container</td></tr>
<tr><td><code>make rails-status</code></td><td>Show running processes inside Rails container</td></tr>

<tr><td colspan="2"><strong>Logs</strong></td></tr>
<tr><td><code>make rails-log-tail</code></td><td>Tail development application log</td></tr>
<tr><td><code>make rails-logs</code></td><td>Tail development application log (alias)</td></tr>
<tr><td><code>make rails-log-clear</code></td><td>Clear development application log</td></tr>

</table>
