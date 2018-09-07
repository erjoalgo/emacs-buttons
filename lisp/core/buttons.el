(defun buttons-add-super-modifier (keyspec)
  (if (equal keyspec "\\")
      (kbd "s-\\")
    (let ((fmt
	   (if (equal (length keyspec) 1) "(kbd \"s-%s\")"
	     "(kbd \"<s-%s>\")")))
      (eval (read (format fmt keyspec))))))

(unless (functionp 'string-join)
  (defun string-join (strings separator)
    (reduce (lambda (cum a)
	      (concat a separator cum))
	    strings)))

(defmacro buttons-make (&rest bindings)
  (let ((kmap-sym (gensym "kmap")))
    `(let ((,kmap-sym (make-sparse-keymap)))
       ,@(loop with map = (make-sparse-keymap)
               for (key-spec value . rest) in bindings
               when rest do (error "malformed key definition")
               as key = (if (stringp key-spec)
                            ;; TODO use dynamically defined modifier
                            (buttons-add-super-modifier key-spec)
                          key-spec)
               collect `(define-key ,kmap-sym ,key ,value))
       ,kmap-sym)))

(defmacro defbuttons (kmap-sym ancestor-kmap load-after-keymap-syms keymap)
  (let* ((sym-name (symbol-name kmap-sym)))
    `(progn
       (defvar ,kmap-sym nil ,(format "%s buttons map" sym-name))
       (setf ,kmap-sym ,keymap)
       (when ,ancestor-kmap
         ;; (set-keymap-parent ,keymap ,ancestor-kmap)
         (define-keymap-onto-keymap ,ancestor-kmap ,kmap-sym :from-sym ',kmap-sym
           :no-overwrite-p t))
       ,@(loop for orig in (if (and load-after-keymap-syms
                                    (atom load-after-keymap-syms))
                               (list load-after-keymap-syms)
                             load-after-keymap-syms)
               collect `(push (cons ',orig ,kmap-sym)
                              buttons-after-load-alist)))))

(defmacro with-temporary-erjoalgo-mode-state (state &rest forms)
  (let ((orig-state (gensym "erjoalgo-mode-orig-state-")))
    `(let ((,orig-state erjoalgo-command-mode))
       (global-erjoalgo-command-mode ,state)
       ,@forms
       (global-erjoalgo-command-mode ,orig-state))))

(defun buttons-rec ()
  (with-temporary-erjoalgo-mode-state 0 (recursive-edit)))

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

(cl-defun define-keymap-onto-keymap (from-map to-map &key from-sym no-overwrite-p)
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
                                    (or (symbol-name from-sym) "child") (key-description keyvec) (or (reverse path) "")))
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

(cl-defun buttons-display (keymap &key
                               hide-command-names-p
                               max-description-chars
                               hide-command-use-count-p)
  (let (sym)
    (when (symbolp keymap)
      (setf sym keymap
            keymap (symbol-value keymap)))
    (cl-labels ((print-key (event)
                           (princ (key-description (vector event))))
                (peek (string len)
                      (if (not len) string
                        (subseq string 0 (min len (length string)))))
                (print-command (binding)
                               (unless hide-command-names-p
                                 (princ binding))
                               (unless (or hide-command-use-count-p
                                           (null (get binding 'use-count)))
                                 (princ (format "(%d)" (get binding 'use-count))))

                               (when (and (commandp binding)
                                          (documentation binding)
                                          (or (null max-description-chars)
                                              (not (zerop max-description-chars))))
                                 (princ "\t")
                                 (princ (peek (s-replace "\n" "\\n" (documentation binding))
                                              max-description-chars))))
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
      (with-help-window (format "%s help" (or sym "unknown keymap"))
        (print-keymap keymap "")))))


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
	      (let ((undo-len (length buffer-undo-list)))
	        (undo-boundary)
	        (or (progn ,@forms t)
		    (message "undoing from autogen button: %d"
			     (- (length buffer-undo-list) undo-len))
		    (undo (- (length buffer-undo-list) undo-len)))))))))

(defmacro defalias-tmp (aliases &rest body )
  (let (defs pre post)
    (loop for (from to) in aliases
          do
          (if (fboundp from)
              (let ((tmp (gensym "original-")))
                (push `(defalias ',tmp ',from) pre)
                (push `(defalias ',from ',tmp) post)
                (push `(fmakunbound ',tmp) post))
            (push `(fmakunbound ',from) post))
          collect `(defalias ',from ,to) into defs
          finally
          (return
           `(progn
              ,@pre
              ,@defs
              (prog1 (progn ,@body)
                ,@(reverse post)))))))

(defmacro buttons-macrolet (&rest body)
  "define 3-letter aliases for useful functions and macros
to provide a compact DLS for defining buttons"
  `(defalias-tmp
     ((ins 'buttons-insert-rec-template)
      (rec 'recursive-edit)
      (cmd 'buttons-defcmd)
      (cbd 'buttons-insert-code-block)
      (cmt 'comint-send-input)
      (idt 'indent-for-tab-command))
     ,@body)
  `(macrolet
       ((nli () `(newline-and-indent))
        (ins (text) `(buttons-insert-rec-template ,text))
        (cmd (&rest rest) `(buttons-defcmd ,@rest))
        (cbd () `(buttons-insert-code-block))
        (rec () `(recursive-edit))
        (idt () `(indent-for-tab-command)))
     ,@body))

(buttons-display 'cl-buttons)
