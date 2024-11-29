DROP TABLE IF EXISTS ads__region_app_activity_area__overview_stat_d;
CREATE TABLE IF NOT EXISTS ads__region_app_activity_area__overview_stat_d
(
    `period_code`             VARCHAR(20) COMMENT '周期代码,例：ALL：至今；2023：2023年，202311：2023年11月，2023-2024S1：2023-2024学年秋季学期，',
    `period_end_date`         VARCHAR(20) COMMENT '统计周期结束日期',
    `period_type_code`        VARCHAR(20) COMMENT '统计周期编码 10：昨日；21：过去7日；22：过去14日；31：过去30日；99：至今',
    `parent_id`               BIGINT(20) COMMENT '统计父级节点地区id，全国时为0',
    `region_id`               BIGINT(20) COMMENT '统计地区id',
    `activity_type`           VARCHAR(100) COMMENT '活动类型',
    `section_type_code`       VARCHAR(100) COMMENT '学段编码（ALL-全部、$ON020000-小学、$ON030000-初中、$ON040000-高中、OTHER-其他）',
    `province_id`             BIGINT(20) COMMENT '地区-省级-编码 (0:全国  -1: 直属学校)',
    `city_id`                 BIGINT(20) COMMENT '地区-市级-编码 (0:全市  -1: 直属学校)',
    `area_id`                 BIGINT(20) COMMENT '地区-区县级-编码',

    `stat_time`               VARCHAR(50) COMMENT '统计时间',
    `stat_date`               VARCHAR(20) COMMENT '统计日期：天（yyyy-MM-dd）',
    `period_start_date`       VARCHAR(20) COMMENT '统计周期开始日期',
    `period_type_text`        VARCHAR(50) COMMENT '统计周期',
    `region_name`             VARCHAR(100) COMMENT '统计地区名称',
    `province_name`           VARCHAR(100) COMMENT '地区-省级-名称 (全国  直属学校 ....)',
    `city_name`               VARCHAR(100) COMMENT '地区-市级-名称 (全市  直属学校 ....)',
    `area_name`               VARCHAR(100) COMMENT '地区-区县级-名称',
    `area_type`               VARCHAR(100) COMMENT '统计地域类型,all:全国；province:省；city：市；area：区县',
    `activity_type_name`      VARCHAR(100) COMMENT '活动名称',
    `section_type_name`       VARCHAR(100) COMMENT '学段名称（全部、小学、初中、高中）',
    `publish_num`             BIGINT(20) COMMENT '活动发布数',
    `publish_num_rank`        VARCHAR(50) COMMENT '活动发布数同级排名',
    `school_publish_avg`      DECIMAL(10, 6) COMMENT '学校平均发布活动数',
    `school_publish_avg_rank` VARCHAR(50) COMMENT '学校平均发布活动数同级排名',
    index idx_activity(activity_type) USING bitmap COMMENT '活动索引',
    index idx_parent(parent_id) USING bitmap COMMENT '父级地区索引',
    index idx_region(region_id) USING bitmap COMMENT '地区索引',
    index idx_province(province_id) USING bitmap COMMENT '省份索引',
    index idx_city(city_id) USING bitmap COMMENT '市索引',
    index idx_area(area_id) USING bitmap COMMENT '县索引'
) ENGINE=OLAP
UNIQUE  KEY(`period_code`,`period_end_date`,`period_type_code`,`parent_id`,`region_id`,`activity_type`,`section_type_code`,`province_id`,`city_id`,`area_id`)
COMMENT 'ADS-区域看板-应用分析-区域-活动概览分析'
PARTITION BY
LIST (`period_code`)()
    DISTRIBUTED BY HASH(region_id) BUCKETS 20
    PROPERTIES (
    "replication_allocation" = "tag.location.default: 3",
    "in_memory" = "false",
    "storage_format" = "V2"
    );
SELECT period_code,period_end_date,period_type_code,parent_id,region_id,activity_type,section_type_code,province_id,city_id,area_id,stat_time,stat_date,period_start_date,period_type_text,region_name,province_name,city_name,area_name,area_type,is_leaf,activity_type_name,section_type_name,publish_num,publish_num_rank,school_publish_avg,school_publish_avg_rank
FROM ads__region_app_activity_area__overview_stat_d