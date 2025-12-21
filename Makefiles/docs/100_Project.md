# Project Management Commands

Simple reference for `Makefiles/100_Project.mk` commands in logical usage order.

## Available Commands

<table width="100%">
<tr><th>Command</th><th>Description</th></tr>

<tr><td colspan="2"><strong>Help</strong></td></tr>
<tr><td><code>make project-help</code></td><td>Show project management commands help</td></tr>

<tr><td colspan="2"><strong>Container Build</strong></td></tr>
<tr><td><code>make build</code></td><td>Build containers</td></tr>
<tr><td><code>make rebuild</code></td><td>Rebuild containers (no cache)</td></tr>

<tr><td colspan="2"><strong>Container Lifecycle</strong></td></tr>
<tr><td><code>make start</code></td><td>Start all containers</td></tr>
<tr><td><code>make up</code></td><td>Start all containers (alias)</td></tr>
<tr><td><code>make stop</code></td><td>Stop all containers</td></tr>
<tr><td><code>make down</code></td><td>Stop all containers (alias)</td></tr>

<tr><td colspan="2"><strong>Container Status & Access</strong></td></tr>
<tr><td><code>make status</code></td><td>Show running containers status</td></tr>
<tr><td><code>make shell</code></td><td>Open shell in rails container</td></tr>
<tr><td><code>make root-shell</code></td><td>Open shell in rails container as root</td></tr>

<tr><td colspan="2"><strong>Project Setup</strong></td></tr>
<tr><td><code>make project-setup-structure</code></td><td>Create required project directories and files</td></tr>

</table>
