CREATE TABLE if not exists `ads__region_app_class_area_stat_d`
(
    `period_type_code`        varchar(10) COMMENT '统计周期编码 10：昨日；21：过去7日；22：过去14日；31：过去30日；99：至今',
    `parent_id`               bigint COMMENT '统计父级节点地区id，全国时为0',
    `region_id`               bigint COMMENT '统计地区id',
    `section_type_code`       varchar(128) COMMENT '学段编码',
    `province_id`             bigint COMMENT '地区-省级-编码 (0:全国  -1: 直属学校)',
    `city_id`                 bigint COMMENT '地区-市级-编码 (0:全市  -1: 直属学校)',
    `area_id`                 bigint COMMENT '地区-区县级-编码',
    `area_type`               varchar(128) COMMENT '统计地域类型,all:全国；province:省；city：市；area：区县',
    `stat_date`               date NOT NULL COMMENT '统计日期：天（yyyy-MM-dd）',
    `stat_time`               varchar(50) COMMENT '统计时间',
    `period_start_date`       varchar(20) COMMENT '统计周期开始日期',
    `period_end_date`         varchar(20) COMMENT '统计周期结束日期',
    `period_type_text`        varchar(20) COMMENT '统计周期',
    `province_name`           varchar(128) COMMENT '地区-省级-名称 (全国  直属学校 ....)',
    `city_name`               varchar(128) COMMENT '地区-市级-名称 (全市  直属学校 ....)',
    `area_name`               varchar(128) COMMENT '地区-区县级-名称',
    `is_leaf`                 int COMMENT '是否叶子节点',
    `section_type_name`       varchar(128) COMMENT '学段名称（小学、初中、高中）',
    `class_num`                             bigint COMMENT '班级个数',
    `regular_class_num`                     bigint COMMENT '普通班个数',
    `administrative_class_num`              bigint COMMENT '行政班个数',
    `regular_class_cover_school_num`        int COMMENT '普通班覆盖学校数',
    `administrative_class_cover_school_num` bigint COMMENT '行政班覆盖学校数'
) ENGINE=OLAP
UNIQUE  KEY(`period_type_code`,`parent_id`,`region_id`,`section_type_code`,`province_id`,`city_id`,`area_id`,`area_type`,`stat_date`)
COMMENT 'ADS-区域看板-应用分析-区域-班级分析'
PARTITION BY RANGE(`stat_date`)()
DISTRIBUTED BY HASH(`period_type_code`,`parent_id`,`region_id`,`section_type_code`) BUCKETS 10
PROPERTIES (
"replication_allocation" = "tag.location.default: 3",
"in_memory" = "false",
"storage_format" = "V2"
);
ALTER TABLE ads__region_app_class_area_stat_d
    ADD COLUMNS (
        `class_rank` varchar(50) COMMENT '班级数量同级排名',
        `administrative_class_rank` varchar(50) COMMENT '行政班级数量同级排名',
        `administrative_class_cover_rate` DECIMAL(10, 6) COMMENT '行政班级覆盖率',
        `administrative_class_cover_rate_rank` varchar(50) COMMENT '行政班级覆盖率同级排名',
        `regular_class_rank` varchar(50) COMMENT '普通班级数量同级排名',
        `administrative_class_cover_school_rank` varchar(50) COMMENT '行政班级覆盖学校数同级排名',
        `administrative_class_cover_school_rate` DECIMAL(10, 6) COMMENT '行政班级覆盖学校率',
        `administrative_class_cover_school_rate_rank` varchar(50) COMMENT '行政班级覆盖学校率同级排名',
        `regular_class_cover_school_rank` varchar(50) COMMENT '普通班级覆盖学校数同级排名',
        `regular_class_cover_school_rate` DECIMAL(10, 6) COMMENT '普通班级覆盖学校率',
        `regular_class_cover_school_rate_rank` varchar(50) COMMENT '普通班级覆盖学校率同级排名'
        );

SELECT period_type_code,parent_id,region_id,section_type_code,province_id,city_id,area_id,area_type,stat_date,stat_time,period_start_date,period_end_date,period_type_text,province_name,city_name,area_name,is_leaf,section_type_name,class_num,regular_class_num,administrative_class_num,regular_class_cover_school_num,administrative_class_cover_school_num,class_rank,administrative_class_rank,administrative_class_cover_rate,administrative_class_cover_rate_rank,regular_class_rank,administrative_class_cover_school_rank,administrative_class_cover_school_rate,administrative_class_cover_school_rate_rank,regular_class_cover_school_rank,regular_class_cover_school_rate,regular_class_cover_school_rate_rank
FROM ads__region_app_class_area_stat_d