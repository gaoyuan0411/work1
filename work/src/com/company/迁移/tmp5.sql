CREATE TABLE IF NOT EXISTS ads__hinge__area_base_point__error_log_stat__d_tmp
(
    `dt`                     DATE COMMENT '分区时间',
    `period_type_code`       INT COMMENT '统计周期编码，10：昨日；21：过去7日；22：过去14日；31：过去30日；99：至今；',
    `period_type_text`       VARCHAR(100) COMMENT '统计周期，昨日；过去7日；过去14日；过去30日；至今；',
    `period_start_date`      VARCHAR(100) COMMENT '统计周期开始日期：天（yyyy-MM-dd）',
    `period_end_date`        VARCHAR(100) COMMENT '统计周期结束日期：天（yyyy-MM-dd）',
    `client_id`              VARCHAR(100) COMMENT '所属应用id(平台id)',
    `client_name`            VARCHAR(100) COMMENT '所属应用名称(平台名称)',
    `event`                  VARCHAR(100) COMMENT '事件编码',
    `detection_mode_code`    VARCHAR(100) COMMENT '检测方式编码',
    `detection_mode_name`    VARCHAR(100) COMMENT '检测方式名称：必填参数非空校验、埋点UUID唯一性校验、编码ID类非中文校验、枚举校验',

    `last_detection_time`    VARCHAR(100) COMMENT '最后检测时间(精确到分钟)',
    `detection_total_num`    BIGINT(20) COMMENT '检测总次数',
    `detection_pass_num`     BIGINT(20) COMMENT '检测通过次数',
    `detection_not_pass_num` BIGINT(20) COMMENT '检测不通过次数',
    `detection_total_ratio`  DECIMAL(20, 9) COMMENT '检测通过率',
    `stat_time`              VARCHAR(100) COMMENT '数据生成时间',
    `stat_date`              VARCHAR(100) COMMENT '数据统计日期'

) ENGINE=OLAP
UNIQUE KEY(`dt`,period_type_code,period_type_text,period_start_date,period_end_date,client_id,client_name,event,detection_mode_code,detection_mode_name)
COMMENT 'ADS-枢纽-数据埋点质量的错误日志-全量'
PARTITION BY RANGE(`dt`)()
DISTRIBUTED BY HASH(`dt`,`period_type_code`,`period_end_date`) BUCKETS 10
PROPERTIES (
"replication_allocation" = "tag.location.default: 3",
"dynamic_partition.enable" = "true",
"dynamic_partition.time_unit" = "DAY",
"dynamic_partition.time_zone" = "Asia/Shanghai",
"dynamic_partition.end" = "2",
"dynamic_partition.prefix" = "p",
"dynamic_partition.replication_allocation" = "tag.location.default: 3",
"dynamic_partition.buckets" = "10",
"dynamic_partition.create_history_partition" = "true",
"dynamic_partition.hot_partition_num" = "0",
"dynamic_partition.reserved_history_periods" = "NULL",
"dynamic_partition.history_partition_num" = "180",
"in_memory" = "false",
"storage_format" = "V2"
);
CREATE TABLE `ads__region_app_class_area_stat_d`
(
    `period_type_code`                            VARCHAR(10) NULL COMMENT '统计周期编码 10：昨日；21：过去7日；22：过去14日；31：过去30日；99：至今',
    `parent_id`                                   BIGINT NULL COMMENT '统计父级节点地区id，全国时为0',
    `region_id`                                   BIGINT NULL COMMENT '统计地区id',
    `section_type_code`                           VARCHAR(128) NULL COMMENT '学段编码',
    `province_id`                                 BIGINT NULL COMMENT '地区-省级-编码 (0:全国 -1: 直属学校)',
    `city_id`                                     BIGINT NULL COMMENT '地区-市级-编码 (0:全市 -1: 直属学校)',
    `area_id`                                     BIGINT NULL COMMENT '地区-区县级-编码',
    `area_type`                                   VARCHAR(128) NULL COMMENT '统计地域类型,all:全国；province:省；city：市；area：区县',
    `stat_date`                                   DATE NOT NULL COMMENT '统计日期：天（yyyy-MM-dd）',
    `stat_time`                                   VARCHAR(50) NULL COMMENT '统计时间',
    `period_start_date`                           VARCHAR(20) NULL COMMENT '统计周期开始日期',
    `period_end_date`                             VARCHAR(20) NULL COMMENT '统计周期结束日期',
    `period_type_text`                            VARCHAR(20) NULL COMMENT '统计周期',
    `province_name`                               VARCHAR(128) NULL COMMENT '地区-省级-名称 (全国 直属学校 ....)',
    `city_name`                                   VARCHAR(128) NULL COMMENT '地区-市级-名称 (全市 直属学校 ....)',
    `area_name`                                   VARCHAR(128) NULL COMMENT '地区-区县级-名称',
    `is_leaf`                                     INT NULL COMMENT '是否叶子节点',
    `section_type_name`                           VARCHAR(128) NULL COMMENT '学段名称（小学、初中、高中）',
    `class_num`                                   BIGINT NULL COMMENT '班级个数',
    `regular_class_num`                           BIGINT NULL COMMENT '普通班个数',
    `administrative_class_num`                    BIGINT NULL COMMENT '行政班个数',
    `regular_class_cover_school_num`              INT NULL COMMENT '普通班覆盖学校数',
    `administrative_class_cover_school_num`       BIGINT NULL COMMENT '行政班覆盖学校数',
    `class_rank`                                  VARCHAR(50) NULL COMMENT '班级数量同级排名',
    `administrative_class_rank`                   VARCHAR(50) NULL COMMENT '行政班级数量同级排名',
    `administrative_class_cover_rate`             DECIMAL(10, 6) NULL COMMENT '行政班级覆盖率',
    `administrative_class_cover_rate_rank`        VARCHAR(50) NULL COMMENT '行政班级覆盖率同级排名',
    `regular_class_rank`                          VARCHAR(50) NULL COMMENT '普通班级数量同级排名',
    `administrative_class_cover_school_rank`      VARCHAR(50) NULL COMMENT '行政班级覆盖学校数同级排名',
    `administrative_class_cover_school_rate`      DECIMAL(10, 6) NULL COMMENT '行政班级覆盖学校率',
    `administrative_class_cover_school_rate_rank` VARCHAR(50) NULL COMMENT '行政班级覆盖学校率同级排名',
    `regular_class_cover_school_rank`             VARCHAR(50) NULL COMMENT '普通班级覆盖学校数同级排名',
    `regular_class_cover_school_rate`             DECIMAL(10, 6) NULL COMMENT '普通班级覆盖学校率',
    `regular_class_cover_school_rate_rank`        VARCHAR(50) NULL COMMENT '普通班级覆盖学校率同级排名'
) ENGINE=OLAP UNIQUE KEY(`period_type_code`, `parent_id`, `region_id`, `section_type_code`, `province_id`, `city_id`, `area_id`, `area_type`, `stat_date`) COMMENT 'ADS-区域看板-应用分析-区域-班级分析' PARTITION BY LIST(`stat_date`) () DISTRIBUTED BY HASH(`period_type_code`, `parent_id`, `region_id`, `section_type_code`) BUCKETS 10 PROPERTIES ( "replication_allocation" = "tag.location.default: 3", "min_load_replica_num" = "-1", "is_being_synced" = "false", "storage_medium" = "hdd", "storage_format" = "V2", "inverted_index_storage_format" = "V1", "enable_unique_key_merge_on_write" = "true", "light_schema_change" = "true", "disable_auto_compaction" = "false", "enable_single_replica_compaction" = "false", "group_commit_interval_ms" = "10000", "group_commit_data_bytes" = "134217728" );
