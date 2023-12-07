#!/bin/bash

rm -f luacov.report.out
rm -f luacov.stats.out

pongo run -v -- --coverage

pongo down
