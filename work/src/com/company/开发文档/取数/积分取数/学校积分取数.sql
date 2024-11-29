--积分统计
-- 学校
-- 每个月都是1-至今的数据 取每月1号的数据
--表结构
DROP TABLE ads__incentive_school__d__test;
CREATE TABLE IF NOT EXISTS ads__incentive_school__d__test
(
    school_name               STRING COMMENT '学校名称',
    province_name             STRING COMMENT '省份名称',
    city_name                 STRING COMMENT '市名称',
    area_name                 STRING COMMENT '区县名称',
    school_educational_system STRING COMMENT '学校学制',
    stat_date                 STRING COMMENT '日期',
    integral_count            DECIMAL(20, 2) COMMENT '总积分',
    management_count          DECIMAL(20, 2) COMMENT '组织管理积分',
    effectiveness_count       DECIMAL(20, 2) COMMENT '管理成效积分'
) COMMENT '学校积分取数'
    PARTITIONED BY (
        `dt` STRING COMMENT '分区，统计时间'
        ) ROW FORMAT DELIMITED NULL DEFINED AS '';
--逻辑
WITH dim_date_period_tmp AS (
    SELECT date_code,
           period_code,
           period_start_date,
           period_end_date,
           period_type_code,
           period_type_text
    FROM nddc.dim__date_period t
    WHERE period_type_code = 50
      AND period_start_date <= '${biz_date}'
      AND period_end_date >= '${biz_date}'
      AND date_code <= '${biz_date}'
)
,incentive_data AS (
    SELECT t1.scope_type,
           t1.scope_id,
           t1.tenant_id                        AS tenant_id,
           new_balance,
           amount                              AS balance,
           rule_id,
           t7.product_id                       AS product_id,
           DATE_FORMAT(biz_time, 'yyyy-MM-dd') AS create_time
    FROM nddc.dwd__po__t_big_biz_incentive_detail__d__full t1
             INNER JOIN nddc.dim__md__product_app_tenant t7
                        ON t1.tenant_id = t7.tenant_id
                            AND t7.dt = '${full_biz_date}'
    WHERE t1.dt = '${biz_date}'
      AND t1.scope_id IS NOT NULL
      AND amount != 0          --增量0积分的可以不要
      AND point_type = 'POINT' --其实数据都是这个POINT
      AND t1.tenant_id = '416'
)
,incentive_area AS (
    SELECT CAST(t2.scope_id AS BIGINT)                                   AS scope_id,
           NVL(t2.balance, 0)                                            AS balance,
           NVL(DATE_FORMAT(t2.create_time, 'yyyy-MM-dd'), '${biz_date}') AS create_date,
           t5.value                                                      AS value_2,
           t5.name                                                       AS name_2
    FROM incentive_data t2
             INNER JOIN nddc.dim_dict t5
                        ON CAST(t2.rule_id AS INT) = t5.position
                            AND t5.dict_code IN ('school_integral_object_type_2')
                            AND t2.scope_type = 'SCHOOL'
)

,incentive_data_count AS (
    SELECT period_code,
           MAX(period_start_date)                                 AS period_start_date,
           MAX(period_end_date)                                   AS period_end_date,
           MAX(period_type_code)                                  AS period_type_code,
           MAX(period_type_text)                                  AS period_type_text,
           scope_id,
           ROUND(SUM(balance), 2)                                 AS integral_count,
           ROUND(SUM(if(value_2 = 'organizational_management',balance,0)),2) AS management_count,
           ROUND(SUM(if(value_2 = 'management_effectiveness',balance,0)),2) AS effectiveness_count
    FROM incentive_area t1
             INNER JOIN dim_date_period_tmp t2
                        ON t1.create_date= t2.date_code
    GROUP BY  period_code,scope_id

)
INSERT overwrite TABLE ads__incentive_school__d__test PARTITION (dt)
SELECT school_name,
       province_name,
       if(city_name is NULL ,'直属',city_name) as city_name,
       if(area_name is NULL ,'直属',area_name) as area_name,
       src_name      AS school_educational_system,
       '${biz_date}' AS stat_date,
       integral_count,
       management_count,
       effectiveness_count,
       '${biz_date}' AS dt
FROM incentive_data_count t
         INNER JOIN (SELECT school_id
                          , school_name
                          , school_section
                          , school_educational_system
                          , province_name
                          , city_name
                          , county_name AS area_name
                     FROM nddc.dim__whole_school
                     WHERE dt = '${full_biz_date}') t2 ON t.scope_id = t2.school_id
         INNER JOIN (SELECT src_code, src_name, target_code
                     FROM nddc.dim__dict_ref
                     WHERE target_code IN ('BASIC_EDU', 'ORG', 'VOCATIONAL_EDU')) t3
                    ON t2.school_section = t3.src_code AND t2.school_educational_system = t3.target_code

;
--取月数据
DROP TABLE ads__incentive_school__d__test1;
CREATE TABLE IF NOT EXISTS ads__incentive_school__d__test1
(
    school_name               STRING COMMENT '学校名称',
    province_name             STRING COMMENT '省份名称',
    city_name                 STRING COMMENT '市名称',
    area_name                 STRING COMMENT '区县名称',
    school_educational_system STRING COMMENT '学校学制',
    stat_date                 STRING COMMENT '日期',
    integral_count            DECIMAL(20, 2) COMMENT '总积分',
    management_count          DECIMAL(20, 2) COMMENT '组织管理积分',
    effectiveness_count       DECIMAL(20, 2) COMMENT '管理成效积分'
)
    ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
    STORED AS TEXTFILE
    LOCATION '/user/nddc_uat/ads__incentive_school__d__test1'
    TBLPROPERTIES (
        'serialization.null.format'=''
    );
INSERT OVERWRITE TABLE ads__incentive_school__d__test1
SELECT school_name
     , province_name
     , city_name
     , area_name
     , school_educational_system
     , stat_date
     , integral_count
     , management_count
     , effectiveness_count
FROM ads__incentive_school__d__test
WHERE dt != '2024-11-11'
ORDER BY province_name,city_name ,area_name,school_name,stat_date;
--创建外部表

;
--取至今数据
DROP TABLE ads__incentive_school__d__test2;
CREATE TABLE IF NOT EXISTS ads__incentive_school__d__test2
(
    school_name               STRING COMMENT '学校名称',
    province_name             STRING COMMENT '省份名称',
    city_name                 STRING COMMENT '市名称',
    area_name                 STRING COMMENT '区县名称',
    school_educational_system STRING COMMENT '学校学制',
    integral_count            DECIMAL(20, 2) COMMENT '总积分',
    management_count          DECIMAL(20, 2) COMMENT '组织管理积分',
    effectiveness_count       DECIMAL(20, 2) COMMENT '管理成效积分'
)
    ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
    STORED AS TEXTFILE
    LOCATION '/user/nddc_uat/ads__incentive_school__d__test2'
    TBLPROPERTIES (
        'serialization.null.format'=''
    );
INSERT OVERWRITE TABLE ads__incentive_school__d__test2
SELECT school_name
     , province_name
     , city_name
     , area_name
     , school_educational_system
     , integral_count
     , management_count
     , effectiveness_count
FROM ads__incentive_school__d__test
WHERE dt = '2024-11-11'
ORDER BY province_name,city_name ,area_name,school_name
--创建外部表

;





