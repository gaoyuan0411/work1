--  user_id        分数
-- 452547481612    335.40
-- 452711801407    299.20
-- 452549582728    288.10
-- 452547815694    263.90
-- 452547743499    262.10
WITH user_data AS (
    SELECT account_id
         , real_name
    FROM nddc.dwd__md__person_account__d__full
    WHERE dt = '${full_biz_date}'
      AND is_canceled = 0
      AND (is_teacher + is_manager + is_electric_teacher + is_academic_staff) > 0 --获取教师类型身份
      AND COALESCE(user_province_id, 0) <> 594035816785
      AND account_id IN (452547481612, 452711801407, 452549582728, 452547815694, 452547743499)
)
   , incentive_data AS (
    SELECT CAST(user_id AS BIGINT)             AS user_id
         , CAST(new_balance AS DECIMAL(10, 2)) AS new_balance
         , CAST(rule_id AS INT)                AS rule_id
         , CAST(amount AS DECIMAL(10, 2))      AS amount
         , biz_time
         , rule_code
         , tenant_id
    FROM nddc.dwd__incentive__teacher__incentive_detail__d__full
    WHERE dt = '${full_biz_date}'
      AND type = 'income'
      AND `version` = '2024'
      AND CAST(new_balance AS DECIMAL(10, 6)) > 0
      AND CAST(user_id AS BIGINT) IN (452547481612, 452711801407, 452549582728, 452547815694, 452547743499)
       and tenant_id='416'
)
SELECT id.user_id
     , ud.real_name
     , rule_id
     , NVL(dd.value, 'other') AS type_1
     , NVL(dd.name,'未知')     AS type_name_1
     , NVL(dd3.value, 'other')                AS type_2
     , NVL(dd3.name, '未知')                    AS type_name_2
     , NVL( diam.code, 'other') AS detail_type
     , NVL(diam.name, '未知')     AS detail_type_name
     , biz_time
     , rule_code
     , new_balance
     , amount
FROM incentive_data id
         INNER JOIN user_data ud ON id.user_id = ud.account_id
         LEFT JOIN (SELECT * FROM nddc.dim_dict WHERE dict_code = 'integral_object_type') dd ON id.rule_id = dd.position
         LEFT JOIN (SELECT * FROM nddc.dim_dict WHERE dict_code = 'integral_object_type_3') dd3 ON id.rule_id = dd3.position
         LEFT JOIN nddc.dim__incentive_activity_map diam ON id.rule_code = diam.code
         ORDER BY user_id,biz_time desc