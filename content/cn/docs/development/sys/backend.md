
---
title: "后台服务"
weight: 200
description: >
  系统管理平台的后台服务开发。
---

后台服务源代码托管在 [https://gitee.com/henry-tech/nk-sys-backend](https://gitee.com/henry-tech/nk-sys-backend)。

## 使用 eclipse 进行开发

## 在 eclipse 中开发和调试


## 配置 application.properties

    server.port=8081

    spring.mvc.view.prefix=/
    spring.mvc.view.suffix=.html

    spring.mvc.static-path-pattern=/**
    spring.resources.static-locations=file:///D:/home/restdb/src/main/resources/static/;classpath:/META-INF/resources/;classpath:/META-INF/resources/

    jersey.datasource.config.file=file:///D:/home/restdb/src/main/resources/datasource.yaml
    jersey.resources.config.folder=file:///D:/home/restdb/src/main/resources/config
    jersey.resources.url.mapping=/api/*

    keycloak.enabled=false

    keycloak.auth-server-url=http://localhost:8080/auth
    keycloak.realm=SpringBoot
    keycloak.resource=restdb-app
    keycloak.public-client=true

    keycloak.security-constraints[0].authRoles[0]=user
    keycloak.security-constraints[0].securityCollections[0].patterns[0]=/*
    keycloak.principal-attribute=preferred_username

    logging.level.root=info
    logging.level.org.nutz.dao.impl.sql.run=debug

## 配置 datasource.yaml

    ---

    # datasource configuration

    mysql:
      driverClassName      : com.mysql.cj.jdbc.Driver
      url                  : jdbc:mysql://localhost/nk_emission
      username             : root
      password             : ''
      connectionProperties : userUnicode=true;characterEncoding=UTF-8;useFastDateParsing=false;serverTimezone=Asia/Shanghai
      initialSize          : 1                  # 初始化大小、最小、最大
      minIdle              : 1                  # 初始化大小、最小、最大
      maxActive            : 20                 # 初始化大小、最小、最大
      maxWait              : 60000              # 获取连接等待超时的时间
      validationQuery      : SELECT 1
      testWhileIdle        : true
      testOnBorrow         : false
      testOnReturn         : false
      filters              : stat               # 启用监控统计功能
      timeBetweenEvictionRunsMillis : 60000     # 间隔多久才进行一次检测，检测需要关闭的空闲连接，单位是毫秒
      minEvictableIdleTimeMillis    : 300000    # 一个连接在池中最小生存的时间，单位是毫秒
      poolPreparedStatements        : false


## 道路相关 RESTful 请求

新建 config/road.yaml 文件, 输入

    ---

    datasource: mysql

    resource:
    - method: GET
      description: "获取路段列表。参数：district: 行政区域；area：地理区域；offset: 偏移(0开始)；size：行数"
      sql:
      - text: "SELECT COUNT(*) FROM t_road WHERE district LIKE '%$district%' AND area LIKE '%$area%' AND name LIKE '%$name%'"
        sql-type: SELECT
        ret-name: total
        ret-type: scalar
      - text: |
          SELECT t.road_id, t.district, t.area, t.name, t.description, r.speed, r.flow, r.updated_at
          FROM t_road t, t_road_now r
          WHERE t.road_id = r.road_id AND t.district LIKE '%$district%' AND t.area LIKE '%$area%' AND t.name LIKE '%$name%'
          ORDER BY t.road_id ASC
          LIMIT $offset, $size
        sql-type: SELECT
        ret-name: list
        ret-type: array

## 车辆相关 RESTful 请求

新建 config/fleet.yaml 文件, 输入

    ---

    datasource: mysql

    resource:
    - method: GET
      description: "获取车队信息。参数: fleet_id: 类别 ID"
      sql:
      - text: "SELECT f.*, (SELECT COUNT(*) FROM t_fleet_closure fc where fc.fleet_pid = f.fleet_id) = 1 AS 'is_leaf' FROM t_fleet f WHERE f.fleet_id = @fleet_id LIMIT 1"
        sql-type: SELECT
        ret-name: item
        ret-type: object


    - path: children
      method: GET
      description: "获取车队列表。参数: fleet_pid: 父类别 ID"
      sql:
      - text: "SELECT f.*, (SELECT COUNT(*) FROM t_fleet_closure fc where fc.fleet_pid = f.fleet_id) = 1 AS 'is_leaf' FROM t_fleet f WHERE f.fleet_pid = @fleet_pid"
        sql-type: SELECT
        ret-name: list
        ret-type: array


    - method: POST
      description: "创建车队"
      sql:
      - text: |
          INSERT INTO t_fleet(fleet_id, name, description, avatar, fleet_pid) 
          VALUES(@fleet_id, @name, @description, @avatar, @fleet_pid)
        sql-type: INSERT
        ret-name: inserted
        ret-type: scalar
      - text: "INSERT INTO t_fleet_closure(fleet_pid, fleet_id, distance) VALUES(@fleet_id, @fleet_id, 0)"
      - text: "INSERT INTO t_fleet_closure(fleet_pid, fleet_id, distance) SELECT fleet_pid, @fleet_id, distance+1 FROM t_fleet_closure WHERE fleet_id = @fleet_pid"
      
      
    - method: PUT
      description: "更新车队"
      sql:
      - text: "UPDATE t_fleet SET name=@name, description=@description, avatar=@avatar WHERE fleet_id=@fleet_id"
        sql-type: UPDATE
        ret-name: updated
        ret-type: scalar
        
        
    - method: DELETE
      description: "删除车队"
      sql:
      - text: "DELETE FROM t_fleet WHERE fleet_id=@fleet_id OR fleet_id IN (SELECT fleet_id FROM t_fleet_closure WHERE fleet_pid = @fleet_id)"
        sql-type: DELETE
        ret-name: deleted
        ret-type: scalar
      - text: "DELETE t1 FROM t_fleet_closure t1, t_fleet_closure t2 WHERE (t1.fleet_pid = t2.fleet_id OR t1.fleet_id = t2.fleet_id) AND t2.fleet_pid = @fleet_id"
      - text: "DELETE FROM t_fleet_closure WHERE fleet_pid=@fleet_id OR fleet_id=@fleet_id"

      
    - path: ratio
      method: GET
      description: "查询道路车队占比"
      sql:
      - text: "SELECT COUNT(*) FROM t_road WHERE district LIKE '%$district%' AND area LIKE '%$area%' AND name LIKE '%$name%'"
        sql-type: SELECT
        ret-name: total
        ret-type: scalar
      - text: "SELECT fleet_id, name FROM t_fleet WHERE fleet_pid = @fleet_pid"
        sql-type: SELECT
        ret-name: header
        ret-type: array
      - text: "CALL query_fleet_ratio(@fleet_pid, @district, @area, @name, @offset, @size)"
        sql-type: CALL
        ret-name: list
        ret-type: array
      
      
    - path: ratio
      method: PUT
      description: "设置道路车队占比"
      sql:
      - text: |
          INSERT t_fleet_ratio(road_id, fleet_id, fleet_ratio)
          VALUES (@road_id, @fleet_id, @fleet_ratio)
          ON DUPLICATE KEY UPDATE fleet_ratio=@fleet_ratio
        sql-type: UPDATE
        ret-name: updated
        ret-type: scalar

## 模型相关 RESTful 请求

新建 config/model.yaml 文件, 输入

    ---

    datasource: mysql

    resource:
    - method: GET
      description: "获取模型列表"
      sql:
      - text: "SELECT * FROM t_model"
        sql-type: SELECT
        ret-name: list
        ret-type: array


    - path: parameter
      method: GET
      description: "获取模型参数列表"
      sql:
      - text: |
          SELECT p.*, f.name, f.fleet_id 
          FROM t_fleet f LEFT JOIN t_model_param p ON f.fleet_id=p.fleet_id 
          WHERE fleet_pid=@fleet_pid
        sql-type: SELECT
        ret-name: list
        ret-type: array


    - path: parameter
      method: PUT
      description: "更新模型参数列表"
      sql:
      - text: |
          INSERT INTO t_model_param(model_id, fleet_id, a, b, c, d, e, f, g, k, speed_min, speed_max)
          VALUES('model-01', @fleet_id, @a, @b, @c, @d, @e, @f, @g, @k, @speed_min, @speed_max)
          ON DUPLICATE KEY UPDATE a=@a, b=@b, c=@c, d=@d, e=@e, f=@f, g=@g, k=@k, speed_min=@speed_min, speed_max=@speed_max
        sql-type: UPDATE
        ret-name: updated
        ret-type: scalar

