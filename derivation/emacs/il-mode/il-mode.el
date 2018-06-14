;;; il-mode.el --- Major mode for Il-formated-text -*- lexical-binding: t; -*-

;; Copyright (C) 2018 Atlas Jobinson and il-mode contributors(see the
;; commit log for details).

;; Author: Atlas Jobinson <jobinson99@hotmail.com>
;; Maintainer: Atlas Jobinson <jobinson99@hotmail.com>
;; Created: June 14, 2018
;; Version: 20180614-alpha
;; Package-Requires: ((emacs "25.1") (cl-lib "0.5"))
;; Keywords: Il
;; URL: https://il.bian.ga

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; See the file Readme.il for details.

;;; Installation:

;; (autoload 'il-mode "il-mode")
;; (add-to-list 'auto-mode-alist '("\\.il\\'" . il-mode))

;; 可参考 textile-mode 快速实现，其他的功能慢慢添加

;;; Code:

(require 'easymenu)
(require 'cl-lib)

;;; User Customizable Viriables ========================================

;;;###autoload
(defgroup il nil
  "Major mode for editing Il text files."
  :prefix "il-"
  :group 'languages
  :link '(url-link "https://il.bian.ga"))

(defcustom il-mode-hook nil
  "Hook run when entering Il mode."
  :type 'hook
  :group 'il)

(defcustom il-before-export-hook nil
  "Hook run before running Il to export HTML output.
The hook may modify the buffer, which will be restored to its
original state after exporting is complete."
  :type 'hook
  :group 'il)

(defcustom il-after-export-hook nil
  "Hook run after HTML output has been saved.
Any changes th the output buffer made by this hook will be saved."
  :type 'hook
  :group 'il)


(defcustom il-command "il"
  "Command to run il."
  :group 'il
  :type '(choice (string :tag "Shell command") function))

(defcustom il-command-needs-filename nil
  "Set to non-nil if `il-mode' does not accept input from stdin.
Instead, it will be passed a filename as the final command line
option.  As a result, you will only be able to run Markdown from
buffers which are visiting a file."
  :group 'il
  :type 'boolean)

(defcustom il-open-command nil
  "Command used for opening Markdown files directly.
For example, a standalone Markdown previewer.  This command will
be called with a single argument: the filename of the current
buffer.  It can also be a function, which will be called without
arguments."
  :group 'il
  :type '(choice file function (const: tag "None" nil)))



;;; Constants =====================================================
(defconst il-mode-version "20180614-alpha"
  "Version of `il-mode'.")

(defconst il-output-buffer-name "*il-output*"
  "Name of temporary buffer for il command output.")



;;; Global Variables ==============================================

(defvar il-live-preview-mode nil
  "Sentinel variable for comman `il-live-preview-mode'.")


;;; Regular Expressions ===========================================

(defun il-re-concat (l)
  "Concatenate the elements of a list with a \\| separator and non-matching parentheses"
  (concat
   ""
   (mapconcat 'identity l "\\|")
   ""))

(defvar il-blocks
  '("^#1" "^#2" ))
(defvar il-inline-markup
  '(""))


(defun il-block-matcher (bloc)
  "Return the matcher regexp for a block element"
  (concat
   "^"
   bloc
   ""
   ))

(defun il-list-matcher (bullet)
  "Return the matcher regexp for a list bullet"
  (concat
   ""
   bullet
   ""))

(defun il-inline-matcher (markup)
  "Return the matcher regexp for an inline markup"
  (concat
   ""
   markup
   ""))

;;; Mode setup

(defvar il-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "M-RET" 'il-insert-head)
    
    map)
    "Keymap used in `il-mode' buffers."
  )

(defvar il-mode-syntax-table
  (let ((syntax-table (make-syntax-table)))
    (modify-syntax-entry ?\ "" syntax-table)
    
    syntax-table)
  "Syntax table used in `il-mode' buffers.")



;;; Font Lock =====================================================

(defvar il-font-lock-keywords
  (list
   ;; headers
   `(,(il-block-matcher "#1") 1 'il-h1-face t t)
   `(,(il-block-matcher "#2") 1 'il-h2-face t t)
   `(,(il-block-matcher "#3") 1 'il-h3-face t t)
   `(,(il-block-matcher "#4") 1 'il-h4-face t t)
   `(,(il-block-matcher "#5") 1 'il-h5-face t t)
   `(,(il-block-matcher "#6") 1 'il-h6-face t t)
   ;; blockquotes
   ;; pre
   ;; list
   ;; inline
   
   )
  "Keyword/Regexp for fontlocking of il-mode")

(defgroup il-faces nil
  "Faces use in il mode for syntax highlighting."
  :group 'il
  :face 'faces)

(defface il-h1-face
  '((t (:height 2.0 :weight bold)))
  "Face used to highlight h1 headers."
  :group 'il-faces)

(defface il-h2-face
  '((t (:height 1.75 :weight bold)))
  "Face used to highlight h2 headers."
  :group 'il-faces)

(defface il-h3-face
  '((t (:height 1.6 :weight bold)))
  "Face used to highlight h3 headers."
  :group 'il-faces)

(defface il-h4-face
  '((t (:height 1.35 :weight bold)))
  "Face used to highlight h4 headers."
  :group 'il-faces)

(defface il-h5-face
  '((t (:height 1.2 :weight bold)))
  "Face used to highlight h5 headers."
  :group 'il-faces)

(defface il-h6-face
  '((t (:height 1.0 :weight bold)))
  "Face used to highlight h6 headers."
  :group 'il-faces)

(defface il-blockquote-face
  '((t (:foreground "cyan")))
  "Face used to highlight blockquotes."
  :group 'il-faces)

(defface il-list-face
  '((t (:foreground "ivory1")))
  "Face used for list item"
  :group 'il-faces)

(defface il-pre-face
  '((t (:foreground "ivory2")))
  "Face used for <pre> blocks"
  :group 'il-faces)

(defface il-pre-language-face
  '((t (:foreground "orange")))
  "Face used for <pre> language names."
  :group 'il-faces)

(defface il-pre-keyword-face
  '((t (:foreground "brown")))
  "Face used for <pre> keywords."
  :group 'il-faces)

(defface il-italic-face
  '((t (:slant italic)))
  "Face used for italic text."
  :group 'il-faces)

(defface il-bold-face
  '((t (:weight bold)))
  "Face used for bold text."
  :group 'il-faces)

(defface il-deleted-face
  '((t (:strike-through t)))
  "Face used for deleted words."
  :group 'il-faces)

(defface il-underline-face
  '((t (:underline t)))
  "Face used for underline words."
  :group 'il-mode)

(defface il-superscript-face
  '((t (:height 1.1)))
  "Face used for superscript words."
  :group 'il-faces)

(defface il-subscript-face
  '((t (:height 0.8)))
  "Face used for subscript words."
  :group 'il-faces)

(defface il-code-face
  '((t (:foreground "cyan")))
  "Face used to highlight inline code."
  :group 'il-faces)


(defface il-link-face
  '((t (:foreground "pink")))
  "Face used to highlight links."
  :group 'il-mode)




;;; Il Parsing Functions ==========================================


;;; Element Insertion =============================================




(defconst il-extension-recognized-laguages
  "language list for the extension"
  '("table" "meta" "header" "1C-Enterprise" "ABAP" "ABNF" "AGS-Script" "AMPL" "ANTLR"
    "API-Blueprint" "APL" "ASN.1" "ASP" "ATS" "ActionScript" "Ada" "Agda"
    "Alloy" "Alpine-Abuild" "Ant-Build-System" "ApacheConf" "Apex"
    "Apollo-Guidance-Computer" "AppleScript" "Arc" "Arduino" "AsciiDoc"
    "AspectJ" "Assembly" "Augeas" "AutoHotkey" "AutoIt" "Awk" "Batchfile"
    "Befunge" "Bison" "BitBake" "Blade" "BlitzBasic" "BlitzMax" "Bluespec"
    "Boo" "Brainfuck" "Brightscript" "Bro" "C#" "C++" "C-ObjDump"
    "C2hs-Haskell" "CLIPS" "CMake" "COBOL" "COLLADA" "CSON" "CSS" "CSV"
    "CWeb" "Cap'n-Proto" "CartoCSS" "Ceylon" "Chapel" "Charity" "ChucK"
    "Cirru" "Clarion" "Clean" "Click" "Clojure" "Closure-Templates"
    "CoffeeScript" "ColdFusion" "ColdFusion-CFC" "Common-Lisp"
    "Component-Pascal" "Cool" "Coq" "Cpp-ObjDump" "Creole" "Crystal"
    "Csound" "Csound-Document" "Csound-Score" "Cuda" "Cycript" "Cython"
    "D-ObjDump" "DIGITAL-Command-Language" "DM" "DNS-Zone" "DTrace"
    "Darcs-Patch" "Dart" "Diff" "Dockerfile" "Dogescript" "Dylan" "EBNF"
    "ECL" "ECLiPSe" "EJS" "EQ" "Eagle" "Ecere-Projects" "Eiffel" "Elixir"
    "Elm" "Emacs-Lisp" "EmberScript" "Erlang" "F#" "FLUX" "Factor" "Fancy"
    "Fantom" "Filebench-WML" "Filterscript" "Formatted" "Forth" "Fortran"
    "FreeMarker" "Frege" "G-code" "GAMS" "GAP" "GCC-Machine-Description"
    "GDB" "GDScript" "GLSL" "GN" "Game-Maker-Language" "Genie" "Genshi"
    "Gentoo-Ebuild" "Gentoo-Eclass" "Gettext-Catalog" "Gherkin" "Glyph"
    "Gnuplot" "Go" "Golo" "Gosu" "Grace" "Gradle" "Grammatical-Framework"
    "Graph-Modeling-Language" "GraphQL" "Graphviz-(DOT)" "Groovy"
    "Groovy-Server-Pages" "HCL" "HLSL" "HTML" "HTML+Django" "HTML+ECR"
    "HTML+EEX" "HTML+ERB" "HTML+PHP" "HTTP" "Hack" "Haml" "Handlebars"
    "Harbour" "Haskell" "Haxe" "Hy" "HyPhy" "IDL" "IGOR-Pro" "INI"
    "IRC-log" "Idris" "Inform-7" "Inno-Setup" "Io" "Ioke" "Isabelle"
    "Isabelle-ROOT" "JFlex" "JSON" "JSON5" "JSONLD" "JSONiq" "JSX"
    "Jasmin" "Java" "Java-Server-Pages" "JavaScript" "Jison" "Jison-Lex"
    "Jolie" "Julia" "Jupyter-Notebook" "KRL" "KiCad" "Kit" "Kotlin" "LFE"
    "LLVM" "LOLCODE" "LSL" "LabVIEW" "Lasso" "Latte" "Lean" "Less" "Lex"
    "LilyPond" "Limbo" "Linker-Script" "Linux-Kernel-Module" "Liquid"
    "Literate-Agda" "Literate-CoffeeScript" "Literate-Haskell"
    "LiveScript" "Logos" "Logtalk" "LookML" "LoomScript" "Lua" "M4"
    "M4Sugar" "MAXScript" "MQL4" "MQL5" "MTML" "MUF" "Makefile" "Mako"
    "Markdown" "Marko" "Mask" "Mathematica" "Matlab" "Maven-POM" "Max"
    "MediaWiki" "Mercury" "Meson" "Metal" "MiniD" "Mirah" "Modelica"
    "Modula-2" "Module-Management-System" "Monkey" "Moocode" "MoonScript"
    "Myghty" "NCL" "NL" "NSIS" "Nemerle" "NetLinx" "NetLinx+ERB" "NetLogo"
    "NewLisp" "Nginx" "Nim" "Ninja" "Nit" "Nix" "Nu" "NumPy" "OCaml"
    "ObjDump" "Objective-C" "Objective-C++" "Objective-J" "Omgrofl" "Opa"
    "Opal" "OpenCL" "OpenEdge-ABL" "OpenRC-runscript" "OpenSCAD"
    "OpenType-Feature-File" "Org" "Ox" "Oxygene" "Oz" "P4" "PAWN" "PHP"
    "PLSQL" "PLpgSQL" "POV-Ray-SDL" "Pan" "Papyrus" "Parrot"
    "Parrot-Assembly" "Parrot-Internal-Representation" "Pascal" "Pep8"
    "Perl" "Perl6" "Pic" "Pickle" "PicoLisp" "PigLatin" "Pike" "Pod"
    "PogoScript" "Pony" "PostScript" "PowerBuilder" "PowerShell"
    "Processing" "Prolog" "Propeller-Spin" "Protocol-Buffer" "Public-Key"
    "Pug" "Puppet" "Pure-Data" "PureBasic" "PureScript" "Python"
    "Python-console" "Python-traceback" "QML" "QMake" "RAML" "RDoc"
    "REALbasic" "REXX" "RHTML" "RMarkdown" "RPM-Spec" "RUNOFF" "Racket"
    "Ragel" "Rascal" "Raw-token-data" "Reason" "Rebol" "Red" "Redcode"
    "Regular-Expression" "Ren'Py" "RenderScript" "RobotFramework" "Roff"
    "Rouge" "Ruby" "Rust" "SAS" "SCSS" "SMT" "SPARQL" "SQF" "SQL" "SQLPL"
    "SRecode-Template" "STON" "SVG" "Sage" "SaltStack" "Sass" "Scala"
    "Scaml" "Scheme" "Scilab" "Self" "ShaderLab" "Shell" "ShellSession"
    "Shen" "Slash" "Slim" "Smali" "Smalltalk" "Smarty" "SourcePawn"
    "Spline-Font-Database" "Squirrel" "Stan" "Standard-ML" "Stata"
    "Stylus" "SubRip-Text" "Sublime-Text-Config" "SuperCollider" "Swift"
    "SystemVerilog" "TI-Program" "TLA" "TOML" "TXL" "Tcl" "Tcsh" "TeX"
    "Tea" "Terra" "Text" "Textile" "Thrift" "Turing" "Turtle" "Twig"
    "Type-Language" "TypeScript" "Unified-Parallel-C" "Unity3D-Asset"
    "Unix-Assembly" "Uno" "UnrealScript" "UrWeb" "VCL" "VHDL" "Vala"
    "Verilog" "Vim-script" "Visual-Basic" "Volt" "Vue"
    "Wavefront-Material" "Wavefront-Object" "Web-Ontology-Language"
    "WebAssembly" "WebIDL" "World-of-Warcraft-Addon-Data" "X10" "XC"
    "XCompose" "XML" "XPages" "XProc" "XQuery" "XS" "XSLT" "Xojo" "Xtend"
    "YAML" "YANG" "Yacc" "Zephir" "Zimpl" "desktop" "eC" "edn" "fish"
    "mupad" "nesC" "ooc" "reStructuredText" "wisp" "xBase")
  "Language specifiers recognized for extension syntax highlighting features.")



;;; Keymap ========================================================


;;; Menu ===========================================================

(easy-menu-define il-mode-menu il-mode-map
  "Menu for Il mode"
  '("〖友码〗"
    "---"
    ("文件操作")
    "---"
    ("设定标题级别")
    "---"
    ("段内样式")
    "---"
    ("列表项")
    "---"
    ("链接")
    "---"
    ["插入横线" il-insert-hr]
    ("扩充块"
     ["插入引言" il-insert-blockquote]
     ["插入代码块" il-insert-code]
     ["插入表格" il-insert-table])
    "---"
    ("显/隐文本结构")
    "---"
    ("文档"
     ["查看文档" il-mode-info]
     ["版本" il-mode-show-version])
    ))


;;; imenu ==========================================================
(defvar il-imenu-generic-expression
  `(("Headings" "^#[[:digit:]]\s" 1))
  "Expression to generate imenu entries.")


;;; Extension Framework ============================================


;;; Mode Definition ================================================

(defun il-mode-version ()
  "Display the version number in the minibuffer."
  (interactive)
  (message "il-mode version %s" il-mode-version)
  il-mode-version)

(defun il-mode-info ()
  "Open the il-mode homepage."
  (interactive)
  (browse-url "https://il.bian.ga"))

;;;###autoload
(define-derived-mode il-mode text-mode "Il"
  "A Major mode for editing Il files."
  (set (make-local-variable 'font-lock-defaults) '(textile-font-lock-keywords t))
  (set (make-local-variable 'font-lock-multiline) 'undecided)
  (set (make-local-variable 'imenu-generic-expression) il-imenu-generic-expression)
  
  ;; Syntax
  ;; Outline mode
  ;; Flyspell
  ;; Electric quoting
  ;; add live preview export hook)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.il\\" . il-mode) t)
;; auto activate the il-mode while find-file *.il


;;; Viewing Modes

;;;###autoload


;;; Live Preview Mode ==============================================
;;;###autload


;;; 注：不用外挂编译器

(provide 'il-mode)

;; Local Variables:
;; indent-tabs-mode: nil
;; coding: utf-8
;; End:
;; il-mode.el ends here
