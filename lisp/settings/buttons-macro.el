(defun buttons-recedit-record-text ()
  (let ((old-point (point)))
    (recursive-edit)
    (buffer-substring-no-properties old-point (point))))

(defmacro buttons-insert-rec-template (tmpl)
  (loop with start = 0
        with forms = nil
        with rec-sym-alist = nil
        as rec-group-start = (string-match "{\\([0-9]+\\)?}" tmpl start)
        do (if rec-group-start
               (progn
                 (unless (= start rec-group-start)
                   (push `(insert ,(subseq tmpl start rec-group-start)) forms))
                 (let ((group-no-str (match-string 1 tmpl)))
                   (if (null group-no-str)
                       (push `(recursive-edit) forms)
                     (let* ((group-no (string-to-number group-no-str))
                            (sym (cdr (assoc group-no rec-sym-alist))))
                       (if sym
                           (push `(insert ,sym) forms)
                         (setf sym (gensym (format "rec-group-%d--" group-no)))
                         (push (cons group-no sym) rec-sym-alist)
                         (push `(setf ,sym (buttons-recedit-record-text)) forms)))))
                 (setf start (match-end 0)))
             (progn (when (< start (length tmpl))
                      (push `(insert ,(subseq tmpl start)) forms))
                    (setf start (length tmpl))))
        while rec-group-start
        finally (return `(let ,(mapcar 'cdr rec-sym-alist)
                           ;; (doc ,tmpl)
                           ,@(reverse forms)))))

(defmacro buttons-defcmd (&body body)
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
         `(defun ,cmd-name ()
            ,(s-join "" (reverse (mapcar 'prin1-to-string forms)))
            (interactive)
	    (let ((undo-len (length buffer-undo-list)))
	      (undo-boundary)
	      (or (progn ,@forms t)
		  (message "undoing from autogen button: %d"
			   (- (length buffer-undo-list) undo-len))
		  (undo (- (length buffer-undo-list) undo-len))))))))


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

(defmacro with-button-aliases (&rest body)
   (defalias-tmp
     ((ins 'buttons-insert-rec-template)
      (nli 'newline-and-indent)
      (rec 'recursive-edit)
      (cmd 'buttons-make-anonymous-command)
      ;; (cbd 
      )
      'retval)
  (macrolet ((ins (tmpl)
                  `(insert-rec-template ,tmpl))
             (ins-raw (&rest text)
                      `(insert ,@text))
             (sxp (string)
                  `(ins ,(format "(%s {})" string)))
             (cmd (&body body)))
    (cmd
     (ins "for (int {0} = 0; {0} < {}; {0}++)")
     (sxp "defvar"))))

   
