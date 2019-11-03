
---
title: "后台服务"
weight: 200
description: >
  系统管理平台的后台服务开发。
---

后台服务源代码托管在 [https://gitee.com/henry-tech/nk-sys-backend](https://gitee.com/henry-tech/nk-sys-backend)。

## 代码编译

    git clone https://gitee.com/henry-tech/nk-sys-backend.git
    cd nk-sys-backend
    mvn package
    mvn spring-boot:run

## 测试和验证

打开浏览器，输入 http://localhost:8081/api/model
, 返回 JSON 字符串如下:

    {"list":[{"model_id":"emission-model-01","name":"排放测算模型","description":"为研究城市机动车污染特征，实现污染物排放的最优控制，我们提出了研究排放控制目标的数学优化模型。","avatar":"/images/model/emission.jpg","created_at":"2019-11-2 21:41:20","created_by":null,"update_note":null,"updated_at":"2019-11-2 21:41:20","updated_by":null}]}


## 服务配置

config/application.properties

## 数据库配置

config/datasource.yaml

## RESTful 配置

config/rest/*.yaml

配置规则请参考 config/rest/test.yaml 文件内容。