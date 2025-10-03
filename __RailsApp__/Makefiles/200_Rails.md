# Rails Development Commands (Container Level)

Simple reference for `__RailsApp__/Makefiles/200_Rails.mk` commands executed inside the container.

**Note**: These commands are executed inside the Rails container and are designed for development environment.

## Available Commands

<table width="100%">
<tr><th>Command</th><th>Description</th></tr>

<tr><td colspan="2"><strong>Help</strong></td></tr>
<tr><td><code>make rails-help</code></td><td>Show Rails commands help</td></tr>
<tr><td><code>make rails-internal-help</code></td><td>Show Rails commands help (alias)</td></tr>

<tr><td colspan="2"><strong>Application Setup</strong></td></tr>
<tr><td><code>make setup</code></td><td>Setup application environment (bundle + db-create + db-migrate + db-seed)</td></tr>

<tr><td colspan="2"><strong>Server Management</strong></td></tr>
<tr><td><code>make server</code></td><td>Start Rails server</td></tr>
<tr><td><code>make start</code></td><td>Start Rails server (alias)</td></tr>
<tr><td><code>make rails-start</code></td><td>Start Rails server (alias)</td></tr>
<tr><td><code>make stop</code></td><td>Stop Rails server</td></tr>

<tr><td colspan="2"><strong>Console</strong></td></tr>
<tr><td><code>make console</code></td><td>Open Rails console</td></tr>

<tr><td colspan="2"><strong>Logs</strong></td></tr>
<tr><td><code>make log-tail</code></td><td>Tail application log</td></tr>
<tr><td><code>make logs</code></td><td>Tail application log (alias)</td></tr>
<tr><td><code>make log-clear</code></td><td>Clear application log</td></tr>

</table>
