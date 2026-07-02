# External API Integration

Patterns for Blip plugins that call REST backends (not Blip Router resources). Lessons from `blip-stellantis-coupons` anti-patterns and Stellantis Coupons API.

## When to use

- Plugin UI talks to a custom .NET/Node API
- Backend repo is **separate** from the plugin repo
- Use `use skill dotnet-developer` for backend work; `react-developer` + this guideline for the plugin client

For Blip-native storage only, use `lib/services/resource.js` instead.

## .NET Result&lt;T&gt; envelope

Stellantis APIs return:

```json
{
  "value": { ... },
  "statusCode": 200
}
```

**Wrong:**

```javascript
const data = response.data; // misses .value
```

**Correct:**

```javascript
const result = response.data;
if (result.statusCode !== 200 || !result.value) {
  throw new ApiError(result);
}
const payload = result.value;
```

For paginated search:

```javascript
const { items, totalCount, page, pageSize } = result.value;
```

Centralize unwrap logic in one API factory/service - do not repeat in every component.

## Authorization header

Blip/Stellantis APIs expect:

```
Authorization: Key <token>
```

**Wrong:** `Authorization: <token>` or `Bearer <token>` without verifying API contract.

Obtain token via `getToken` iframe message (Full profile) or from `appsettings.json` in dev only.

## Required headers

| Header | When |
|--------|------|
| `Authorization: Key <token>` | All authenticated routes |
| `X-Campaign-Code` | Campaign-scoped coupon endpoints |
| `Content-Type: application/json` | POST/PUT bodies |
| Correlation ID (if API defines) | Pass through for support/debug |

Read header requirements from OpenAPI or controller filters - do not guess.

## Status and enum mapping

API may return numeric filters and localized display strings:

| API filter (`status`) | Meaning | Display (PT example) |
|-----------------------|---------|----------------------|
| `0` | Available | Disponível |
| `1` | Reserved | Reservado |
| `2` | Claimed | Resgatado |

**Wrong:** hardcode English labels (`Available`, `Reserved`, `Claimed`) when API returns Portuguese.

Map in a single constants module:

```javascript
export const COUPON_STATUS = {
  Available: 0,
  Reserved: 1,
  Claimed: 2,
};

export const COUPON_STATUS_LABEL = {
  [COUPON_STATUS.Available]: 'Disponível',
  [COUPON_STATUS.Reserved]: 'Reservado',
  [COUPON_STATUS.Claimed]: 'Resgatado',
};
```

## Error handling

**Wrong:**

```javascript
try {
  const data = await api.search();
  setRows(data);
} catch {
  setRows([]); // hides auth failures
}
```

**Correct:**

```javascript
try {
  const data = await api.search();
  setRows(data);
} catch (error) {
  Toast.Error(error.message || t('errors.searchFailed'));
  setRows([]);
  setErrorState(error);
}
```

Handle HTTP 401/403 explicitly - prompt re-auth or show unauthorized page.

## API client structure

```
src/
  lib/
    services/
      api/
        client.js       # axios/fetch instance, interceptors, Result unwrap
        coupons.js      # domain endpoints
    constants/
      api.js            # routes, status enums
```

Configure base URL from `config/appsettings.json`:

```json
{
  "api": {
    "url": "",
    "key": ""
  }
}
```

Inject real values at deploy - never commit production keys.

## Endpoint coverage checklist

Before marking a feature complete, verify all controller routes needed by the UI are implemented in the client service layer. For Coupons API, see matrix in `docs/blip-plugin-integration.md`.

Common gaps in the coupons fixture:

- `reserve`, `claim`, `reset`, `export`, `expire`, `getById`, `exists` - implement only what the UI needs, but document gaps

## OpenAPI handoff

When backend exposes Swagger/OpenAPI, use `use skill api-integrate` in the backend repo to generate typed clients, then adapt unwrap logic for `Result<T>` if the generator does not handle it.

## Testing API integration

- Mock API at the service layer in Cypress tests
- Integration tests against a test API environment - not production
- Verify auth header format in at least one test per authenticated endpoint
