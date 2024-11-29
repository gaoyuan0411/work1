DROP TABLE IF EXISTS ads__region_app_activity_area__overview_stat_d;
CREATE TABLE IF NOT EXISTS ads__region_app_activity_area__overview_stat_d
(
    `stat_time`               STRING COMMENT '统计时间',
    `stat_date`               STRING COMMENT '统计日期：天（yyyy-MM-dd）',
    `period_code`             STRING COMMENT '周期代码,例：ALL：至今；2023：2023年，202311：2023年11月，2023-2024S1：2023-2024学年秋季学期，',
    `period_start_date`       STRING COMMENT '统计周期开始日期',
    `period_end_date`         STRING COMMENT '统计周期结束日期',
    `period_type_code`        STRING COMMENT '统计周期编码 10：昨日；21：过去7日；22：过去14日；31：过去30日；99：至今',
    `period_type_text`        STRING COMMENT '统计周期',
    `parent_id`               BIGINT COMMENT '统计父级节点地区id，全国时为0',
    `region_id`               BIGINT COMMENT '统计地区id',
    `region_name`             BIGINT COMMENT '统计地区名称',
    `province_id`             BIGINT COMMENT '地区-省级-编码 (0:全国  -1: 直属学校)',
    `province_name`           STRING COMMENT '地区-省级-名称 (全国  直属学校 ....)',
    `city_id`                 BIGINT COMMENT '地区-市级-编码 (0:全市  -1: 直属学校)',
    `city_name`               STRING COMMENT '地区-市级-名称 (全市  直属学校 ....)',
    `area_id`                 BIGINT COMMENT '地区-区县级-编码',
    `area_name`               STRING COMMENT '地区-区县级-名称',
    `area_type`               STRING COMMENT '统计地域类型,all:全国；province:省；city：市；area：区县',
    `activity_type`           STRING COMMENT '活动类型',
    `activity_type_name`      STRING COMMENT '活动名称',
    `section_type_code`       STRING COMMENT '学段编码（ALL-全部、$ON020000-小学、$ON030000-初中、$ON040000-高中、OTHER-其他）',
    `section_type_name`       STRING COMMENT '学段名称（全部、小学、初中、高中）',
    `publish_num`             BIGINT COMMENT '活动发布数',
    `publish_num_rank`        STRING COMMENT '活动发布数同级排名',
    `school_publish_avg`      DECIMAL(10, 6) COMMENT '学校平均发布活动数',
    `school_publish_avg_rank` STRING COMMENT '学校平均发布活动数同级排名'
) COMMENT 'ADS-区域看板-应用分析-区域-活动概览分析' PARTITIONED BY (
    `dt` STRING COMMENT '按天(yyyy-MM-dd)'
    ) ROW FORMAT DELIMITED NULL DEFINED AS '';
