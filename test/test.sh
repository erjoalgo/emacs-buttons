#!/bin/bash -x

set -euo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )"

emacs -Q -batch -l ert -L ..  \
      -l buttons-tests.el \
      -f ert-run-tests-batch-and-exit
