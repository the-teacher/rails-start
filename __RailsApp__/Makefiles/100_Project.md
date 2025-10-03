# Common Project Commands (Container Level)

Simple reference for `__RailsApp__/Makefiles/100_Project.mk` commands executed inside the container.

**Note**: These commands are executed inside the Rails container and work for both development and production environments.

## Available Commands

<table width="100%">
<tr><th>Command</th><th>Description</th></tr>

<tr><td colspan="2"><strong>Help</strong></td></tr>
<tr><td><code>make project-help</code></td><td>Show common project commands help</td></tr>
<tr><td><code>make project-internal-help</code></td><td>Show common project commands help (alias)</td></tr>

<tr><td colspan="2"><strong>Dependencies</strong></td></tr>
<tr><td><code>make bundle</code></td><td>Install Ruby dependencies</td></tr>
<tr><td><code>make update-bundler</code></td><td>Update bundler and dependencies</td></tr>

<tr><td colspan="2"><strong>Work with Database</strong></td></tr>
<tr><td><code>make db-create</code></td><td>Create database</td></tr>
<tr><td><code>make db-migrate</code></td><td>Run database migrations</td></tr>
<tr><td><code>make migrate</code></td><td>Run database migrations (alias)</td></tr>
<tr><td><code>make db-seed</code></td><td>Seed the database</td></tr>
<tr><td><code>make seed</code></td><td>Seed the database (alias)</td></tr>
<tr><td><code>make db-drop</code></td><td>Drop database</td></tr>
<tr><td><code>make db-reset</code></td><td>Reset database (drop, create, migrate, seed)</td></tr>
<tr><td><code>make db-rollback</code></td><td>Rollback last migration</td></tr>

<tr><td colspan="2"><strong>Rails Generators</strong></td></tr>
<tr><td><code>make generate</code></td><td>Show generator usage</td></tr>
<tr><td><code>make generate-model name=ModelName</code></td><td>Generate model</td></tr>
<tr><td><code>make model name=ModelName</code></td><td>Generate model (alias)</td></tr>
<tr><td><code>make generate-controller name=ControllerName</code></td><td>Generate controller</td></tr>
<tr><td><code>make controller name=ControllerName</code></td><td>Generate controller (alias)</td></tr>
<tr><td><code>make generate-migration name=migration_name</code></td><td>Generate migration</td></tr>
<tr><td><code>make migration name=migration_name</code></td><td>Generate migration (alias)</td></tr>

<tr><td colspan="2"><strong>Testing</strong></td></tr>
<tr><td><code>make test</code></td><td>Run all tests</td></tr>
<tr><td><code>make test-system</code></td><td>Run system tests</td></tr>

<tr><td colspan="2"><strong>Assets</strong></td></tr>
<tr><td><code>make assets-clean</code></td><td>Clean compiled assets</td></tr>

<tr><td colspan="2"><strong>Utilities</strong></td></tr>
<tr><td><code>make routes</code></td><td>Show all routes</td></tr>
<tr><td><code>make tasks</code></td><td>Show all available Rails tasks</td></tr>

<tr><td colspan="2"><strong>Code Quality</strong></td></tr>
<tr><td><code>make brakeman</code></td><td>Run security analysis</td></tr>
<tr><td><code>make rubocop</code></td><td>Run code style analysis</td></tr>
<tr><td><code>make rubocop-fix</code></td><td>Auto-fix code style issues</td></tr>

<tr><td colspan="2"><strong>Maintenance</strong></td></tr>
<tr><td><code>make clean</code></td><td>Clean assets, logs, cache</td></tr>

<tr><td colspan="2"><strong>Information</strong></td></tr>
<tr><td><code>make env-check</code></td><td>Check environment versions and configuration</td></tr>
<tr><td><code>make status</code></td><td>Show running processes</td></tr>
<tr><td><code>make disk-usage</code></td><td>Show disk usage information</td></tr>
<tr><td><code>make network</code></td><td>Show network configuration</td></tr>

</table>
