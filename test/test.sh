#!/bin/bash -x

set -euo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )"

rm -f ../*.elc

test "${EMACS:-t}" = "t" && EMACS=emacs

${EMACS} -Q -batch -l ert -L ..  \
      -l buttons-tests.el \
      -f ert-run-tests-batch-and-exit

# env
# echo "${EMACS}"
# ${EMACS:-emacs} -batch -L .. -l load-flycheck.el -l buttons.el -f flycheck-buffer
