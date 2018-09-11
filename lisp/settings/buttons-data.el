(defun super-add (key-spec)
  "if ‘key-spec' is a string, then prefix it with super
otherwise, leave it intact"
  (if (not (stringp key-spec))
      key-spec
    (if (equal key-spec "\\")
        (kbd "s-\\")
      (let ((fmt
             (if (equal (length key-spec) 1) "(kbd \"s-%s\")"
               "(kbd \"<s-%s>\")")))
        (eval (read (format fmt key-spec)))))))

(buttons-macrolet
 ()
 (defbuttons programming-buttons nil nil
   (buttons-make super-add
    ("\\" (cmd (ins "\\n")))
    ("%" (cmd (ins "%d")))
    ("3" (cmd (ins "({})")))
    ("#" (cmd (ins "){}(")))
    ("2" (cmd (ins "\"{}\"")))
    ("@" (cmd (ins "'{}'")))
    ("8" (cmd (ins "*")))
    ("9" (cmd (ins "[0-9]+")))
    ("e" (cmd (ins " = {inm}")))
    ("4" (cmd (ins "[{}]")))
    ("r" (cmd (ins "return ")))
    ("SPC" (cmd (ins ", {inm}")))
    ("5" (cmd (ins "%s")))
    ("=" (cmd (ins " == ")))
    ("+" (cmd (ins " != ")))
    ("]" (cmd (ins "[]")))
    ("6" (cmd (ins "[^{}]")))
    ((kbd "M-/") 'my-comment-out)
    ((kbd "M-?") 'my-comment-out-and-duplicate)
    ("R" (cmd (ins "***REMOVED***")))))

 (defbuttons python-buttons programming-buttons
   (python-mode-map)
   (buttons-make super-add
    ("e"
     (lambda nil
       (interactive)
       (insert
        (if
            (looking-back "^[ 	]*[a-zA-Z_.,]+ *")
            " = " "="))))
    ("f" (cmd (ins "for {} in {}:{nli}{}{nli}{idt}")))
    ("F" (cmd (ins "[ {} for {} in {} ]")))
    ("w" (cmd (ins "while {}:{nli}{}{nli}{idt}")))
    ("T" (cmd (ins "try:{nli}{}{nli}{idt}except:{nli}")))
    ("z" (cmd (ins "if {}:{nli}")))
    ("x" (cmd (ins "elif {}:{nli}")))
    ("c" (cmd (ins "else:{nli}")))
    ("v" (cmd (ins " if {} else {}")))
    ("1" (cmd (ins "not ")))
    ("d" (cmd (ins "def {}({inm}{}):{nli}")))
    ("a" (cmd (ins "lambda {}: {inm}")))
    ("2" (cmd (ins "\"{}\"")))
    ("@" (cmd (ins "'{}'")))
    ("q"
     (buttons-make super-add
      ("x" (cmd (ins "xrange({})")))))
    ("M" (cmd (ins "from {} import *")
              (cmt)
              (ins "{nli}")))
    ("N" (cmd (ins "print ( {} ){nli}")))
    ("n" (cmd (ins "print ({}){nli}")))
    ("r" (cmd (ins "return {}{nli}{idt}")))
    ("L" (cmd (ins "class {}(object):{nli}")))
    ("l" (cmd (ins "len({})")))
    ("'" (cmd (ins "\"\"\"{}\"\"\"{nli}")))
    ("W" (cmd (ins "with open({}, \"{}\") as fh:{nli}{}{nli}")))
    ("SPC" (cmd (ins ", ")))
    ("I" (cmd (ins "def __init__( self ):{nli}")))
    ("0" (cmd (insert python-argparse-template)))
    ("t" (cmd (ins "True")))
    ("g" (cmd (ins "False")))
    ("G" (cmd (ins "None")))
    ("." (cmd (ins "import pdb;pdb.set_trace(){nli}")))
    ("_" (cmd (ins "if __name__ == \"__main__\":{nli}")))
    ("=" (cmd (ins " == ")))
    ("j" (cmd (ins " or {inm}")))
    ("k" (cmd (ins " and {inm}")))
    (">" 'python-indent-shift-right)
    ("<" 'python-indent-shift-left)
    ("s" (cmd (ins "self{inm}")))
    ("h" (cmd (python-dir-on-expression)))
    ("H" (cmd (pdb-help-on-expression)))
    ("i" (cmd (ins " in ")))
    ("[" (cmd (insert "{")
              (ins "{}}")))
    ("[" (cmd (insert "{}")))
    ("]" (cmd (ins ".format({})")))
    ("N" (cmd (ins "a=[{}]{nli}print(getattr(Solution(), dir(Solution)[-1])(*a))")))
    ("E" (cmd (ins "raise Exception({})")))
    ("u"
     (buttons-make super-add
      ("a" (cmd (ins "assert({})")))))))

 (defbuttons pdb-buttons python-buttons
   (inferior-python-mode-map)
   (buttons-make super-add
    ("r" (cmd (cmt "restart")
              (pdb-restart)))
    ("c" (cmd (gud-cont nil)))
    ("d" (cmd (cmt "n")))
    ("x" (cmd (gud-break nil)))
    ("z" (cmd (gud-remove nil)))
    ("b" (cmd (cmt "b")))
    ("escape" (cmd (cmt "")))
    ("X" (cmd (cmt "exit")))))

 (defbuttons emacs-lisp-buttons programming-buttons
   (emacs-lisp-mode-map read-expression-map inferior-emacs-lisp-mode-map)
   (buttons-make super-add
    ("d"
     (buttons-make super-add
      ("v" (cmd (ins "(defvar {}){nli}")))
      ("f" (cmd (ins "(defun {} ({}){nli}{})")))
      ("m" (cmd (ins "(defmacro {} ({}){nli}{})")))))
    ("u"
     (buttons-make super-add
      ("k" (cmd (ins "(defpackage {nli}(:use :cl){})")))
      ("i" (cmd (ins "(:import-from #:{}")))
      ("e" (cmd (ins "(:export #:")))
      ("u" (cmd (ins "(:export #:")))))
    ("w" (cmd (ins "(while {}){nli}")))
    ("a" (cmd (ins "(lambda ({}) {})")))
    ("z" (cmd (ins "(if {})")))
    ("x" (cmd (ins "(when {})")))
    ("c" (cmd (ins "(unless {})")))
    ("v" (cmd (ins "(progn {})")))
    ("l"
     (buttons-make super-add
      ("l" (cmd (ins "(let ({}){nli}{}){nli}")))
      ("L" (cmd (ins "(let* ({}){nli}{}){nli}")))))
    ("e" (cmd (ins "(setf {})")))
    ("i" (cmd (ins "(interactive)")))
    ("7"
     (buttons-make super-add
      ("r" (cmd (ins "&rest ")))
      ("k" (cmd (ins "&key ")))
      ("b" (cmd (ins "&body ")))
      ("o" (cmd (ins "&optional ")))))
    ("g" (cmd (ins "nil")))
    ("t"
     (buttons-make super-add
      ("l"
       (buttons-make super-add
        ("t" (cmd (ins "(list {})")))
        ("l" (cmd (ins "(length {})")))))
      ("1" (cmd (ins "(null {})")))
      ("m"
       (buttons-make super-add
        ("m" (cmd (ins "(mapcar {}){nli}")))
        ("x" (cmd (ins "(macroexpand '{}){nli}")))))
      ("g" (cmd (ins "({0}-sym (gensym \"{0}\")){nli}")))
      ("e"
       (buttons-make super-add
        ("e" (cmd (ins "(equal {})")))
        ("q" (cmd (ins "(eq {})")))
        ("=" (cmd (ins "(= {})")))
        ("l" (cmd (ins "(eql {})")))))
      ("f"
       (buttons-make super-add
        ("r" (cmd (ins "(remove-if {})")))
        ("R" (cmd (ins "(remove-if-not {})")))))
      ("+" (cmd (ins "(1+ {})")))
      ("s" (cmd (ins "(subseq {})")))
      ("r" (cmd (ins "(return {})")))
      ("v" (cmd (ins "(reverse {})")))
      ("i" (cmd (ins "(insert {})")))
      ("b" (cmd (ins "(boundp {})")))
      ("n" (cmd (insert "~{~A~^")
                (ins "{}~}")))
      ("a" (cmd (ins "(assert {})")))
      ("p" (cmd (ins "(push {})")))
      ("c"
       (buttons-make super-add
        ("d" (cmd (ins "(cdr {})")))
        ("a" (cmd (ins "(car {})")))
        ("c" (cmd (ins "(cons {})")))))
      ("z" (cmd (ins "(zerop {})")))))
    ("n"
     (buttons-make super-add
      ("n" (cmd (ins "(format \"{}\"{})")))
      ("m" (cmd (ins "(message \"{}\"{})")))))
    ("\\" (cmd (ins "\\\\({}\\\\)")))
    ("s" (cmd (call-interactively 'insert-emacs-sym)))
    ("j" (cmd (ins "(or {})")))
    ("k" (cmd (ins "(and {})")))
    ("1" (cmd (ins "(not {})")))
    (":" (cmd (ins ": ")))
    ("'" (cmd (ins "'")))
    ("-" (cmd (ins "(-> {})")))
    ("_" (cmd (ins "(->> {})")))
    ("`" (cmd (ins "`{}'")))
    ("p"
     (buttons-make super-add
      ("l" (cmd (ins "(loop for {}){nli}")))
      ("i" (cmd (ins " in ")))
      ("t" (cmd (ins "with {} = ")))
      ("b" (cmd (ins "below ")))
      ("w" (cmd (ins "while ")))
      ("d" (cmd (ins "do ")))
      ("c" (cmd (ins "collect ")))
      ("a" (cmd (ins "append ")))
      ("f" (cmd (ins "finally ")))
      ("r" (cmd (ins "(return {})")))
      ("3" (cmd (ins "#P\"{}\"")))))))

 (defbuttons cl-buttons emacs-lisp-buttons
   (lisp-mode-map slime-mode-map)
   (buttons-make super-add
    ("d"
     (buttons-make super-add
      ("i" (cmd (ins "(declare (ignore {}))")))
      ("c" (cmd (ins "(defcommand {} ({}) ({}){nli}{})")))
      ("p" (cmd (ins "(defparameter {})")))
      ("s" (cmd (ins "(defstruct {}{nli}{})")))))
    ("n"
     (buttons-make super-add
      ("g" (cmd (ins "(format nil {})")))
      ("t" (cmd (ins "(format t {})")))
      ("f" (cmd (ins "(format fh {})")))
      ("n" (cmd (ins "(format {})")))
      ("[" (cmd (insert "~{~A~^")
                (ins "{}~}")))))
    ("#" (cmd (ins "#:")))
    ("5" (cmd (ins "~A")))
    ("%" (cmd (ins "~D")))
    ("|" (cmd (ins "#\\Newline")))
    ("\\" (cmd (ins "~%")))
    (";" (cmd (ins ":")))
    (":" (cmd (ins "::")))
    ("h"
     (buttons-make super-add
      ("d" (cmd (move-beginning-of-line nil)
                (ins "(describe '")
                (move-end-of-line nil)
                (ins ")")
                (slime-repl-return)))
      ("a" (cmd (ins "(apropos \"{}\"){nli}")))
      ("D" (cmd (ins "(declaim (optimize (debug 3) (speed 0)))")))))))

 (defbuttons clojure-buttons cl-buttons
   (clojure-mode-map cider-repl-mode-map)
   (buttons-make super-add
    ("5" (cmd (ins "%s")))
    ("%" (cmd (ins "%d")))
    ("\\" (cmd (ins "\\n")))
    ("l" (cmd (ins "(let [{}]{nli}{}){nli}")))
    ("d"
     (buttons-make super-add
      ("f" (cmd (ins "(defn {} [{}]{nli}{}){nli}")))))
    ("n" (cmd (ins "(printf \"{}\\n\"{})")))
    (";" (cmd (ins ": ")))
    ("[" (cmd (insert "{")
              (ins "{}}")))
    ("c" (cmd (ins "(when-not  {})")))
    ("h" (cmd (ins "(doc  {})")))
    ("{" (cmd (insert "{:keys [")
              (ins "{}]{nli}")
              (insert ":or {")
              (ins "{}}}")))
    ("a" (cmd (ins "(fn [{}]{nli}{})")))
    ("e" (cmd (ins "(def {})")))))

 (defbuttons c-buttons programming-buttons
   (c-mode-map)
   (buttons-make super-add
    ("f"
     (buttons-make super-add
      ("f" (cmd (ins "for ( int {0} = 0; {0} < {}; {0}++ ){cbd}")))
      ("F" (cmd (ins "for ( int {0} = {}; {0} >= 0; {0}-- ){cbd}")))))
    ("w" (cmd (ins "while ({}){cbd}")))
    ("z" (cmd (ins "if ({}){cbd}")))
    ("x" (cmd (ins " else if ({}){cbd}")))
    ("c" (cmd (ins " else {cbd}")))
    ("v" (cmd (ins "?{}: {}")))
    ("V" (cmd (kill-surrounding-sexp nil)
              (end-of-line)
              (ins "{nli}(void)")
              (yank-or-pop)
              (ins ";{inm}")))
    ("1" (cmd (ins "!")))
    ("n" (cmd (ins "printf( {} );")))
    ("N" (cmd (ins "scanf( \"{}\"{} );")))
    ("l" (cmd (ins "strlen( {} )")))
    ("'" (cmd (ins "/*{}*/{nli}")))
    ("/" nil)
    ("t" (cmd (ins "true")))
    ("g" (cmd (ins "false")))
    ("G" (cmd (ins "NULL")))
    ("j" (cmd (ins " || ")))
    ("k" (cmd (ins " && ")))
    (">" (cmd (python-indent-shift-right)))
    ("<" (cmd (python-indent-shift-left)))
    ("[" (cmd (insert "{")
              (ins "{}}")))
    (";" (cmd (move-end-of-line nil)
              (ins ";{nli}")))
    ("d"
     (buttons-make super-add
      ("d" (cmd (ins " ( {} ){cbd}")))
      ("m" (cmd (ins "int main (int argc, char* argv[]){cbd}")))))
    ("i"
     (buttons-make super-add
      ("u" (cmd (ins "unsigned ")))
      ("i" (cmd (ins "int ")))
      ("l" (cmd (ins "long ")))
      ("c" (cmd (ins "char ")))
      ("I" (cmd (ins "char* ")))
      ("v" (cmd (ins "void ")))
      ("t" (cmd (ins "const ")))
      ("b" (cmd (ins "bool ")))))
    ("s" (cmd (ins "sizeof({})")))
    ("S" (cmd (ins "sizeof({0})/sizeof(*{0})")))
    ("-" (cmd (ins "->")))
    ("m" (cmd (ins "#include <stdlib.h>{nli}#include <stdio.h>{nli}#include <string.h>{nli}#include <assert.h>{nli}#define MAX(a, b) ((a)>(b)? (a):(b)){nli}#define MIN(a, b) ((a)<(b)? (a):(b)){nli}#define ABS(a) ((a)>=0? (a):-(a)){nli}")))
    ("b"
     (buttons-make super-add
      ("c" (cmd (ins "continue;")))
      ("b" (cmd (ins "break;")))))))

 (defbuttons java-buttons c-buttons
   (java-mode-map)
   (buttons-make super-add
    ("n" (cmd (ins "System.out.printf( \"{}\\n\"{} );{nli}")))
    ("l" (cmd (ins ".length")))
    ("G" (cmd (ins "null")))
    ("d"
     (buttons-make super-add
      ("d" (cmd (ins " ( {} ){cbd}")))
      ("m" (cmd (ins "public static void main ( String[] argv){cbd}")))))
    ("p"
     (buttons-make super-add
      ("p" (cmd (ins "public ")))
      ("v" (cmd (ins "private ")))
      ("k" (cmd (ins "package ")))
      ("s" (cmd (ins "static ")))))
    ("s" (cmd (ins "this.{inm}")))
    ("S" (cmd (java-new)))
    ("F" (cmd (ins "for ({}: {}){cbd}")))
    ("L" (cmd (ins "class {}{cbd}")))
    ("i"
     (buttons-make super-add
      ("i" (cmd (ins "int {inm}")))
      ("I" (cmd (ins "Integer {inm}")))
      ("s" (cmd (ins "String ")))))
    ("$" (cmd (ins "new {}")
              (insert "[]{")
              (ins "{}}")))
    ("-" (cmd (ins " -> ")))
    ("m" (cmd (ins "import {};")))
    ("m" 'java-imports-add-import-dwim)
    ("t" (cmd (ins "try {cbd}catch ({}){cbd}")))))

 (defbuttons xml-buttons nil
   (nxml-mode-map)
   (buttons-make super-add
    ("/" (cmd (ins "<!--{}-->{nli}")))
    ((kbd "M-/") 'xml-toggle-line-comment)
    ("." (cmd (ins "</{0}>")))
    ("e" (cmd (ins "=")))
    ("2" (cmd (ins "\"{}\"")))
    ("u" (cmd (ins "<u>{}</u>")))
    ("," (cmd (ins "<{0}>{}</{0}>")))
    ("n"
     (lambda
       (mix-expr)
       (interactive "senter mix expression: ")
       (insert
        (format
         (concat "<mix:message log-level=\"INFO\">" "%s is <mix:copy-of select=\"%s\"/>" "</mix:message>")
         mix-expr mix-expr))))))

 (defbuttons html-buttons xml-buttons
   (html-mode-map)
   (buttons-make super-add
    ("\\" (cmd (ins "<br/>")))
    ("P" (cmd (ins "<p>{}</p>")))))

 (defbuttons js-buttons c-buttons
   (js-mode-map)
   (buttons-make super-add
    ("d" (cmd (ins "function {} ( {} ){cbd}")))
    ("a" (cmd (ins "function({}")
              (insert "){")
              (ins "{}}")))
    ("." (cmd (ins "debugger;{nli}")))
    ("n" (cmd (ins "console.log( \"{}\"{} );")))
    ("T" (cmd (ins "try{cbd}catch(err){cbd}")))
    ("f" (cmd (ins "for (var {0} = 0; {0}<{}; {0}++){cbd}")))
    ("F" (cmd (ins "for (var {} in {}){cbd}")))
    ("l" (cmd (ins ".length")))
    ("r" (cmd (ins "return {};")))
    ("Z" (cmd (ins "if ( {}")
              (insert " ){ ")
              (ins "{} }")))
    ("v" (cmd (ins "var {inm}")))
    ("[" (cmd (insert "{}")))
    ("]" (cmd (ins ".format({})")))
    ("{" (cmd (insert "{")
              (ins "{nli}{}{nli}}{idt}")))
    (";" (cmd (ins ": ")))
    (":" (cmd (ins ": ")))
    ("_" (cmd (ins ",{nli}{inm}")))
    ("L" (cmd (insert "let { ")
              (ins "{} } = ")))
    ("G" (cmd (ins "null")))
    ("N" (cmd (ins "logger.silly( \"")
              (insert
               (format "%s-%d"
                       (f-filename
                        (buffer-file-name))
                       (random)))
              (ins "\");")))
    ("s" (cmd (ins "this.")))
    ("i" (cmd (ins "in")))
    ("p" (cmd (ins ".prototype.")))))

 (defbuttons go-buttons c-buttons
   (go-mode-map)
   (buttons-make super-add
    ("a" (cmd (ins "func({}")
              (insert "){")
              (ins "{}}")))
    ("s" (cmd (ins ".(*{})")))
    ("E" (cmd (ins " := ")))
    ("d" (cmd (ins "func {} ( {} ) {}{cbd}")))
    ("D" (cmd (ins "func Test{} ( t *testing.T ){cbd}")))
    ("]" (cmd (ins "[]")))
    ("#" (cmd (ins "()")))
    ("#" (cmd (ins "()")))
    ("r" (cmd (ins "return {inm}")))
    ("M" (cmd (ins "package main{nli}")))
    ("m" (cmd (ins "fmt.Sprintf( \"{}\\n\"{} )")))
    ("n" (cmd (ins "fmt.Printf( \"{}\\n\"{} )")))
    ("x" (cmd (ins "else if {}; {}{cbd}")))
    ("z" (cmd (ins "if {}; {}{cbd}")))
    (":" (cmd (ins ": ")))
    ("Z" (cmd (ins "if {}{cbd}")))
    ("Z" (cmd (ins "if ; DEBUG{cbd}")))
    ("F" (cmd (ins "for i := 0; i < {}; i++{cbd}")))
    ("W" (cmd (ins "switch {cbd}")))
    ("w" (cmd (ins "case {}:{nli}")))
    (";" (cmd (ins ":{nli}")))
    ("T" (cmd (ins "type {} struct {cbd}")))
    ("G" (cmd (ins "nil")))
    ("6" (cmd (ins "%v")))
    ("^" (cmd (ins "%#v")))
    ("v" (cmd (ins "var ")))
    ("e" (cmd (ins " = ")))
    ("l" (cmd (ins "len( {} )")))
    ("R" (cmd (ins "range {inm}")))
    ("f11" (cmd (go-run)))
    ("+" (cmd (ins " != ")))
    ("f" (cmd (ins "for {} := range {}{cbd}")))
    ("P" (cmd (ins "%p")))
    ("_" (cmd (ins "_, ")))
    ("{" (cmd (ins "&{}")
              (insert "{")
              (ins "{}}")))
    ("O" (cmd (insert "verbose(func(){fmt.Printf(\"VERBOSE: ")
              (ins "{}\"{})})")))))

 (defbuttons bash-buttons programming-buttons
   (sh-mode-map)
   (buttons-make super-add
    ("1" (cmd (ins "! ")))
    ("V" (cmd (insert "\"${")
              (rec)
              (upcase-last)
              (ins "}\"")))
    ("v" (cmd (insert "${")
              (rec)
              (upcase-last)
              (ins "}")))
    ("w" (cmd (ins "while {}; do{nli}{}{nli}done")))
    ("e" (cmd (upcase-last)
              (ins "=")))
    ("E" (cmd (upcase-last)
              (insert "=${")
              (insert
               (bash-identifier-current-line))
              (ins "{}:-{}}{nli}")))
    ("$" (cmd (ins "$({})")))
    ("j" (cmd (ins " || ")))
    ("k" (cmd (ins " && ")))
    ("S" (cmd (ins "{idt}")
              (insert "case ${")
              (rec)
              (upcase-last)
              (ins "} in{nli}{}{nli}esac{nli}")))
    ("s" (cmd (ins "{idt}){nli}{}{nli};;{nli}")))
    ("o" (cmd (insert "${OPTARG}")))
    ("4" (cmd (ins "[ {} ]")))
    ("z" (cmd (ins "if {}; then{nli}{}{nli}fi{idt}{nli}")))
    ("x" (cmd (ins "elif {}; then{nli}{}{nli}{idt}")))
    ("c" (cmd (ins "else {}; then{nli}{}{nli}{idt}")))
    ("\\" (cmd (ins " \\{nli}")))
    ("|" (cmd (ins " | ")))
    ("n" (cmd (ins "echo ")))
    ("d" (cmd (ins "function {}{cbd}")))
    ("l" (cmd (insert " || exit ${LINENO}")))
    ("L" (cmd (ins "echo \"{}")
              (insert "\" && exit ${LINENO}")))
    ("f" (cmd (ins "for {}")
              (upcase-last)
              (ins " in {}; do{nli}{}{nli}done")))
    ("H" (cmd (insert "${1} && shift")
              (ins "{nli}")))
    ("g" (cmd (ins "true")))
    ("G" (cmd (ins "false")))
    ("u" 'insert-unique-line)
    ("C" (cmd (ins "<<EOF{nli}{}EOF")))
    ;; ( "x" 'shell-command-of-region)
    ("0" (cmd (insert sh-getopt-template)))))

 (defbuttons tex-buttons programming-buttons
   (tex-mode-map)
   (buttons-make super-add
    ("m" (cmd (ins "${}$")))
    ("b" (cmd (insert "\\begin{")
              (ins "{0}}{}")
              (insert "\\end{")
              (ins "{0}}")))
    ("B" (cmd (insert "\\textbf{")
              (ins "{}}")))
    ("[" (cmd (insert "{")
              (ins "{}}")))
    ("i" (cmd (ins "\\in ")))
    ("I" (cmd (ins "\\item {idt}{}{nli}")))
    ("I" (cmd (ins "\\item {idt}{}{nli}")))
    ("l" (cmd (insert "\\begin{align*}")
              (ins "{nli}{}{nli}")
              (insert "\\end{align*}")))
    ("L" (cmd (insert "\\begin{tabular}{lr}")
              (ins "{nli}{}")
              (insert "\\end{tabular}")))
    ("_" (cmd (ins ".${}$.")))
    ("x" (cmd (ins "(.x.)")))
    ("q" (cmd (insert "\\begin{numedquestion}")
              (ins "% q#{}{nli}{}{nli}")
              (insert "\\end{numedquestion}")
              (ins "{idt}{nli}")))
    ("P" (cmd (insert "\\begin{part}")
              (ins "% ({}){nli}{}{nli}")
              (insert "\\end{part}")
              (ins "{idt}{nli}")))
    ("j" (cmd (ins " \\vee ")))
    ("k" (cmd (ins " \\wedge ")))
    ("j" (cmd (ins "\\cup ")))
    ("k" (cmd (ins "\\cap ")))
    ("1" (cmd (ins " \\sim ")))
    ("\\" (cmd (ins " \\\\{nli}{inm}")))
    ("6" (cmd (insert "^{")
              (ins "{}}")))
    ("K" (cmd (insert "{")
              (ins "{} \\choose {}} {inm}")))
    ("f" (cmd (insert "\\frac{")
              (rec)
              (insert "}{")
              (ins "{}}")))
    ("(" (cmd (ins "P({})")))
    ("8" (cmd (ins "P({})")))
    (")" (cmd (ins " + ")))
    ("." (cmd (ins "\\cdot ")))
    ("|" (cmd (ins "P({}|{})")))
    ("_" (cmd (backward-char)
              (upcase-last)
              (ins "_")
              (forward-char)))
    ("t" (cmd (insert "\\text{")
              (ins "{}}")))
    ("{" (cmd (insert "\\{")
              (ins "{}\\}")))
    ("-" (cmd (ins "(1-p)^{inm}")))
    ("_" (cmd (ins "_")))
    ("p" (cmd (ins "^{inm}")))
    (";" (cmd (insert "P(\\{X=")
              (ins "{}\\})")))
    ("=" (cmd (ins " + ")))
    ("E" (cmd (ins "E[{}]")))
    ("]" (cmd (ins "^")))
    ("+" (cmd (ins "+")))
    ("v" (cmd (insert "\\begin{verbatim}")
              (rec)
              (insert "\\end{verbatim}")))
    ("7" (cmd (ins " & ")))
    (";" (cmd (ins "\\;")))
    ("/" 'my-comment-out)))

 (defbuttons matlab-buttons python-buttons
   (matlab-mode-map)
   (buttons-make super-add
    ("z" (cmd (ins "if {};{nli}{}{nli}end{idt}")))
    ("'" (cmd (ins "'")))
    ("f" (cmd (ins "for {}=1{}:{}{nli}{}end")))
    ("j" (cmd (ins " ||  ")))
    ("k" (cmd (ins " &&  ")))
    ("2" (cmd (ins "'{}'")))
    ("L" (cmd (ins "size({})")))
    ("l" (cmd (ins "length({})")))
    ("s" (cmd (ins "class({})")))
    ("+" (cmd (ins "~=")))
    ("h" (cmd (ins "help {inm}")))
    ("1" (cmd (ins "~")))
    ("@" (cmd (ins "@(x)")))
    ("a" (cmd (ins "arrayfun(@(x) {})")))
    (">" (cmd (ins "keyboard;{nli}")))
    ("Q" (cmd (ins "dbquit")
              (cmt "")))
    ("q" (cmd (ins "dbcont")
              (cmt "")))
    ("N" (cmd (ins "sprintf('{}')")))
    ("N" (cmd (ins "disp(sprintf('{}'{}))")))
    ("[" (cmd (insert "{")
              (ins "{}}")))
    ("5" (cmd (ins "%f")))
    (";" (cmd (ins ": ")))
    ("x" (cmd (ins "elseif ")))))

 (defbuttons r-buttons programming-buttons
   (ess-mode-map)
   (buttons-make super-add
    ("h" (cmd (ins "help.search({inm}{})")))
    ("e" (cmd (ins " <- ")))
    ("d" (cmd (ins " <- function({}){cbd}")))
    ("8" (cmd (ins "%*%")))
    ("'" (cmd (ins "t({})")))
    ("f" (cmd (ins "for({} in as.single({}:{})){cbd}")))
    ("-" (cmd (ins "attr({}, \"{}\" )")))
    ("N" (cmd (ins "print({})")))))

 (defbuttons octave-buttons matlab-buttons
   (octave-mode-map inferior-octave-mode-map)
   (buttons-make super-add
    ("d" (cmd (ins "function [{}] = {}({}){nli}{}{nli}endfunction")))
    ("'" (cmd (insert "#{")
              (ins "{}#}")))
    ("2" (cmd (ins "\"{}\"")))))

 (defbuttons cpp-buttons c-buttons
   (c++-mode-map)
   (buttons-make super-add
    ("f"
     (buttons-make super-add
      ("F" (cmd (ins "for(auto& {}: {}){cbd}")))))
    ("i"
     (buttons-make super-add
      ("s" (cmd (ins "string ")))))
    ("m" (cmd (ins "using namespace std;{nli}#include <vector>{nli}#include <unordered_map>{nli}#include <iostream>{nli}#define MAX(a, b) ((a)>(b)? (a):(b)){nli}#define MIN(a, b) ((a)<(b)? (a):(b)){nli}#define ABS(a) ((a)>=0? (a):-(a)){nli}")))
    ("N" (cmd (ins "cout << {} << endl;{nli}")))
    ("," (cmd (ins " << ")))
    ("l" (cmd (ins ".size()")))
    ("s" (cmd (ins "scanf( \"{inm}{}\", {} )")))
    ("s" (cmd (ins "scanf( \"%d\", &{inm}{} );")))
    ("S" (cmd (ins "int {0}; scanf( \"%d\", &{0} );{nli}")))
    ("M" (cmd (ins "#include <unordered_map>{nli}#include <iostream>{nli}#include <string>{nli}#include <assert.h>{nli}using namespace std;{nli}")))))

 (defbuttons yacc-buttons programming-buttons
   (yacc-mode-map)
   (buttons-make super-add
    ("v" (cmd (ins "$")
              (insertchar)))
    ("D" (cmd (ins "{nli}:	")))
    ("d" (cmd (ins "{nli}|	")))))

 (defbuttons dot-buttons programming-buttons
   (dot-mode-map)
   (buttons-make super-add
    ("l" (cmd (ins " [label=\"{}\"];")))
    ("-" (cmd (ins " -> ")))))

 (defbuttons forum-post-buttons programming-buttons
   (forum-mode-map)
   (buttons-make super-add
    ("," (cmd (ins "[code]{}[/code]")))))

 (defbuttons org-buttons nil
   (org-mode-map)
   (buttons-make super-add
    ("q" (cmd (ins "#+BEGIN_SRC {}{nli}{}#+END_SRC{nli}")))
    ("`" (cmd (ins "~{}~")))
    ("Q" (cmd (ins "#+begin_quote {}{nli}{}#+end_quote{nli}")))
    ((kbd "<s-tab>") 'org-indent-block)
    ("return" 'org-toggle-list-heading)
    ("i"
     (lambda nil
       (interactive)
       (if org-inline-image-overlays
           (org-remove-inline-images)
         (org-display-inline-images))))
    ("m" (cmd (ins "#+OPTIONS: ^:nil{nli}#+OPTIONS: toc:nil{nli}#+OPTIONS: html-postamble:nil{nli}#+OPTIONS: num:nil{nli}#+TITLE: {}{nli}")))
    ("R" (cmd (ins "***REMOVED***")))
    ("p" 'org-todo-promote-top)
    ("r" 'org-refile)
    ("w" 'org-refile)))

 (defbuttons message-buttons nil
   (message-mode-map)
   (buttons-make super-add
    ("=" (cmd (ins " => ")))
    ("<" (cmd (re-sub "^[ 	]*>?[ 	]*" "")))))

 (defbuttons ansi-term-buttons nil
   (term-raw-map)
   (buttons-make super-add
    ("c"
     (lambda nil
       (interactive)
       "send ^C^C"
       (term-send-raw-string "")
       (term-send-raw-string "")))))

 (defbuttons conf-buttons programming-buttons
   (conf-mode-map)
   (buttons-make super-add
    ("e" (cmd (ins "=")))))

 (defbuttons magit-buttons nil
   (magit-mode-map)
   (buttons-make super-add
    ("p" 'magit-go-backward)
    ("n" 'magit-go-forward)))

 (defbuttons diff-buttons nil
   (diff-mode-map)
   (buttons-make super-add
    ("-"
     (git-hunk-toggle-cmd "-"))
    ("="
     (git-hunk-toggle-cmd "+"))
    ("0"
     (git-hunk-toggle-cmd " "))))

 (defbuttons backtrace-bindings nil
   (debugger-mode-map emacs-lisp-mode-map inferior-emacs-lisp-mode-map)
   (buttons-make super-add
    ("h"
     (buttons-make super-add
      ("f" (cmd (describe-function-at-point)))
      ("d" (cmd (setf debug-on-error (not debug-on-error))
                (message "debug-on-error: %s" debug-on-error)))
      ("q" (cmd (with-current-buffer "*Backtrace*" (top-level))))))))

 (defbuttons sldb-bindings nil
   (sldb-mode-map)
   (buttons-make super-add
      ("a" 'sldb-abort)
      ("c" 'sldb-continue)
      ("q" 'sldb-quit))))
