# 友码 Il is markup language

![标志](/docs/images/il-logo.png)

> 感觉不到编辑器
> ease and extensible

状态：语法风格已经大致确定，只剩几个小细节可能略有调整。

## 特点

+ 区块全部无行首缩进
+ 可扩展：
  + 行内和区块
  + 可方便添加扩展
+ 规则统一：
  + 起始和终点符号一致
  + 自定义行内样式和链接规则统一
  + 可方便添加类名和识别名
- 视觉上要舒服


## 已经稳定的规则 stable rules

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


## 探索中的规则 Rules in Development

参见 [设计草案](/docs/2018-06-25-友码文设计大体定案.md)

尚需解决几个小问题：

- 自定义类起首要不要特定标记？
- 起首符号后，要不要加空格？
- 中间间隔符用什么？目前用 `:`

## 待办任务 TODO list

- [ ] 实现 nodejs 编译器
- [x] 为emacs编写一个 il-mode，非全版reg
- [ ] 编写 snippet ln到snippet文件夹里
- [x] 编写 kwrite 规则 [kde syntax highlighting framework](https://github.com/KDE/syntax-highlighting)，放于 `~/.local/share/org.kde.syntax-highlighting/syntax` 20180627初步搞定。非全版reg
- [x] 编写一个适配手机编辑器的高亮方案 jota，20180625 爬山登顶后，小坐一会，搞定。
- [ ] vscode 高亮方案
- [ ] atom 的高亮方案
- [ ] vim 高亮方案
- [ ] codemirror高亮方案：在src/mode/里
- [ ] 制造一个编辑器，使其能把各种媒体内容放入，保存时归档，打开是解开归档。从而形成一个编辑器。


## 如何使用 Quick Start

### 仅需语法高亮

根据所使用平台，调用derivation里的相应插件即可。

比如emacs：

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

### 需要把文件输出为html：
```
npm instal -g il-mode
il-mode -i inputfile -o outputfile
```

## 如何参与 How to Contribute

### 文件夹解析 file structure：

- lib 为源码 contains all source code.
- docs 为文档 contains all document including design draft.
- derivation 为适配插件，用于kwrite等外部工具 contains all derivation for many platforms, such as emacs vim kate vscode github-atom
- test 测试代码区 contains all test files
- public 文档发布区 empty, for docs to deploy as static web pages.

## 历史 History

+ 20141105 开始规划
+ 20180617 端午前夕，初步完成emacs il-mode
+ 20180622 规则初步定案
+ 20180625 调整规则：行内为单个标识符且带始终标识，首写。连接统一设置，可扩展区块换标识符。完成手机编辑器jota的高亮适配。
+ 20180626 完成kate/kwrite高亮移植。

