CREATE TABLE dwm__resource__resource_visit_detail__dy
(
    `user_id`            BIGINT COMMENT '用户id',
    `app_key`            STRING COMMENT 'app_key',
    `channel_code`       STRING COMMENT '频道编码',
    `visit_count`        BIGINT COMMENT '访问量',
    `detail_visit_count` BIGINT COMMENT '最细粒度访问'
) COMMENT '资源-资源浏览明细-每年-增量' PARTITIONED BY (
    dt STRING COMMENT '分区-日期(yyyy)'
    ) ROW FORMAT DELIMITED NULL DEFINED AS '';
--将已学数据按需汇总成年表
INSERT OVERWRITE TABLE dwm__resource__resource_visit_detail__dy PARTITION (dt = '2023')
SELECT user_id, app_key, channel_code, SUM(visit_count) AS visit_count, SUM(detail_visit_count) AS detail_visit_count
FROM nddc.dwm__resource__resource_visit_detail__d
WHERE dt BETWEEN '2023-01-01' AND '2023-12-31'
  AND user_id <> 0
  AND channel_code <> ''
  AND app_key <> ''
GROUP BY user_id, app_key, channel_code;
--计算各学校，排名前三栏目
WITH user_data AS (
    SELECT a.account_id
         , a.identity
         , b.`order`
         ,b.province
         , b.map_school_name
    FROM (SELECT DISTINCT account_id
                        , school_id
                        , IF(is_teacher = 1, 'TEACHER', 'STUDENT') AS identity
          FROM nddc.dwd__md__person_account__d__full
          WHERE dt = '${biz_date}'
            AND is_canceled = 0
            AND (is_teacher + is_student) > 0
         ) a
             INNER JOIN
         dim_BNU_school_data b ON a.school_id = b.school_id
)
   , visit_data_tmp AS (
    SELECT vs.user_id
         , vs.app_key
         , vs.channel_code
         , vs.visit_count
         , vs.detail_visit_count
         , vs.dt AS stat_date
         , ud.`order`
         ,ud.province
         , ud.map_school_name
         , ud.identity
    FROM (SELECT * FROM dwm__resource__resource_visit_detail__dy) vs
             INNER JOIN user_data ud ON vs.user_id = ud.account_id
)
   , visit_data AS (
    SELECT t1.*
         , IF(t2.platform IN ('android', 'ios', 'android_hd', 'ios_hd'), 'app', 'other') AS platform
         , t3.channel_name
    FROM visit_data_tmp t1
             LEFT JOIN (SELECT * FROM nddc.dim__md__product_app WHERE product_code = 'zxx') t2
                       ON t1.app_key = t2.app_id
             LEFT JOIN (SELECT * FROM nddc.dim__talr__channel WHERE product_code = 'zxx') t3
                       ON t1.channel_code = t3.channel_code
)
   , visit_data_stat AS (
    SELECT `order`
         ,province
         , map_school_name
         , channel_code
         , channel_name
         , SUM(IF(stat_date = '2023' AND identity = 'TEACHER', detail_visit_count, 0)) AS 2023_teacher_visit_count
         , SUM(IF(stat_date = '2023' AND identity = 'STUDENT', detail_visit_count, 0)) AS 2023_student_visit_count
         , SUM(IF(stat_date = '2023' AND identity = 'TEACHER' AND platform = 'app', detail_visit_count,
                  0))                                                                  AS 2023_teacher_app_visit_count
         , SUM(IF(stat_date = '2023' AND identity = 'STUDENT' AND platform = 'app', detail_visit_count,
                  0))                                                                  AS 2023_student_app_visit_count
         , SUM(IF(stat_date = '2022' AND identity = 'TEACHER', detail_visit_count, 0)) AS 2022_teacher_visit_count
         , SUM(IF(stat_date = '2022' AND identity = 'STUDENT', detail_visit_count, 0)) AS 2022_student_visit_count
         , SUM(IF(stat_date = '2022' AND identity = 'TEACHER' AND platform = 'app', detail_visit_count,
                  0))                                                                  AS 2022_teacher_app_visit_count
         , SUM(IF(stat_date = '2022' AND identity = 'STUDENT' AND platform = 'app', detail_visit_count,
                  0))                                                                  AS 2022_student_app_visit_count
    FROM visit_data
    WHERE channel_name IS NOT NULL
    GROUP BY `order`, province,map_school_name, channel_code, channel_name
)
   , all_data AS (
    SELECT `order`
         ,province
         , map_school_name
         , channel_code
         , channel_name
         , 2023_teacher_visit_count
         , ROW_NUMBER() OVER (PARTITION BY `order`,map_school_name ORDER BY 2023_teacher_visit_count DESC)     AS 2023_teacher_order
         , 2023_student_visit_count
         , ROW_NUMBER() OVER (PARTITION BY `order`,map_school_name ORDER BY 2023_student_visit_count DESC)     AS 2023_student_order
         , 2023_teacher_app_visit_count
         , ROW_NUMBER() OVER (PARTITION BY `order`,map_school_name ORDER BY 2023_teacher_app_visit_count DESC) AS 2023_teacher_app_order
         , 2023_student_app_visit_count
         , ROW_NUMBER() OVER (PARTITION BY `order`,map_school_name ORDER BY 2023_student_app_visit_count DESC) AS 2023_student_app_order
         , 2022_teacher_visit_count
         , ROW_NUMBER() OVER (PARTITION BY `order`,map_school_name ORDER BY 2022_teacher_visit_count DESC)     AS 2022_teacher_order
         , 2022_student_visit_count
         , ROW_NUMBER() OVER (PARTITION BY `order`,map_school_name ORDER BY 2022_student_visit_count DESC)     AS 2022_student_order
         , 2022_teacher_app_visit_count
         , ROW_NUMBER() OVER (PARTITION BY `order`,map_school_name ORDER BY 2022_teacher_app_visit_count DESC) AS 2022_teacher_app_order
         , 2022_student_app_visit_count
         , ROW_NUMBER() OVER (PARTITION BY `order`,map_school_name ORDER BY 2022_student_app_visit_count DESC) AS 2022_student_app_order
    FROM visit_data_stat
)
SELECT t1.`order`
     ,t1.province
     , t1.map_school_name
     , t1.order_number
     , t2.channel_name as 2023_teacher_channel
     , t3.channel_name as 2023_student_channel
     , t4.channel_name as 2023_teacher_app_channel
     , t5.channel_name as 2023_student_app_channel
     , t6.channel_name as 2022_teacher_channel
     , t7.channel_name as 2022_student_channel
     , t8.channel_name as 2022_teacher_app_channel
     , t9.channel_name as 2022_student_app_channel
FROM (SELECT DISTINCT `order`, province,map_school_name, order_number
      FROM dim_BNU_school_data LATERAL VIEW EXPLODE(ARRAY(1, 2, 3)) tmp3 AS order_number) t1
         LEFT JOIN (SELECT * FROM all_data WHERE 2023_teacher_order <= ${rank}) t2
                   ON t1.`order` = t2.`order` AND t1.order_number = t2.2023_teacher_order
         LEFT JOIN (SELECT * FROM all_data WHERE 2023_student_order <= ${rank}) t3
                   ON t1.`order` = t3.`order` AND t1.order_number = t3.2023_student_order
         LEFT JOIN (SELECT * FROM all_data WHERE 2023_teacher_app_order <= ${rank}) t4
                   ON t1.`order` = t4.`order` AND t1.order_number = t4.2023_teacher_app_order
         LEFT JOIN (SELECT * FROM all_data WHERE 2023_student_app_order <= ${rank}) t5
                   ON t1.`order` = t5.`order` AND t1.order_number = t5.2023_student_app_order
         LEFT JOIN (SELECT * FROM all_data WHERE 2022_teacher_order <= ${rank}) t6
                   ON t1.`order` = t6.`order` AND t1.order_number = t6.2022_teacher_order
         LEFT JOIN (SELECT * FROM all_data WHERE 2022_student_order <= ${rank}) t7
                   ON t1.`order` = t7.`order` AND t1.order_number = t7.2022_student_order
         LEFT JOIN (SELECT * FROM all_data WHERE 2022_teacher_app_order <= ${rank}) t8
                   ON t1.`order` = t8.`order` AND t1.order_number = t8.2022_teacher_app_order
         LEFT JOIN (SELECT * FROM all_data WHERE 2022_student_app_order <= ${rank}) t9
                   ON t1.`order` = t9.`order` AND t1.order_number = t9.2022_student_app_order
order by t1.`order` , t1.order_number