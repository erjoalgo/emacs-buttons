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
	('re-sub (let ((form `(replace-regexp ,(first args) ,(second args))))
		   `(,(format "%s" form) ,form)))
	(t (error "unknown action %s %s" action fun)))
      )))

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

(defmacro defbuttons (kmap-sym load-after-keymap-syms ancestor-kmap keymap)
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
               collect `(eval-buttons-after-load ,orig ',kmap-sym)))))

(defmacro mk-cmd (&rest actions)
  (loop
   with name-sym = (gentemp (concat "autogen-cmd-"
				   (when (boundp 'mk-cmd-prefix)
				     (concat mk-cmd-prefix "-"))))
   for action in actions
   with descs = nil
   append (destructuring-bind (desc . forms)
	      (mk-cmd-read-action action)
	    (push desc descs)
	    forms)
   into forms
   finally (return
	    `(defun ,name-sym ()
	       ,(s-join "" (reverse descs))
               (interactive)
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

(defmacro eval-buttons-after-load (mode-keymap-sym buttons-keymap)
  `(push (cons ',mode-keymap-sym ,buttons-keymap)
         buttons-after-load-alist))

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
                               max-description-chars)
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
                               (when (and (commandp binding)
                                          (documentation binding)
                                          (or (null max-description-chars)
                                              (not (zerop max-description-chars))))
                                 (princ "\t")
                                 (prin1 (peek (s-replace "\n" "\\n" (documentation binding))
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
