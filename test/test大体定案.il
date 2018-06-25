#1 核心代码手记

表达式要打开 全局和多行，情景敏感 /gm
行内 不加 /m



#2 行内

两边要空格么？

注意：单个单词和多个单词的表达式区别。

==[
加粗
[* bold]
		emacs版：\\(\\[[*][[:space:]]+\\)\\(?:\\w\\|\\w.*?\\w\\|[[{(].*?\\w\\)\\(\\]\\)
		\\(\(\\[[*][[:space:]]+\\)\\(\\w\\|\\w.*?\\w\\|[[{(].*?\\w\\)\\(\\]\\)
\\(\\[[*][[:space:]]+\\)\\(?:.*?\\w\\)\\(\\]\\)\\)

 *xxx*       / \*\w+\* /g
              / \*.+\* /g
	      / \*[\s\S]+?\* /g
              / \*(?=\S)([\s\S]*?\S)\* (?!\*)/g
**xxx**	      emacs版：\\(\\([*]\\{2\\}\\)\\(?:\\w\\|\\w.*?\\w\\|[\\[{(]\\w\\)\\2\\)
	      
斜体
[/ italic]
		emacs版：
/xxx/		/ \/\w+\/ /g
	      / \/(?=\S)([\s\S]*?\S)\/ (?!\/)/g
	      emacs版：
删除线
[+ strikethrough]
 +xxx+          / \+\w+\+ /g
	      / \+(?=\S)([\s\S]*?\S)\+ (?!\+)/g
	      emacs版：
下划线
[_ underline]
 _xxx_          / \_\w+\_ /g
	      / \_(?=\S)([\s\S]*?\S)\_ (?!\_)/g
	      emacs版：

上下标
[^ superscript]
^xxx^		/\^\w+\^/g
[~ subscript]
~xxx~		/\~\w+\~/g
	      /(?<!\\|\s)\^(\S+?)\^(?<!\\\^)/g     前后不能有空格，且消除了 第一个代号转义问题。中间不能有空格
	      /(?<!\\)\^(\S+?)\^(?<!\\\^)/g    前后可有空格
	      emacs版：\\^\\w+\\^ 仍有诸多bug
	     
代码
[= code]
 `xxx` 		/ \`\w+\` /g
	      / \`(?=\S)([\s\S]*?\S)\` (?!\`)/g
	      emacs版：
	     
代码块里，其他选定失效。


自定义行内
[class class: content]
		emacs版：\\(\\[\\(?:.*?\\w+\\)[:]\\)\\(?:.*?\\w\\)\\(\\]\\)   需修正 : 导致的不起作用问题。
		\\(\\(\\[\\(?:\\w.*?\\)\\([:]\\B[[:space:]]\\)\\)\\(?:.*?\\w\\)\\(\\]\\)\\) 已修正
		
{xxx| yyy}      / \{\w+\| (?=\S).*\} /g 
{xxx[ yyy]}
[xxx| yyy|]
[[xxx xxx][yyy xxx]]      / \[\w+\]\[(?=\S).*\]\] /g
	       emacs版：
转义
\              / \\ /g
	       emacs版：
==]


#3 测试数据：行内


word [* bold要选到bold] word
inword[* bold词内要选到]word
word [* many words bold要选到bold] 
word [ * start blank nobold不选到nobold ]
word [** nobold不选到nobold]
word [* bold要选到第一个]]]]]
word [* bold \] word]
[* start line bold选到] content
中文[* 加粗]中文加粗，中文 [*加 粗]

[*] no bold 
[**] no bold
[* *] bold
[ *] no bold
[*     word] bold

word[* bold[word\]bold]word
word[* bold[* bold in bold] bold] word

 [/ italic italic要选到italic] 
[/ italic选到italic]

 [+ strike through 要选到strike through] 
begin [+ strikethrough要选到strikethrough] end
[+ start line strikethrough选到strikethrough]  strike through
 [+        strikethrough不选到nostrikethrough]
 [+ strikethrough要选到strikethrough\]]]]]


3 + 5 = 8 4 - 2 = 2  no inline style
1 + 2 + 3 = 6
1+2+3=6

word[^ superscript上标要选到superscript]word
word\[^ nosuperscript不选到nosuperscript]word [^ superscript要选到superscript]word
word[^ superscript要选到\]no end here 要选到superscript] word
[^ nosuperscript不选到] start line no superscript
Roll ov[^ e]r matches or the ex\[^ p不选到res[^ superscript要选到]superscript. blank superscript[^ ]  [^] no script. [^ superscript要选到h]t不选到sh[^ h要选到] eet, full Ref[^ er要选到e\]n要选到]ce, results [^ superscript选到] the Tools below. Replace & List ou[^ 67要选到tp]ut

word [~ subscript下标] word word [~ 下标superscript] word word[~ supscript] 

word [= code要选到] word [= code code要选到code] word
word [= code with \]code\] code]word

word word [= \]nocode end要选到code code] word.
start and end with space [` code ] word. 

\[= no code [= code begin] code begin



#3 连接


==[
[>link linkname]	js版：
           emacs版：\\(\\[[>][[:space:]]*\\)\\(?:.*?\\w\\)\\([[:space:]]\\)\\(?:\\w\\|\\w.*?\\w\\|[[{(].*?\\w\\)\\(\\]\\)
	    \\(\\(\\[[><!#][[:space:]]*\\)\\(?:.*?\\w\\)\\([[:space:]]+\\)\\(?:\\w\\|\\w.*?\\w\\|[[{(].*?\\w\\)\\(\\]\\)\\)
	   
[#pageid id content]
[<ref position in place]
[!imagposition imagename]
[class name: content]

[xxx](yyy)      / \[\w+\]\(.+\) /g
[xxx| yyy]      / \[\w+\| .+\]/g
                / \[.+\| .+\]/g     可多个单词描述，加空格

[[link : name]]           emacs版： \\(\\[\\{2\\}\\)\\(?:.*?\\w\\)\\([[:space:]]:[[:space:]]\\)\\(?:.*?\\w\\)\\(\\]\\{2\\}\\)


[[#anchor][anchorname]]
[[:anchor][anchor content]]
==]


#3 测试数据：连接

[>http://www.bian.ga/连接地址 bian.ga链接名]
[!dir/image.png图片位置 imagename图片标题]
[#站内idname content话题名]
[<ref页内引用 position in place位置]
[class name 类名: content内容]



#2 区块

注意：看不见的换行，断行，缩进等

==[
标题  正则表达式
 #1 #2 #3   /^(#[1-6]{1}\+?\s*) ([^\n]+?)\s*(?:\n$)/gm bug多
            /^#[1-6]{1}\+?\s.+\n$/gm    仍有bug，断行会使其失效
	    /^#[1-6]{1}\+?\s.+\n*$/gm   从此处下面的都消除了断行 失效问题。但若第一行无空格，则连续断行会被选取。
	    /^#[1-6]{1}\+?\s.+\n?$/gm
	    /^#[1-6]{1}\+?\s.+\n*?$/gm
	    /^#[1-6]{1}\+?\s.+(?:\n$)/gm
	    /^(#[1-6]{1}\+?) .+(?:\n|$)/gm 消除了第一行无空格，连续断行会被选取问题。
	    ^(#[1-6]{1}\+?\s+.*[\n\r][^]*?)  这也行
	   
	    emacs版：^\\(\\(#[1-6]\\+?[[:blank:]]+\\).*[\n\r][\\^]*?\\)
	  
捕获 #1 ~#6 #1+~#6+ 且 句末换行。
但不 捕获立刻换行和多个 #若干空格 后直接换行的。

分隔行
 ===     /^(\={3} *)(?:\n+|$)/    或    /^(\={3}\s*)(?:\n+|$)/
         emacs版：^=\\{3\\}[[:blank:]]*\\(?:\n\\|$\\)
捕获 行首 === 且需换行


引用块
 > >> >[ >]     /^([\>]+(\[|\])?)\s+([^\n]+?)\s*(?:\n+|$)/
捕获 行首 且 行末可空格 且 需换行

 >[ >]     /(^\>\[ )(.|\n)*(-\>\])/
          emacs版：\\(\\(^\\([>]+\\)\\[\\([[:blank:]]+\\)\\(.\\|\n\\)*?\\(^\\3\\]\n?\\)\\)\\|\\(^\\([>]+[[:blank:]]+\\).*[\n\r][\\^]*?\\)\\)

列表
 - -- + -[ -]     /^([\-|\+]+(\[|\])?)\s+([^\n]+?)\s*(?:\n+|$)/

 -[ -]     /(^\-\[ )(.|\n)*(-\-\])/
           emacs版：单行 \\(^\\([+-]+[[:blank:]]+\\).*[\n\r][\\^]*?\\)
           多行 \\(^[+-]+\\)\\[\\([[:blank:]]+\\)\\(.\\|\n\\)*?\\(\\1\\]\n?\\)

	   \\(\\(^\\([+-]+\\)\\[\\([[:blank:]]+\\)\\(.\\|\n\\)*?\\(^\\3\\]\n?\\)\\)\\|\\(^\\([+-]+[[:blank:]]+\\).*[\n\r][\\^]*?\\)\\)
	   颠倒过来，效果一样

程序块  \1 表示引用第一个 匹配组 ```
\==[ shell  \==]	  
			  emacs版：\\(^[=]+\\)\\[\\(\\s \\)\\(.\\|\n\\)*?\\(^[=]+\\]\\)\\(?:\n$\\)
 ``` ``` shell   /^(`{3})([\s\S]*?)\n?\s*\1\s*(?:\n+|$)/
                /(^`{3})([\s\S]*?)(.|\n)*\1/ 
                /(^`{3})([\s\S]*?).*\1(?=\s*\n$)/gm   解决最后三个`后面跟空格问题。
		/^(`{3}.*[\n\r][^]*?^`{3})/gm   这也可
                emacs版：\\(^```\\)\\(\\s \\)\\(.\\|\n\\)*?\\(^```\\)\\n?
注意：所有的选择在程序块里，都应失效。
可参考 markdown mode里的 gfm部分。

自定义区块
\==[ custom xxx yyy
 内容
\==]

换行 空一行
              /^\n+/

==]



#2 测试用的样例：区块



#3 测试用的样例：标题



##1+ no title 不可选到


#1+ title1 需要选到

##   no title

## 

#1 
#11 no title 不要选到

#2:: no title 不要选到

#22: no title 不要选到

#1: no title 不要选到

# 22 no title 不要选到


#22 no title 不要选到

# 1

## no title 不要选到

##3: no title 不要选到

# no title 不要选到
### no title 不要选到


#+ no title 不要选到

#2 title2 要选到

#3: no title不要选到

#2 #3 #2

#4 title4 要选到

#111 rank out of range, no title 不要选到 

#2  title2 要选到

#2 title2要选到 #2

#no title不要选到 

###

 #1 no title 不要选到

[解决]断行会使其失效
#1 title1 要选到 

[解决]第一行无空格，连续断行会被选取问题。

#1
no title 不要 选到


#3 测试用的样例：分隔线

line started with blank, no hr

 ===

line ended with blank, hr
=== 

===   

===   no hr 需要失效

===

  ===

to many tokens, no hr

=====


#3 测试用的样例：引用

> blockquote
>  blockquote started with multi blank
>> sub blockquote

>>> rank 3 blockquote

>[ multiline blockquote start

>[ multiline blockquote 必需对应
必需选到
>] multiline blockquote end 必需对应

>>[ sub multiline blockquote start必需对应
必需选到
>>] sub multiline blockquote end 必需对应

 > line started with blank, no blockquote 不可选到

>no blank ahead, no blockquote不可选到
>[no blank ahead, no blockquote不可选到

#3 测试用的样例：列表

- not ordered list
-- sub list
-+ list, sub ordered list 

-[ multiline list必需对应
必需选到
-] multiline list必需对应，但不选中后面的

--[ multiline list必需对应
必需选到
--] mulitiline list endf 必需对应，但不选中后面的

--[ no blockquote无法对应
无对应
-+] no blockquote 无法对应

+ ordered list可选到

++- ordered list non-ordered list 
不可选到

--no list不可选到
+no ordered list不可选到
 - no list不可选到
 + no ordered list不可选到



#3 测试用的样例：程序块

==[ shell highlight pretty init

defun test

line *bold* 不可作用

#1 title 不可作用

> blockquote 不可作用
line

- list不可作用
+ order-list不可作用

new line
==]

==[ shell custom word tag
code block line 1
line 2
line3
line4 要选到
5line
6line 需要修正：最后空一行，导致选不到

==]

==[
1line 要选到
line2
==]

  ==[
  不要选到
  ==]

==[
code block

==]


====[[[[ 
no code block 不要选到
 
====]

==[ shell
code block 要选到
==]

==[ 
  ==[ no code block start不要选到
  code block区段要选到
  ==]
  
==]


==[ emacs-lisp highlight run init
defun functionname 要选到
==]


==[
code block
   code block
code block 要选到
code block
==]


==[
code
==] no code end
==]

==[    
code
==]

==[
code
==]

