
---
title: "RestDB 使用手册"
weight: 1000
description: >
  RestDB 是一个只需要配置 SQL 语句就能提供 Restful 服务的应用程序。
---

## 启动 RestDB

RestDB 当前以源代码方式提供，您可以从 gitee.com 上下载代码并运行:

    git clone https://gitee.com/henry-tech/nk-sys-backend.git
    cd nk-sys-backend
    mvn clean package spring-boot:run

> **说明**  
> 系统需要安装 maven 3 和 jdk-8。  

## 查看 RESTful API

RestDB 将已定义的 API 通过 swagger-ui 发布。

启动后，您可以在 http://localhost:8081/swagger-ui.html 查看当前已发布的 API。


## 配置数据源

RestDB 使用 SpringBoot 开发，所以 RestDB 配置通过 SpringBoot 方式进行配置。

RestDB 中生产阶段的配置文件为 `config/application-prod.properties`。

配置文件中，我们对所要访问的数据源进行配置:

    # 配置一个数据源(这里数据源的名称为 mysql)
    # 可以配置多个数据源, 只需要使用不同的名称即可
    jersey.datasources.mysql.driverClassName=com.mysql.cj.jdbc.Driver
    jersey.datasources.mysql.url=jdbc:mysql://localhost/nk_emission
    jersey.datasources.mysql.username=root
    jersey.datasources.mysql.password=
    jersey.datasources.mysql.connectionProperties=userUnicode=true;characterEncoding=UTF-8;useFastDateParsing=false;serverTimezone=Asia/Shanghai

    # 指定默认使用的数据源，必须与上面所配置的一个数据源名称相同
    jersey.default.datasource=mysql


## RestDB API 配置

RestDB 中 API 在 `config/rest` 目录中配置。
该目录中以 `.yaml` 结尾的文件都会被作为 API 配置文件。

yaml 是一种用来表达数据序列化的格式，类似于 JSON，但比 JSON 更简洁。

下面我们来看系统自带的 `test.yaml` API 配置文件:

    ---

    default:
      isolationLevel: REPEATABLE_READ

    resources:
    - path: hello/{name}
      method: GET
      summary: 路径参数示例
      notes: 演示路径参数的声明和使用方法。
      params:
      - name: name
        value: 姓名
        required: true
        dataType: string
        paramType: path   # paraType: path, query, body, header or form
        example: 何江
      actions:
      - # 使用 prepare statement 参数
        text: "SELECT concat('hello ', @name) as greetings"
        sql-type: select
        ret-name: prep
        ret-type: object
      - # 使用 placeholder 进行 sql 拼接
        text: "SELECT concat('hello ', '$name') as greetings FROM dual"
        sql-type: select
        ret-name: place
        ret-type: scalar


### 设置默认属性

在 `.yaml` 文件中, 我们可以在 `default` 下进行默认属性设置:

    default:
      datasource: mysql
      isolationLevel: REPEATABLE_READ

这里的配置会覆盖 `application-prod.properties` 中 `jersey.default.*` 下的配置。

这非常有用，因为 `jersey.default.*` 中对所有 `.yaml` 文件起作用，而一个 `.yaml` 文件中 `default` 下的配置只对该文件中的资源配置起作用。

默认属性可配置项说明:

1. `datasource`: 指定默认数据源名称，数据源名称必须来自 `application-prod.properties` 文件中 `jersey.datasources.*` 下定义的名称；

1. `isolationLevel`: 指定默认事务隔离级别，可配置为 `NONE`, `READ_UNCOMMITTED`, `READ_COMMITTED`, `REPEATABLE_READ`, `SERIALIZABLE` 五个级别中的一个。


### 定义 Restful 资源

RestDB 在 `resources` 下对 Restful 资源进行定义。  
`resources` 是一个列表，每一个 Restful 资源是 `resources` 的一项。  

    resources:
    - path: hello/{name}
      method: GET
      summary: 路径参数示例
      notes: 演示路径参数的声明和使用方法。
      params:
      - name: name
        value: 姓名
        required: true
        dataType: string
        paramType: path   # paraType: path, query, body, header or form
        example: 何江
      actions:
      - # 使用 prepare statement 参数
        text: "SELECT concat('hello ', @name) as greetings"
        sql-type: select
        ret-name: prep
        ret-type: object
      - # 使用 placeholder 进行 sql 拼接
        text: "SELECT concat('hello ', '$name') as greetings FROM dual"
        sql-type: select
        ret-name: place
        ret-type: scalar

资源定义配置项说明:

1. `path`: 指定资源路径。资源路径可以是相对路径，也可以是绝对路径。

1. `method`:

1. `summary`:

1. `notes`:

1. `params`:

1. `actions`:


#### 参数说明

Restful 请求参数在 `params` 下进行说明。

#### 行为定义

Restful 行为在 `actions` 下进行定义。


## 与前端界面集成

你也可以直接使用 RestDB 的 WEB 容器来发布前端界面静态资源。
只需要将编译好的前端界面文件复制到 RestDB 的 `static` 目录下，
用户就可以通过同样的地址访问前端页面。

RestDB 是 SPA 应用友好的。
任何无后缀请求，都会被重定向到 index.html 中。
所以前端应用中可以随意使用 hash 或 history 路由，而不用担心发布后页面刷新和跳转问题。
