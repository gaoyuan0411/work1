-- WITH user_data AS (
--     SELECT DISTINCT account_id
--                   , is_teacher
--                   , is_student
--                   , school_id
--                   , DATE_FORMAT(created_date, 'yyyy') AS stat_date
--     FROM nddc.dwd__md__person_account__d__full
--     WHERE dt = '${biz_date}'
--       AND is_canceled = 0
--       AND created_date < '2024-01-01'
-- ),
--      user_school_data AS (
--          SELECT ud.*
--               , t1.`order`
--               , t1.map_school_name
--          FROM dim_BNU_school_data t1
--                   INNER JOIN user_data ud ON t1.school_id = ud.school_id
--      )
-- SELECT `order`
--      , map_school_name
--      , COUNT(DISTINCT IF(stat_date = '2023', account_id, NULL))                                       AS 2023_all_user
--      , COUNT(DISTINCT IF(stat_date = '2023' AND is_teacher = 1, account_id, NULL))                    AS 2023_teacher_user
--      , COUNT(DISTINCT IF(stat_date = '2023' AND is_teacher = 0 AND is_student = 1, account_id, NULL)) AS 2023_student_user
--      , COUNT(DISTINCT IF(stat_date = '2022', account_id, NULL))                                       AS 2022_all_user
--      , COUNT(DISTINCT IF(stat_date = '2022' AND is_teacher = 1, account_id, NULL))                    AS 2022_teacher_user
--      , COUNT(DISTINCT IF(stat_date = '2022' AND is_teacher = 0 AND is_student = 1, account_id, NULL)) AS 2022_student_user
-- FROM user_school_data
-- GROUP BY `order`, map_school_name
-- ORDER BY `order`;
WITH user_data AS (
    SELECT school_id
         , period_code AS stat_date
         , if(type=0,teacher_count,-teacher_count)teacher_count
         , if(type=0,student_count,-student_count)student_count
         , if(type=0,all_count,-all_count)all_count
    FROM nddc.ads__ur__user_school_stat__da__full
    WHERE dt = '${biz_date}'
      AND period_type_code = 50
      AND period_code < '2024'
      and app_id ='zxx'
    and  type in (0,1)
),
     user_school_data AS (
         SELECT ud.*
              , t1.`order`
              ,t1.province
              , t1.map_school_name
         FROM dim_BNU_school_data t1
                  INNER JOIN user_data ud ON t1.school_id = ud.school_id
     )
SELECT `order`
     ,province
     , map_school_name
     , SUM(IF(stat_date = '2023', all_count, 0))     AS 2023_all_user
     , SUM(IF(stat_date = '2023', teacher_count, 0)) AS 2023_teacher_user
     , SUM(IF(stat_date = '2023', student_count, 0)) AS 2023_student_user
     , SUM(IF(stat_date = '2022', all_count, 0))     AS 2022_all_user
     , SUM(IF(stat_date = '2022', teacher_count, 0)) AS 2022_teacher_user
     , SUM(IF(stat_date = '2022', student_count, 0)) AS 2022_student_user
FROM user_school_data
GROUP BY `order`,province, map_school_name
ORDER BY `order`