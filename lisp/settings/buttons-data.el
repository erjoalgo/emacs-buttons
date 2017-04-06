
(setf
 programming-buttons
 (buttons-make-bindings
  "programming"
  nil
  ( "\\" (mk-cmd (ins "\\n")))
  ( "%" (mk-cmd (ins "%d ")))
  ( "3" (mk-cmd (ins "(") (rec) (ins ")")))
  ( "#" (mk-cmd (ins ")") (rec) (ins "(")))
  ( "2" (mk-cmd (ins "\"") (rec) (ins "\"")))
  ( "@" (mk-cmd (ins "'") (rec) (ins "'")))
  ( "8" (mk-cmd (ins "*")))
  ( "9" (mk-cmd (ins "[0-9]+")))
  ( "e" (mk-cmd (ins " = ") (inm)))
  ( "4" (mk-cmd (ins "[") (rec) (ins "]")))
  ( "r" (mk-cmd (ins "return ") ))
  ( "SPC" (mk-cmd (ins ", ") (inm)))
  ( "5" (mk-cmd (ins "%s")))
  ( "=" (mk-cmd (ins " == ")))
  ( "+" (mk-cmd (ins " != ")))
  ( "]" (mk-cmd (ins "[]")))
  ( "6" (mk-cmd (ins "[^") (rec) (ins "]")))
  ( "?" (mk-cmd (evl (comment-out-and-duplicate))))
  )
 )


(setf
 python-buttons
 (buttons-make-bindings
  "python"
  programming-buttons
  ( "f" (mk-cmd (ins "for ") (rec) (ins " in ") (rec) (ins ":")
		(nli) (rec) (nli) (py-bck)))
  ( "F" (mk-cmd (ins "[ ") (rec) (ins " for ") (rec) (ins " in ") (rec) (ins " ]")))
  ( "w" (mk-cmd (ins "while ") (rec) (py-scn) (rec) (nli) (py-bck)))
  ( "T" (mk-cmd (ins "try") (py-scn) (rec) (nli) (py-bck) (ins "except") (py-scn)))
  ( "z" (mk-cmd (ins "if ") (rec) (py-scn)))
  ( "x" (mk-cmd (ins "elif ") (idt) (rec) (py-scn)))
  ( "c" (mk-cmd (ins "else") (idt) (py-scn)))
  ( "v" (mk-cmd (ins " if ") (rec) (ins " else ") (rec) ))
  ( "B" (mk-cmd (ins "break")))
  ( "b" (mk-cmd (ins "continue")))
  ( "1" (mk-cmd (ins "not ") ))
  ( "d" (mk-cmd (ins "def ") (rec) (ins " ( ") (inm) (rec) (ins " )") (py-scn)))
  ( "a" (mk-cmd (ins "lambda ") (rec) (ins ": ") (inm)))
  ( "2" (mk-cmd (ins "\"") (rec) (ins "\"")))
  ( "@" (mk-cmd (ins "'") (rec) (ins "'")))
  ( "q" (mk-cmd (ins " % (") (rec) (ins ")")))
  ( "m" (mk-cmd (ins "import ") (evl (pshell_import_completion)) (cmt) (nli)))
  ( "u" (mk-cmd (ins "#!/usr/bin/python") (nli)))
  ( "U" (mk-cmd (ins "from ernestoutils import *") (nli)))
  ( "M" (mk-cmd (ins "from ") (rec) (ins " import *") (cmt) (nli)))
  ( "N" (mk-cmd (ins "print ( ") (rec) (ins " )") (nli)))
  ( "n" (mk-cmd (ins "print (") (rec) (ins " )") (nli)))
  ( "r" (mk-cmd (ins "return ") (rec) (nli) (py-bck)))
  ( "L" (mk-cmd (ins "class ") (rec) (ins "(object)") (py-scn)))
  ( "l" (mk-cmd (ins "len(") (rec) (ins ")")))
  ( "'" (mk-cmd (ins "\"\"\"") (rec) (ins "\"\"\"") (nli)))
  ( "W" (mk-cmd (ins "with open( ") (rec) (ins ", \"") (rec) (ins "\") as fh:") (nli) (rec) (nli)))
  ( "SPC" (mk-cmd (ins ", ")))
  ( "I" (mk-cmd (ins "def __init__( self") (ins " )") (py-scn)))
  ( "0" (mk-cmd (evl (insert python-argparse-template))))
  ( "t" (mk-cmd (ins "True")))
  ( "g" (mk-cmd (ins "False")))
  ( "G" (mk-cmd (ins "None")))
  ( "." (mk-cmd (ins "import pdb;pdb.set_trace()") (nli)))
  ( "_" (mk-cmd (ins "if __name__ == \"__main__\":") (nli)))
  ( "=" (mk-cmd (ins "==")))
  ( "j" (mk-cmd (ins " or ") (inm)))
  ( "k" (mk-cmd (ins " and ") (inm)))
  ( ">" (mk-cmd (py-shift right)))
  ( "<" (mk-cmd (py-shift left)))
  ( "s" (mk-cmd (ins "self") (inm)))
  ( "h" (mk-cmd (evl (python-dir-on-expression))))
  ( "H" (mk-cmd (evl (pdb-help-on-expression))))
  ( "i" (mk-cmd (ins " in ")))
  ( "[" (mk-cmd (ins "{") (rec) (ins "}")))
  ( "[" (mk-cmd (ins "{}")))
  ( "]" (mk-cmd (ins ".format(") (rec) (ins ")")))

  )
 )


(defun define-keymap-onto-keymap (from-map to-map)
  (map-keymap
   (lambda (key cmd)
     (message "k %s cmd %s" key cmd)
     (define-key to-map (vector key) cmd))
   from-map))

(defmacro eval-buttons-after-load (feature
				   mode-keymap-sym buttons-keymap)
  `(with-eval-after-load ,(or feature (symbol-file mode-keymap-sym))
     (unless (boundp ',mode-keymap-sym) (edebug)
	     (error "%s is not bound" ,mode-keymap-sym))
     (define-keymap-onto-keymap ,buttons-keymap
       ,mode-keymap-sym)))

(eval-buttons-after-load nil python-mode-map python-buttons)

'(eval-buttons-after-load nil inferior-python-mode-map python-buttons)

(setf
 pdb-buttons
 (buttons-make-bindings
  "pdb"
  python-buttons
  ( "r" (mk-cmd (cmt "restart") (evl (pdb-restart))))
  ( "c" (mk-cmd (evl (gud-cont nil))))
  ( "d" (mk-cmd (cmt "n")))
  ( "x" (mk-cmd (evl (gud-break nil))))
  ( "z" (mk-cmd (evl (gud-remove nil))))
  ( "b" (mk-cmd (cmt "b")))
  ( "escape" (mk-cmd (cmt "")))
  ( "X" (mk-cmd (cmt "exit")))
  ))

'(eval-buttons-after-load nil
			  inferior-python-mode pdb-buttons)

(defun describe-function-at-point ()
  (interactive)
  (describe-function (function-called-at-point)))

(defmacro ins-sexp (string &rest forms)
  `((ins ,(concat "(" string)) ,@forms (ins ")")))


(setf
 emacs-lisp-buttons
 (buttons-make-bindings
  "emacs-lisp"
  programming-buttons
  ( "d" (buttons-make-bindings "emacs-lisp-def*" nil
			       ( "v" (mk-cmd (ins "(defvar ") (rec) (ins ")") (nli)))
			       ( "d" (mk-cmd (ins "(defun ") (rec) (ins ")") (nli)))
			       ( "m" (mk-cmd (ins "(defmacro ") (rec) (ins ")") (nli)))))
  ( "w" (mk-cmd (ins "(while ") (rec) (ins ")") (nli)))
  ( "a" (mk-cmd (ins "(lambda (") (rec) (ins ") ") (rec) (ins ")")))
  ( "z" (mk-cmd (ins "(if ") (rec) (ins ")")))
  ( "x" (mk-cmd (ins "(when ") (rec) (ins ")")))
  ( "c" (mk-cmd (ins "(unless ") (rec) (ins ")")))
  ( "v" (mk-cmd (ins "(progn ") (rec) (ins ")")))
  ( "l" (mk-cmd (ins "(let* (") (rec) (ins ")") (nli) (rec) (ins ")") (nli)))
  ( "L" (mk-cmd (ins "(let (") (rec) (ins ")") (nli) (rec) (ins ")") (nli)))
  ( "e" (mk-cmd (ins "(setf ") (rec) (ins ")")))
  ( "i" (mk-cmd (ins "(interactive)") ))
  ( "7" (mk-cmd (ins "&optional ")))
  ( "g" (mk-cmd (ins "nil") ))
  ( "t" (mk-cmd (ins "(list ") (rec) (ins ")")))
  ( "N" (mk-cmd (ins "(message \"") (rec) (ins "\"") (rec) (ins ")")))
  ( "\\" (mk-cmd (ins "\\\\(") (rec) (ins "\\\\)")))
  ( "s" (mk-cmd (evl (call-interactively 'insert-emacs-sym))))

  ( "j" (mk-cmd (ins "(or ") (rec) (ins ")")))
  ( "k" (mk-cmd (ins "(and ") (rec) (ins ")")))
  ( "1" (mk-cmd (ins "(not ") (rec) (ins ")")))
  ( ":" (mk-cmd (ins ": ")))
  ( "'" (mk-cmd (ins "'")))
  ( "h" (mk-cmd (evl (describe-function-at-point))))
  ( "-" (mk-cmd (ins "(-> ") (rec) (ins ")")))
  ( "_" (mk-cmd (ins "(->> ") (rec) (ins ")")))
  ))

(eval-buttons-after-load nil
			 emacs-lisp-mode-map
			 emacs-lisp-buttons)

(eval-buttons-after-load nil
			 read-expression-map
			 emacs-lisp-buttons)

(eval-buttons-after-load "ielm"
			 inferior-emacs-lisp-mode-map
			 emacs-lisp-buttons)

(setf
 cl-buttons
 (buttons-make-bindings
  "cl"
  emacs-lisp-buttons
  ( "N" (mk-cmd (ins "(format t \"") (rec) (ins "~%\" ") (rec)  (ins ")")))
  ( "5" (mk-cmd (ins "~A")))
  ( "%" (mk-cmd (ins "~D")))
  ( "|" (mk-cmd (ins "#\\Newline")))
  ( "\\" (mk-cmd (ins "~%")))
  ( "L" (mk-cmd (ins "(let (") (rec) (ins ")") (nli) (rec) (ins ")") (nli)))
  ( ";" (mk-cmd (ins ":")))
  ( ":" (mk-cmd (ins "::")))
  )
 )

(eval-buttons-after-load nil
			 lisp-mode-map
			 cl-buttons)

(eval-buttons-after-load nil
			 slime-mode-map
			 cl-buttons)

(setf
 clj-buttons
 (buttons-make-bindings
  "clj"
  cl-buttons
  ( "5" (mk-cmd (ins "%s")))
  ( "%" (mk-cmd (ins "%d")))
  ( "\\" (mk-cmd (ins "\\n")))
  ( "l" (mk-cmd (ins "(let [") (rec) (ins "]") (nli) (rec) (ins ")") (nli)))
  ( "d" (mk-cmd (ins "(defn ") (rec) (ins " [") (rec) (ins "]") (nli) (rec) (ins ")") (nli)))
  ( "N" (mk-cmd (ins "(printf \"") (rec) (ins "\\n\"") (rec) (ins ")")))
  ( ";" (mk-cmd (ins ": ")))
  ( "[" (mk-cmd (ins "{") (rec) (ins "}")))
  ( "c" (mk-cmd (ins "(when-not  ") (rec) (ins ")")))
  ( "h" (mk-cmd (ins "(doc  ") (rec) (ins ")")))
  ( "{" (mk-cmd (ins "{:keys [") (rec) (ins "]") (nli) (ins ":or {") (rec) (ins "}}")))
  ( "a" (mk-cmd (ins "(fn [") (rec) (ins "]") (nli) (rec) (ins ")")))
  ( "e" (mk-cmd (ins "(def ") (rec) (ins ")")))
  ))

(eval-buttons-after-load nil
			 clojure-mode-map
			 clj-buttons)

(setf
 c-buttons
 (buttons-make-bindings
  "c"
  programming-buttons

  ( "f" (mk-cmd (ins "int ") (var-rec c-loop-var) (ins ";") (nli) (ins "for ( ")
		(var-ins c-loop-var)
		(ins " = 0; ") (var-ins c-loop-var) (ins " < ") (rec) (ins "; ")
		(var-ins c-loop-var) (ins "++ )")  (var-pop c-loop-var)
		(cbd)))
  ( "w" (mk-cmd (ins "while (") (rec) (ins ")") (cbd)))
  ( "z" (mk-cmd (ins "if (") (rec) (ins ")") (cbd)))
  ( "x" (mk-cmd (ins "else if (") (rec) (ins ")") (cbd)))
  ( "c" (mk-cmd (ins "else ") (cbd)))
  ( "v" (mk-cmd (ins "?") (rec) (ins ": ") (rec) ))
  ( "1" (mk-cmd (ins "!") ))
  ( "n" (mk-cmd (ins "printf( ") (rec) (ins " )") (scn)))
  ( "N" (mk-cmd (ins "printf( ") (rec) (ins " );")))
  ( "l" (mk-cmd (ins "strlen( ") (rec) (ins " )")))
  ( "'" (mk-cmd (ins "/*") (rec) (ins "*/") (nli)))
  ( "/" (mk-cmd (ins "/*") (rec) (ins "*/") (nli)))
  ( "t" (mk-cmd (ins "true")))
  ( "g" (mk-cmd (ins "false")))
  ( "G" (mk-cmd (ins "NULL")))
  ( "j" (mk-cmd (ins " || ")))
  ( "k" (mk-cmd (ins " && ")))
  ( ">" (mk-cmd (py-shift right)))
  ( "<" (mk-cmd (py-shift left)))
  ( "[" (mk-cmd (ins "{") (rec) (ins "}")))
  ( ";" (mk-cmd (evl (move-end-of-line nil)) (ins ";") (nli)))
  ( "B" (mk-cmd (ins "break")))
  ( "b" (mk-cmd (ins "continue")))

  ( "d" (mk-cmd (ins " ( ") (rec) (ins " )") (cbd)))
  ( "i" (mk-cmd (ins "int")))
  ( "-" (mk-cmd (ins "->")))
  ))

(eval-buttons-after-load "cc-mode"
			 c-mode-map
			 c-buttons)

(setf
 java-buttons
 (buttons-make-bindings
  "java"
  c-buttons
  ( "N" (mk-cmd (ins "System.out.printf( \"") (rec) (ins "\\n\"") (rec) (ins " )")  (scn)))
  ( "l" (mk-cmd (ins ".length") ))
  ( "G" (mk-cmd (ins "null")))
  ( "d" (mk-cmd (ins "public ") (rec) (ins " ( ") (rec) (ins " )") (cbd)))
  ( "s" (mk-cmd (ins "this.") (inm)))
  ( "S" (mk-cmd (evl (java-new))))
  ( "F" (mk-cmd (ins "for ( ") (rec) (ins ": ") (rec) (ins " )") (cbd) ))
  ( "L" (mk-cmd (ins "class ") (rec)  (cbd) ))
  ( "i" (mk-cmd (ins "int ") (inm) ))
  ( "I" (mk-cmd (ins "String ") (inm) ))
  ( "$" (mk-cmd (ins "new ") (rec) (ins "[]{") (rec) (ins "}") ))
  ( "-" (mk-cmd (ins " -> ") ))
  ( "m" (mk-cmd (ins "import ") (rec) (ins ";")))

  ))

(eval-buttons-after-load nil
			 java-mode-map
			 java-buttons)

(setf
 xml-buttons
 (buttons-make-bindings
  "xml"
  nil
  ( "'" (mk-cmd (evl (xml-toggle-line-comment))))
  ( "/" (mk-cmd (ins "<!--") (rec) (ins "-->") (nli)))
  ( "." (mk-cmd (ins "</") (var-ins current-html-tag) (ins ">")))
  ( "e" (mk-cmd (ins "=")))
  ( "2" (mk-cmd (ins "\"") (rec) (ins "\"")))
  ( "u" (mk-cmd (ins "<u>") (rec) (ins "</u>")))
  ( "N" (mk-cmd (ins "<br/>") ))
  ( "," (mk-cmd (ins "<") (var-rec curr-html-tag) (ins ">") (rec) (ins "</")
		(var-ins curr-html-tag) (ins ">") (var-pop curr-html-tag)))
  )
 )

(eval-buttons-after-load "sgml-mode"
			 sgml-mode-map
			 xml-buttons)

(setf
 html-buttons
 (buttons-make-bindings
  "html"
  xml-buttons
  ( "P" (mk-cmd (ins "<p>") (rec) (ins "</p>")))
  )
 )

(eval-buttons-after-load nil
			 html-mode-map
			 html-buttons)


(setf
 js-buttons
 (buttons-make-bindings
  "js"
  c-buttons
  ( "d" (mk-cmd (ins "function ") (rec) (ins " ( ") (rec) (ins " )") (cbd)))
  ( "a" (mk-cmd (ins "function") (ins "(") (rec) (ins "){") (rec) (ins "}")))
  ( "." (mk-cmd (ins "debugger;") (nli)))
  ( "N" (mk-cmd (ins "console.log( \"") (rec) (ins "\"") (rec) (ins " );")))
  ( "T" (mk-cmd (ins "try") (cbd) (ins "catch(err)") (cbd)))
  ( "f" (mk-cmd (ins "for (var i = 0; i<") (rec) (ins ".length; i++)") (cbd)))
  ( "F" (mk-cmd (ins "for (var ") (rec) (ins " in ") (rec) (ins ")") (cbd)))
  ( "l" (mk-cmd (ins ".length")))
  ( "r" (mk-cmd (ins "return ") (rec) (ins ";")))
  ( "Z" (mk-cmd (ins "if ( ") (rec) (ins " ){ ") (rec) (ins " }")))
  ( "v" (mk-cmd (ins "var ") (inm)))

  ( "[" (mk-cmd (ins "{}")))
  ( "]" (mk-cmd (ins ".format(") (rec) (ins ")")))
  ( "{" (mk-cmd (ins "{") (nli) (rec) (nli) (ins "}") (idt)))
  ( ";" (mk-cmd (ins ": ")))
  ( ":" (mk-cmd (ins ": ")))
  ( "_" (mk-cmd (ins ",") (nli) (inm)))
  ( "L" (mk-cmd (ins "let { ") (rec) (ins " } = ") ))
  )
 )

(eval-buttons-after-load nil
			 js-mode-map
			 js-buttons)

(setf
 go-buttons
 (buttons-make-bindings
  "go"
  c-buttons
  ( "a" (mk-cmd (ins "func") (ins "(") (rec) (ins "){") (rec) (ins "}")))
  ( "s" (mk-cmd (ins ".(*") (rec) (ins ")")))
  ( "E" (mk-cmd (ins " := ")))
  ( "d" (mk-cmd (ins "func ") (rec) (ins " ( ") (rec) (ins " ) ") (rec) (cbd)))
  ( "D" (mk-cmd (ins "func Test") (rec) (ins " ( t *testing.T )") (cbd)))
  ( "]" (mk-cmd (ins "[]")))
  ( "#" (mk-cmd (ins "()")))
  ( "#" (mk-cmd (ins "()")))
  ( "r" (mk-cmd (ins "return ") (inm)))
  ( "M" (mk-cmd (ins "package main") (nli)))
  ( "m" (mk-cmd (ins "fmt.Sprintf( \"") (rec) (ins "\\n\"") (rec) (ins " )")))
  ( "N" (mk-cmd (ins "fmt.Printf( \"") (rec) (ins "\\n\"") (rec) (ins " )")))
  ( "x" (mk-cmd (ins "else if ") (rec) (ins "; ") (rec) (cbd)))
  ( "z" (mk-cmd (ins "if ") (rec) (ins "; ") (rec) (cbd)))
  ( ":" (mk-cmd (ins ": ") ))
  ( "Z" (mk-cmd (ins "if ") (rec) (cbd)))
  ( "Z" (mk-cmd (ins "if ; DEBUG") (cbd)))
  ( "F" (mk-cmd (ins "for i := 0; i < ") (rec) (ins "; i++") (cbd)))
  ( "W" (mk-cmd (ins "switch ") (cbd) ))
  ( "w" (mk-cmd (ins "case ") (rec) (ins ":") (nli) ))
  ( ";" (mk-cmd (ins ":") (nli) ))
  ( "T" (mk-cmd (ins "type ") (rec) (ins " struct ") (cbd) ))
  ( "G" (mk-cmd (ins "nil")))
  ( "6" (mk-cmd (ins "%v")))
  ( "^" (mk-cmd (ins "%#v")))
  ( "v" (mk-cmd (ins "var ")))
  ( "e" (mk-cmd (ins " = ")))
  ( "l" (mk-cmd (ins "len( ") (rec) (ins " )") ))
  ( "R" (mk-cmd (ins "range ") (inm)))
  ( "f11" (mk-cmd (evl (go-run))))
  ( "+" (mk-cmd (ins " != ")))
  ( "f" (mk-cmd (ins "for ") (rec) (ins " := range ") (rec) (cbd)))
  ( "P" (mk-cmd (ins "%p")))
  ( "_" (mk-cmd (ins "_, ")))
  ( "{" (mk-cmd (ins "&") (rec) (ins "{") (rec) (ins "}")))
  ( "O" (mk-cmd (ins "verbose(func(){fmt.Printf(\"VERBOSE: ") (rec) (ins "\"") (rec) (ins ")})")))

  )
 )
'(setq go-types '("struct" "int" "bool" "string" "float"))

(eval-buttons-after-load nil
			 go-mode-map
			 go-buttons)


'(;;(edebug)
  (setq peg-buttons
	(
	 ( "a" (mk-cmd (ins " <- ") ))
	 ( "A" (mk-cmd (evl (peg-insert-alternatives)) ))
	 ( "|" (mk-cmd (ins " /") (nli)))
	 ( "S" (mk-cmd (ins "{return string(c.text), nil}")))
	 ))
  (go-mode)
  (setq gofmt-ignore-p t)
  )

(setf
 bash-buttons
 (buttons-make-bindings
  "bash"
  nil
  ( "1" (mk-cmd (ins "! ")))
  ( "V" (mk-cmd (ins "\"${") (rec) (evl (upcase-last)) (ins "}\"")))
  ( "v" (mk-cmd (ins "${") (rec) (evl (upcase-last)) (ins "}")))
  ( "w" (mk-cmd (ins "while ") (rec) (ins "; do") (nli) (rec) (nli) (ins "done")))
  ( "e" (mk-cmd (evl (upcase-last)) (ins "=")))
  ( "E" (mk-cmd (evl (upcase-last)) (ins "=${") (evl (insert (bash-identifier-current-line))) (rec) (ins ":-") (rec) (ins "}") (nli)))
  ( "$" (mk-cmd (ins "$(") (rec) (ins ")")))
  ( "j" (mk-cmd (ins " || ")))
  ( "k" (mk-cmd (ins " && ")))
  ( "S" (mk-cmd (idt) (ins "case ${") (rec) (ins "} in") (nli) (rec) (nli) (ins "esac") (nli)))
  ( "s" (mk-cmd (idt) (ins ")") (nli) (rec) (nli) (ins ";;") (nli)))
  ( "o" (mk-cmd (ins "${OPTARG}")))
  ( "4" (mk-cmd (ins "[ ") (rec) (ins " ]")))
  ( "2" (mk-cmd (ins "\"") (rec) (ins "\"")))
  ( "z" (mk-cmd (ins "if ") (rec) (ins "; then") (nli) (rec) (nli) (py-bck) (ins "fi")))
  ( "x" (mk-cmd (ins "elif ") (rec) (ins "; then") (nli) (rec) (nli) (py-bck)))
  ( "c" (mk-cmd (ins "else ") (rec) (ins "; then") (nli) (rec) (nli) (py-bck) ))
  ( "3" (mk-cmd (ins "(") (rec) (ins ")")))
  ( "\\" (mk-cmd (ins " | ")))
  ( "N" (mk-cmd (ins "echo ")))
  ( "d" (mk-cmd (ins "function ") (rec) (cbd)))
  ( "l" (mk-cmd (ins "test ") ))
  )
 )

(eval-buttons-after-load nil
			 sh-mode-map
			 bash-buttons)

(setf
 tex-buttons
 (buttons-make-bindings
  "tex"
  programming-buttons
  ( "m" (mk-cmd (ins "$") (rec) (ins "$")))
  ( "b" (mk-cmd (ins "\\begin{") (rec) (ins "}")))
  ( "B" (mk-cmd (ins "\\end{") (rec) (ins "}")))
  ( "[" (mk-cmd (ins "{") (rec) (ins "}")))
  ( "i" (mk-cmd (ins "\\in ")))
  ( "I" (mk-cmd (ins "\\item ") (idt) (rec) (nli) ))
  ( "I" (mk-cmd (ins "\\item ") (idt) (rec) (nli) ))
  ( "l" (mk-cmd (ins "\\begin{align*}") (nli) (rec) (nli) (ins "\\end{align*}")))
  ( "L" (mk-cmd (ins "\\begin{tabular}{lr}") (nli) (rec) (ins "\\end{tabular}")))
  ( "_" (mk-cmd (ins ".$") (rec) (ins "$.")))
  ( "x" (mk-cmd (ins "(.x.)")))
  ( "q" (mk-cmd (ins "\\begin{numedquestion}") (ins "% q#") (rec) (nli) (rec) (nli)  (ins "\\end{numedquestion}") (idt) (nli)))
  ( "P" (mk-cmd (ins "\\begin{part}") (ins "% (") (rec) (ins ")") (nli) (rec) (nli)  (ins "\\end{part}") (idt) (nli)))


  ( "j" (mk-cmd (ins " \\vee ")))
  ( "k" (mk-cmd (ins " \\wedge ")))
  ( "j" (mk-cmd (ins "\\cup ")))
  ( "k" (mk-cmd (ins "\\cap ")))

  ( "1" (mk-cmd (ins " \\sim ")))

  ( "\\" (mk-cmd (ins " \\\\") (nli) (inm)))

  ( "6" (mk-cmd (ins "^{") (rec) (ins "}")))
  ( "K" (mk-cmd (ins "{") (rec) (ins " \\choose ") (rec) (ins "} ") (inm)))
  ( "f" (mk-cmd (ins "\\frac{") (rec) (ins "}{") (rec) (ins "}")))
  ( "(" (mk-cmd (ins "P(") (rec)  (ins ")") ))
  ( "8" (mk-cmd (ins "P(") (rec)  (ins ")") ))
  ( ")" (mk-cmd (ins " + ")))
  ( "." (mk-cmd (ins "\\cdot ")))
  ( "|" (mk-cmd (ins "P(") (rec)  (ins "|") (rec) (ins ")") ))
  ( "_" (mk-cmd (evl (backward-char)) (evl (upcase-last)) (ins "_") (evl (forward-char))  ))
  ( "t" (mk-cmd (ins "\\text{") (rec) (ins "}")  ))
  ( "{" (mk-cmd (ins "\\{") (rec) (ins "\\}")  ))
  ( "-" (mk-cmd (ins "(1-p)^") (inm)))
  ( "_" (mk-cmd (ins "_")))
  ( "p" (mk-cmd (ins "^") (inm)))
  ( ";" (mk-cmd (ins "P(\\{X=") (rec) (ins "\\})")))
  ( "=" (mk-cmd (ins " + ")))
  ( "E" (mk-cmd (ins "E[") (rec) (ins "]")  ))
  ( "]" (mk-cmd (ins "^")))
  ( "+" (mk-cmd (ins "+")))


  ( "v" (mk-cmd (ins "\\begin{verbatim}") (rec) (ins "\\end{verbatim}")))
  ( "7" (mk-cmd (ins " & ")))

  ( ";" (mk-cmd (ins "\\;")))
  )
 )

(eval-buttons-after-load nil
			 tex-mode-map
			 tex-buttons)

(setf
 matlab-buttons
 (buttons-make-bindings
  "matlab"
  python-buttons
  ( "z" (mk-cmd (ins "if ") (rec) (ins ";") (nli) (rec) (nli) (ins "end") (idt)))
  ( "'" (mk-cmd (ins "'")))
  ( "f" (mk-cmd (ins "for ") (rec) (ins "=1") (rec) (ins ":") (rec) (nli) (rec) (ins "end") ))
  ( "j" (mk-cmd (ins " ||  ")))
  ( "k" (mk-cmd (ins " &&  ")))
  ( "2" (mk-cmd (ins "'") (rec) (ins "'")))
  ( "L" (mk-cmd (ins "size(") (rec) (ins ")")))
  ( "l" (mk-cmd (ins "length(") (rec) (ins ")")))
  ( "s" (mk-cmd (ins "class(") (rec) (ins ")")))
  ( "+" (mk-cmd (ins "~=")))
  ( "h" (mk-cmd (ins "help ") (inm)))
  ( "1" (mk-cmd (ins "~") ))
  ( "@" (mk-cmd (ins "@(x)")))
  ( "a" (mk-cmd (ins "arrayfun(@(x) ") (rec) (ins ")")))
  ( ">" (mk-cmd (ins "keyboard;") (nli)))
  ( "Q" (mk-cmd (ins "dbquit") (cmt "")))
  ( "q" (mk-cmd (ins "dbcont") (cmt "")))
  ( "N" (mk-cmd (ins "sprintf('") (rec) (ins "'") (ins ")") ))
  ( "N" (mk-cmd (ins "disp(sprintf('") (rec) (ins "'") (rec) (ins "))") ))
  ( "[" (mk-cmd (ins "{") (rec) (ins "}")))
  ( "5" (mk-cmd (ins "%f")))
  ( ";" (mk-cmd (ins ": ")))
  ( "x" (mk-cmd (ins "elseif ")))
  )
 )

(eval-buttons-after-load nil
			 matlab-mode-map
			 matlab-buttons)

(setf
 r-buttons
 (buttons-make-bindings
  "r"
  programming-buttons
  ( "h" (mk-cmd (ins "help.search(") (inm) (rec) (ins ")")))
  ( "e" (mk-cmd (ins " <- ")))
  ( "d" (mk-cmd (ins " <- function(") (rec) (ins ")") (cbd)))
  ( "8" (mk-cmd (ins "%*%")))
  ( "'" (mk-cmd (ins "t(") (rec) (ins ")")))
  ( "f" (mk-cmd (ins "for(") (rec) (ins " in as.single(") (rec) (ins ":") (rec) (ins "))") (cbd)))
  ( "-" (mk-cmd (ins "attr(") (rec) (ins ", \"") (rec) (ins "\" )")))
  ( "N" (mk-cmd (ins "print(") (rec) (ins ")")))
  )
 )

(eval-buttons-after-load nil
			 ess-mode-map
			 r-buttons)

(setf
 octave-buttons
 (buttons-make-bindings
  "octave"
  matlab-buttons
  ( "d" (mk-cmd (ins "function [") (rec) (ins "] = ") (rec) (ins "(")
		(rec) (ins ")") (nli) (rec) (nli) (ins "endfunction")))
  ( "'" (mk-cmd (ins "#{") (rec) (ins "#}")))
  ( "2" (mk-cmd (ins "\"") (rec) (ins "\"")))
  )
 )

(eval-buttons-after-load nil
			 octave-mode-map
			 octave-buttons)

(add-hook 'octave-mode-hook 'octave_install_buttons)
(add-hook 'inferior-octave-mode-hook 'octave_install_buttons)


(setf
 cpp-buttons
 (buttons-make-bindings
  "cpp"
  c-buttons
  ( "d" (mk-cmd (ins " ( ") (rec) (ins " )")   (cbd)))
  ( "m" (mk-cmd (ins "#include ")))
  ( "V" (mk-cmd (ins "int ")  ))
  ( "N" (mk-cmd (ins "printf( ") (rec) (ins " )")))
  ( "," (mk-cmd (ins "<") (rec) (ins ">")))
  ( "C" (mk-cmd (evl (cpp-compile))))
  ( "D" (mk-cmd (ins "int main ( ") (rec) (ins " )") (cbd)))
  ( "i" (mk-cmd (ins "int ") (inm)))
  ( "s" (mk-cmd (ins "scanf( \"") (inm) (rec) (ins "\", ") (rec) (ins " )")))
  ( "s" (mk-cmd (ins "scanf( \"%d\", &") (inm) (rec) (ins " );") ))
  ( "S" (mk-cmd (ins "int ") (var-rec scanf-var) (ins "; ") (ins "scanf( \"%d\", &")
		(var-ins scanf-var) (var-pop scanf-var)  (ins " );") (nli)))

  ("M"
   (mk-cmd (ins "#include <unordered_map>") (nli)
	   (ins "#include <iostream>") (nli)
	   (ins "#include <string>") (nli)
	   (ins "#include <assert.h>") (nli)
	   (ins "using namespace std;") (nli)))
  ))

(eval-buttons-after-load nil
			 c++-mode-map
			 cpp-buttons)

(setf
 yacc-buttons
 (buttons-make-bindings
  "yacc"
  programming-buttons
  ( "v" (mk-cmd (ins "$") (evl (insertchar))))
  ( "D" (mk-cmd (nli) (ins ":\t")))
  ( "d" (mk-cmd (nli) (ins "|\t")))
  )
 )

(eval-buttons-after-load nil
			 yacc-mode-map
			 yacc-buttons)

(setf
 dot-buttons
 (buttons-make-bindings
  "dot"
  programming-buttons
  ( "l" (mk-cmd (ins " [label=\"") (rec) (ins "\"];")))
  ( "-" (mk-cmd (ins " -> ")))))

(eval-buttons-after-load nil
			 dot-mode-map
			 dot-buttons)


(setf
 forum-post-buttons
 (buttons-make-bindings
  "forum-post"
  programming-buttons
  ( "," (mk-cmd (ins "[code]") (rec) (ins "[/code]") ))
  ))

'(eval-buttons-after-load nil
			  forum-mode-map
			  forum-buttons)

(defun my-comment-out (arg) (interactive "P")
       (let ((start-end (if mark-active
			    (cons (save-excursion
				    (goto-char (region-beginning))
				    (line-beginning-position))
				  (region-end))
			  (cons
			   (line-beginning-position)
			   (save-excursion
			     (when arg (next-line (1- arg)))
			     (line-end-position))))))
	 (let* ((start (car start-end))
		(end (cdr start-end))
		(comment-regexp (concat
				 "^[[:space:]]*"
				 (regexp-quote comment-start)))
		(sample-text (buffer-substring-no-properties start end))
		(is-commented (string-match comment-regexp sample-text)))
	   (funcall (if is-commented 'uncomment-region 'comment-region)
		    start end nil))))

(global-set-key (kbd "M-/") 'my-comment-out)

