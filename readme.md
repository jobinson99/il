# 友码 Il is markup language

![标志](/docs/images/il-logo.png)

> 感觉不到编辑器

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
标题
#1
#1+


=== 分隔线

列表
-
+
-+
-[
-]


引用块
>
>[
>]

代码块、扩展块
=[ mark
=]

或 任意多=
=============[
代码
===]

注释
=[ comment
=]

元信息
=[ meta
=]

表格
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


