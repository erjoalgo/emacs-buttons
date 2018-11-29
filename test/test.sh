#!/bin/bash -x

set -euo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )"

rm -f ../*.elc

test "${EMACS:-t}" = "t" && EMACS=emacs

${EMACS} -Q -batch -l ert -L ..  \
      -l buttons-tests.el \
      -f ert-run-tests-batch-and-exit

${EMACS} -Q --batch -l load-flycheck.el -- ../buttons.el
