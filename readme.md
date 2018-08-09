# 友码 Il is markup language  一种标记式文本语言，特点是 规则统一精炼，容易扩展，容易掌握，视觉舒服。

![标志](/docs/images/il-logo.png)

> 感觉不到编辑器
> ease and extensible

状态：语法风格已经大致确定，只剩几个小细节可能略有调整。

## #2 特点

+ 区块全部无行首缩进
+ 可扩展：
  + 行内和区块
  + 可方便添加扩展
+ 规则统一：
  + 起始和终点符号一致
  + 自定义行内样式和链接规则统一
  + 可方便添加类名和识别名
- 视觉上要舒服


## #2 Stable rules

行内标识 inline markup
```
[* 加粗bold]
[/ 斜体italic]
[_ underline]
[+ 删除线strike through]
[^ 上标superscript]
[~ 下标subscript]
[= 代码code]
```

连接 link
```
[>连接地址http://www.bian.ga/ 链接名bian.ga]
[!图片位置dir/image.png 图片标题imagename]
[#站内idname 话题名]
[<页内引用ref 位置position in place]
[类名class name: 内容content]
```

区块 block
```
#1 标题1 title 1
#2 标题2 title 2
#1+   有序标题 ordered title 1


=== 分隔线 hr
或任意多 = or as many = as you wish
========================

- 列表list
+ 有序列表order list
-+
-[  多行列表开始 multiline list start
-]  多行列表终止 multiline list end

> 应用块blockquote
>[ 多行引用块开始 multiline blockquote start
>] 多行引用块终止 multiline blockquote end


=[ 代码块，各种扩展块开始 language start
=] 代码块，扩展块终止 language end

或 任意多= or as many = as you wish
=============[ javascript hightlight pretty init
代码 code
===]


注释 comment
=[ comment
=]

元信息 meta
=[ meta
=]

表格 table
=[ table
=]

数学公式 math
=[ math
=]

矢量图 vector diagram
=[ graphviz
=]

```

效果 见 截图，实测效果可参见 test文件夹

![截图](/docs/images/screen1.png)


## #2 Rules in Development

参见 [设计草案](/docs/2018-06-25-友码文设计大体定案.md)

尚需解决几个小问题：

- 自定义类起首要不要特定标记？
- 起首符号后，要不要加空格？
- 中间间隔符用什么？目前用 `:`

## #2 TODO list

- [ ] 实现 nodejs 编译器
- [x] 为emacs编写一个 il-mode。
- [ ] 编写 snippet ln到snippet文件夹里
- [x] 编写 kwrite 规则 [kde syntax highlighting framework](https://github.com/KDE/syntax-highlighting)，20180627初步搞定。
- [x] 编写一个适配手机编辑器的高亮方案 jota，20180625 爬山登顶后，小坐一会，搞定。
- [ ] vscode 高亮方案
- [ ] atom 的高亮方案
- [ ] vim 高亮方案
- [ ] codemirror高亮方案：在src/mode/里
- [ ] 制造一个编辑器，使其能把各种媒体内容放入，保存时归档，打开是解开归档。从而形成一个编辑器。
- [ ] 拆分文档为中英文模式，而非现在的混杂模式。

> 注意：emacs和kate的reg引擎都有瑕疵，大体不差，但还需要进一步适配，以精确表达规则。


## #2 Quick Start

### #3 Syntax Highlight only

> 注意：由于目前尚未把语法高亮提交相应平台，所以只能手动添加。

根据所使用平台，调用derivation里的相应插件即可。

#### #4 emacs里的il语法高亮
符号连接或者直接复制到相应目录。

``` shell
ln -s /path/to/derivation/emacs-mode/il-mode.el ~/.emacs.d/plugins
ln -s /path/to/derivation/snippet ~/.emacs.d/snippet/il-mode
```
然后在 init.el里添加下面两行，调用插件
```
;; 自动加载 il-mode
(autoload 'il-mode "il-mode")
(add-to-list 'auto-mode-alist '("\\.il\\'" . il-mode) t)
```

#### #4 kate/kwrite语法高亮

符号连接或者直接复制到相应目录。
``` shell
ln -s /path/to/derivation/kde-il/il.xml ~/.local/share/org.kde.syntax-highlighting/syntax/il.xml

```
#### #4 jota语法高亮

把 /derivation/jota/il.conf 放入手机sdcard的 `.jota/keyword/user/` 里即可。


### #3 需要把文件输出为html：

尚不可用。

```
npm instal -g il-mode
il-mode -i inputfile -o outputfile
```

## #2 How to Contribute

### #3 File Structure：

- lib: contains all source code.
- docs: contains all document including design draft.
- derivation: contains all derivation for many platforms, such as emacs vim kate vscode github-atom
- test: contains all test files
- public: empty, for docs to deploy as static web pages.

## #2 History

+ 20141105 Design begins
+ 20180617 端午前夕，初步完成emacs il-mode
+ 20180622 规则初步定案
+ 20180625 调整规则：行内为单个标识符且带始终标识，首写。连接统一设置，可扩展区块换标识符。完成手机编辑器jota的高亮适配。
+ 20180626 完成kate/kwrite高亮移植。

