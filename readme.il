#1 友码 Il is markup language

#2 特点

+ 区块全部无行首缩进
+ 可扩展：
++ 行内和区块
++ 可方便添加扩展
+ 规则统一：
++ 起始和终点符号一致
++ 自定义行内样式和链接规则统一
++ 可方便添加类名和识别名


#2 已经稳定的规则

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


```


#2 探索中的规则

参见 [[/设计草案.il][设计草案]]



#2 待办任务

- [todo] 实现 nodejs 编译器
- [todo] 把markdown-mode改造下，转化为 il-mode
- [todo] 编写 snippet
- [todo] 编写 kwrite 规则 [kde syntax highlighting framework](https://github.com/KDE/syntax-highlighting)
- [todo] 制造一个编辑器，使其能把各种媒体内容放入，保存时归档，打开是解开归档。从而形成一个编辑器。




#2 如何参与

文件夹解析：
- lib 为源码
- docs为文档
- derivation 为适配插件，用于kwrite等外部工具
- test 测试代码区
- public 文档发布区



