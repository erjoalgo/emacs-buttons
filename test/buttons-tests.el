(require 'cl)
(require 'cl-lib)
(require 'buttons)

(defmacro with-mock-recedit (body recedit-forms)
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
         ,body))))

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
   (defbuttons test-buttons-common-lisp
     test-buttons-emacs-lisp
     lisp-mode-map
     (but ("d"
           (but ("p"
                 (cmd (ins "(defparameter {})")))))))))

(ert-deftest test-buttons ()
  (check (lookup-key emacs-lisp-mode-map (kbd "s-3")))
  (check (lookup-key emacs-lisp-mode-map (kbd "s-d s-f")))
  (check (lookup-key lisp-mode-map (kbd "s-3")))
  (check (lookup-key lisp-mode-map (kbd "s-d s-f")))
  (check (lookup-key lisp-mode-map (kbd "s-d s-p")))
  (check (not (lookup-key emacs-lisp-mode-map (kbd "s-d s-p"))))

  (with-temp-buffer
    (emacs-lisp-mode)
    (should (zerop (length (buffer-string))))
    (with-mock-recedit
     (press-button emacs-lisp-mode-map (kbd "s-d s-f"))
     ((insert "buttons-test-fn-1")
      (insert "arg1")
      (insert "(1+ arg1)")))
     (should (equal (read (buffer-string))
                    '(defun buttons-test-fn-1 (arg1) (1+ arg1))))
     (eval-buffer)
     (should (= (buttons-test-fn-1 2) 3)))

  (with-temp-buffer
    (lisp-mode)
    (with-mock-recedit
     (press-button lisp-mode-map (kbd "s-d s-p"))
     ((insert "my-var")))
     (should (equal (read (buffer-string))
                    '(defparameter my-var)))))

(ert-deftest test-visualization-keybinding ()
  (press-button emacs-lisp-mode-map (kbd "s-?")))

(defun press-button (keymap key)
  (funcall (check (lookup-key keymap key))))

(ert-deftest test-cbd ()
  (let-when-compile
      ((buttons-make-key-mapper #'buttons-modifier-add-super))
    (buttons-macrolet
     nil
     (defbuttons test-cbd-buttons nil
       (c++-mode-map)
       (but
        ("t" (cmd (ins "true")))
        ("g" (cmd (ins "false")))
        ("z" (cmd (ins "if ({}){(cbd)}")))
        ("r" (cmd (ins "return {};")))))))

  (with-temp-buffer
    (c++-mode)
    (with-mock-recedit
     (press-button test-buttons-cbd (kbd "s-z"))
     ((press-button test-buttons-cbd (kbd "s-t"))
      (with-mock-recedit
       (press-button test-buttons-cbd (kbd "s-r"))
       ((press-button test-buttons-cbd (kbd "s-g"))))))
    (message "(buffer-string):\n%s" (buffer-string))
    (should (string-match "if (true) +{\n +return false;\n *}"
                          (buffer-string)))))
