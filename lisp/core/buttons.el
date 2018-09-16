(defmacro buttons-make (key-mapper &rest bindings)
  "Define an anonymous keymap.
BINDINGS... is a list of (KEY TARGET) pairs, where key
must be suitable to use as the KEY argument in DEFINE-KEY,
for example <s-f1>

KEY-MAPPER is optionally a function that transforms a "
  (let ((kmap-sym (gentemp "kmap")))
    `(lexical-let ((,kmap-sym (make-sparse-keymap)))
       (define-key ,kmap-sym (kbd "s-?") (lambda () (interactive)
                                           (buttons-display ,kmap-sym)))
       ,@(loop with map = (make-sparse-keymap)
               for (key-spec value . rest) in bindings
               when rest do (error "malformed key definition")
               as key = (if key-mapper
                            (if (symbolp key-mapper)
                                `(,key-mapper ,key-spec)
                              `(funcall ,key-mapper ,key-spec))
                          key-spec)
               collect `(define-key ,kmap-sym ,key ,value))
       ,kmap-sym)))

(defmacro defbuttons (kmap-sym ancestor-kmap load-after-keymap-syms keymap)
  "Define a keymap KMAP-SYM. ANCESTOR-KMAP, if non-nil,
is merged recursively onto KMAP-SYM via DEFINE-KEYMAP-ONTO-KEYMAP.
LOAD-AFTER-KEYMAP-SYMS is a list of keymap symbols, bound or unbound,
onto which to define KMAP-SYM via AFTER-SYMBOL-LOADED-FUNCTION-ALIST.
KEYMAP is the keymap, for example, one defined via BUTTONS-MAKE"
  (let* ((sym-name (symbol-name kmap-sym)))
    `(progn
       (defvar ,kmap-sym nil ,(format "%s buttons map" sym-name))
       (setf ,kmap-sym ,keymap)
       ,@(when ancestor-kmap
           `((define-keymap-onto-keymap ,ancestor-kmap ,kmap-sym ',kmap-sym t)))
       ,@(loop for orig in (if (and load-after-keymap-syms
                                    (atom load-after-keymap-syms))
                               (list load-after-keymap-syms)
                             load-after-keymap-syms)
               as form = `(define-keymap-onto-keymap ,kmap-sym ,orig)
               append
               (if (boundp orig)
                   `(,form)
                 `((push (cons ',orig (lambda () ,form))
                         after-symbol-loaded-function-alist)))))))

(defun buttons-insert-code-block (&optional content)
  (insert " {")
  (newline-and-indent)
  (indent-for-tab-command)
  (recursive-edit)
  (newline-and-indent)
  (insert "}")
  (if (member major-mode '(c-mode js-mode))
      (c-indent-line-or-region)
    (indent-for-tab-command)))

(defun define-keymap-onto-keymap (from-map to-map &optional from-sym no-overwrite-p)
  "Define bindings FROM-MAP onto TO-MAP, recursively.
If a binding A in FROM-MAP doesn't exist on TO-MAP, define A onto TO-MAP.
Otherwise, if a binding is a prefix key on both maps, merge recursively.
Otherwise FROM-MAP's binding overwrites TO-MAP's binding
only when NO-OVERWRITE-P is non-nil.
"
  (cl-labels ((merge (from-map to-map &optional path)
                     (map-keymap
                      (lambda (key cmd)
                        (let* ((keyvec (vector key))
                               (existing (lookup-key to-map keyvec)))
                          (cond
                           ((and (keymapp cmd) (keymapp existing))
                            (merge cmd existing (cons path (key-description keyvec))))
                           ((or (not no-overwrite-p) (not existing))
                            (when (and existing (keymapp existing))
                              (warn "%s overwrites nested keymap with plain command on %s %s"
                                    (or (symbol-name from-sym) "child")
                                    (key-description keyvec)
                                    (or (reverse path) "")))
                            (define-key to-map keyvec cmd)))))
                      from-map)))
    (merge from-map to-map)))

(defvar after-symbol-loaded-function-alist nil
  "An alist where each element has the form (SYMBOL . FUNCTION).
FUNCTION takes no arguments and is evaluated after SYMBOL has been bound.
If SYMBOL is currently bound, FUNCTION is called immediately.
")

(defun after-symbol-loaded (file-loaded)
  "Function invoked after new symbols may have been defined.
Iterates over list of pending items in ‘after-symbol-loaded-function-alist',
evaluating and removing entries for symbols that have become bound."
  (setf after-symbol-loaded-function-alist
        (loop for (sym . fun) in after-symbol-loaded-function-alist
              if (boundp sym) do
              (progn
                (message "calling hook for %s" (symbol-name sym))
                (condition-case err (funcall fun)
                  ('error
	           (warn "WARNING: unable to load action %s for symbol %s: %s"
                         sym fun err))))
              else collect (cons sym fun))))

(add-hook 'after-load-functions 'after-symbol-loaded)

(defun read-keymap ()
  "Taken from help-fns+.el. Interactively read a keymap symbol."
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
are visualized recurisvely. This is suitable for visualizing
BUTTONS-MAKE-defined nested keymaps.

If HIDE-COMMAND-NAMES-P is non-nil, command names are not displayed.
If HIDE-COMMAND-USE-COUNT-P is non-nil, no attempt is made to display recorded
command use-counts.

"
  (interactive (list (read-keymap)))
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
                                 (princ (s-replace "\n" "\\n" (documentation binding)))))
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
  (define-key help-map "M" 'buttons-display))

(defmacro buttons-insert-rec-template (&rest templates)
  "Compile a string specificing a keyboard macro template into
   a progression of lisp command.

   Any directive {DIRECTIVE} within curly brackets is interpreted:

       If DIRECTIVE is the empty string, a recursive edit is
           entered for the user to type any text.

       If DIRECTIVE is a number K, and a string labeled K does not exist,
           a recursive edit is entered for the user to type any text. Upon exit,
           the substring in the current buffer between the markers
           before and after the recursive edit are stored as a string labeled K.
           If a string labeled K already exists, it is inserted.

       Otherwise, DIRECTIVE is interpreted as a function or macro, and
       expanded into the call: (DIRECTIVE)

    Any non-directive text is inserted literally.

    No escaping of the curly brackets is supported.

    Example:

    for ( int {0} = 0; {0} < {}; {0}++ ){cbd}

    Expands into:

        - insert 'for ( int '
        - enter recursive edit. upon exit, record the text string labeled 0
        - insert ' = ; '
        - insert the already-recoded string 0
        - insert ' < '
        - enter recursive edit, no recording is done
        - enter '; '
        - insert the already-recorded string 0
        - insert '++ )
        - expand into the form: (cbd), which denotes the name a function or a macro
"

  (loop with start = 0
        with forms = nil
        with tmpl = (apply 'concat templates)
        with rec-sym-alist = nil
        as rec-group-start = (string-match "{\\(.*?\\)}" tmpl start)
        do (if rec-group-start
               (progn
                 (unless (= start rec-group-start)
                   (push `(insert ,(subseq tmpl start rec-group-start)) forms))
                 (let ((group-no-str (match-string 1 tmpl))
                       (match-data (match-data)))
                   (cond
                    ((zerop (length group-no-str)) (push `(recursive-edit) forms))
                    ((string-match "^[0-9]+$" group-no-str)
                     (let* ((group-no (string-to-number group-no-str))
                            (sym (cdr (assoc group-no rec-sym-alist))))
                       (if sym
                           (push `(insert ,sym) forms)
                         (setf sym (gensym (format "rec-group-%d--" group-no)))
                         (push (cons group-no sym) rec-sym-alist)
                         (push `(setf ,sym (buttons-recedit-record-text)) forms))))
                    (t (push `(,(intern group-no-str)) forms)))
                   (set-match-data match-data)
                   (setf start (match-end 0))))
             (progn (when (< start (length tmpl))
                      (push `(insert ,(subseq tmpl start)) forms))
                    (setf start (length tmpl))))
        while rec-group-start
        finally (return `(let ,(mapcar 'cdr rec-sym-alist)
                           ;; (doc ,tmpl)
                           ,@(reverse forms)))))

(defmacro buttons-defcmd (&rest body)
  "Define an anonymous command with body BODY.
The number of times the command is invoked is recorded
as the USE-COUNT property of the function symbol.
This can be helpful for analysis and for making
decisions about which bindings' key-sequence
lengths are worth shortening.
"
  (loop for form in body
        with forms = nil
        with doc = nil
        with cmd-name = (gentemp "autogen-cmd")
        with undo-len-sym = (gensym "undo-list-len")
        do (if (and (consp form)
                    (eq (car form) 'doc))
               (push (second form) doc)
             (push form forms))
        finally
        (return
         `(progn
            (put ',cmd-name 'use-count (or (get ',cmd-name 'use-count) 0))
            (defun ,cmd-name ()
              ,(s-join "" (reverse (mapcar 'prin1-to-string forms)))
              (interactive)
              (incf (get ',cmd-name 'use-count))
	      (let (,undo-len-sym)
                (unless (eq t buffer-undo-list)
                  (setf ,undo-len-sym (length buffer-undo-list))
	          (undo-boundary))
	        (or (progn ,@(reverse forms) t)
                    (when ,undo-len-sym
		      (undo (- (length buffer-undo-list) ,undo-len-sym))))))))))

(defmacro buttons-macrolet (more-macrolet-defs &rest body)
  "Define 3-letter aliases for useful functions and macros
to provide a compact DLS for defining buttons"
  `(macrolet
       ((nli () `(newline-and-indent))
        (ins (text) `(buttons-insert-rec-template ,text))
        (cmd (&rest rest) `(buttons-defcmd ,@rest))
        (cbd () `(buttons-insert-code-block))
        (rec () `(recursive-edit))
        (idt () `(indent-for-tab-command))
        ,@more-macrolet-defs)
     ,@body))
