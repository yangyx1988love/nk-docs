
-- database nk_emission
use mysql;
drop database if exists nk_emission;
create database nk_emission;
use nk_emission;

-- create user and grant priviledges
drop user if exists 'nk'@'localhost';
create user 'nk'@'localhost' identified with 'mysql_native_password' by 'nk';
grant all on nk_emission.* to 'nk'@'localhost';

-- table t_road
drop table if exists t_road;
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


-- table t_fleet
drop table if exists t_fleet;
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


-- table t_fleet_closure
drop table if exists t_fleet_closure;
create table t_fleet_closure(
    fleet_pid   varchar(20) not null,
    fleet_id    varchar(20) not null,
    distance    int not null,
    
    primary key(fleet_pid, fleet_id)
);

insert into t_fleet(fleet_id, name, description, avatar) values('ROOT', '全部车辆', '全部车辆', '/images/model/avatar.jpg');

-- table t_model
drop table if exists t_model;
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

insert into t_model(model_id, name, description, avatar)
values('emission-model-01', '排放测算模型', '为研究城市机动车污染特征，实现污染物排放的最优控制，我们提出了研究排放控制目标的数学优化模型。', '/images/model/emission.jpg');


-- table t_param
drop table if exists t_model_param;
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


-- table t_fleet_ratio
drop table if exists t_fleet_ratio;
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


-- table t_road_now
drop table if exists t_road_now;
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


-- table t_road_history
drop table if exists t_road_history;
create table t_road_history(
    road_id     varchar(20) not null,
    
    speed       double,
    flow        double,
    emission    double,
    
    created_at  datetime    not null    default now(),
    created_by  varchar(20)
);


-- table t_road_emission
drop table if exists t_road_emission;
create table t_road_emission(
    emission_id bigint      not null auto_increment,
    road_id     varchar(20) not null,
    fleet_id    varchar(20) not null,
    
    emission    double      not null,
    
    created_at  datetime    not null    default now(),
    created_by  varchar(20),

    primary key(emission_id)
);


show tables;

-- 新建存储过程用于构造 t_fleet_closure 内容
drop procedure if exists populate_fleet_closure;
DELIMITER //

CREATE PROCEDURE populate_fleet_closure()
BEGIN
  DECLARE distance int;
  TRUNCATE TABLE t_fleet_closure;
  SET distance = 0;
  -- seed closure with self-pairs (distance 0)
  INSERT INTO t_fleet_closure (fleet_pid, fleet_id, distance)
    SELECT fleet_id, fleet_id, distance
      FROM t_fleet;

  -- for each pair (root, leaf) in the closure,
  -- add (root, leaf->child) from the base table
  REPEAT
    SET distance = distance + 1;
    INSERT INTO t_fleet_closure (fleet_pid, fleet_id, distance)
      SELECT t_fleet_closure.fleet_pid, t_fleet.fleet_id, distance
        FROM t_fleet_closure, t_fleet
          WHERE t_fleet_closure.fleet_id = t_fleet.fleet_pid
          AND t_fleet_closure.distance = distance - 1;
  UNTIL (ROW_COUNT() = 0)
  END REPEAT;
END //

DELIMITER ;

-- 构造 t_fleet_closure 表内容

delete from t_fleet_closure;
call populate_fleet_closure;
select count(*) from t_fleet_closure;


-- 新建存储过程用于查询 t_fleet_ratio
drop procedure if exists query_fleet_ratio;
DELIMITER //

CREATE PROCEDURE query_fleet_ratio(IN fleet_pid VARCHAR(20), IN district VARCHAR(20), IN area VARCHAR(20), IN name VARCHAR(20), IN offset INT, IN size INT)
BEGIN
  
  SELECT GROUP_CONCAT(DISTINCT CONCAT('MAX(IF(f.fleet_id = ''', f.fleet_id, ''', fr.fleet_ratio, 0)) AS ''', f.fleet_id, ''''))
  INTO @sql
  FROM t_fleet f
  WHERE f.fleet_pid = fleet_pid;

  SELECT CONCAT('SELECT r.district, r.area, r.road_id, r.name, 
  ', @sql, ' 
  FROM (SELECT * FROM t_road 
        WHERE district LIKE ''%', district, '%'' 
          AND area     LIKE ''%', area    , '%'' 
          AND name     LIKE ''%', name    , '%'' 
        ORDER BY road_id ASC 
        LIMIT ', offset, ', ', size, ') r
  CROSS JOIN t_fleet f
  LEFT JOIN t_fleet_ratio fr ON fr.road_id = r.road_id AND fr.fleet_id = f.fleet_id
  WHERE r.district LIKE ''%', district, '%''
    AND r.area     LIKE ''%', area    , '%'' 
    AND r.name     LIKE ''%', name    , '%'' 
    AND f.fleet_pid = ''', fleet_pid, '''
  GROUP BY r.road_id
  ORDER BY r.road_id ASC')
  INTO @sql;
  
  PREPARE stmt FROM @sql;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
  
END //

DELIMITER ;

