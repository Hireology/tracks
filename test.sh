#!/bin/bash
set -eu

failures=0
total=20

for run in `seq $total`; do
    echo "Run $run/$total"

    if ! bundle exec cucumber features/dependencies.feature:115; then
        failures=$(($failures + 1))
    fi

    echo "Test run $run complete, $failures failures"
done

