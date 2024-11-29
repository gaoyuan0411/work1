-- 1 区域画像切换qt，数据
-- 2 阳光学校 活动分析
-- 3 门户专题访问
-- 4 中小学-积分看板支持区域
-- --
-- 5 区域看板应用分析 增加同级排名
-- 20.
-- 21.
--2024-09-10
-- 1 阳光学校 活动分析
-- 数据
--任务流：运营分析-教师积分
ALTER table nddc.ads__incentive__teacher__user_period_stat__d RENAME  to nddc.ads__incentive__teacher__user_period_stat__d_bak;
create table nddc.ads__incentive__teacher__user_period_stat__d like nddc_uat.ads__incentive__teacher__user_period_stat__d;
INSERT OVERWRITE  table  nddc.ads__incentive__teacher__user_period_stat__d PARTITION (pc,p_id)
select * from nddc_uat.ads__incentive__teacher__user_period_stat__d;
ALTER table nddc.ads__incentive__teacher__overview_period_stat__d RENAME  to nddc.ads__incentive__teacher__overview_period_stat__d_bak;
create table nddc.ads__incentive__teacher__overview_period_stat__d like nddc_uat.ads__incentive__teacher__overview_period_stat__d;
INSERT OVERWRITE  table  nddc.ads__incentive__teacher__overview_period_stat__d PARTITION (pc,p_id)
select * from nddc_uat.ads__incentive__teacher__overview_period_stat__d;
--接口
新增
v1/incentive/teacher/max_uesr
v1/incentive/teacher/school_user
修改
v1/incentive/teacher/uesr_rank
v1/incentive/teacher/overview
v1/incentive/teacher/type_analysis
v1/incentive/teacher/trend_analysis
v1/incentive/teacher/distribute

-- 2 门户专题访问
-- 接口：screen/v2/smart/special
product_id,product_name,period_code,parent_id,region_id,region_name,province_id,province_name,city_id,city_name,area_id,area_name,school_id,school_name,area_type,region_level,is_leaf,verify_status,verify_status_name,parent_type,type_code,type_name,type_code_1,type_name_1,type_code_2,type_name_2,type_level,type_is_leaf,incentive_number,incentive_score,incentive_avg_score,max_incentive_score,stat_time,stat_date
CREATE TABLE `dws__tala__open_live_visit_event_stat__da__full`
(
    `stat_date`               DATE NOT NULL COMMENT '数据统计日期',
    `period_type_code`        INT NULL COMMENT '统计周期编码',
    `identity`                VARCHAR(50) NULL COMMENT '浏览时身份：all-所有身份',
    `live_id`                 VARCHAR(100) NULL COMMENT '直播ID',
    `country_name`            VARCHAR(100) NULL COMMENT '所属国家名称',
    `replay_flag`             VARCHAR(50) NULL COMMENT '回放标识：play-直播；replay-回放',
    `province_id`             BIGINT NULL COMMENT '所属省id',
    `city_id`                 BIGINT NULL COMMENT '所属市id',
    `area_id`                 BIGINT NULL COMMENT '所属区id',
    `school_id`               BIGINT NULL COMMENT '所属学校编码: 所有为0，本期不统计',
    `product_code`            VARCHAR(50) NULL COMMENT '产品编码',
    `product_platform`        VARCHAR(50) NULL COMMENT '产品所属端,按埋点的app_key区分，不区分web和h5: all-所有',
    `platform`                VARCHAR(100) NULL COMMENT '(user_agent)平台: all-所有',
    `period_start_date`       VARCHAR(100) NULL COMMENT '统计周期开始日期',
    `period_end_date`         VARCHAR(100) NULL COMMENT '统计周期结束日期',
    `period_type_text`        VARCHAR(100) NULL COMMENT '统计周期',
    `live_name`               VARCHAR(500) NULL COMMENT '直播名称',
    `province_name`           VARCHAR(100) NULL COMMENT '所属省名称',
    `city_name`               VARCHAR(100) NULL COMMENT '所属市名称',
    `area_name`               VARCHAR(100) NULL COMMENT '所属区名称',
    `school_name`             VARCHAR(300) NULL COMMENT '所属学校名称',
    `product_id`              VARCHAR(100) NULL COMMENT '产品标识',
    `begin_date`              VARCHAR(50) NULL COMMENT '直播开始日期 使用begin_time取日期',
    `replay_begin_time`       VARCHAR(50) NULL COMMENT '直播回放设置时间',
    `visit_count`             BIGINT NULL COMMENT '浏览次数',
    `user_visit_count`        BIGINT NULL COMMENT '登录用户浏览次数',
    `visit_device_count`      BIGINT NULL COMMENT '浏览设备数',
    `visit_user_count`        BIGINT NULL COMMENT '浏览用户数',
    `play_count`              BIGINT NULL COMMENT '播放/回放次数',
    `user_play_count`         BIGINT NULL COMMENT '登录用户播放/回放次数',
    `play_device_count`       BIGINT NULL COMMENT '播放/回放设备数',
    `play_user_count`         BIGINT NULL COMMENT '播放/回放用户数',
    `event_play_count`        BIGINT NULL COMMENT '实际事件播放/回放次数（回放标识与事件标识对应，不处理直播结束与回放开始前的数据）',
    `event_user_play_count`   BIGINT NULL COMMENT '实际事件登录用户播放/回放次数（回放标识与事件标识对应，不处理直播结束与回放开始前的数据）',
    `event_play_device_count` BIGINT NULL COMMENT '实际事件播放/回放设备数（回放标识与事件标识对应，不处理直播结束与回放开始前的数据）',
    `event_play_user_count`   BIGINT NULL COMMENT '实际事件播放/回放用户数（回放标识与事件标识对应，不处理直播结束与回放开始前的数据）',
    `stat_time`               VARCHAR(50) NULL COMMENT '统计处理时间'
) ENGINE=OLAP UNIQUE KEY(`stat_date`, `period_type_code`, `identity`, `live_id`, `country_name`, `replay_flag`, `province_id`, `city_id`, `area_id`, `school_id`, `product_code`, `product_platform`, `platform`) COMMENT '公开直播-直播播放浏览周期统计表'
    PARTITION BY RANGE(`stat_date`) ()

