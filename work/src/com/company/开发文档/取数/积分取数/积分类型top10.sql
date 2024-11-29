-- ==================================================================
-- 脚本名称： ads__incentive__teacher__overview_period_stat__d
-- 所属专题： 运营分析
-- 实现功能： 运营分析-运营服务-积分统计-教师积分（概览、地区排行榜、积分类型排行）
-- 统计周期： 日
-- 任务流名称：业务数据统计 --》 运营分析-教师积分 --》 积分概览-ads__incentive__teacher__overview_period_stat__d
-- 创建者：   1007103
-- 创建日期： 2024-06-21
--          依赖表：dwd__incentive__teacher__incentive_detail__d__full
--                  dwd__md__person_account__d__full
--                  dwd__md__teacher_verify__d__full
--                  dim__area
--                  dim_dict
--                  dim__school
--                  dim__md__product_app_tenant
-- 修改者:10017103
-- 修改日期：2024-08-01
-- 修改内容：增加学校层级增加直属节点，增加教师认证状态层架，增加区域最高分数指标
-- ==================================================================runtime=8m
DROP TABLE IF EXISTS ads__incentive_type_top_d_test;
CREATE TABLE IF NOT EXISTS ads__incentive_type_top_d_test
(
    type_name       STRING COMMENT '积分类型',
    rk              INT COMMENT '排名',
    user_id         BIGINT COMMENT '用户id',
    user_name       STRING COMMENT '用户名称',
    incentive_score DECIMAL(20, 2) COMMENT '积分值',
    province_name   STRING COMMENT '省名称',
    city_name       STRING COMMENT '市名称',
    area_name       STRING COMMENT '区县名称',
    school_name     STRING COMMENT '学校名称',
    level           TINYINT COMMENT '积分类型层级',
    stat_date       STRING COMMENT '计算日期'
) COMMENT '积分类型top10取数';
WITH user_data AS (
    SELECT DISTINCT ud.account_id
                  , NVL(ud.user_province_id, -2)                                                               AS province_id
                  , IF(ud.user_city_id IS NULL AND ud.school_id IS NOT NULL, -1, NVL(ud.user_city_id, -2))     AS city_id
                  , IF(ud.user_county_id IS NULL AND ud.school_id IS NOT NULL, -1, NVL(ud.user_county_id, -2)) AS area_id
                  , NVL(ud.school_id, -2)                                                                      AS school_id
                  , real_name
    FROM (SELECT account_id
               , IF(user_province_id IN (-1, -2), NULL, user_province_id) AS user_province_id
               , IF(user_city_id IN (-1, -2), NULL, user_city_id)         AS user_city_id
               , IF(user_county_id IN (-1, -2), NULL, user_county_id)     AS user_county_id
               , IF(school_id IN (-1, -2), NULL, school_id)               AS school_id
               , real_name
          FROM nddc.dwd__md__person_account__d__full
          WHERE dt = '${full_biz_date}'
            AND is_canceled = 0
            AND (is_teacher + is_manager + is_electric_teacher + is_academic_staff) > 0 --获取教师类型身份
            AND COALESCE(user_province_id, 0) <> 594035816785
         ) ud
)
   , incentive_data AS (
    SELECT CAST(user_id AS BIGINT)             AS user_id
         , CAST(new_balance AS DECIMAL(10, 6)) AS new_balance
         , CAST(rule_id AS INT)                AS rule_id
         , CAST(amount AS DECIMAL(10, 6))      AS amount
         , DATE_FORMAT(biz_time, 'yyyy-MM-dd') AS biz_time
         , rule_code
         , `version`                           AS period_code
         , tenant_id
    FROM nddc.dwd__incentive__teacher__incentive_detail__d__full
    WHERE dt = '${full_biz_date}'
      AND type = 'income'
      AND `version` = '${biz_year}'
      AND CAST(new_balance AS DECIMAL(10, 6)) > 0
)
   , incentive_data_tmp AS (
    SELECT user_id
         , rule_id
         , rule_code
         , period_code
         , tenant_id
         , SUM(amount) AS amount
    FROM incentive_data
    GROUP BY user_id, rule_id, rule_code, period_code, tenant_id
)
   --维度补充
   , incentive_data_tmp2 AS (
    SELECT idt.user_id
         , ud.real_name
         , ud.province_id
         , ud.city_id
         , ud.area_id
         , ud.school_id
         , COALESCE(dd.value, diam.code, 'other') AS type_1
         , COALESCE(dd.name, diam.name, '未知')     AS type_name_1
         , NVL(dd3.value, 'other')                AS type_2
         , NVL(dd3.name, '未知')                    AS type_name_2
         , idt.amount
    FROM incentive_data_tmp idt
             INNER JOIN user_data ud ON idt.user_id = ud.account_id
             INNER JOIN (SELECT *
                         FROM (
                                  SELECT *,
                                         ROW_NUMBER() OVER (PARTITION BY tenant_id ORDER BY app_priority DESC ) AS rk
                                  FROM nddc.dim__md__product_app_tenant
                                  WHERE dt = '${full_biz_date}'
                                    AND product_code = 'zxx') t1
                         WHERE rk = 1
    ) pt ON idt.tenant_id = pt.tenant_id
             LEFT JOIN (SELECT * FROM nddc.dim_dict WHERE dict_code = 'integral_object_type') dd ON idt.rule_id = dd.position
             LEFT JOIN (SELECT * FROM nddc.dim_dict WHERE dict_code = 'integral_object_type_3') dd3 ON idt.rule_id = dd3.position
             LEFT JOIN nddc.dim__incentive_activity_map diam ON idt.rule_code = diam.code
)
   , incentive_data_stat AS (
    --一级类型计算
    SELECT user_id
         , real_name
         , province_id
         , city_id
         , area_id
         , school_id
         , type_name_1 AS type_name
         , SUM(amount) AS incentive_score
         , 1           AS level
    FROM incentive_data_tmp2
    GROUP BY user_id, real_name, province_id, city_id, area_id, school_id, type_1, type_name_1
             --二级类型计算
    UNION ALL
    SELECT user_id
         , real_name
         , province_id
         , city_id
         , area_id
         , school_id
         , CONCAT(type_name_1, '-', type_name_2) AS type_name
         , SUM(amount)                           AS incentive_score
         , 2                                     AS level
    FROM incentive_data_tmp2
    WHERE type_1 IN ('active_platform', 'training', 'teaching_organization')
    GROUP BY user_id, real_name, province_id, city_id, area_id, school_id, type_1, type_name_1, type_2, type_name_2
)
   , all_data AS (
    SELECT ids.user_id
         , ids.real_name               AS user_name
         , ids.province_id
         , CASE
               WHEN ids.province_id = -2 THEN '未知'
               ELSE area1.name END     AS province_name
         , ids.city_id
         , CASE
               WHEN ids.city_id = -2 THEN '未知'
               WHEN ids.city_id = -1 THEN '直属'
               ELSE area2.name END     AS city_name
         , ids.area_id
         , CASE
               WHEN ids.area_id = -2 THEN '未知'
               WHEN ids.area_id = -1 THEN '直属'
               ELSE area3.name END     AS area_name
         , ids.school_id
         , CASE
               WHEN ids.school_id = -2 THEN '未知'
               ELSE sc.school_name END AS school_name
         , type_name
         , ids.incentive_score
         , ids.level
    FROM incentive_data_stat ids
             LEFT JOIN (SELECT DISTINCT area_id, name FROM nddc.dim__area WHERE dt = '${full_biz_date}' AND area_level = 1) area1
                       ON ids.province_id = area1.area_id
             LEFT JOIN (SELECT DISTINCT area_id, name FROM nddc.dim__area WHERE dt = '${full_biz_date}' AND area_level = 2) area2
                       ON ids.city_id = area2.area_id
             LEFT JOIN (SELECT DISTINCT area_id, name FROM nddc.dim__area WHERE dt = '${full_biz_date}' AND area_level = 3) area3
                       ON ids.area_id = area3.area_id
             LEFT JOIN (SELECT DISTINCT school_id, school_name FROM nddc.dim__school WHERE dt = '${full_biz_date}') sc
                       ON ids.school_id = sc.school_id
)
INSERT OVERWRITE TABLE ads__incentive_type_top_d_test
SELECT type_name
     , ROW_NUMBER() OVER (PARTITION BY type_name ORDER BY incentive_score DESC) AS rk
     , user_id
     , user_name
     , incentive_score
     , province_name
     , city_name
     , area_name
     , school_name
     , level
     , '${full_biz_date}'                                                       AS stat_date
FROM all_data ad
;
--取积分类型top10
SELECT type_name
     , rk
     , user_name
     , incentive_score
     , province_name
     , city_name
     , area_name
     , school_name
     , level
FROM ads__incentive_type_top_d_test
where rk<=10
ORDER BY type_name,rk


