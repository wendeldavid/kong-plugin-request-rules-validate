
# Request-Rules-validate

The `Request-Rules-validate` plugin checks some pre-conditions to allow or deny the request. Can combine multiples conditions or strict on some.

It is useful to accpet only request that have some specific combinations of headers, ou deny ir is have some specific combination. Note that you can use allow and deny configurations at the same time, but deny will have highest priority, or, if an allow configuration check is all right but deny configuration matches, the request will be refused.

## Configuration

This plugin is **full compatible** with DB and DB-less mode.

### Compatible protocols

Te `Request-Rules-validate` is compatible with the following protocols:

`grpc`, `grpcs`, `http`, `https`

### Parameters

Here's a list of all parameters which can be used in this plugin configuration:

**name**

| string | required |
|--------|----------|
| The name of the plugin |

**service.name** or **service.id**

| string |
|--------|
| The name or ID of the service the plugin targets. Set one of these parameters if adding the plugin to a service through the top-level /plugins endpoint. Not required if using /services/SERVICE_NAME|ID/plugins |

**route.name** or **route.id**

| string |
|--------|
| The name or ID of the route the plugin targets. Set one of these parameters if adding the plugin to a route through the top-level /plugins endpoint. Not required if using /routes/ROUTE_NAME|ID/plugins |

**enabled**

| boolean | default: `true` |
|---------|----------|
| Whether this plugin will be applied |

**config.allow.headers**

| array of type string |
|--------|
| List of headers (`key:value` pair) which will be checked on every request |

**config.deny.headers**

| array of type string |
|--------|
| List of headers (`key:value` pair) which will be checked on every request |

**config.strict_allow**

| boolean | defaul: `false` |
|--------|
| Configure to only accept the request if and only if the request headers matches with the `allow.headers` configuration |

## Basic configuration examples

The following example provide sime typical configuration for enabling the `Request-Rules-validate` plugin on a service:

Make the following request on Kong Amin API:

```
curl -X POST http://localhost:8001/services/{service}/plugins \
    --data "name=request-rules-validate" \
    --data "config.allow_headers[1]=content-type:application/json" \
    --data "config.allow_headers[2]=charset:UTF-8" \
    --data "config.deny_headers[1]=content-type:plain/text" \
    --data "config.strict_allow=false"
```

Replace **service** placeholder to a service name or service ID.

## Changelog

* v1.0.0

First release of this plugin. Configuration supports only headers.