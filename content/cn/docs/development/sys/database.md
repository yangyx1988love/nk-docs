
---
title: "数据库"
weight: 100
description: >
  系统管理平台的数据库表开发。
---

系统默认采用 mysql 存储数据。

## 下载并安装 mysql

下载 MySQL 社区版
https://dev.mysql.com/downloads/

## 导入 schema.sql

下载 schema 文件
[schema.sql](../attachment/schema.sql)

在 mysql 客户端导入

    D:\bin\mysql-8.0.15-winx64>bin\mysql -uroot
    
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 17
    Server version: 8.0.15 MySQL Community Server - GPL

    Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    mysql>
    mysql> source D:\home\nk-docs\content\cn\docs\development\sys\attachment\schema.sql
    Database changed
    Query OK, 9 rows affected (1.40 sec)

    Query OK, 1 row affected (0.05 sec)

    Database changed
    Query OK, 0 rows affected (0.05 sec)

    Query OK, 0 rows affected (0.06 sec)

    Query OK, 0 rows affected (0.06 sec)

    Query OK, 0 rows affected, 1 warning (0.03 sec)

    Query OK, 0 rows affected (0.46 sec)

    Query OK, 0 rows affected, 1 warning (0.06 sec)

    Query OK, 0 rows affected (0.34 sec)

    Query OK, 0 rows affected, 1 warning (0.03 sec)

    Query OK, 0 rows affected (0.36 sec)

    Query OK, 1 row affected (0.06 sec)

    Query OK, 0 rows affected, 1 warning (0.04 sec)

    Query OK, 0 rows affected (0.62 sec)

    Query OK, 1 row affected (0.10 sec)

    Query OK, 0 rows affected, 1 warning (0.04 sec)

    Query OK, 0 rows affected (0.51 sec)

    Query OK, 0 rows affected, 1 warning (0.02 sec)

    Query OK, 0 rows affected (0.44 sec)

    Query OK, 0 rows affected, 1 warning (0.04 sec)

    Query OK, 0 rows affected (0.39 sec)

    Query OK, 0 rows affected, 1 warning (0.04 sec)

    Query OK, 0 rows affected (0.45 sec)

    Query OK, 0 rows affected, 1 warning (0.02 sec)

    Query OK, 0 rows affected (0.44 sec)

    +-----------------------+
    | Tables_in_nk_emission |
    +-----------------------+
    | t_fleet               |
    | t_fleet_closure       |
    | t_fleet_ratio         |
    | t_model               |
    | t_model_param         |
    | t_road                |
    | t_road_emission       |
    | t_road_history        |
    | t_road_now            |
    +-----------------------+
    9 rows in set (0.01 sec)

    Query OK, 0 rows affected, 1 warning (0.02 sec)

    Query OK, 0 rows affected (0.07 sec)

    Query OK, 0 rows affected (0.01 sec)

    Query OK, 0 rows affected (0.53 sec)

    +----------+
    | count(*) |
    +----------+
    |        1 |
    +----------+
    1 row in set (0.00 sec)

    Query OK, 0 rows affected, 1 warning (0.02 sec)

    Query OK, 0 rows affected (0.07 sec)

    mysql>

## 数据库表说明

系统涉及以下几种实体:

* 道路  
  系统对道路进行分段，对各段道路分别监测和计算。
  
* 车辆  
  系统对车辆进行分类，按车队校准参数来评估排放。
  
* 模型  
  排放模型包含一些列参数，以及参数的有效使用场景。

## t_road 表

    create table t_road(
        road_id     varchar(20) not null,
        name        varchar(20),
        description varchar(200),

        district    varchar(20),
        area        varchar(20),
        road_len    double not null,
        
        created_at  datetime    not null    default now(),
        created_by  varchar(20),
        update_note varchar(200),
        updated_at  datetime    not null    default now(),
        updated_by  varchar(20),
        
        primary key(road_id)
    );

## t_fleet 表

    create table t_fleet(
        fleet_id    varchar(20) not null,
        name        varchar(20),
        description varchar(200),
        avatar      varchar(200),
        
        fleet_pid   varchar(20),

        created_at  datetime    not null    default now(),
        created_by  varchar(20),
        update_note varchar(200),
        updated_at  datetime    not null    default now(),
        updated_by  varchar(20),
        
        primary key(fleet_id)
    );

    create table t_fleet_closure(
        fleet_pid   varchar(20) not null,
        fleet_id    varchar(20) not null,
        distance    int not null,
        
        primary key(fleet_pid, fleet_id)
    );

## t_model 表

    create table t_model(
        model_id    varchar(20) not null,
        name        varchar(20) not null,
        description varchar(200),
        avatar      varchar(200),

        created_at  datetime    not null    default now(),
        created_by  varchar(20),
        update_note varchar(200),
        updated_at  datetime    not null    default now(),
        updated_by  varchar(20),
        
        primary key(model_id)
    );

## t_model_param 表

    create table t_model_param(
        model_id    varchar(20) not null,
        fleet_id    varchar(20) not null,
        
        speed_min   double,
        speed_max   double,
        
        a           double      not null,
        b           double      not null,
        c           double      not null,
        d           double      not null,
        e           double      not null,
        f           double      not null,
        g           double      not null,
        k           double      not null,
        
        created_at  datetime    not null    default now(),
        created_by  varchar(20),
        update_note varchar(200),
        updated_at  datetime    not null    default now(),
        updated_by  varchar(20),
        
        primary key(model_id, fleet_id)
    );

## t_fleet_ratio 表

    create table t_fleet_ratio(
        road_id     varchar(20) not null,
        fleet_id    varchar(20) not null,
        
        fleet_ratio double      not null,
        
        ratio_begin time    not null        default '00:00:00',
        ratio_end   time    not null        default '11:59:59',

        effect_at   datetime    not null    default '2000-01-01 00:00:00',
        expire_at   datetime    not null    default '2099-12-31 11:59:59',
        
        created_at  datetime    not null    default now(),
        created_by  varchar(20),
        update_note varchar(200),
        updated_at  datetime    not null    default now(),
        updated_by  varchar(20),
        
        primary key(road_id, fleet_id)
    );

## t_road_now 表

t_road_now 表存储最新的道路采集数据和排放评估结果数据。

    create table t_road_now(
        road_id     varchar(20) not null,
        
        speed       double,
        flow        double,
        emission    double,
        
        created_at  datetime    not null    default now(),
        created_by  varchar(20),
        update_note varchar(200),
        updated_at  datetime    not null    default now(),
        updated_by  varchar(20),

        primary key(road_id)
    );

## t_road_history 表

t_road_history 表存储道路采集数据和排放评估结果历史数据。

    create table t_road_now(
        road_id     varchar(20) not null,
        
        speed       double,
        flow        double,
        emission    double,
        
        created_at  datetime    not null,
        created_by  varchar(20)
    );

## t_road_emission 表

t_road_emission 表存储道路各种车辆排放评估历史数据。

    create table t_road_emission(
        emission_id bigint      not null auto_increment,
        road_id     varchar(20) not null,
        fleet_id    varchar(20) not null,
        
        emission    double      not null,
        
        created_at  datetime    not null    default now(),
        created_by  varchar(20),

        primary key(emission_id)
    );
