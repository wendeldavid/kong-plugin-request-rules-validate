#!/bin/bash

export POSTGRES_IMAGE=postgres:15
export KONG_LOG_LEVEL=debug

rm -f luacov.report.out
rm -f luacov.stats.out


# pongo run -v -- ./spec/request-rules-validator/01-unit_spec.lua --coverage
pongo run -v -- ./spec/request-rules-validator/02-integration_spec.lua

# all tests
# pongo run -v -- --coverage

pongo down
