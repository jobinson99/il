;;; il-mode.el --- Major mode for Il-formated-text

;; Copyright (C) 2018 Atlas Jobinson and il-mode contributors(see the
;; commit log for details).

;; Author: Atlas Jobinson <jobinson99@hotmail.com>
;; Maintainer: Atlas Jobinson <jobinson99@hotmail.com>
;; Created: June 14, 2018
;; Version: 20180625-alpha
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
(require 'outline)

;;; User Customizable Viriables ========================================

;;;###autoload
(defgroup il nil
  "Major mode for editing Il text files."
  :prefix "il-"
  :group 'wp
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
(defconst il-mode-version "20180625"
  "Version of `il-mode'.")

(defconst il-output-buffer-name "*il-output*"
  "Name of temporary buffer for il command output.")



;;; Global Variables ==============================================

(defvar il-live-preview-mode nil
  "Sentinel variable for comman `il-live-preview-mode'.")


;;; Regular Expressions ===========================================


(defvar il-blocks
  '("^#1" "^#2" "^#3" "^#4" "^#5" "^#6" "^#1\\+" "^#2\\+" "^#3\\+" "^#4\\+" "^#5\\+" "^#6\\+" "^=[" "=]" "^\-" "^\+" "^\>")
  "区块标识清单，此非必要")
(defvar il-inline-markup
  '()
  "行内标识清单，此非必要")

(defun il-re-concat (lists)
  "Concatenate the elements of a list with a \\| separator and non-matching parentheses."
  (concat
   "\\(?:"
   (mapconcat 'identity lists "\\|")
   "\\)"
   ))

(defun il-block-matcher (markup)
  "Return the matcher regexp for a block element."
  (concat
   "^\\(\\("
   markup
   "[[:blank:]]+\\).*[\n\r][\\^]*?\\)"
   ))

;; need to fixed
(defun il-block-multiline-matcher (markup)
  "Return the matcher regexp for a list or blockquote with start and end."
  (concat
   "\\(\\(^\\(["
   markup
   "]+\\)\\[\\([[:blank:]]+\\)"
   "\\(.\\|\n\\)*?\\(^\\3\\]\n?\\)\\)"
   "\\|\\(^\\(["
   markup
   "]+[[:blank:]]+\\).*[\n\r][\\^]*?\\)\\)"
   ))

;; need to fixed language and keyword
(defun il-block-custom-matcher (markup &optional lang keyword)
  "Return the matcher regexp for a custom pre block."
  (concat
   "\\(^["
   markup
   "]+\\)\\["
   "\\(\\s \\)"
   lang
   keyword
   "\\(.\\|\n\\)*?"
   "\\(^["
   markup
   "]+\\]\\)\\(?:\n$\\)"
   ))

(defun il-block-hr-matcher (markup)
  "Return the matcher regexp for a hr block."
  (concat
   "\\(^"
   markup
   "\\{3\\}[[:space:]]*\\(?:$\\)\\)"
   ))


;; start with \ will miss match, but can change the content easily to fixed this problem
(defun il-inline-matcher (markup)
  "Return the matcher regexp for an inline markup."
  (concat
   "\\(\\["
   markup
   "[[:space:]]+\\)\\(?:\\w\\|\\w.*?\\w\\|[[{(].*?\\w\\)"
   "\\(\\]\\)"
   ))

(defun il-inline-oneword-matcher (markup)
  "Return the matcher regexp for only  one inline markup started, it can ended with blank.
such as subscript and superscript used in math and chemistry.
"
  (concat
   "\\(\\[["
   markup
   "][[:space:]]+\\)\\(?:\\w\\|\\w.*?\\w\\|[[{(].*?\\w\\)"
   "[[:space:]]+"
   ))

(defun il-inline-link-matcher (markup markup-seperator)
  "Return the matcher regexp for a link."
  (concat
   "\\(\\[["
   markup
   "][[:space:]]*\\)\\(?:.*?\\w\\)\\("
   markup-seperator
   "+\\)\\(?:\\w\\|\\w.*?\\w\\|[[{(].*?\\w\\)"
   "\\(\\]\\)"
   ))

(defun il-inline-custom-matcher (markup-seperator)
  "Return the matcher regexp for a custom mark."
  (concat
   "\\(\\["
   "\\(?:\\w.*?\\)\\(["
   markup-seperator
   "]\\B[[:space:]]\\)\\)\\(?:.*?\\w\\)"
   "\\(\\]\\)"
   ))

;;; Mode setup

(defvar il-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "M-RET" 'il-insert-head)
    map)
  "Keymap used in `il-mode' buffers."
  )

;; (defvar il-mode-syntax-table
;;   (let ((syntax-table (make-syntax-table)))
;;     (modify-syntax-entry ?\ "" syntax-table)
;;     syntax-table)
;;   "Syntax table used in `il-mode' buffers.")



;;; Font Lock =====================================================

(defvar il-font-lock-keywords
  (list
   ;; headers
   `(,(il-block-matcher "#1\\+?") 1 'il-face-h1 t t)
   `(,(il-block-matcher "#2\\+?") 1 'il-face-h2 t t)
   `(,(il-block-matcher "#3\\+?") 1 'il-face-h3 t t)
   `(,(il-block-matcher "#4\\+?") 1 'il-face-h4 t t)
   `(,(il-block-matcher "#5\\+?") 1 'il-face-h5 t t)
   `(,(il-block-matcher "#6\\+?") 1 'il-face-h6 t t)
   ;; hr
   `(,(il-block-hr-matcher "=") 1 'il-face-hr t t)
   ;; blockquotes
   `(,(il-block-multiline-matcher ">") 1 'il-face-blockquote t t)
   ;; list
   `(,(il-block-multiline-matcher "+-") 1 'il-face-list t t)
   ;; pre custom block  needs to fixed
   ;; il-pre-language-face il-pre-keywords-face
   `(,(il-block-custom-matcher "=") 0 'il-face-pre t t)
   
   ;; links
   `(,(il-inline-link-matcher "\\<\\>\\!\\#" "[[:space:]]") 1 'il-face-link prepend t)
   
   ;; inline custom
   `(,(il-inline-custom-matcher "\\:") 1 'il-face-inline-custom prepend t)
   ;; inline
   `(,(il-inline-matcher "\\*") 1 'il-face-bold prepend t)
   `(,(il-inline-matcher "/") 1 'il-face-italic prepend t)
   `(,(il-inline-matcher "\\+") 1 'il-face-deleted prepend t)
   `(,(il-inline-matcher "_") 1 'il-face-underline prepend t)
   `(,(il-inline-matcher "\\^") 1 'il-face-superscript prepend t)
   `(,(il-inline-matcher "~") 1 'il-face-subscript prepend t)
   `(,(il-inline-matcher "=") 0 'il-face-code prepend t)
   )
  "Keyword/Regexp for fontlocking of `il-mode'.")

(defgroup il-faces nil
  "Faces use in il mode for syntax highlighting."
  :group 'faces)

(defface il-face-h1
  '((t (:height 2.0 :weight bold)))
  "Face used to highlight h1 headers."
  :group 'il-faces)

(defface il-face-h2
  '((t (:height 1.75 :weight bold)))
  "Face used to highlight h2 headers."
  :group 'il-faces)

(defface il-face-h3
  '((t (:height 1.6 :weight bold)))
  "Face used to highlight h3 headers."
  :group 'il-faces)

(defface il-face-h4
  '((t (:height 1.35 :weight bold)))
  "Face used to highlight h4 headers."
  :group 'il-faces)

(defface il-face-h5
  '((t (:height 1.2 :weight bold)))
  "Face used to highlight h5 headers."
  :group 'il-faces)

(defface il-face-h6
  '((t (:height 1.0 :weight bold)))
  "Face used to highlight h6 headers."
  :group 'il-faces)

(defface il-face-blockquote
  '((t (:background "cyan")))
  "Face used to highlight blockquotes."
  :group 'il-faces)

(defface il-face-list
  '((t (:background "LemonChiffon2")))
  "Face used for list item"
  :group 'il-faces)

(defface il-face-hr
  '((t (:background "gray")))
  "Face used for <hr> blocks"
  :group 'il-faces)

(defface il-face-pre
  '((t (:background "LemonChiffon3")))
  "Face used for <pre> blocks"
  :group 'il-faces)

(defface il-face-pre-language
  '((t (:foreground "orange")))
  "Face used for <pre> language names."
  :group 'il-faces)

(defface il-face-pre-keywords
  '((t (:foreground "brown")))
  "Face used for <pre> keywords."
  :group 'il-faces)

;; custom block meta comment table need to fixed
(defface il-face-comment
  '((t (:background "ivory2")))
  "Face used for comment blocks"
  :group 'il-faces)

(defface il-face-italic
  '((t (:slant italic)))
  "Face used for italic text."
  :group 'il-faces)

(defface il-face-bold
  '((t (:weight bold)))
  "Face used for bold text."
  :group 'il-faces)

(defface il-face-deleted
  '((t (:strike-through t)))
  "Face used for deleted words."
  :group 'il-faces)

(defface il-face-underline
  '((t (:underline t)))
  "Face used for underline words."
  :group 'il-mode)

;; 高低度还不够
(defface il-face-superscript
  '((t (:height 0.8 :raise 0.3)))
  "Face used for superscript words."
  :group 'il-faces)

(defface il-face-subscript
  '((t (:height 0.8 :raise -0.3)))
  "Face used for subscript words."
  :group 'il-faces)

(defface il-face-code
  '((t (:background "brown" :foreground "white")))
  "Face used to highlight inline code."
  :group 'il-faces)

(defface il-face-link
  '((t (:foreground "blue")))
  "Face used to highlight links."
  :group 'il-mode)

(defface il-face-inline-custom
  '((t (:foreground "brown")))
  "Face used for customized style inline words."
  :group 'il-faces)


;;; Il Parsing Functions ==========================================


;;; Element Insertion =============================================

;; TODO or use snippets

(defun il-export () "")
(defun il-insert-title () "")
(defun il-insert-ordered-title () "")
(defun il-insert-bold () "")
(defun il-insert-italic () "")
(defun il-insert-underline () "")
(defun il-insert-strike-through () "")
(defun il-insert-supperscript () "")
(defun il-insert-subscript () "")
(defun il-insert-code () "")
(defun il-insert-custom-mark () "")
(defun il-insert-image () "")
(defun il-insert-url () "")
(defun il-insert-navigation () "")
(defun il-insert-footnote () "")
(defun il-insert-list () "")
(defun il-insert-ordered-list () "")
(defun il-insert-multiline-list () "")
(defun il-insert-hr () "")
(defun il-insert-blockquote () "")
(defun il-insert-multiline-blockquote () "")
(defun il-insert-pre () "")
(defun il-insert-table () "")
(defun il-insert-meta () "")
(defun il-insert-comment () "")
(defun il-insert-custom-block ()
  "插入自定义的区块，可添加 类别或名称"
  (interactive)
  )
(defun il-insert-pre-edit ()
  "利用emacs本身的代码编辑器功能，编辑代码，可缩进，可自动提示等。"
  (interactive))

;;; Show or hide or init or highlight the block
(defun il-toggle-preview () "")
(defun il-toggle-buffer-tree ()
  ""
  )
(defun il-toggle-image () "")
(defun il-toggle-init-table () "")
(defun il-toggle-init-math () "")
(defun il-toggle-init-svg () "")
(defun il-toggle-pre-highlight () "")

;;; Mode meta infomation

(defun il-mode-show-version ()
  "Display the version number in the minibuffer."
  (interactive)
  (message "il-mode version %s" il-mode-version)
  il-mode-version)

(defun il-mode-info ()
  "Open the `il-mode' homepage."
  (interactive)
  (eww-browse-url "https://il.bian.ga"))


;; 用于扩展，用于自动完成
(defconst il-extension-languages
  ;; "language list for the extension"
  '("table" "meta" "header" "comment" "custom"
    "1C-Enterprise" "ABAP" "ABNF" "AGS-Script" "AMPL" "ANTLR"
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

(defun il-get-codelist ()
  "Get the supported extension list")

;;; Keymap ========================================================


;;; Menu ===========================================================

(easy-menu-define il-mode-menu il-mode-map
  "Menu for Il mode"
  '("〖友码〗"
    "---"
    ("文件操作"
     ["导出" il-export]
     )
    "---"
    ("设定标题级别"
     ["不编号标题" il-insert-title]
     ["编号标题" il-insert-ordered-title]
     )
    "---"
    ("段内样式"
     ["加粗" il-insert-bold]
     ["斜体" il-insert-italic]
     ["下划线" il-insert-underline]
     ["删除线" il-insert-strike-through]
     ["上标" il-insert-supperscript]
     ["下标" il-insert-subscript]
     ["行内代码" il-insert-code]
     "---"
     ["自定义" il-insert-custom-mark])
    "---"
    ("链接"
     ["图片" il-insert-image]
     ["网络链接" il-insert-url]
     ["页内链接" il-insert-navigation]
     ["脚注" il-insert-footnote])
    "---"
    ("列表项"
     ["插入 无序列表" il-insert-list]
     ["插入 有序列表" il-insert-ordered-list]
     ["插入多行列表" il-insert-multiline-list])
    "---"
    ["插入横线" il-insert-hr]
    ("插件化区块"
     ["插入引言" il-insert-blockquote]
     ["插入多行引言" il-insert-multiline-blockquote]
     ["插入代码块" il-insert-pre]
     ["插入表格" il-insert-table]
     ["插入元信息" il-insert-meta]
     ["插入注释" il-insert-comment]
     "---"
     ["插入自定区块" il-insert-custom-block]
     ["代码编辑" il-insert-pre-edit
      :enable (il-insert-pre-edit)])
    "---"
    ("显/隐文本结构"
     ["显/隐全部" il-toggle-buffer-tree
      :enable (il-toggle-buffer-tree)]
     ["实时预览" il-toggle-preview
      :style radio
      :selected il-toggle-preview]
     "---"
     ["显/隐 图像" il-toggle-image
      :style radio
      :selected il-toggle-image]
     ["显/隐 表格" il-toggle-init-table
      :style radio
      :selected il-toggle-init-table]
     ["显/隐 数学公式" il-toggle-init-math
      :style radio
      :selected il-toggle-init-math]
     ["显/隐 脚本图" il-toggle-init-svg
      :style radio
      :selected il-toggle-init-svg]
     ["显/隐 代码高亮" il-toggle-pre-highlight
      :style radio
      :selected il-toggle-pre-highlight]
     )
    "---"
    ("文档"
     ["查看文档" il-mode-info]
     ["版本" il-mode-show-version])
    ))


;;; imenu ==========================================================
(defvar il-imenu-generic-expression
  `(("Headings" "^\\(\\(#[1-6]\\+?[[:blank:]]+\\).*[\n\r][\\^]*?\\)" 1))
  "Expression to generate imenu entries.")


;;; Extension Framework ============================================



;;; Mode definition ================================================

;;;###autoload
(define-derived-mode il-mode text-mode "Il"
  "A Major mode for editing Il files."
  ;; Font lock
  (set (make-local-variable 'font-lock-defaults) '(il-font-lock-keywords t))
  (set (make-local-variable 'font-lock-multiline) 'undecided)
  (set (make-local-variable 'imenu-generic-expression) il-imenu-generic-expression)
  
  ;; Syntax
  ;; Outline mode
  ;; Flyspell
  ;; Electric quoting
  ;; Menu
  (easy-menu-add il-mode-menu il-mode-map)
  ;; Extensions
  
  ;; add live preview export hook
  )

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.il\\'" . il-mode) t)
;; auto activate the il-mode while find-file *.il
;; (add-to-list 'auto-mode-alist (cons "\\.il\\'" 'il-mode))


;;; Viewing Modes
;;; Live Preview Mode ==============================================
;;;###autload
(define-minor-mode il-live-preview-mode
  "Toggle native previewing on save for a specific il file")

;;; 注：不用外挂编译器

(provide 'il-mode)

;; Local Variables:
;; indent-tabs-mode: nil
;; coding: utf-8
;; End:
;;; il-mode.el ends here
