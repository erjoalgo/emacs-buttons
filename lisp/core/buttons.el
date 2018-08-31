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

(defun mk-cmd-read-action (action)
  (destructuring-bind (fun . args) action
    (let ((arg1 (car args)))
					;(edebug)
      (case fun
	('ins `(,arg1 (insert ,arg1)))
	('rec `("REC" (buttons-rec)))
	('inm `("(insert mode)" (global-erjoalgo-command-mode 0)))
	('nli `("\n" (newline-and-indent)))
	('evl `(,(format "%s" arg1) ,arg1))
	('cbd `("{\nREC\n}" (cbd)))
	('cmt `(,(concat arg1 " <RET>")
		,(when arg1 `(insert ,arg1))
		(comint-send-input)))
	('py-bck `(,"(unindent)"
		   (python-indent-dedent-line-backspace nil )))
	('py-scn `(": \n\t" (insert ":") (newline-and-indent)))
	('scn `("; \n\t" (insert ";") (newline-and-indent)))
	('idt `("(indent-for-tab-command)" (indent-for-tab-command)))
	('cmo `("(comment-out current-prefix-arg)" (comment-out current-prefix-arg)))
	('py-shift (let ((sym-name (format "python-indent-shift-%s" arg1)))
		     (list sym-name (intern sym-name))))
	('var-rec `(,(upcase (symbol-name arg1)) (buttons-recedit-record-text ',arg1)))
	('var-pop `("" (buttons-pop-text ',arg1)))
	('var-ins `(,(upcase (symbol-name arg1)) (insert (car ,arg1))))
	('chs `(,(s-join args "|") (insert (select-option args "select: " ))))
	('re-sub (let ((form `(replace-regexp ,(first args) ,(second args))))
		   `(,(format "%s" form) ,form)))
	(t (error "unknown action %s %s" action fun)))
      )))

(defmacro buttons-make-bindings (language-prefix base-map &rest bindings)
  (loop for (key-spec value . rest) in bindings
	when rest do (error "more than one sexp in input")
	with kmap-sym = (gensym (format "buttons-keymap-%s-"
					language-prefix))
	as key = (if (stringp key-spec)
		     (buttons-add-super-modifier key-spec)
		   key-spec)
	as name-sym = (gensym (format "buttons-%s-%s-" language-prefix
				      key-spec))
					;collect `(define-key ,kmap-sym ,key
	collect `(define-key ,kmap-sym ,key ,value)
	into define-keys
	finally (return `(let ((,kmap-sym (if ,base-map (copy-keymap ,base-map)
					    (make-sparse-keymap))))
			   ,@define-keys
			   ,kmap-sym))))

(defmacro mk-cmd (&rest actions)
  (loop
   with name-sym = (gensym (concat "autogen-cmd-"
				   (when (boundp 'mk-cmd-prefix)
				     (concat mk-cmd-prefix "-"))))
   for action in actions
   as form-desc = (mk-cmd-read-action action)
   with descs = nil
   append (destructuring-bind (desc . forms)
	      form-desc
	    (push desc descs)
	    forms)
   into forms
   finally (return
	    `(defun ,name-sym ()
	       ,(s-join "" (reverse descs)) (interactive)
	       (let ((undo-len (length buffer-undo-list)))
		 (undo-boundary)
		 (or (catch 'button-abort
		       ,@forms t)
		     (message "undoing %d "
			      (- (length buffer-undo-list) undo-len))
		     (undo (- (length buffer-undo-list) undo-len))))))))

(defmacro with-temporary-erjoalgo-mode-state (state &rest forms)
  (let ((orig-state (gensym "erjoalgo-mode-orig-state-")))
    `(let ((,orig-state erjoalgo-command-mode))
       (global-erjoalgo-command-mode ,state)
       ,@forms
       (global-erjoalgo-command-mode ,orig-state))))

(defun buttons-recedit-record-text (var-sym)
  (with-temporary-erjoalgo-mode-state
   0
   (let ((old-point (point)))
     (recursive-edit)
     (when var-sym
       (unless (boundp var-sym) (set var-sym nil))
       (let ((text (buffer-substring-no-properties old-point (point))))
	 (add-to-list var-sym text)
	 '(set var-sym (cons text (symbol-value var-sym))))))))

(defun buttons-pop-text (var-sym)
  (set var-sym (cdr (symbol-value var-sym))))

(setq cbd-map
      (list 'go-mode 'js-mode 'js2-mode
	    'c++-mode 'java-mode 'shell-script-mode 'sh-mode))

(defun buttons-rec ()
  (with-temporary-erjoalgo-mode-state 0 (recursive-edit)))

(defun cbd (&optional content)
  (insert " {")
  (newline-and-indent)
  (indent-for-tab-command)
  (buttons-rec)
  (newline-and-indent)
  (insert "}")
  (if (member major-mode '(c-mode js-mode))
      (c-indent-line-or-region)
    (indent-for-tab-command)))
