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
         ,body
         (unless (eq ,(length recedit-forms) ,count-sym)
           (error "Recursive-edit called %s times, not %s"
                  ,count-sym ,(length recedit-forms)))))))

(defmacro check (form)
  "Ensure FORM is non-nil."
  (let ((val-sym (gensym "val-")))
    `(let ((,val-sym ,form))
       (should ,val-sym)
       ,val-sym)))

(let-when-compile
    ((buttons-make-key-mapper #'buttons-modifier-add-super))
  (buttons-macrolet
   nil
   (defbuttons test-buttons-emacs-lisp nil
     (emacs-lisp-mode-map)
     (but ("3" (cmd (ins "({})")))
          ("d"
           (but
            ("f" (cmd (ins "(defun {} ({}){(nli)}{})")))))))
   (defbuttons test-buttons-common-lisp
     test-buttons-emacs-lisp
     (lisp-mode-map)
     (but ("d"
           (but ("p"
                 (cmd (ins "(defparameter {})")))))))))

(ert-deftest test-buttons ()
  (dolist (kmap (list emacs-lisp-mode-map lisp-mode-map))
    (dolist (key (list (kbd "s-3") (kbd "s-d s-f")))
      ;; both keymaps have the ancestor's bindings
      (check (lookup-key kmap key))))

  (check (lookup-key lisp-mode-map (kbd "s-d s-p")))
  ;; no defparameter in emacs-lisp
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
     (defbuttons test-buttons-cbd nil
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

(ert-deftest test-ins ()
  (let-when-compile
      ((buttons-make-key-mapper #'buttons-modifier-add-super))
    (buttons-macrolet
     ((buf () `(file-name-nondirectory (buffer-name))))
     (defbuttons test-buttons-c nil
       (c++-mode)
       (but
        ("f";; for-loops submap
         (but
          ;; ascending
          ("a" (cmd-ins "for ( int {0} = 0; {0} < {}; {0}++ )" (cbd)))
          ;; descending
          ("d" (cmd-ins "for ( int {0} = {}; {0} >= 0; {0}--)" (cbd)))))

        ;; log an expression for debugging
        ("n" ;; print-expression submap
         (but
          ("v" ;; print value
           (cmd-ins "cout << \"" (buf)
                    ": value of {0}: \" << {0} << endl;"))))))))

  (with-temp-buffer
    (c++-mode)
    (with-mock-recedit
     (press-button test-buttons-c (kbd "s-f s-a"))
     ((insert "i")
      (insert "10")
      (with-mock-recedit
       (press-button test-buttons-c (kbd "s-f s-d"))
       ((insert "ii")
        (insert "5")
        (with-mock-recedit
         (press-button test-buttons-c (kbd "s-n s-v"))
         ((insert "i*ii")))))))

    (message "(buffer-string):\n%s" (buffer-string))

    (should (equal
             (concat "for ( int i = 0; i < 10; i++ )  {\n"
                     "  for ( int ii = 5; ii >= 0; ii--)  {\n"
                     "    cout << \""
                     (file-name-nondirectory (buffer-name))
                     ": value of i*ii: \" << i*ii << endl;\n"
                     "  }\n"
                     " }")
             (buffer-string)))))

(ert-deftest test-overriding-keymap-warning ()
  (buttons-macrolet
   ()
   (let (warnings
         (buttons-tests--target-keymap (but ([f1] (make-sparse-keymap)))))
     (defvar buttons-tests--target-keymap)
     (cl-letf (((symbol-function 'warn)
                (lambda (fmt &rest args)
                  (push (apply #'format fmt args) warnings))))
       (eval '(defbuttons overriding-keymap
                nil
                buttons-tests--target-keymap
                (buttons-make ([f1] 'next-line))))
       (should (eql 1 (length warnings)))
       ;; expect sym name in warning string
       (should (string-match-p "buttons-tests--target-keymap"
                               (car warnings)))))))
