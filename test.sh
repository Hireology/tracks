#!/bin/bash

bundle exec rake db:migrate

set -eu

failures=0
total=50

for run in `seq $total`; do
    echo "Run $run/$total"

    if ! bundle exec cucumber features/dependencies.feature:115; then
        failures=$(($failures + 1))
    fi

    echo "Test run $run complete, $failures failures"
done

exit $failures
