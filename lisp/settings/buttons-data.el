
(setf
 programming-buttons
 (buttons-make-bindings
  "programming"
  nil
  ( "\\" (ins "\\n"))
  ( "%" (ins "%d "))
  ( "3" (ins "(") (rec) (ins ")"))
  ( "#" (ins ")") (rec) (ins "("))
  ( "2" (ins "\"" (rec) (ins "\"")))
  ( "@" (ins "'") (rec) (ins "'"))
  ( "8" (ins "*"))
  ( "9" (ins "[0-9]+"))
  ( "e" (ins " = ") (inm))
  ( "4" (ins "[") (rec) (ins "]"))
  ( "r" (ins "return ") )
  ( "SPC" (ins ", ") (inm))
					;( "/" (cmo) )
  ( "5" (ins "%s"))
  ( "=" (ins " == "))
  ( "+" (ins " != "))
					;( ">" (py-shift 'right))
					;( "<" (py-shift 'left))
  ( "]" (ins "[]"))
  ( "6" (ins "[^") (rec) (ins "]"))
  ( "?" (evl (comment-out-and-duplicate)))
  ( "backspace" (evl (throw 'button-abort nil)))
					;( ":" (evl (semi-and-next-line current-prefix-arg)))
  )
 )


(setf
 python-buttons
 (buttons-make-bindings
  "python"
  programming-buttons
  ( "f" (ins "for ") (rec) (ins " in ") (rec) (ins ":")
    (nli) (rec) (nli) (py-bck))
  ( "F" (ins "[ ") (rec) (ins " for ") (rec) (ins " in ") (rec) (ins " ]"))
  ( "w" (ins "while ") (rec) (py-scn) (rec) (nli) (py-bck))
  ( "T" (ins "try") (py-scn) (rec) (nli) (py-bck) (ins "except") (py-scn))
  ( "z" (ins "if ") (rec) (py-scn))
  ( "x" (ins "elif ") (idt) (rec) (py-scn))
  ( "c" (ins "else") (idt) (py-scn))
  ( "v" (ins " if ") (rec) (ins " else ") (rec) )
  ( "B" (ins "break"))
  ( "b" (ins "continue"))
  ( "1" (ins "not ") )
  ( "d" (ins "def ") (rec) (ins " ( ") (inm) (rec) (ins " )") (py-scn))
  ( "a" (ins "lambda ") (rec) (ins ": ") (inm))
					;(list "." (rec) (ins ".") (rec))
  ( "2" (ins "\"") (rec) (ins "\""))
  ( "@" (ins "'") (rec) (ins "'"))
					;(list "q" (ins "\"") (rec) (ins "\" % (") "cmsEnter string substitutions" (ins ")"))
					;(list "q" (ins " % (") "cmsEnter string substitutions" (ins ")"))
  ( "q" (ins " % (") (rec) (ins ")"))
					;(list "9" (ins "(") (cmt) (ins ")"))
  ( "m" (ins "import ") (evl (pshell_import_completion)) (cmt) (nli))
  ( "u" (ins "#!/usr/bin/python") (nli))
  ( "U" (ins "from ernestoutils import *") (nli))
  ( "M" (ins "from ") (rec) (ins " import *") (cmt) (nli))
					;(list "'" (ins "'") (rec) (ins "'"))
  ( "N" (ins "print ( ") (rec) (ins " )") (nli))
  ( "n" (ins "print (") (rec) (ins " )") (nli))
					;(list "n" (ins "print >>sys.stderr, ") (rec) (nli))
  ( "r" (ins "return ") (rec) (nli) (py-bck))
  ( "L" (ins "class ") (rec) (ins "(object)") (py-scn))
  ( "l" (ins "len(") (rec) (ins ")"))
  ( "'" (ins "\"\"\"") (rec) (ins "\"\"\"") (nli))
					;(list " " (ins "_"))
  ( "W" (ins "with open( ") (rec) (ins ", \"") (rec) (ins "\") as fh:") (nli) (rec) (nli))
					;(list "SPC" (ins "_"))
  ( "SPC" (ins ", "))
  ( "I" (ins "def __init__( self") (ins " )") (py-scn))
  ;;(list "0" (evl (insert-file \)/home/ernesto/Projects/argparse_template.py\")")
  ( "0" (evl (insert python-argparse-template)))
  ( "t" (ins "True"))
  ( "g" (ins "False"))
  ( "G" (ins "None"))
  ( "." (ins "import pdb;pdb.set_trace()") (nli))
  ( "_" (ins "if __name__ == \"__main__\":") (nli))
  ( "=" (ins "=="))
  ( "j" (ins " or ") (inm))
  ( "k" (ins " and ") (inm))
  ( ">" (py-shift right))
  ( "<" (py-shift left))
  ( "s" (ins "self") (inm))
  ( "h" (evl (python-dir-on-expression)))
  ( "H" (evl (pdb-help-on-expression)))
					;(list "\\" (ins "\\n"))
					;(define-key (current-local-map) (kbd "s-SPC") '(lambda () (interactive) (insert "_")))
  ( "i" (ins " in "))
  ( "[" (ins "{") (rec) (ins "}"))
					;(list "?" (evl (insert (format \)print 'running line %d'#autogen\" (line-number-at-pos)))")
  ;;(list "?" (evl (insert (format \)print 'running line %d'#autogen\" (random 999))")
					;(list "[" (ins "{") (evl (insertchar)) (ins "}"))
  ( "[" (ins "{}"))
  ( "]"  (ins ".format(") (rec) (ins ")"))
					;( "f11" (evl (pdb-run)))

  ;;(list "f1" (ins "(") (evl (insertchar)) (ins ", ") (evl (insertchar)) (ins ", ") (rec) (ins "),") (nli))
  ;;(list "f2" (ins "p"))
  ;;(list "f3" (ins "1-p"))
					;    (list "m" (rec) (ins ".") py-scn")
					;(list "m" (ins "import ") (inm))
  )
 )


(defmacro eval-buttons-after-load (feature
				   mode-keymap-sym buttons-keymap)
  `(with-eval-after-load ,(or feature (symbol-file mode-keymap-sym))
     (unless (boundp ',mode-keymap-sym) (edebug)
	     (error "%s is not bound" ,mode-keymap-sym))
     (let ((mode-keymap ,mode-keymap-sym))
       (mapc (lambda (kv)
	       ;;(destructuring-bind (k . v) kv
	       (let ((k (car kv)) (v (cdr kv)))
		 (define-key mode-keymap k v)))
	     ,buttons-keymap))))

(eval-buttons-after-load nil python-mode-map python-buttons)

'(eval-buttons-after-load nil inferior-python-mode-map python-buttons)

(setf
 pdb-buttons
 (buttons-make-bindings
  "pdb"
  python-buttons
  ;;(list "f1" (evl (comint-previous-input 1)))
  ;;(list "f2" (evl (comint-next-input 1)))
					;(list "r" (cmt "restart") (cmt "n"))
  ( "r" (cmt "restart") (evl (pdb-restart)))
					;(list "a" (evl (gud-step nil)))
					;(list "c" (evl (comint-send-input)))
  ( "c" (evl (gud-cont nil)))
  ( "d" (cmt "n"))
					;(list "e" (cmt "u"))
  ( "x" (evl (gud-break nil)))
  ( "z" (evl (gud-remove nil)))
  ( "b" (cmt "b"))
  ( "escape" (cmt ""))
  ( "X" (cmt "exit"))
  ))

'(eval-buttons-after-load nil
			  inferior-python-mode pdb-buttons)

(setf
 emacs-lisp-buttons
 (buttons-make-bindings
  "emacs-lisp"
  programming-buttons
  ( "d" (ins "(defun ") (rec) (ins " (") (rec) (ins ")")
    (nli) (rec) (ins ")") (nli))
  ( "w" (ins "(while ") (rec) (ins ")") (nli))
  ( "a" (ins "(lambda (") (rec) (ins ") ") (rec) (ins ")"))
  ( "z" (ins "(if ") (rec) (ins ")"))
  ( "x" (ins "(when ") (rec) (ins ")"))
  ( "c" (ins "(unless ") (rec) (ins ")"))
  ( "v" (ins "(progn ") (rec) (ins ")"))
  ( "l" (ins "(let* (") (rec) (ins ")") (nli) (rec) (ins ")") (nli))
  ;;(list "L" (ins "(lexical-let (") (rec) (ins ")") (nli) (rec) (ins ")") (nli))
  ( "L" (ins "(let (") (rec) (ins ")") (nli) (rec) (ins ")") (nli))
  ( "e" (ins "(setf ") (rec) (ins ")"))
  ( "i" (ins "(interactive)") )
  ( "7" (ins "&optional "))
					;(list "escape" (cmt ""))
  ( "g" (ins "nil") )
  ( "t" (ins "(list ") (rec) (ins ")"))
  ( "N" (ins "(message \"") (rec) (ins "\"") (rec) (ins ")"))
  ( "\\" (ins "\\\\(") (rec) (ins "\\\\)"))
  ;;(list "?" (evl (insert (format \)(print \\\"running line %d\\\");#autogen\" (random 999)))")
  ;;(list "irl" (evl (insert (format \)(print \\\"running line %d\\\");#autogen\" (random 999)))")
  ( "s" (evl (call-interactively 'insert-emacs-sym)))

  ( "j" (ins "(or ") (rec) (ins ")"))
  ( "k" (ins "(and ") (rec) (ins ")"))
  ( "1" (ins "(not ") (rec) (ins ")"))
  ( ":" (ins ": "))
  ( "'" (ins "'"))
  ( "h" (evl (describe-function-at-point)))
  ( "-" (ins "(-> ") (rec) (ins ")"))
  ( "_" (ins "(->> ") (rec) (ins ")"))
  ))

(eval-buttons-after-load nil
			 emacs-lisp-mode-map
					;emacs-lisp-mode-map
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
  ;;(list "N" (ins "(format ") (rec) (ins " \"") (rec) (ins "\"") (rec) (ins ")"))
  ( "N" (ins "(format t \"") (rec) (ins "~%\" ") (rec)  (ins ")"))
  ( "5" (ins "~A"))
  ( "%" (ins "~D"))
  ( "|" (ins "#\\Newline"))
  ( "\\" (ins "~%"))
  ( "L" (ins "(let (") (rec) (ins ")") (nli) (rec) (ins ")") (nli))
  ( ";" (ins ":"))
  ( ":" (ins "::"))
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
  ( "5" (ins "%s"))
  ( "%" (ins "%d"))
  ( "\\" (ins "\\n"))
  ( "l" (ins "(let [") (rec) (ins "]") (nli) (rec) (ins ")") (nli))
  ( "d" (ins "(defn ") (rec) (ins " [") (rec) (ins "]") (nli) (rec) (ins ")") (nli))
  ( "N" (ins "(printf \"") (rec) (ins "\\n\"") (rec) (ins ")"))
  ( ";" (ins ": "))
  ( "[" (ins "{") (rec) (ins "}"))
  ( "c" (ins "(when-not  ") (rec) (ins ")"))
  ( "h" (ins "(doc  ") (rec) (ins ")"))
  ( "{" (ins "{:keys [") (rec) (ins "]") (nli) (ins ":or {") (rec) (ins "}}"))
  ( "a" (ins "(fn [") (rec) (ins "]") (nli) (rec) (ins ")"))
  ( "e" (ins "(def ") (rec) (ins ")"))
  ))

(eval-buttons-after-load nil
			 clojure-mode-map
			 clj-buttons)

(setf
 c-buttons
 (buttons-make-bindings
  "c"
  programming-buttons
					;(list "f" (ins "for (") (rec) (ins "; ") (rec) (ins "; ") (rec) (ins ")") (cbd))
					;(list "f" (ins "for ( int ") (var-ins c-loop-var) (ins " = 0; ") (var-ins c-loop-var) (ins " < ") (rec) (ins "; ") (var-ins c-loop-var) (ins "++ )")  (var-pop c-loop-var) (cbd))

  ( "f" (ins "int ") (var-rec c-loop-var) (ins ";") (nli) (ins "for ( ")
    (var-ins c-loop-var)
    (ins " = 0; ") (var-ins c-loop-var) (ins " < ") (rec) (ins "; ")
    (var-ins c-loop-var) (ins "++ )")  (var-pop c-loop-var)
    (cbd))
  ( "w" (ins "while (") (rec) (ins ")") (cbd))
  ( "z" (ins "if (") (rec) (ins ")") (cbd))
  ( "x" (ins "else if (") (rec) (ins ")") (cbd))
  ( "c" (ins "else ") (cbd))
  ( "v" (ins "?") (rec) (ins ": ") (rec) )
  ( "1" (ins "!") )
  ( "n" (ins "printf( ") (rec) (ins " )") (scn))
  ( "N" (ins "printf( ") (rec) (ins " );"))
  ( "l" (ins "strlen( ") (rec) (ins " )"))
  ( "'" (ins "/*") (rec) (ins "*/") (nli))
  ( "/" (ins "/*") (rec) (ins "*/") (nli))
					;(list "\"" (ins "*/") (rec) (ins "/*") (nli))
  ( "t" (ins "true"))
  ( "g" (ins "false"))
  ( "G" (ins "NULL"))
  ( "j" (ins " || "))
  ( "k" (ins " && "))
  ( ">" (py-shift right))
  ( "<" (py-shift left))
  ( "[" (ins "{") (rec) (ins "}"))
  ( ";" (evl (move-end-of-line nil)) (ins ";") (nli))
  ( "B" (ins "break"))
  ( "b" (ins "continue"))

					;(list "?" (evl (insert (format \)printf( \\\"running line %d\\\\n\\\");//autogen\" (line-number-at-pos)))" (idt))
  ;;(list "?" (evl (insert (format \)printf( \\\"running line %d\\\\n\\\");//autogen\" (random 10000)))" (idt))
  ( "d" (ins " ( ") (rec) (ins " )") (cbd))
  ( "i" (ins "int"))
  ( "-" (ins "->"))
  ))

(eval-buttons-after-load "cc-mode"
			 c-mode-map
			 c-buttons)

(setf
 java-buttons
 (buttons-make-bindings
  "java"
  c-buttons
  ( "N" (ins "System.out.printf( \"") (rec) (ins "\\n\"") (rec) (ins " )")  (scn))
  ;;(list "," (evl (go-next-error t)))
  ;;(list "." (evl (go-next-error)))
					;(list "N" (ins "System.out.printf( ") (rec) (ins " )") (scn))
					;(list "n" (ins "new "))
					;(list "l" (ins "length( ") (rec) (ins " )"))
  ( "l" (ins ".length") )
  ( "G" (ins "null"))
  ( "d" (ins "public ") (rec) (ins " ( ") (rec) (ins " )") (cbd))
  ( "s" (ins "this.") (inm))
					;(list "S" (ins "new ") (inm) (rec) (ins "(") (rec) (ins ")"))
  ( "S" (evl (java-new)))
  ( "F" (ins "for ( ") (rec) (ins ": ") (rec) (ins " )") (cbd) )
  ( "L" (ins "class ") (rec)  (cbd) )
  ( "i" (ins "int ") (inm) )
  ( "I" (ins "String ") (inm) )
  ( "$" (ins "new ") (rec) (ins "[]{") (rec) (ins "}") )
  ( "-" (ins " -> ") )
  ( "m" (ins "import ") (rec) (ins ";"))
  ;;(list "$" (ins "new ") "rsm"ims1" (rec) (ins "[]{") (rec) (ins "}") )

					;(list "," (ins "<") (rec) (ins "> "))
  ))

(eval-buttons-after-load nil
			 java-mode-map
			 java-buttons)

(setf
 xml-buttons
 (buttons-make-bindings
  "xml"
  nil
  ("'" (evl(xml-toggle-line-comment)))
  ("/" (ins "<!--") (rec) (ins "-->") (nli))
					;("," (ins "<") (ine (store-current-html-tag)) (ins ">") (rec) (ins "</") (ine current-html-tag) (ins ">"))
  ("." (ins "</") (var-ins current-html-tag) (ins ">"))
  ("e" (ins "="))
  ("2" (ins "\"" (rec) (ins "\"")))
  ("u" (ins "<u>") (rec) (ins "</u>"))
  ("N" (ins "<br/>") )
  ("," (ins "<") (var-rec curr-html-tag) (ins ">") (rec) (ins "</")
   (var-ins curr-html-tag) (ins ">") (var-pop curr-html-tag))
  )
 )

(eval-buttons-after-load nil
			 xml-mode-map
			 xml-buttons)

(setf
 html-buttons
 (buttons-make-bindings
  "html"
  xml-buttons
  ( "P" (ins "<p>") (rec) (ins "</p>"))
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
  ( "d" (ins "function ") (rec) (ins " ( ") (rec) (ins " )") (cbd))
  ( "a" (ins "function") (ins "(") (rec) (ins "){") (rec) (ins "}"))
  ( "." (ins "debugger;") (nli))
  ;;(list "N" (ins "console.log( \"") (rec) (ins "\" );"))
  ( "N" (ins "console.log( \"") (rec) (ins "\"") (rec) (ins " );"))
  ( "T" (ins "try") (cbd) (ins "catch(err)") (cbd))
  ;;(list "N" (ins "console.log( ") (rec) (ins " );"))
  ;;(list "?" (evl (insert (format \)console.log('running line %d')//autogen\" (line-number-at-pos)))")
  ;;(list "?" "irlconsole.log('running line %d in %s')//autogen")
  ;;(list "?" "irlconsole.log('running line %d in %s: %s');//autogen")
  ;;(list "?" "irlconsole.log('%s in %s (%s) ');//autogen")
  ( "f" (ins "for (var i = 0; i<") (rec) (ins ".length; i++)") (cbd))
  ( "F" (ins "for (var ") (rec) (ins " in ") (rec) (ins ")") (cbd))
  ( "l" (ins ".length"))
  ( "r" (ins "return ") (rec) (ins ";"))
  ( "Z" (ins "if ( ") (rec) (ins " ){ ") (rec) (ins " }"))
  ( "v" (ins "var ") (inm))

  ;;(list "[" (ins "{") (evl (insertchar)) (ins "}"))
  ( "[" (ins "{}"))
  ( "]"  (ins ".format(") (rec) (ins ")"))
  ( "{" (ins "{") (nli) (rec) (nli) (ins "}") (idt))
  ( ";" (ins ": "))
  ( ":" (ins ": "))
  ( "_" (ins ",") (nli) (inm))
  ( "L" (ins "let { ") (rec) (ins " } = ") )
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
  ( "a" (ins "func") (ins "(") (rec) (ins "){") (rec) (ins "}"))
  ( "s" (ins ".(*") (rec) (ins ")"))
  ( "E" (ins " := "))
  ( "d" (ins "func ") (rec) (ins " ( ") (rec) (ins " ) ") (rec) (cbd))
  ( "D" (ins "func Test") (rec) (ins " ( t *testing.T )") (cbd))
  ( "]" (ins "[]"))
  ( "#" (ins "()"))
  ( "#" (ins "()"))
  ( "r" (ins "return ") (inm))
  ( "M" (ins "package main") (nli))
					;(list "m" (ins "import ( ") (nli) (rec) (nli) (ins " )") (evl (indent-for-tab-command)) (nli))
  ( "m" (ins "fmt.Sprintf( \"") (rec) (ins "\\n\"") (rec) (ins " )"))
  ( "N" (ins "fmt.Printf( \"") (rec) (ins "\\n\"") (rec) (ins " )"))
  ;;(list "x" (ins "else if ") (rec) (cbd))
  ( "x" (ins "else if ") (rec) (ins "; ") (rec) (cbd))
  ;;(list "z" (ins "if ") (rec) (cbd))
  ( "z" (ins "if ") (rec) (ins "; ") (rec) (cbd))
  ( ":" (ins ": ") )
  ( "Z" (ins "if ") (rec) (cbd))
  ( "Z" (ins "if ; DEBUG") (cbd))
					;(list "w" (ins "switch ") (rec) (ins "; ") (rec) (cbd))
					;(list "F" (ins "for ") (rec) (cbd))
					;(list "F" (ins "for ") (rec) (ins "; ") (rec) (ins "; ") (rec) (cbd))
  ( "F" (ins "for i := 0; i < ") (rec) (ins "; i++") (cbd))
  ( "W" (ins "switch ") (cbd) )
  ( "w" (ins "case ") (rec) (ins ":") (nli) )
  ( ";" (ins ":") (nli) )
					;(list "T" (ins "type ") (rec) (ins " ") "chsgo-types" (cbd) )
  ( "T" (ins "type ") (rec) (ins " struct ") (cbd) )
  ( "G" (ins "nil"))
  ( "6" (ins "%v"))
  ( "^" (ins "%#v"))
					;(list "D" (ins "defer ") (rec) "nil")
  ( "v" (ins "var "))
					;( "V" (ins "var ") (rec) (ins " ") "chsgo-types")
  ( "e" (ins " = "))
  ( "l" (ins "len( ") (rec) (ins " )") )
  ( "R" (ins "range ") (inm))
  ;;(list "." (evl (go-next-error)))
  ;;(list "," (evl (go-next-error t)))
  ( "f11" (evl (go-run)))
  ( "+" (ins " != "))
  ( "f" (ins "for ") (rec) (ins " := range ") (rec) (cbd))
  ( "P" (ins "%p"))
  ( "_" (ins "_, "))
  ;;(list "?" (evl (insert (format \)fmt.Printf( \\\"running line %d\\\\n\\\" )//autogen\" (line-number-at-pos)))")
  ( "{" (ins "&") (rec) (ins "{") (rec) (ins "}"))
  ( "O" (ins "verbose(func(){fmt.Printf(\"VERBOSE: ") (rec) (ins "\"") (rec) (ins ")})"))

  )
 )
'(setq go-types '("struct" "int" "bool" "string" "float"))

(eval-buttons-after-load nil
			 go-mode-map
			 go-buttons)


'(;;(edebug)
  (setq peg-buttons
	(
					;(list "a" (ins " <- ") (rec) (cbd))
	 ( "a" (ins " <- ") )
	 ( "A" (evl (peg-insert-alternatives)) )
	 ( "|" (ins " /") (nli))
	 ( "S" (ins "{return string(c.text), nil}"))
	 ))
  (go-mode)
  ;;(define-key (current-local-map) "s" nil )sss
  (setq gofmt-ignore-p t)
  )

(setf
 bash-buttons
 (buttons-make-bindings
  "bash"
  nil
  ( "1" (ins "! "))
  ( "V" (ins "\"${") (rec) (evl (upcase-last)) (ins "}\""))
  ( "v" (ins "${") (rec) (evl (upcase-last)) (ins "}"))
  ( "w" (ins "while ") (rec) (ins "; do") (nli) (rec) (nli) (ins "done"))
  ( "e" (evl (upcase-last)) (ins "="))
  ( "E" (evl (upcase-last)) (ins "=${") (evl (insert (bash-identifier-current-line))) (rec) (ins ":-") (rec) (ins "}") (nli))
  ( "$" (ins "$(") (rec) (ins ")"))
  ( "j" (ins " || "))
  ( "k" (ins " && "))
  ( "S" (idt) (ins "case ${") (rec) (ins "} in") (nli) (rec) (nli) (ins "esac") (nli))
  ( "s" (idt) (ins ")") (nli) (rec) (nli) (ins ";;") (nli))
  ( "o" (ins "${OPTARG}"))
  ( "4" (ins "[ ") (rec) (ins " ]"))
  ( "2" (ins "\"") (rec) (ins "\""))
  ( "z" (ins "if ") (rec) (ins "; then") (nli) (rec) (nli) (py-bck) (ins "fi"))
  ( "x" (ins "elif ") (rec) (ins "; then") (nli) (rec) (nli) (py-bck))
  ( "c" (ins "else ") (rec) (ins "; then") (nli) (rec) (nli) (py-bck) )
  ( "3" (ins "(") (rec) (ins ")"))
  ( "\\" (ins " | "))
  ( "N" (ins "echo "))
  ( "d" (ins "function ") (rec) (cbd))
  ( "l" (ins "test ") )
  ;;(list "d" (ins "function ") (rec) (ins "{") (nli) (rec) (ins "}"))
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
  ( "m" (ins "$") (rec) (ins "$"))
  ;;(list "M" (ins "$") (rec) (ins "$"))
  ( "b" (ins "\\begin{") (rec) (ins "}"))
  ( "B" (ins "\\end{") (rec) (ins "}"))
  ( "[" (ins "{") (rec) (ins "}"))
  ( "i" (ins "\\in "))
  ( "I" (ins "\\item ") (idt) (rec) (nli) )
  ( "I" (ins "\\item ") (idt) (rec) (nli) )
					;(list "L" (ins "\\begin{list}{}{}") (nli) (rec) (ins "\\end{list}"))
  ( "l" (ins "\\begin{align*}") (nli) (rec) (nli) (ins "\\end{align*}"))
  ( "L" (ins "\\begin{tabular}{lr}") (nli) (rec) (ins "\\end{tabular}"))
  ( "_" (ins ".$") (rec) (ins "$."))
  ( "x" (ins "(.x.)"))
					;(list "P" (ins "\\begin{part}") (nli) (rec) (nli) (ins "\\end{part}") (idt)  (nli))
  ( "q" (ins "\\begin{numedquestion}") (ins "% q#") (rec) (nli) (rec) (nli)  (ins "\\end{numedquestion}") (idt) (nli))
  ( "P" (ins "\\begin{part}") (ins "% (") (rec) (ins ")") (nli) (rec) (nli)  (ins "\\end{part}") (idt) (nli))


  ( "j" (ins " \\vee "))
  ( "k" (ins " \\wedge "))
  ( "j" (ins "\\cup "))
  ( "k" (ins "\\cap "))

  ( "1" (ins " \\sim "))

  ( "\\" (ins " \\\\") (nli) (inm))

  ;;(list "6" (ins "\\mycomp{") (rec) (ins "}"))
  ( "6" (ins "^{") (rec) (ins "}"))
  ( "K" (ins "{") (rec) (ins " \\choose ") (rec) (ins "} ") (inm))
  ( "f" (ins "\\frac{") (rec) (ins "}{") (rec) (ins "}"))
  ;;(list "f" (ins "\\frac{") (evl (insertchar)) (ins "} {") (evl (insertchar)) (ins "}"))
					;(list "(" (ins "P(") (rec)  (ins ")") (evl (upcase-last)))
  ( "(" (ins "P(") (rec)  (ins ")") )
  ( "8" (ins "P(") (rec)  (ins ")") )
  ( ")" (ins " + "))
  ( "." (ins "\\cdot "))
  ( "|" (ins "P(") (rec)  (ins "|") (rec) (ins ")") )
  ( "_" (evl (backward-char)) (evl (upcase-last)) (ins "_") (evl (forward-char))  )
  ( "t" (ins "\\text{") (rec) (ins "}")  )
  ( "{" (ins "\\{") (rec) (ins "\\}")  )
  ( "-" (ins "(1-p)^") (inm))
  ;;(list "_" (ins "(1-p)^") (inm))
  ( "_" (ins "_"))
					;(list "-" (ins "p^") (inm))
  ( "p" (ins "^") (inm))
  ( ";" (ins "P(\\{X=") (rec) (ins "\\})"))
  ( "=" (ins " + "))
  ( "E" (ins "E[") (rec) (ins "]")  )
					;(list "p" (ins "^"))
  ( "]" (ins "^"))
  ( "+" (ins "+"))


  ( "v" (ins "\\begin{verbatim}") (rec) (ins "\\end{verbatim}"))
  ( "7" (ins " & "))
					;per-session
					;(list "f1" (ins "(\\forall ") (rec) (ins "\\in ") (rec) (ins ") "))
  ;;(list "f1" (ins "r_{") (evl (insertchar)) (ins ",") (evl (insertchar)) (ins "}(") (evl (insertchar)) (ins ")"))
					;(list "f2" (ins " \\sset "))
					;(list "f2" (ins " \\mathbb{") (rec) (ins "}"))
  ;;(list "f2" (ins "\\mathbb{N}") (inm))
  ;;(list "f3" (ins "\\rightarrow ") (inm))
  ;;(list "f4" (ins "\\leftrightarrow ") (inm))
					;(list "f3" (ins "\\cap (b) "))
  ;;(list "f4" (ins "f(\\cap (b)) "))
  ;;(list "f5" (ins "f( ") (rec) (ins " )"))
  ;;(list "f1" (ins "\\section{") (rec) (ins "}"))
  ;;(list "f2" (ins "\\subsection{") (rec) (ins "}"))
  ;;(list "f3" (ins "\\bibitem{") (rec) (ins "}"))
  ;;(list "o" (ins "\\cite{") (rec) (ins "}"))

  ;;(list "f4" (ins " \\sset"))
  ;;(list "7" (ins " & "))
  ;;(list "\\" (ins "\\\\" ")nli")
  ( ";" (ins "\\;"))
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
  ( "z" (ins "if ") (rec) (ins ";") (nli) (rec) (nli) (ins "end") (idt))
  ( "'" (ins "'"))
					;(list "f" (ins "for  ") (rec) (ins "=") (rec) (nli) (rec) (ins "end") )
  ;;(list "f" (ins "for ") (ins "i=") (rec) (nli) (rec) (ins "end") )
  ( "f" (ins "for ") (rec) (ins "=1") (rec) (ins ":") (rec) (nli) (rec) (ins "end") )
  ( "j" (ins " ||  "))
  ( "k" (ins " &&  "))
  ( "2" (ins "'") (rec) (ins "'"))
  ( "L" (ins "size(") (rec) (ins ")"))
  ( "l" (ins "length(") (rec) (ins ")"))
  ( "s" (ins "class(") (rec) (ins ")"))
					;( "d" (ins "function Y = ") (evl (insert (extract-match \).*/\\\\(.*\\\\)[.]m\" (current-buffer-file-name) 1))" (ins "(") (rec) (ins ")") (nli))
  ( "+" (ins "~="))
  ( "h" (ins "help ") (inm))
  ( "1" (ins "~") )
  ;;(list "?" (evl (insert (format \)'running line %d'%%autogen\" (line-number-at-pos)))")
  ( "@" (ins "@(x)"))
					;(list "a" (ins "arrayfun(") (rec) (ins ")"))
  ( "a" (ins "arrayfun(@(x) ") (rec) (ins ")"))
  ;;(list "." (ins "keyboard;") (nli))
  ( ">" (ins "keyboard;") (nli))
  ( "Q" (ins "dbquit") (cmt ""))
  ( "q" (ins "dbcont") (cmt ""))
  ;;(list "f3" nil )
  ;;(list "f3" (ins "dbstep") (cmt ""))
  ( "N" (ins "sprintf('") (rec) (ins "'") (ins ")") )
					;(list "N" (ins "disp(") (rec) (ins "" ")ins)" )
  ( "N" (ins "disp(sprintf('") (rec) (ins "'") (rec) (ins "))") )
  ( "[" (ins "{") (rec) (ins "}"))
  ( "5" (ins "%f"))
  ( ";" (ins ": "))
  ( "x" (ins "elseif "))
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
  ( "h" (ins "help.search(") (inm) (rec) (ins ")"))
  ( "e" (ins " <- "))
  ( "d" (ins " <- function(") (rec) (ins ")") (cbd))
  ( "8" (ins "%*%"))
  ( "'" (ins "t(") (rec) (ins ")"))
  ( "f" (ins "for(") (rec) (ins " in as.single(") (rec) (ins ":") (rec) (ins "))") (cbd))
  ( "-" (ins "attr(") (rec) (ins ", \"") (rec) (ins "\" )"))
  ( "N" (ins "print(") (rec) (ins ")"))
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
  ( "d" (ins "function [") (rec) (ins "] = ") (rec) (ins "(")
    (rec) (ins ")") (nli) (rec) (nli) (ins "endfunction"))
  ( "'" (ins "#{") (rec) (ins "#}"))
  ( "2" (ins "\"") (rec) (ins "\""))
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
					;(list "d" (ins "int ") (rec) (ins " ( ") (rec) (ins " )")   (cbd))
  ( "d"  (ins " ( ") (rec) (ins " )")   (cbd))
  ( "m" (ins "#include "))
  ( "V" (ins "int ")  )
					;(list "N" (ins "std::cout << "))
  ( "N" (ins "printf( ") (rec) (ins " )"))
  ( "," (ins "<") (rec) (ins ">"))
  ( "C" (evl (cpp-compile)))
  ( "D" (ins "int main ( ") (rec) (ins " )") (cbd))
  ( "i" (ins "int ") (inm))
  ( "s" (ins "scanf( \"") (inm) (rec) (ins "\", ") (rec) (ins " )"))
  ( "s" (ins "scanf( \"%d\", &") (inm) (rec) (ins " );") )
  ( "S" (ins "int ") (var-rec scanf-var) (ins "; ") (ins "scanf( \"%d\", &")
    (var-ins scanf-var) (var-pop scanf-var)  (ins " );") (nli))
					;(list "f" (ins "for ( int i = 0") (rec)  (ins "; i < ") (rec) (ins "; i++)")(cbd))

  ("M"
   (ins "#include <unordered_map>") (nli)
   (ins "#include <iostream>") (nli)
   (ins "#include <string>") (nli)
   (ins "#include <assert.h>") (nli)
   (ins "using namespace std;") (nli))
  ))

(eval-buttons-after-load nil
			 c++-mode-map
			 cpp-buttons)

(setf
 yacc-buttons
 (buttons-make-bindings
  "yacc"
  programming-buttons
  ( "v"  (ins "$") (evl (insertchar)))
  ( "D"  (nli) (ins ":\t"))
  ( "d"  (nli) (ins "|\t"))
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
  ( "l"  (ins " [label=\"") (rec) (ins "\"];"))
  ( "-"  (ins " -> "))))

(eval-buttons-after-load nil
			 dot-mode-map
			 dot-buttons)


(setf
 forum-post-buttons
 (buttons-make-bindings
  "forum-post"
  programming-buttons
					;(list "d" (ins "int ") (rec) (ins " ( ") (rec) (ins " )")   (cbd))
  ( ","  (ins "[code]") (rec) (ins "[/code]") )
  ))

'(eval-buttons-after-load nil
			  forum-mode-map
			  forum-buttons)
