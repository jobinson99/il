#1 核心代码手记

表达式要打开 全局和多行，情景敏感 /gm
行内 不加 /m



#2 行内

两边要空格么？

注意：单个单词和多个单词的表达式区别。

==[
加粗
[* bold]	js版：(?<!\\)(\[\*\s+)([\s\S]*?\S)(?<!\\)(\])

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


word [* 加粗bold] word
inword[* 词内加粗bold in word]word
word [* 多词同时加粗many words bold] 
word [ * start blank nobold左中括号必需紧跟符号，否则不加粗nobold ]
word [** nobold符号只能跟一个，跟2个不算nobold]
word [* 加粗，选到第一个bold]]]]]
word [* 加粗bold \] 加粗word]
[* start line bold加粗] content
word \[* 非加粗word [* bold加粗] content
中文[* 加粗]中文加粗，中文 [*不加 粗]

[*] 非加粗 no bold 
[**] 非加粗 no bold
[* *] 加粗 bold
[ *] 非加粗 no bold
[* ] 非加粗 no bold
[*     加粗bold] word

word[* bold[word\]bold]word
word[* 加粗bold[* 加粗bold in bold] 加粗bold] word

 [/ 斜体italic italic] 
[/ 斜体italic]

 [+ strike through 多个词删除线strike through] 
begin [+ strikethrough删除线strikethrough] end
[+ start line strikethrough删除线strikethrough]  strike through
 [+        strikethrough删除线strikethrough]
 [+ strikethrough删除线strikethrough\]]]]]


3 + 5 = 8 4 - 2 = 2  no inline style
1 + 2 + 3 = 6
1+2+3=6

word[^ superscript词中上标]word
word\[^ nosuperscript此非上标]word [^ superscript上标]word
word[^ superscript上标\]no end here 上标superscript] word
[^ 非上标nosuperscript] 行首非上标start line no superscript
Roll ov[^ e]r matches or the ex\[^ nosuperscript 非上标[^ superscript上标]word. blank superscript[^ ]  [^] no script. [^ 上标superscripth]不选到no superscript[^ 上标] eet, full Ref[^ er上标e\]n上标]ce, results [^ 上标superscript] the Tools below. Replace & List ou[^ 12上标]word

word [~ subscript下标] word word [~ 下标superscript] word word[~ supscript] 

word [= 行内代码code] word [= 行内代码 inline code] word
word [= 行内代码 code with \]code\] 行内代码code]word

word word [= \]行内代码 nocode end code code] word.
start and end with space [= 行内代码code ] word. 

\[= 非代码no code [= 行内代码code begin] code begin



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
                /(^`{3})([\s\S]*?).*\1(?=\s*\n$)/gm   解决结束的三个`后面跟空格无法正确识别问题。
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



##1+ 非标题 no title


#1+ 标题1+ title1+

##   非标题no title

## 

#1 
#11 非标题 no title

#2:: 非标题 no title

#22: 非标题 no title

#1: 非标题 no title

# 22 非标题no title


#22 非标题no title

# 1

## 非标题no title

##3: 非标题 no title

# 非标题 no title
### 非标题 no title


#+ 非标题 no title

#2 标题 title2 标题

#3: 非标题 no title

#2 #3 #2

#4 标题 title4

#111 超过限值，非标题 out of range, no title

#2  标题 title2

#2 标题2 title2 #2

#非标题no title

###

 #1 非标题 no title

[解决]断行会使其失效
#1 标题1 title1 

[解决]第一行无空格，连续断行会被选取问题。

#1
非标题 no title


#3 测试用的样例：分隔线

行首为空格，非分隔线，line started with blank, not hr

 ===

符号后带空格，为分分隔线，line ended with blank, hr
=== 

===   

===   符号后带文字，非分隔线，with words after =， not hr

===

  ===

超过3个，考虑可为分隔线 more than 3 =, hr

=====

不连续，不是分隔线 not continued =, not hr
=== ===


#3 测试用的样例：引用

> 引用 blockquote
>  引用，允许大于号后多个空格 blockquote started with multi blank
>> 二级引用，sub blockquote

>>> 三级引用，rank 3 blockquote

>[ 多行引用，必需对应匹配后面结束符号 multiline blockquote start
引用
多行引用，必需对应的同等级结束符号，multiline blockquote end
>]

>>[ sub multiline blockquote start必需对应
必需选到
sub multiline blockquote end 必需对应
>>]

 > 行首缩进，非引用line started with blank, no blockquote

>行首无空格，非引用no blank ahead, no blockquote
>[行首无空格，非引用no blank ahead, no blockquote

#3 测试用的样例：列表

- 无序列表not ordered list
-- 二级列表sub list
-+ 无序列表，二级有序列表 list, sub ordered list 

-[ 必需对应同级 \-] need to meet the same rank \-]
多行列表
multiline list
-]

--[ 必需对应同级 \-] need to meet the same rank \-]
多行列表必需选到
mulitiline list
--] 

--[ 无法对应 not found end symbol, not multiline list
非多行列表
no multiline list
-+] 

+ 有序列表 ordered list

++- 有序列表，二级有序列表，三级无序列表 ordered list non-ordered list 
不可选到

--无空格，非列表no list
+无空格，非列表no ordered list
 - 缩进，非列表no list
 + 缩进，非列表no ordered list



#3 测试用的样例：程序块

==[ shell highlight pretty init

defun test

line [* 加粗]不起作用 no [* bold]

#1 标题不起作用 no title

> 引用不起作用 no blockquote
line

- 无序列表不起作用 no list
+ 有序列表不可作用 no rodered-list

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
1代码区1 line
line2
==]

  ==[
  缩进的判断为非代码
  no code block with tab/space start
  ==]

==[
code block

==]


====[[[[ 
no code block 不要选到
 
====]

==[ shell
code block
代码区
==]

==[ 
  ==[ no code block start缩进的判断为非代码
  code block代码区
  ==]
  
==]


==[ emacs-lisp highlight run init
defun functionname
代码区
==]

==[
code block
   code block
code block
代码区
==]


==[
code
末行符号后不能跟文字，跟文字部分为代码区
==] no code end
==]

==[    
code
首行后跟若干空格，代码区
==]

==[
code
首行无任何其他元素，代码区
==]

====[ comment
comment
注释
==]

==[ test
code
代码区
==] 

==[ test
code
非代码区
==]]]]
