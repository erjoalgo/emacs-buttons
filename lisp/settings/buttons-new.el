(defun map-buttons (source-file)
  (cl-labels
      ((rec (form)
            (cond
             ((atom form) form)
             (t (case (car form)
                  (mk-cmd
                   (loop with curr = ""
                         with ret = '(cmd)
                         for (act . rest) in (append (cdr form)  '(nil))
                         do (case act
                                   (ins (setf curr (concat curr (car rest))))
                                   (rec (setf curr (concat curr "{}")))
                                   (var-rec (setf curr (concat curr "{0}")))
                                   (var-ins (setf curr (concat curr "{0}")))
                                   (var-pop nil)
                                   (t
                                    (when (not (zerop (length curr)))
                                      (push `(my-ins ,curr) ret)
                                      (setf curr ""))
                                    (when act
                                      (if (eq 'evl act)
                                          (push rest ret)
                                        (push `(,act ,@rest) ret)))))
                         finally (return (reverse ret))))
                  (t
                   ;; (mapcar 'rec form)
                   (loop for sub in form collect (rec sub))
                     ))))))
    (let* ((contents
            (format "(progn %s)" (debian-file->string source-file)))
           (read (read contents)))
      (rec read))))

(setf print-level nil)
(let ((print-level nil))
  (with-help-window "new buttons!"
    (print (pp-to-string (map-buttons "buttons-data.el")))))
