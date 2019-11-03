
---
title: "前端界面"
weight: 300
description: >
  系统管理平台的前端界面开发。
---

前端界面源代码托管在 [https://gitee.com/henry-tech/nk-sys-frontend](https://gitee.com/henry-tech/nk-sys-frontend)。

## 搭建编译环境

前端界面需要在 Linux 上编译。
我们采用 vagrant 来搭建编译环境。

从 https://vagrantup.com/ 下载并安装。

参考配置 [Vagrantfile](../attachement/Vagrantfile)

### 进入系统

    D:\home\nk-centos>vagrant up
    D:\home\nk-centos>start vagrant rsync-auto
    D:\home\nk-centos>vagrant ssh

### 安装工具

    [vagrant@localhost ~]$ sudo yum install wget -y
    [vagrant@localhost ~]$ wget https://nodejs.org/dist/v12.13.0/node-v12.13.0-linux-x64.tar.xz
    [vagrant@localhost ~]$ tar xvf node-v12.13.0-linux-x64.tar.xz

    [vagrant@localhost ~]$ sudo ln -s ~/node-v12.13.0-linux-x64/bin/node /usr/local/bin/node
    [vagrant@localhost ~]$ sudo ln -s ~/node-v12.13.0-linux-x64/bin/npm /usr/local/bin/npm

    [vagrant@localhost ~]$ cd frontend/
    [vagrant@localhost frontend]$ npm install

### 启动程序

    [vagrant@localhost ~]$ cd frontend/
    [vagrant@localhost frontend]$ npm start


## 运行界面截图

![](../attachment/fe-01.jpg)

![](../attachment/fe-02.jpg)

![](../attachment/fe-03.jpg)

![](../attachment/fe-04.jpg)

![](../attachment/fe-05.jpg)

![](../attachment/fe-06.jpg)
