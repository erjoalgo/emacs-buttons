(require 'cl)
(require 'cl-lib)
(require 'buttons)

(defmacro with-mock-recedit (recedit-forms &rest body)
  "Mock (length RECEDIT-FORMS) invocations of (recursive-edit) in BODY."

  (let ((count-sym (gensym "count-")))
    `(lexical-let ((,count-sym 0))
       (cl-letf (((symbol-function 'recursive-edit)
                  (lambda ()
                    (case ,count-sym
                      ,@(append
                         (loop for form in recedit-forms
                               for i from 0
                               collect `(,i ,form))
                         `((t (error "Recursive-edit called too many times")))))
                    (incf ,count-sym))))
         ,@body))))

(defmacro check (form)
  "Ensure FORM is non-nil."
  (let ((val-sym (gensym "val-")))
    `(let ((,val-sym ,form))
       (should ,val-sym)
       ,val-sym)))

(let-when-compile
    ((buttons-make-key-mapper #'buttons-modifier-add-super))
  (buttons-macrolet
   nil;; ancestor
   (defbuttons test-buttons-emacs-lisp nil
     emacs-lisp-mode-map
     (but ("3" (cmd (ins "({})")))
          ("d"
           (but
            ("f" (cmd (ins "(defun {} ({}){(nli)}{})")))))))
   (defbuttons test-buttons-common-lisp test-buttons-emacs-lisp
     lisp-mode-map;; ancestor
     (but ("d"
           (but ("c"
                 (cmd (ins "(defclass {} ({}){(nli)}({}))")))))))))

(ert-deftest test-buttons ()

  (check (lookup-key emacs-lisp-mode-map (kbd "s-3")))
  (check (lookup-key emacs-lisp-mode-map (kbd "s-d s-f")))
  (check (lookup-key lisp-mode-map (kbd "s-3")))
  (check (lookup-key lisp-mode-map (kbd "s-d s-f")))
  (check (lookup-key lisp-mode-map (kbd "s-d s-c")))
  (check (not (lookup-key emacs-lisp-mode-map (kbd "s-d s-c"))))

  (with-temp-buffer
    (emacs-lisp-mode)
    (should (zerop (length (buffer-string))))
    (with-mock-recedit
     ((insert "buttons-test-fn-1")
      (insert "arg1")
      (insert "(1+ arg1)"))
     (funcall (check (lookup-key emacs-lisp-mode-map (kbd "s-d s-f"))))
     (should (equal (read (buffer-string))
                    '(defun buttons-test-fn-1 (arg1) (1+ arg1))))
     (eval-buffer)
     (should (= (buttons-test-fn-1 2) 3))))

  (with-temp-buffer
    (lisp-mode)
    (with-mock-recedit
     ((insert "my-class")
      (insert "parent")
      (with-mock-recedit
       ((insert "my-slot :initarg 0"))
       (funcall (check (lookup-key lisp-mode-map (kbd "s-3"))))))
     (funcall (check (lookup-key lisp-mode-map (kbd "s-d s-c"))))
     (should (equal (read (buffer-string))
                    '(defclass my-class (parent) ((my-slot :initarg 0))))))))
