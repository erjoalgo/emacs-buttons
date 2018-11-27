;;; -*- lexical-binding: t; -*-
;;; buttons.el --- emacs-buttons framework
;;
;; Copyright (C) 2018,  Ernesto Alfonso, all rights reserved.
;;
;; Author: Ernesto Alfonso
;; Maintainer: (concat "erjoalgo" "@" "gmail" ".com")
;; Keywords: keymap, template, snippet
;; Created: 16 Sep 2018
;; Package-Requires: ((cl-lib "0.3"))
;; URL: http://github.com/erjoalgo/emacs-buttons
;; Version: 0.0.1
;;
;;; Commentary:
;; A library for conveniently defining deeply nested keymaps
;;;
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Code:


(require 'cl-lib)

(defvar buttons-make-key-mapper #'identity
  "A function used to map key definitions within a ‘buttons-make’ form.
It should be bound at compile-time via ‘let-when'")

(defvar buttons-make-help-binding (kbd "s-?")
  "Key where to install the help visualizer in a buttons-make-defined keymap.")

(defmacro buttons-make (&rest bindings)
  "Create a sparse keymap.

   BINDINGS... is a list of (KEY TARGET) pairs, where KEY
   should be suitable for use as the KEY argument in DEFINE-KEY,
   for example \"<s-f1>\".

   TARGET may be any value that could be passed to the DEF
   argument of DEFINE-KEY, including a command and a keymap,
   including an anonymous keymap created with BUTTONS-MAKE.

   BUTTONS-MAKE-KEY-MAPPER, if non-nil, specifiess
   a function to apply to the KEY of each binding
   before it is passed to DEFINE-KEY.
   As an example, it may be used to add a modifier to
   its input key to make the BINDINGS list more consice."

  (let ((kmap-sym (cl-gentemp "kmap")))
    `(let ((,kmap-sym (make-sparse-keymap))
           (display-kmap-command (lambda (kmap)
                                   `(lambda () (interactive)
                                      (buttons-display ',kmap)))))
       (when buttons-make-help-binding
         (define-key ,kmap-sym buttons-make-help-binding
           (funcall display-kmap-command ,kmap-sym)))
       ,@(cl-loop
               for (key-spec value . rest) in bindings
               when rest do (error "Malformed key definition: %s %s" key-spec value)
               as key = (funcall buttons-make-key-mapper key-spec)
               collect `(define-key ,kmap-sym ,key ,value))
       ,kmap-sym)))

(defun buttons-modifier-add-super (key-spec)
  "Add the supper modifier to KEY-SPEC, if it is a string.

  If KEY-SPEC is a string, then prefix it with the super modifier,
  otherwise leave it intact.
  Suitable as the value of BUTTONS-MAKE-KEY-MAPPER in ‘buttons-make'"
  (cl-typecase key-spec
    (string (kbd (format
                  (if (= (length key-spec) 1)
                      "s-%s"
                    "<s-%s>")
                  key-spec)))
    (t key-spec)))

(defmacro defbuttons (kmap-sym ancestor-kmap load-after-keymap-syms keymap)
  "Define a keymap KMAP-SYM.

   ANCESTOR-KMAP, if non-nil,is merged recursively onto
   KMAP-SYM via BUTTONS-DEFINE-KEYMAP-ONTO-KEYMAP.

   LOAD-AFTER-KEYMAP-SYMS is a list of keymap symbols, bound or unbound,
   onto which to define KMAP-SYM via BUTTONS-AFTER-SYMBOL-LOADED-FUNCTION-ALIST.

   KEYMAP is the keymap, for example, one defined via BUTTONS-MAKE"
  (let* ((sym-name (symbol-name kmap-sym)))
    `(progn
       (defvar ,kmap-sym nil ,(format "%s buttons map" sym-name))
       (setf ,kmap-sym ,keymap)
       ,@(when ancestor-kmap
           `((buttons-define-keymap-onto-keymap ,ancestor-kmap ,kmap-sym ',kmap-sym t)))
       ,@(cl-loop for orig in (if (and load-after-keymap-syms
                                    (atom load-after-keymap-syms))
                               (list load-after-keymap-syms)
                             load-after-keymap-syms)
               as form = `(buttons-define-keymap-onto-keymap ,kmap-sym ,orig)
               append
               (if (boundp orig)
                   `(,form)
                 `((push (cons ',orig (lambda () ,form))
                         buttons-after-symbol-loaded-function-alist)))))))

(defun buttons-define-keymap-onto-keymap (from-map to-map &optional from-sym no-overwrite-p)
  "Define bindings FROM-MAP onto TO-MAP, recursively.

   If a binding A in FROM-MAP doesn't exist on TO-MAP, define A onto TO-MAP.
   Otherwise, if a binding is a prefix key on both maps, merge recursively.
   Otherwise FROM-MAP's binding overwrites TO-MAP's binding
   only when NO-OVERWRITE-P is non-nil.

   The opptional argument FROM-SYM is used for visualization."
  (cl-labels ((merge (from-map to-map &optional path)
                     (map-keymap
                      (lambda (key cmd)
                        (let* ((keyvec (vector key))
                               (existing (lookup-key to-map keyvec)))
                          (cond
                           ((and (keymapp cmd) (keymapp existing))
                            (merge cmd existing (cons (key-description keyvec) path)))
                           ((or (not no-overwrite-p) (not existing))
                            (when (and existing (keymapp existing))
                              (warn "%s overwrites nested keymap with plain command on %s %s"
                                    (or (symbol-name from-sym) "child")
                                    (key-description keyvec)
                                    (or (reverse path) "")))
                            (define-key to-map keyvec cmd)))))
                      from-map)))
    (merge from-map to-map)))

(defvar buttons-after-symbol-loaded-function-alist nil
  "An alist where each element has the form (SYMBOL . FUNCTION).

   FUNCTION takes no arguments and is evaluated after SYMBOL has been bound.
   If SYMBOL is currently bound, FUNCTION is called immediately.")

(defun buttons-after-symbol-loaded (file-loaded)
  "Function invoked after new symbols may have been defined in FILE-LOADED.

   Iterates over list of pending items in
   ‘buttons-after-symbol-loaded-function-alist',
   evaluating and removing entries for symbols that have become bound."
  (setf buttons-after-symbol-loaded-function-alist
        (cl-loop for (sym . fun) in buttons-after-symbol-loaded-function-alist
              if (boundp sym) do
              (progn
                (condition-case err (funcall fun)
                  ('error
	           (warn "WARNING: unable to load action %s for symbol %s: %s"
                         sym fun err))))
              else collect (cons sym fun))))

(add-hook 'after-load-functions #'buttons-after-symbol-loaded)

(defun buttons-read-keymap ()
  "Interactively read a keymap symbol.  Based on ‘help-fns+'."
  (intern
   (completing-read "Keymap: " obarray
                    (lambda (m) (and (boundp m)))
                    t
                    (when (symbol-at-point)
                      (symbol-name (symbol-at-point)))
                    'variable-name-history)))

(defun buttons-display (keymap &optional hide-command-names-p hide-command-use-count-p)
  "Visualize a keymap KEYMAP in a help buffer.

   Unlike the standard keymap bindings help, nested keymaps
   are visualized recurisvely.  This is suitable for visualizing
   BUTTONS-MAKE-defined nested keymaps.

   If HIDE-COMMAND-NAMES-P is non-nil, command names are not displayed.

   If HIDE-COMMAND-USE-COUNT-P is non-nil, no attempt is made to display
   recorded command use-counts."
  (interactive (list (buttons-read-keymap)))
  (let (sym (sep "  "))
    (when (symbolp keymap)
      (setf sym keymap
            keymap (symbol-value keymap)))
    (cl-labels ((print-key (event)
                           (princ (key-description (vector event))))
                (print-command (binding)
                               (unless hide-command-names-p
                                 (princ binding))
                               (unless (or hide-command-use-count-p
                                           (not (symbolp binding))
                                           (null (get binding 'use-count))
                                           (zerop (get binding 'use-count)))
                                 (princ (format "(%d)" (get binding 'use-count))))

                               (when (and (commandp binding)
                                          (documentation binding))
                                 (princ sep)
                                 (princ (replace-regexp-in-string
                                         "\n"
                                         "\\\\n"
                                         (documentation binding)))))
                (print-keymap (keymap level)
                              (map-keymap (lambda (event binding)
                                            (princ level)
                                            (print-key event)
                                            (princ sep)
                                            (if (keymapp binding)
                                                (progn (princ "(prefix)")
                                                       (princ "\n")
                                                       (print-keymap binding (concat level sep)))
                                              (print-command binding))
                                            (princ "\n"))
                                          keymap)))
      (let ((buffer-name (format "%s help" (or sym "unknown keymap")))
            (help-window-select t))
        (with-help-window buffer-name
          (with-current-buffer
              buffer-name
            (let ((help-window (get-buffer-window buffer-name)))
              (print-keymap keymap ""))
            (toggle-truncate-lines t)))))))

(unless (lookup-key help-map "M")
  (define-key help-map "M" #'buttons-display))

(defvar buttons-template-insert-directive-regexp
  "{\\(.*?\\)}"
  "Determines what buttons-template-insert interprets as a directive.

   BUTTONS-TEMPLATE-INSERT-DIRECTIVE-REGEXP may be used to set the regexp
   that defines directives to interpret.  The first capture group is used
   as the directive contents.  Note that this variable should be bonud
   via ‘let-when-compile' instead of ‘let' to make this binding available
   at macro-expansion time.")

(defmacro buttons-template-insert (&rest templates)
  "Compile a string template into a progression of LISP commands.

   The template may be split into
   several arguments TEMPLATES, which are concatenated together.

   Any directive {DIRECTIVE} within curly brackets is interpreted:

       If DIRECTIVE is the empty string, a recursive edit is
           entered for the user to type any text.

       If DIRECTIVE is a number K, and a string labeled K does not exist,
           a recursive edit is entered for the user to type any text.
           Upon exit,the substring in the current buffer between the markers
           before and after the recursive edit are stored as a string labeled K.
           If a string labeled K already exists, it is inserted.

       Otherwise, DIRECTIVE is interpreted as a LISP expression.
       If the expression evaluates to a string, it is inserted.

    Any non-directive text is inserted literally.

    BUTTONS-TEMPLATE-INSERT-DIRECTIVE-REGEXP may be used to set the regexp
    that defines directives to interpret.  The first capture group is used
    as the directive contents.  Note that this variable should be bonud
    via ‘let-when-compile' instead of ‘let' to make this binding available
    at macro-expansion time.

    Example:

    for ( int {0} = 0; {0} < {}; {0}++ ){(cbd)}

    Expands into:

        - insert 'for ( int '
        - enter recursive edit.  on exit, record the entered text as a string labeled '0'
        - insert ' = ; '
        - insert the already-recoded string 0
        - insert ' < '
        - enter recursive edit, no recording is done
        - enter '; '
        - insert the already-recorded string 0
        - insert '++ )
        - expand into the form: (cbd), which denotes the name a function or a macro"

  (cl-loop with start = 0
        with forms = nil
        with tmpl = (apply 'concat templates)
        with rec-sym-alist = nil
        with directive-regexp = buttons-template-insert-directive-regexp
        with recedit-record-form =
        (let ((old-point-sym (gensym "old-point")))
          `(let ((,old-point-sym (point)))
             (recursive-edit)
             (buffer-substring-no-properties ,old-point-sym (point))))
        as rec-capture-start = (string-match directive-regexp tmpl start)
        do (if rec-capture-start
               (progn
                 (unless (= start rec-capture-start)
                   (push `(insert ,(cl-subseq tmpl start rec-capture-start)) forms))
                 (let ((group-no-str (match-string 1 tmpl))
                       (match-data (match-data)))
                   (cond
                    ((zerop (length group-no-str)) (push `(recursive-edit) forms))
                    ((string-match "^[0-9]+$" group-no-str)
                     (let* ((group-no (string-to-number group-no-str))
                            (sym (cdr (assoc group-no rec-sym-alist))))
                       (if sym
                           (push `(insert ,sym) forms)
                         (setf sym (gensym (format "rec-capture-%d--" group-no)))
                         (push (cons group-no sym) rec-sym-alist)
                         (push `(setf ,sym ,recedit-record-form) forms))))
                    (t (push (let ((expr-val-sym (gensym "expr-val")))
                               `(let* ((,expr-val-sym ,(read group-no-str)))
                                  (when (stringp ,expr-val-sym)
                                    (insert ,expr-val-sym))))
                             forms)))
                   (set-match-data match-data)
                   (setf start (match-end 0))))
             (progn (when (< start (length tmpl))
                      (push `(insert ,(cl-subseq tmpl start)) forms))
                    (setf start (length tmpl))))
        while rec-capture-start
        finally (return `(let ,(mapcar 'cdr rec-sym-alist)
                           ;; (doc ,tmpl)
                           ,@(reverse forms)))))

(defmacro buttons-defcmd (&rest body)
  "Define an anonymous command with body BODY.

   The number of times the command is invoked is recorded
   as the USE-COUNT property of the function symbol.
   This may be useful for analysis and for making
   decisions about which bindings' key-sequence
   lengths are worth shortening."
  (cl-loop for form in body
        with forms = nil
        with doc = nil
        with cmd-name = (cl-gentemp "autogen-cmd")
        with point-original-sym = (gensym "point-original")
        do (if (and (consp form)
                    (eq (car form) 'doc))
               (push (cadr form) doc)
             (push form forms))
        finally
        (return
         `(progn
            (put ',cmd-name 'use-count (or (get ',cmd-name 'use-count) 0))
            (defun ,cmd-name ()
              ,(apply 'concat (reverse (mapcar 'prin1-to-string forms)))
              (interactive)
              (cl-incf (get ',cmd-name 'use-count))
              (cl-block ,cmd-name
	      (let ((,point-original-sym (point)))
                (catch 'buttons-abort
                  ,@(reverse forms)
                  (cl-return-from ,cmd-name))
                ;; aborted. undoing...
                (undo-boundary)
                (delete-region ,point-original-sym (point)))))))))

(defun buttons-abort-cmd ()
  "Throw the tag required to abort the current buttons-defined command."
  (interactive)
  (message "aborting buttons command...")
  (throw 'buttons-abort nil))

(defmacro buttons-macrolet (more-macrolet-defs &rest body)
  "Make 3-letter aliases of useful button-related forms available in BODY.

   Provides a compact DLS for defining buttons.
   MORE-MACROLET-DEFS specifies additional user-defined cl-macrolet forms."
  `(cl-macrolet
       ((but (&rest rest) `(buttons-make ,@rest))
        (nli () `(newline-and-indent))
        (ins (&rest text) `(buttons-template-insert ,@text))
        (cmd (&rest rest) `(buttons-defcmd ,@rest))
        (cbd ()
             `(let-when-compile
                  ((buttons-template-insert-directive-regexp "<\\(.*?\\)>"))
                ;; insert a code block with curly braces
                (buttons-template-insert
                 " {<(nli)><><(nli)> }")))
        (rec () `(recursive-edit))
        (idt () `(indent-for-tab-command))
        ,@more-macrolet-defs)
     ,@body))

(provide 'buttons)
;;; buttons.el ends here
