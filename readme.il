#1 标记笔记

- [todo] 实现 nodejs 编译器
- [todo] 把markdown-mode改造下，转化为 il-mode
- [todo] 编写 snippet
- [todo] 编写 kwrite 规则 [kde syntax highlighting framework](https://github.com/KDE/syntax-highlighting)
- [todo] 制造一个编辑器，使其能把各种媒体内容放入，保存时归档，打开是解开归档。从而形成一个编辑器。


文件夹解析：
- lib 为源码
- docs为文档
- derivation 为适配插件，用于kwrite等外部工具

表达式要打开 全局和多行，情景敏感 /gm 
行内 不加 /m


#2 区块 仍有问题

标题  正则表达式
#1 #2 #3   /^(#[1-6]{1}\+?\s*) ([^\n]+?)\s*(?:\n$)/
          /^#[1-6]{1}\+?\s.+\n$/
捕获 #1 ~#6 #1+~#6+ 且 句末换行。
但不 捕获立刻换行和多个 #若干空格 后直接换行的。

分隔行
===     /^(\={3} *)(?:\n+|$)/    或    /^(\={3}\s*)(?:\n+|$)/
捕获 行首 === 且需换行


引用块
> >> >[ >]     /^([\>]+(\[|\])?)\s+([^\n]+?)\s*(?:\n+|$)/
捕获 行首 且 行末可空格 且 需换行

>[ >]     /(^\>\[ )(.|\n)*(-\>\])/


列表
- -- + -[ -]     /^([\-|\+]+(\[|\])?)\s+([^\n]+?)\s*(?:\n+|$)/

-[ -]     /(^\-\[ )(.|\n)*(-\-\])/


程序块  \1 表示引用第一个 匹配组 ```
``` ``` shell   /^(`{3})([\s\S]*?)\n?\s*\1\s*(?:\n+|$)/
                /(^`{3})([\s\S]*?)(.|\n)*\1/ 
                /(^`{3})([\s\S]*?).*\1(?=\s*\n$)/   解决最后三个`后面跟空格问题。

换行 空一行
              /^\n+/


#2 测试用的样例

``` shell
标题

##1+ afdfsfa


#1+ sfadsf

##   ffds

## 

#1 
#11 3

#2:: fad

#22: fasdf

#1: 22

# 22 dfasdf

# 1

## sdfasd

##3: asfsdf

# fasdf
### fasdfa


#+ adsffd

#2 dfdf

#3: afasdf

#2 #3 #2

#4 afsdfaf

#111 dasfsdd 

#2  fasdf asfdf

#2 fasfd #2

#afsdf 

###

 #1 3fdaf

#1 fasf 


分隔线

 ===    
=== 

===   


===

  ===

=====


引用

> a
>  f
>> ad

>>> fsdf

>[ fadf

>[ d

>] f

 > dsf

>sfsdfs
>[afsdf

列表

- fasdf
-- fasd
-+ fasdf 
-[ fdasf 
-] fasdfs 
--[ fasdf
-+] fsadf s
+ ewfasdf
++- fasdfa s
--fsdfa
+fsaddfsa
 - afsdfa
 + sdfas

程序块

``` shell highlight run
defun test
dfasf
afsdf

afsdf
asdfs

afsd
f

sf
```

``` shell2 khk jh ghjj
asdf
sdfs
1fdsa
dfasfd
1fdsa
1dfas

```

```
3asfsad
asdfsdf
```

  ```
  ```

```
dsfdfas

```

```` 
fasdf
 
````

``` shell
asdff
```

```
  ```
```


``` shell highlight run
defun test
```

```
fasdf
   dsfsdfa
asdfdsf
fsdafs
```


```

#2 行内

两边要空格么？


加粗
*xxx*          / \*\w+\* /g
斜体
/xxx/         / \/\w+\/ /g
删除线
+xxx+         / \+\w+\+ /g
下划线
_xxx_        / \_\w+\_ /g
上下标
^xxx^        / \^\w+\^ /g
~xxx~        / \~\w+\~ /g

代码
`xxx` /      \`\w+\` /g


[xxx](yyy)      / \[w+\]\(w+\) /g
[xxx| yyy]      / \[w+\| \w+\]/g  

转义
\             


















