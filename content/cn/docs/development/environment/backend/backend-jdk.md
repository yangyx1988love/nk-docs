
---
title: "JDK"
weight: 200
description: >
  系统管理平台的后台服务采用spring boot框架开发,首先需要配置Java开发环境-JDK。
---

## 一、下载并安装
#### 直接进入Sun公司的官网（https://www.oracle.com/）
![](../img/jdk-01.png)
#### 点击“Download Java for Developers”，进入Java开发的下载页面
![](../img/jdk-02.png)
#### 选择需要下载的java SE、java EE和Java ME的相应版本进行下载
![](../img/jdk-03.png)
#### X86是32Bit,X64是64Bit
![](../img/jdk-04.png)
#### 同意并下载
![](../img/jdk-05.png)
## 二、安装
![](../img/jdk-06.png)
![](../img/jdk-07.png)
![](../img/jdk-08.png)
## 二、配置环境变量
#### 安装好的jdk需要进行环境变量的配置，找到“此电脑/计算机”右键 “属性”，进入“高级系统设置”

![](../img/jdk-09.png)
#### 进入“环境变量”的设置，新建所需的 环境变量（记得要在“系统变量”里面创建）
![](../img/jdk-10.png)

> 1. 新建 JAVA_HOME 变量
> ![](../img/jdk-11.png)

> 2. 查找 CLASSPATH 变量，若没有的话，需新建
> ![](../img/jdk-12.png)

> 3. 找到Path变量进行编辑，将“%JAVA_HOME%\bin”和“%JAVA_HOME%\jre\bin”加入Path的变量值中
> ![](../img/jdk-14.png)

> 4. 每次编辑完“环境变量”，都要点击“确定”加以保存，否则，你所“新建/编辑”的环境变量都是无效的
> ![](../img/jdk-15.png)


##  三、测试

    安装好jdk，并配置好环境变量后，可以通过cmd命令进行测试，是否安装并配置正确。
    在“开始”菜单栏键入 cmd，回车后打开cmd窗口；输入 Java+回车，显示出 java 的相关信息；
    键入 Javac + 回车，显示出　Java 编译的相关信息，即表示安装并配置成功
    
![](../img/jdk-16.png)

    安装好jdk，并配置好环境变量后，可以通过cmd命令进行测试，是否安装并配置正确。
    键入"java -version"，查看JDK版本信息
![](../img/jdk-17.png)