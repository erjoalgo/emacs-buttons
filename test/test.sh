#!/bin/bash -x

set -euo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )"

rm -f ../*.elc

test "${EMACS:-t}" = "t" && EMACS=emacs

${EMACS} -Q -batch -l ert -L ..  \
      -l buttons-tests.el \
      -f ert-run-tests-batch-and-exit

${EMACS} -Q --batch \
         --eval '(with-demoted-errors "Error during package initialization: %S" (package-initialize) (package-refresh-contents) (package-install `flycheck))' \
         --eval '(progn (defvar jka-compr-inhibit) (unwind-protect (let ((jka-compr-inhibit t)) (when (equal (car command-line-args-left) "--") (setq command-line-args-left (cdr command-line-args-left))) (defvar flycheck-byte-compiled-files nil) (let ((byte-compile-dest-file-function (lambda (source) (let ((temp-file (make-temp-file (file-name-nondirectory source)))) (push temp-file flycheck-byte-compiled-files) temp-file)))) (unwind-protect (byte-compile-file (car command-line-args-left)) (mapc (lambda (f) (ignore-errors (delete-file f))) flycheck-byte-compiled-files)) (when (bound-and-true-p flycheck-emacs-lisp-check-declare) (check-declare-file (car command-line-args-left))))) (setq command-line-args-left nil)))' \
         -- ../buttons.el
