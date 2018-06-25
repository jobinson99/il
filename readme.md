# 友码 Il is markup language

![标志](/docs/images/il-logo.png)

> 感觉不到编辑器

状态：语法风格已经大致确定，只剩几个小细节

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


## 已经稳定的规则

行内标识
```
[* 加粗bold]
[/ 斜体italic]
[_ underline]
[+ 删除线strike through]
[^ 上标superscript]
[~ 下标subscript]
[= 代码code]
```

连接
```
[>连接地址http://www.bian.ga/ 链接名bian.ga]
[!图片位置dir/image.png 图片标题imagename]
[#站内idname 话题名]
[<页内引用ref 位置position in place]
[类名class name: 内容content]
```

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


=[ 代码块，各种扩展块 language start
=]

或 任意多= or as many = as you wish
=============[
代码
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

```

效果 见 截图，实测效果可参见 test文件夹

![截图](/docs/images/screen1.png)


## 探索中的规则

参见 [设计草案](/docs/2018-06-25-友码文设计大体定案.md)

尚需解决几个小问题：

- 自定义类起首要不要特定标记？
- 起首符号后，要不要加空格？
- 中间间隔符用什么？目前用 `:`

## 待办任务

- [ ] 实现 nodejs 编译器
- [x] 为emacs编写一个 il-mode
- [ ] 编写 snippet
- [ ] 编写 kwrite 规则 [kde syntax highlighting framework](https://github.com/KDE/syntax-highlighting)
- [x] 编写一个适配手机编辑器的高亮方案 jota，20180625 爬山登顶后，小坐一会，搞定。
- [ ] 制造一个编辑器，使其能把各种媒体内容放入，保存时归档，打开是解开归档。从而形成一个编辑器。




## 如何参与

文件夹解析：
- lib 为源码
- docs为文档
- derivation 为适配插件，用于kwrite等外部工具
- test 测试代码区
- public 文档发布区

## 历史

+ 20141105 开始规划
+ 20180617 端午前夕，初步完成emacs il-mode
+ 20180622 规则初步定案
+ 20180625 调整规则：行内为单个标识符且带始终标识，首写。连接统一设置，可扩展区块换标识符。


