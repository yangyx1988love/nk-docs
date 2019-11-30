
---
title: "RestDB 使用手册"
weight: 1000
description: >
  RestDB 是仅需编写 SQL 语句即可提供 RESTful 后端服务的应用程序。
---

前后端分离之后，很多简单应用软件的后端程序已经退化为支持 RESTful 的数据请求服务。
使用 RestDB 可以完全替换后端程序，不再需要开发专门的后端服务程序，只需要配置 RestDB 即可，简化应用系统开发。

## RestDB 实现原理

RestDB 通过配置将 RESTful API 与 SQL(或其他 Action) 集合相关联。
当客户端进行 RESTful 请求时，RestDB 执行相应的 SQL(或其他 Action) 集合，然后向客户端返回执行结果。

<div class="plantuml">
@startuml
    participant "客户端" as client
    participant "RestDB 服务" as restdb
    participant "数据源 1" as ds1
    participant "数据源 2" as ds2

    client -> restdb: GET /api/test/hello/hejiang
    activate restdb

    restdb -> ds1:    执行第一个 Action
    activate ds1
    restdb <- ds1:    返回执行结果
    deactivate ds1
    
    restdb -> ds2:    执行第二个 Action
    activate ds2
    restdb <- ds2:    返回执行结果
    deactivate ds2

    note over restdb, ds2 
      顺序执行其他 Action
    end note

    restdb -> ds2:    执行最后一个 Action
    activate ds2
    restdb <- ds2:    返回执行结果
    deactivate ds2
    
    client <- restdb: 返回执行结果 {"result":"hello hejiang"}
    deactivate restdb
@enduml
</div>


## 启动 RestDB 服务

RestDB 当前以源代码方式提供，您可以从 gitee.com 上下载代码并运行:

    git clone https://gitee.com/henry-tech/restdb.git
    cd restdb
    mvn clean package spring-boot:run

> **说明**  
> 系统需要安装 [maven 3](http://maven.apache.org/download.cgi) 和 [jdk-8](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)。  


## 构建 docker 镜像

RestDB 支持构建 docker 镜像。想要构建 docker 镜像, 请在 restdb 目录下执行以下命令:

    mvn clean package docker:build

> **说明**  
> 系统需要安装 [docker](https://www.docker.com/)。


## 查看 RESTful API

RestDB 通过 swagger-ui 发布 RESTful API。

启动后，您可以在 http://localhost:8081/swagger-ui.html 查看当前已定义的 RESTful API 列表。


## RestDB 系统配置

RestDB 使用 [Spring Boot](https://spring.io/projects/spring-boot/) 框架，所以 RestDB 配置通过 Spring Boot 方式进行配置。

RestDB 中生产阶段的配置文件为 `config/application-prod.properties`。

RestDB 系统配置主要包括 `数据源` 和 `全局默认值`。

### 配置 RestDB 数据源

在 RestDB 配置文件中，我们需要对 RESTful API 所要访问的数据源进行设置:

    # file: config/application-prod.properties

    jersey.datasources.mysql.driverClassName=com.mysql.cj.jdbc.Driver
    jersey.datasources.mysql.url=jdbc:mysql://localhost/nk_emission
    jersey.datasources.mysql.username=root
    jersey.datasources.mysql.password=
    jersey.datasources.mysql.connectionProperties=userUnicode=true;characterEncoding=UTF-8;useFastDateParsing=false;serverTimezone=Asia/Shanghai

每一个配置项的名称由三部分组成，每个部分之间用 `.` 隔开:

* `jersey.datasources` 前缀是 RestDB 要求的;
* 中间的 `mysql` 是一个数据源**标识符**，标识符是一个字符串, 可以由字母和数字组成。
* 最后面是数据源配置属性。RestDB 使用 alibaba/druid 管理数据源, 
  配置属性列表请参考 [DruidDataSource配置属性列表](https://github.com/alibaba/druid/wiki/DruidDataSource配置属性列表)。

您也可以在 RestDB 中同时配置多个数据源，只需要使用不同的数据源标识符即可:

    # file: config/application-prod.properties
    
    jersey.datasources.mysql.driverClassName=com.mysql.cj.jdbc.Driver
    jersey.datasources.mysql.url=jdbc:mysql://localhost/nk_emission
    jersey.datasources.mysql.username=root
    jersey.datasources.mysql.password=
    jersey.datasources.mysql.connectionProperties=userUnicode=true;characterEncoding=UTF-8;useFastDateParsing=false;serverTimezone=Asia/Shanghai

    jersey.datasources.h2.driverClassName=org.h2.Driver
    jersey.datasources.h2.url=jdbc:h2:mem:testdb;MODE=MYSQL;DB_CLOSE_DELAY=-1;DATABASE_TO_UPPER=false
    jersey.datasources.h2.username=sa
    jersey.datasources.h2.password=sa

在上面的配置文件中，我们配置了两个数据源，分别使用 `mysql` 和 `h2` 标识符。


### 设置全局默认属性

除了数据源以外，我们还可以在 RestDB 配置文件中设置 Restful API 全局默认属性:

    # file: config/application-prod.properties
    
    jersey.default.datasource=h2
    jersey.default.isolationLevel=SERIALIZABLE

每一个配置项的名称由两部分组成：`jersey.default` 前缀，以及一个 RESTful API 配置项名称。  

这个例子中我们设置了两个全局默认属性:

1. `datasource`: Restful API 请求所要访问的数据源。它必须是 RestDB 数据源中已经配置的数据源**标识符**；
1. `isolationLevel`: Restful API 请求访问数据源时, SQL 执行隔离级别。详见 [Restful API 配置项](#restful-api-配置项)。


## RESTful API 定义文件

RESTful API 使用 `yaml` 文件进行定义。RESTful API 定义文件存放在 `config/rest` 目录中。
`config/rest` 目录 (以及子目录) 中以 `.yaml` 结尾的文件都会被作为 RESTful API 定义文件。

`yaml` 是一种用来表达数据序列化的格式，类似于 `JSON`，但比 `JSON` 更简洁。详见 [https://yaml.org/](https://yaml.org/)。

下面是系统自带的 `test.yaml` API 定义文件:

    # file: config/rest/test.yaml

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
        paramType: path   # paramType: path, query, body, header or form
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


### RESTful API 默认属性

除了全局默认属性外，我们还可以在 RESTful API 定义文件设置 RESTful API 默认属性。

在 `.yaml` 文件中, 我们可以在 `default` 下进行默认属性设置:

    # file: config/rest/test.yaml

    default:
      isolationLevel: REPEATABLE_READ

这里的配置会覆盖我们在 `application-prod.properties` 中 `jersey.default.*` 下设置的全局默认属性。

这非常有用，因为在 `jersey.default.*` 设置的全局默认属性对所有RESTful API 定义文件起作用，
而在 RESTful API 定义文件中 `default` 下设置的默认属性只对该文件中的 RESTful API 定义生效。


### RESTful API 定义

RESTful API 在 `resources` 下进行配置。  
`resources` 是一个列表，每一个 RESTful API 定义是 `resources` 的一项。  

    # file: config/rest/test.yaml

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
        paramType: path   # paramType: path, query, body, header or form
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

RESTful API 定义由一组配置项组成。如果某个配置项没有被指定，
系统首先会在 RESTful API 定义所在文件的 `default` 下的默认属性中查找；
如果没有找到，系统才会使用全局默认属性。


### RESTful API 配置项

RESTful API 配置项比较多，现将各配置项说明如下：

1. `path`: RESTful API 路径。
    RESTful API 路径可以是相对路径，也可以是绝对路径(以 `/` 开始的路径)。  
    对于路径参数，因为与路径中的出现位置相关，所以要在路径中使用`{参数名称}`表示出来。
    例如 `hello/{name}` 这个相对路径中, `name` 就是一个路径参数。   
    RestDB 使用 [jersey](https://projects.eclipse.org/projects/ee4j.jersey) 提供 RESTful 服务, 路径参数写法可参考 jersey 文档。

    使用相对路径设置的 RESTful API 路径按以下方式构成:  
    **`/api` + `/` + 子目录名称(如果有) + `/` + RESTful API 定义文件名(不包含.yaml) + `/` + 相对路径**  

    使用绝对路径设置的 RESTful API 路径按以下方式构成:  
    **`/api` + 绝对路径**  
    
1. `method`: RESTful API 请求方法。  
   根据 HTTP 协议，常用的请求方法包括 `GET`, `POST`, `PUT`, `DELETE`。

1. `summary`: RESTful API 简要说明。  
   RESTful API 简要说明会显示在 swagger-ui 中。清晰的说明对 API 使用者非常重要。

1. `notes`: RESTful API 详细说明。  
   RESTful API 详细说明会显示在 swagger-ui 中。清晰的说明对 API 使用者非常重要。

1. `params`: RESTful API 请求参数列表。详见 [RESTful API 请求参数](#restful-api-请求参数)。

1. `actions`: RESTful API 行为列表。详见 [RESTful API 行为定义](#restful-api-行为定义)。


#### RESTful API 请求参数

RESTful API 请求参数在 `params` 下定义。每个参数的配置项如下:

1. `name`: 参数名称。字符串值。

1. `value`: 参数说明。字符串值。

1. `required`: 是否必须参数。可以是 `true` 或 `false`

1. `dataType`: 数据类型。可以是 `string`, `int`, `long`, `double` 等

1. `paramType`: 参数类型。可以是 `path`, `query`, `body`, `header` 或 `form`

1. `example`: 参数值样例。作为 swagger-ui 执行请求时的默认值。


#### RESTful API 行为定义

RESTful API 行为在 `actions` 下定义。行为的配置项与行为的类型 (`type` 参数, 默认为 sql) 相关。


#### SQL 行为配置

SQL 行为配置项如下:

1. `type`: 不设置 (默认为 `sql`)，或设置为 `sql`。

1. `datasource`: 设置执行 SQL 的数据源。不设置 (从默认属性中读取), 或设置为一个数据源**标识符**。

1. `text`: 要执行的 SQL 语句, 可以使用数据源标识符代替 `text`, 在不同数据源下执行不同的 SQL 语句。  
   对于 SQL 语句中参数的书写方式，请参见 [书写 SQL 语句](#书写-sql-语句)。

1. `sql-type`: SQL 语句类型。可以设置为 SELECT, DELETE, TRUNCATE, UPDATE, INSERT, CREATE, DROP, RUN, ALTER, EXEC, CALL (调用存储过程), OTHER

1. `ret-name`: 将 SQL 执行返回的二维表存储到 RESTful 请求返回对象中的属性名称。

1. `ret-type`: 可以设置为 scalar, object, array, array-array。
   我们知道，执行 SQL 语句返回的结果集是一个二维表。所以  
   * `scalar`: 表示返回二维表中的第一行，第一列的值; 对于返回非结果集的 SQL 语句，必须设置为 `scalar`，比如 DELETE 返回影响行数数值;
   * `object`: 表示返回二维表中的第一行，组成一个以字段名称为属性名的对象;
   * `array` : 表示返回对象数组，二维表的每一行是数组的一个对象;
   * `array-array`: 表示返回值数组, 二维表的每一行数组内的一项，也是一个数组。


#### 书写 SQL 语句

SQL 语句中可以使用 RESTful 请求参数。使用请求参数有两种形式:

1. `@参数名`: 例如 `SELECT * FROM table1 WHERE name = @name`。该语句执行时会将请求参数中的 name 参数传给数据库执行；

1. `$参数名`: 例如 `SELECT * FROM table1 WHERE name = '$name'`。  
   该语句执行时会用请求参数中的 name 参数替换 SQL 语句中的 $name。  
   例如传入 name 参数的值是 hejiang, 那么实际执行的 SQL 语句是 `SELECT * FROM table1 WHERE name = 'hejiang'`。  
   这也是为什么 '$name' 两边需要有单引号 (在 SQL 语句中表示字符串常量) 的原因。

RestDB 使用 nutz 执行 SQL 语句。
关于 SQL 语句中参数使用可以参考 http://www.nutzam.com/core/dao/customized_sql.html 。


#### JAVA 行为配置

JAVA 行为配置项如下:

1. `type`: 必须设置为 `java`;

1. `class`: 实现了 `JerseyResourceAction` 接口的类;

1. `其他参数`: 行为配置项由 `class` 使用，其他参数请根据 `class` 需要进行配置。


#### PYTHON 行为配置

PYTHON 行为配置项如下:

1. `type`: 必须设置为 `python`;

1. `其他参数`: 待补充。


## 发布静态 HTML 文件

可以直接使用 RestDB 应用的 WEB 容器来发布前端界面静态资源文件。
只需要将编译好的前端界面文件复制到 RestDB 的 `static/` 目录下，
用户就可以通过同样的地址访问前端页面。

RestDB 是 SPA 应用友好的。
任何无后缀请求，都会被重定向到 `static/index.html` 中。
所以前端应用可以使用 hash 或 history 路由，
不用担心在 RestDB 应用的 WEB 容器中运行时页面刷新和跳转问题。


## RestDB 扩展接口

RestDB Action 通过 JerseyResourceActionProvider 创建。
JerseyResourceActionProvider 通过 Java 的 ServiceLoader 机制加载。

您可以实现自己的 JerseyResourceActionProvider, 并将 jar 包放在 classpath 上即可。

请参考 RestDB 中 JerseyResourceSqlActionProvider,
JerseyResourceJavaActionProvider 或 JerseyResourcePythonActionProvider 类的实现代码。

JerseyResourceActionProvider 和 JerseyResourceAction 接口定义如下:

```java
package com.henrytech.jersey;

public interface JerseyResourceActionProvider {
  JerseyResourceAction createAction(String type);
}

public interface JerseyResourceAction {
  void init(Map<String, Object> description, Map<String, Object> context,
      Map<String, NutDao> datasources) throws Exception;

  void beginTransaction(int level) throws Exception;

  void execute(ContainerRequestContext context, Map<String, Object> result)
      throws Exception;

  void commit() throws Exception;

  void rollback() throws Exception;
}
```


## RestDB 依赖组件

1. Spring Boot: https://spring.io/projects/spring-boot/
1. jersey: https://projects.eclipse.org/projects/ee4j.jersey
1. druid: https://github.com/alibaba/druid/wiki
1. nutz: http://www.nutzam.com/
1. snakeyaml: https://bitbucket.org/asomov/snakeyaml-engine
1. keycloak: https://www.keycloak.org/
1. springfox: https://springfox.github.io/springfox/
1. javaassist: http://www.javassist.org/
1. H2: http://h2database.com/html/main.html
1. commons-io: http://commons.apache.org/proper/commons-io/
1. commons-beanutils: http://commons.apache.org/proper/commons-beanutils/index.html


## RestDB 使用授权

RestDB 采用 Apache License Version 2.0 授权。详见 http://www.apache.org/licenses/LICENSE-2.0 。
