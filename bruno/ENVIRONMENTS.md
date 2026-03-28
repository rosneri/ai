# Bruno Environment Configuration

## Global Environments

Global environments are **not** stored in the collection repo. They are managed by the Bruno desktop app and stored at:

```
~/Library/Application Support/bruno/default-workspace/environments/
```

Each environment is a `.yml` file. Example (`PROD.yml`):

```yaml
name: PROD
variables:
  - name: base_url
    value: https://app.doorloop.com
  - name: db-tenant
    value: 6512ca8ec35c826569a2fbac
  - secret: true
    name: api_key
```

Secret variables (e.g. `api_key`) have `secret: true` and their values are stored separately in `~/Library/Application Support/bruno/secrets.json`, not in the yml file.

### Available Global Environments

- `PROD.yml`
- `Beta.yml`
- `Dev.Com.yml`
- `DevEnv.yml`
- `Dynamic Env.yml`
- `Local Env.yml`
- `Local Env - CAPITAL.yml`
- `PROD JOBS.yml`
- `DEBUG PROD LOCAL.yml`

## Using Global Environments with bru CLI

```bash
bru run "path/to/request.bru" \
  --global-env PROD \
  --workspace-path /path/to/workspace
```

The workspace path should point to the directory containing the collections (where `bruno.json` lives or its parent).

## Overriding / Supplementing Variables

If a request uses a variable not defined in the global env (e.g. `{{server_base_url}}` when the env only defines `{{base_url}}`), pass it inline:

```bash
bru run "request.bru" \
  --global-env PROD \
  --env-var "server_base_url=https://app.doorloop.com"
```

## Collection-Level Environments

Collections can also have their own environments stored as `.bru` files in an `environments/` folder inside the collection directory. These are version-controlled, unlike global environments.

Currently, the DoorLoop collection at `/Users/nrosner/Developer/bruno` does **not** have collection-level environments — it relies entirely on global environments.
