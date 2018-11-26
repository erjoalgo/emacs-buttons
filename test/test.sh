#!/bin/bash -x

set -euo pipefail

emacs -Q -batch -l ert -L .  \
      -l buttons-tests.el \
      -f ert-run-tests-batch-and-exit
