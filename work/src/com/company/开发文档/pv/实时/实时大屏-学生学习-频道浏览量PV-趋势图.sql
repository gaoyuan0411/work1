-- SELECT
--       'today' day_code
--      , stat_hour
--      ,if(stat_hour >= HOUR(now())
--          or (HOUR(now())%2 = 1 and stat_hour = HOUR(now())-1)
--          or (HOUR(now())%2 = 0 and MINUTE(now()) &lt; 30 and stat_hour in (HOUR(now())-1, HOUR(now())-2)),
--          null, SUM(IF(channel_code IN ('course', 'prepare_lesson', 'basicWork', 'exercises', 'experiment'), pv, 0))) as course_type_number
--      ,if(stat_hour >= HOUR(now())
--          or (HOUR(now())%2 = 1 and stat_hour = HOUR(now())-1)
--          or (HOUR(now())%2 = 0 and MINUTE(now()) &lt; 30 and stat_hour in (HOUR(now())-1, HOUR(now())-2)),
--          null, SUM(IF(channel_code IN ('teacherTraining', 'home', 'tchMaterial', 'sedu', 'sport', 'schoolService', 'art', 'labourEdu', 'family', 'localChannel', 'eduReform', 'topic'), pv, 0))) as not_course_type_number
--      ,if(stat_hour >= HOUR(now())
--          or (HOUR(now())%2 = 1 and stat_hour = HOUR(now())-1)
--          or (HOUR(now())%2 = 0 and MINUTE(now()) &lt; 30 and stat_hour in (HOUR(now())-1, HOUR(now())-2)),
--          null, SUM(pv)) as total_type_number
-- FROM ads_zxx_channel_hour_stat_data_d
-- WHERE stat_date = CURDATE()
--   AND app_type IN ('web-all', 'app', 'pc', 'app_hd')
--   AND channel_level = '1' and identity = '学生' AND province = '全球'
--   --学科包括学生自主学习、教师备课授课、教材;非学科包括德育、体育、美育、劳动教育、客户服务、家庭教育、教改经验、地方频道
--   AND channel_code IN
--       ('course', 'prepare_lesson', 'basicWork', 'exercises', 'experiment'
--       , 'teacherTraining', 'home', 'tchMaterial', 'sedu', 'sport', 'schoolService', 'art', 'labourEdu', 'family', 'localChannel', 'eduReform', 'topic')
-- GROUP BY stat_hour
-- order by stat_hour asc
--
-- union all
--
--  SELECT
--        'yesterday' day_code
--       , stat_hour
--      ,if(stat_hour >= HOUR(now())
--          or (HOUR(now())%2 = 1 and stat_hour = HOUR(now())-1)
--          or (HOUR(now())%2 = 0 and MINUTE(now()) &lt; 30 and stat_hour in (HOUR(now())-1, HOUR(now())-2)),
--          null, SUM(IF(channel_code IN ('course', 'prepare_lesson', 'basicWork', 'exercises', 'experiment'), pv, 0))) as course_type_number
--      ,if(stat_hour >= HOUR(now())
--          or (HOUR(now())%2 = 1 and stat_hour = HOUR(now())-1)
--          or (HOUR(now())%2 = 0 and MINUTE(now()) &lt; 30 and stat_hour in (HOUR(now())-1, HOUR(now())-2)),
--          null, SUM(IF(channel_code IN ('teacherTraining', 'home', 'tchMaterial', 'sedu', 'sport', 'schoolService', 'art', 'labourEdu', 'family', 'localChannel', 'eduReform', 'topic'), pv, 0))) as not_course_type_number
--       , SUM(pv) total_type_number
--  FROM ads_zxx_channel_hour_stat_data_d
--  WHERE stat_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
--    AND app_type IN ('web-all', 'app', 'pc', 'app_hd')
--    AND channel_level = '1' and identity = '学生' AND province = '全球'
--    --学科包括学生自主学习、教师备课授课、教材;非学科包括德育、体育、美育、劳动教育、客户服务、家庭教育、教改经验、地方频道
--    AND channel_code IN
--        ('course', 'prepare_lesson', 'basicWork', 'exercises', 'experiment'
--        , 'teacherTraining', 'home', 'tchMaterial', 'sedu', 'sport', 'schoolService', 'art', 'labourEdu', 'family', 'localChannel', 'eduReform', 'topic')
--  GROUP BY stat_hour
--  order by stat_hour asc
SELECT
      'today' day_code
     , cast(event_hour as int) as stat_hour
     ,if(cast(event_hour as int) >= HOUR(now())
         or (HOUR(now())%2 = 1 and cast(event_hour as int) = HOUR(now())-1)
         or (HOUR(now())%2 = 0 and MINUTE(now()) &lt; 30 and cast(event_hour as int) in (HOUR(now())-1, HOUR(now())-2)),
         null, SUM(IF(module_code IN ('course', 'prepare_lesson', 'basicWork', 'exercises', 'experiment'), visit_times, 0))) as course_type_number
     ,if(cast(event_hour as int) >= HOUR(now())
         or (HOUR(now())%2 = 1 and cast(event_hour as int) = HOUR(now())-1)
         or (HOUR(now())%2 = 0 and MINUTE(now()) &lt; 30 and cast(event_hour as int) in (HOUR(now())-1, HOUR(now())-2)),
         null, SUM(IF(module_code IN ('teacherTraining', 'home', 'tchMaterial', 'sedu', 'sport', 'schoolService', 'art', 'labourEdu', 'family', 'localChannel', 'eduReform', 'topic'), visit_times, 0))) as not_course_type_number
     ,if(cast(event_hour as int) >= HOUR(now())
         or (HOUR(now())%2 = 1 and cast(event_hour as int) = HOUR(now())-1)
         or (HOUR(now())%2 = 0 and MINUTE(now()) &lt; 30 and cast(event_hour as int) in (HOUR(now())-1, HOUR(now())-2)),
         null, SUM(visit_times)) as total_type_number
from dwm__pv__event_detail__ih__incr
WHERE stat_date = CURDATE()
           AND product_code = 'zxx'
 AND module_code IN
       ('course', 'prepare_lesson', 'basicWork', 'exercises', 'experiment'
       , 'teacherTraining', 'home', 'tchMaterial', 'sedu', 'sport', 'schoolService', 'art', 'labourEdu', 'family', 'localChannel', 'eduReform', 'topic')
GROUP BY event_hour
UNION ALL
select 'yesterday' day_code
      , cast(event_hour as int) as  stat_hour
     ,if(cast(event_hour as int) >= HOUR(now())
         or (HOUR(now())%2 = 1 and cast(event_hour as int) = HOUR(now())-1)
         or (HOUR(now())%2 = 0 and MINUTE(now()) &lt; 30 and cast(event_hour as int) in (HOUR(now())-1, HOUR(now())-2)),
         null, SUM(IF(module_code IN ('course', 'prepare_lesson', 'basicWork', 'exercises', 'experiment'), visit_times, 0))) as course_type_number
     ,if(cast(event_hour as int) >= HOUR(now())
         or (HOUR(now())%2 = 1 and cast(event_hour as int) = HOUR(now())-1)
         or (HOUR(now())%2 = 0 and MINUTE(now()) &lt; 30 and cast(event_hour as int) in (HOUR(now())-1, HOUR(now())-2)),
         null, SUM(IF(module_code IN ('teacherTraining', 'home', 'tchMaterial', 'sedu', 'sport', 'schoolService', 'art', 'labourEdu', 'family', 'localChannel', 'eduReform', 'topic'), visit_times, 0))) as not_course_type_number
      , SUM(visit_times) total_type_number
 FROM dwm__pv__event_detail__ih__incr
 WHERE stat_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
   AND product_code = 'zxx'
AND module_code IN
('course', 'prepare_lesson', 'basicWork', 'exercises', 'experiment'
, 'teacherTraining', 'home', 'tchMaterial', 'sedu', 'sport', 'schoolService', 'art', 'labourEdu', 'family', 'localChannel', 'eduReform', 'topic')
 GROUP BY event_hour