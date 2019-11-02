
---
title: "数据库"
weight: 100
description: >
  系统管理平台的数据库表设计。
---

系统涉及以下几种实体:

* 道路  
  系统对道路进行分段，对各段道路分别监测和计算。
  
* 车辆  
  系统对车辆进行分类，按车队校准参数来评估排放。
  
* 模型  
  排放模型包含一些列参数，以及参数的有效使用场景。


# t_road 表

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

# t_fleet 表

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

# t_model 表

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

# t_model_param 表

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

# t_fleet_ratio 表

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

# t_road_now 表

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

# t_road_history 表

t_road_history 表存储道路采集数据和排放评估结果历史数据。

    create table t_road_now(
        road_id     varchar(20) not null,
        
        speed       double,
        flow        double,
        emission    double,
        
        created_at  datetime    not null,
        created_by  varchar(20)
    );


## 参考资料

完整设计文档参见 [design.sql](../res/design.sql)。