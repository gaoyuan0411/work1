DROP TABLE IF EXISTS ads__region_app_class_area_stat_d;
CREATE TABLE IF NOT EXISTS ads__region_app_class_area_stat_d
(
    `stat_time`                             string COMMENT '统计时间',
    `stat_date`                             string COMMENT '统计日期：天（yyyy-MM-dd）',
    `period_start_date`                     string COMMENT '统计周期开始日期',
    `period_end_date`                       string COMMENT '统计周期结束日期',
    `period_type_code`                      string COMMENT '统计周期编码 10：昨日；21：过去7日；22：过去14日；31：过去30日；99：至今',
    `period_type_text`                      string COMMENT '统计周期',
    `parent_id`                             bigint COMMENT '统计父级节点地区id，全国时为0',
    `region_id`                             bigint COMMENT '统计地区id',
    `province_id`                           bigint COMMENT '地区-省级-编码 (0:全国  -1: 直属学校)',
    `province_name`                         string COMMENT '地区-省级-名称 (全国  直属学校 ....)',
    `city_id`                               bigint COMMENT '地区-市级-编码 (0:全市  -1: 直属学校)',
    `city_name`                             string COMMENT '地区-市级-名称 (全市  直属学校 ....)',
    `area_id`                               bigint COMMENT '地区-区县级-编码',
    `area_name`                             string COMMENT '地区-区县级-名称',
    `area_type`                             string COMMENT '统计地域类型,all:全国；province:省；city：市；area：区县',
    `is_leaf`                               int COMMENT '是否叶子节点',
    `section_type_code`                     string COMMENT '学段编码（ALL-全部、$ON020000-小学、$ON030000-初中、$ON040000-高中、OTHER-其他）',
    `section_type_name`                     string COMMENT '学段名称（全部、小学、初中、高中）',
    `class_num`                             bigint COMMENT '班级个数',
    `regular_class_num`                     bigint COMMENT '普通班个数',
    `administrative_class_num`              bigint COMMENT '行政班个数',
    `regular_class_cover_school_num`        int COMMENT '普通班覆盖学校数',
    `administrative_class_cover_school_num` bigint COMMENT '行政班覆盖学校数'
) COMMENT 'ADS-区域看板-应用分析-区域-班级分析' PARTITIONED By (
    `dt` string comment '按天(yyyy-MM-dd)'
    ) ROW FORMAT DELIMITED NULL DEFINED AS '';
-- 2024-08-20 新增字段
ALTER TABLE ads__region_app_class_area_stat_d
    ADD COLUMNS (
        `class_rank` STRING COMMENT '班级数量同级排名',
        `administrative_class_rank` STRING COMMENT '行政班级数量同级排名',
        `administrative_class_cover_rate` DECIMAL(10, 6) COMMENT '行政班级覆盖率',
        `administrative_class_cover_rate_rank` STRING COMMENT '行政班级覆盖率同级排名',
        `regular_class_rank` STRING COMMENT '普通班级数量同级排名',
        `administrative_class_cover_school_rank` STRING COMMENT '行政班级覆盖学校数同级排名',
        `administrative_class_cover_school_rate` DECIMAL(10, 6) COMMENT '行政班级覆盖学校率',
        `administrative_class_cover_school_rate_rank` STRING COMMENT '行政班级覆盖学校率同级排名',
        `regular_class_cover_school_rank` STRING COMMENT '普通班级覆盖学校数同级排名',
        `regular_class_cover_school_rate` DECIMAL(10, 6) COMMENT '普通班级覆盖学校率',
        `regular_class_cover_school_rate_rank` STRING COMMENT '普通班级覆盖学校率同级排名'
        );