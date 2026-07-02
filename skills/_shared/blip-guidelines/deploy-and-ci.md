# Deploy and CI

Production deployment artifacts for Blip plugins from `create-blip-extension` / CRA scaffold.

## config:plugin

After scaffold, **always** run:

```powershell
npm run config:plugin
```

This replaces the `PLUGIN_NAME` placeholder in:

- `charts/<plugin-name>/` (Helm chart paths and values)
- `config/appsettings.json` (segment prefix and related identifiers)

Skipping this step leaves mismatched chart names and broken deploy configs.

## Helm charts

```
charts/
  <plugin-name>/
    Chart.yaml
    values.yaml
    templates/
      deployment.yaml
      service.yaml
      ingress.yaml
      secrets.yaml
      autoscale.yaml
```

Customize `values.yaml` for environment-specific replicas, ingress host, and secrets references. Do not delete the charts folder unless the team explicitly opts out of K8s deploy.

## Dockerfile

Static nginx image serving the CRA build output:

```dockerfile
# Typical pattern: multi-stage build
# Stage 1: npm ci && npm run build
# Stage 2: nginx copy build/ to /usr/share/nginx/html
```

Match the template's nginx config for SPA routing (fallback to `index.html`).

## azure-pipelines.yml

Production plugins include Azure DevOps pipeline:

- Build: `npm ci`, lint, test, coverage, `npm run build`
- Docker image build and push
- Helm deploy to Kubernetes

Internal Blip orgs may use shared pipeline templates. External teams: use as reference and replace template references.

Files tied to CI (remove only if not deploying to K8s/ADO):

- `azure-pipelines.yml`
- `Dockerfile`
- `charts/*`

## Environment configuration

| Setting | Source |
|---------|--------|
| `api.url`, `api.key` | Helm secrets / pipeline variables - not git |
| `blip.url`, `blip.domain` | `appsettings.json` per environment |
| `segment.prefix` | Set by `config:plugin` to match plugin name |
| `env` | `prd`, `hmg`, `dev` in appsettings |

## Build validation (pre-handoff)

```powershell
npm run lint
npm run test:cypress   # or npm test per project scripts
npm run build
```

All must pass before merging to main or deploying.

## Portal registration (not in repo)

Deploy produces a public URL. Register in Blip portal:

1. Advanced settings -> Plugins JSON
2. Add plugin entry with deployed URL (HTTPS)
3. For local dev: `http://localhost:3000` (team-specific portal setup)

Never commit portal credentials or bot keys.

## Sync with backend API

When the plugin calls an external API:

- Deploy plugin and API independently
- CORS and auth must be configured on the API for the plugin origin
- Coordinate API URL changes via pipeline variables, not hardcoded commits

## Maintainer note

Pin `create-blip-extension` version in project README when scaffold CLI changes affect `config:plugin` or chart layout. Re-run validation after template upgrades.
