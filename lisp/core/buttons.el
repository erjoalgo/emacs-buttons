(defmacro buttons-make (key-mapper &rest bindings)
  (let ((kmap-sym (gentemp "kmap")))
    `(lexical-let ((,kmap-sym (make-sparse-keymap)))
       (define-key ,kmap-sym "?" (lambda () (interactive)
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
  (let* ((sym-name (symbol-name kmap-sym)))
    `(progn
       (defvar ,kmap-sym nil ,(format "%s buttons map" sym-name))
       (setf ,kmap-sym ,keymap)
       ,@(when ancestor-kmap
         ;; (set-keymap-parent ,keymap ,ancestor-kmap)
         `((define-keymap-onto-keymap ,ancestor-kmap ,kmap-sym ',kmap-sym t)))
       ,@(loop for orig in (if (and load-after-keymap-syms
                                    (atom load-after-keymap-syms))
                               (list load-after-keymap-syms)
                             load-after-keymap-syms)
               collect `(push (cons ',orig ',kmap-sym)
                              buttons-after-load-alist)))))


(defun buttons-insert-code-block (&optional content)
  (insert " {")
  (newline-and-indent)
  (indent-for-tab-command)
  (buttons-rec)
  (newline-and-indent)
  (insert "}")
  (if (member major-mode '(c-mode js-mode))
      (c-indent-line-or-region)
    (indent-for-tab-command)))

(defun define-keymap-onto-keymap (from-map to-map &optional from-sym no-overwrite-p)
  (cl-labels ((merge (from-map to-map &optional path)
                     (map-keymap
                      (lambda (key cmd)
                        (let* ((keyvec (vector key))
                               (existing (lookup-key to-map keyvec)))
                          (cond
                           ((and (keymapp cmd) (keymapp existing))
                            ;; (message "recursive merge on %s..." (key-description keyvec))
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

(defvar buttons-after-load-alist nil)

(defun after-load-button (file-loaded)
  (setf buttons-after-load-alist
        (loop for (sym . buttons-keymap) in buttons-after-load-alist
              if (boundp sym) do
              (progn
                ;; (message "installing %s into %s" (symbol-name buttons-keymap) (symbol-name sym))
                (define-keymap-onto-keymap (symbol-value buttons-keymap)
                  (symbol-value sym)))
              else collect (cons sym buttons-keymap))))

(add-hook 'after-load-functions 'after-load-button)

(defun read-keymap ()
  "taken from help-fns+.el"
  (intern
   (completing-read "Keymap: " obarray
                   (lambda (m) (and (boundp m)  (keymapp (symbol-value m))))
                   t nil 'variable-name-history)))

(defun buttons-display (keymap &optional hide-command-names-p hide-command-use-count-p)
  (interactive (list (read-keymap)))
  (let (sym)
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
                                 (princ "\t")
                                 (princ (s-replace "\n" "\\n" (documentation binding)))))
                (print-keymap (keymap level)
                              (map-keymap (lambda (event binding)
                                            (princ level)
                                            (print-key event)
                                            (princ "\t")
                                            (if (keymapp binding)
                                                (progn (princ "\n")
                                                       (print-keymap binding (concat level "\t")))
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

(defun buttons-recedit-record-text ()
  (let ((old-point (point)))
    (recursive-edit)
    (buffer-substring-no-properties old-point (point))))

(defmacro buttons-insert-rec-template (&rest templates)
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
  "define 3-letter aliases for useful functions and macros
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

