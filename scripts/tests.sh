#!/bin/bash

export POSTGRES_IMAGE=postgres:15
export KONG_VERSION=2.8.4
export KONG_LOG_LEVEL=debug

rm -f luacov.report.out
rm -f luacov.stats.out

# all tests
pongo run -v -- --coverage

exit_code=$?

echo $exit_code

pongo down

exit $exit_code
