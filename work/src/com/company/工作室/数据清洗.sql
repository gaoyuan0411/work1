WITH teacher_studio AS (
    SELECT teacher_studio_id, MAX(scope_type) AS scope_type
    FROM nddc.ods__e_teacher_studio__t_teacher_studio__mysql__full
    WHERE dt = '${full_biz_date}'
    GROUP BY teacher_studio_id
)
   , pv AS (
    SELECT *
    FROM nddc.ods_ads__resouce__studio_visit_stat_d__mysql
    WHERE dt = '${full_biz_date}'
)
INSERT  OVERWRITE  TABLE  ods_ads__resouce__studio_visit_stat_d__mysql PARTITION (dt='2024-09-30')
SELECT p.`_id`
     , p.`stat_date`
     , p.`studio_id`
     , CASE ts.scope_type
           WHEN 'school-space' THEN '学校空间'
           WHEN 'teach-studio' THEN '名师工作室'
           WHEN 'expert-studio' THEN '专家工作室'
           WHEN 'inst-studio' THEN '资源号'
           ELSE '未知' END AS studio_type
--      , p.`studio_type`
     , p.`uv`
     , p.`pv`
     , p.`cum_pv`
     , p.`create_time`
     , p.`update_time`
FROM pv p
         LEFT JOIN teacher_studio ts
                   ON p.studio_id = ts.teacher_studio_id