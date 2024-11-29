-- select
-- course_type_data as course_type_count
-- ,not_course_type_data as not_course_type_count
-- ,(course_type_data / all_data) as course_type_number
-- ,(not_course_type_data / all_data) as not_course_type_number
-- from (
--
--  SELECT
--         SUM(IF(channel_code IN ('course', 'prepare_lesson', 'basicWork', 'exercises', 'experiment'), pv, 0))  AS course_type_data
--       , SUM(IF(channel_code IN ('teacherTraining', 'home', 'tchMaterial', 'sedu', 'sport', 'schoolService', 'art', 'labourEdu', 'family', 'localChannel', 'eduReform', 'topic'), pv,0)) AS not_course_type_data
--       , 1 as join_data
--  FROM ads_zxx_channel_province_stat_d
--  WHERE stat_date = CURDATE()
--  --学科包括学生自主学习、教师备课授课、教材;非学科包括德育、体育、美育、劳动教育、客户服务、家庭教育、教改经验、地方频道
--     AND channel_code IN
--        ('course', 'prepare_lesson', 'basicWork', 'exercises', 'experiment'
--        , 'teacherTraining', 'home', 'tchMaterial', 'sedu', 'sport', 'schoolService', 'art', 'labourEdu', 'family', 'localChannel', 'eduReform', 'topic')
--     AND province = '全国' and identity = '学生'
--     AND app_type IN ('web-all', 'app', 'pc', 'app_hd')
--     AND channel_level = '1'
--
-- ) t1
-- inner join (
--  SELECT
--         SUM(pv) AS all_data
--       , 1 as join_data
--  FROM ads_zxx_channel_province_stat_d
--  WHERE stat_date = CURDATE()
--  --学科包括学生自主学习、教师备课授课、教材;非学科包括德育、体育、美育、劳动教育、客户服务、家庭教育、教改经验、地方频道
--    AND channel_code IN
--        ('course', 'prepare_lesson', 'basicWork', 'exercises', 'experiment'
--        , 'teacherTraining', 'home', 'tchMaterial', 'sedu', 'sport', 'schoolService', 'art', 'labourEdu', 'family', 'localChannel', 'eduReform', 'topic')
--    AND province = '全国' and identity = '学生'
--    AND app_type IN ('web-all', 'app', 'pc', 'app_hd')
--    AND channel_level = '1'
--
-- ) t2 on t1.join_data = t2.join_data

select
        SUM(IF(module_code IN ('course', 'prepare_lesson', 'basicWork', 'exercises', 'experiment'), visit_times, 0))  AS course_type_data
      , SUM(IF(module_code IN ('teacherTraining', 'home', 'tchMaterial', 'sedu', 'sport', 'schoolService', 'art', 'labourEdu', 'family', 'localChannel', 'eduReform', 'topic'), visit_times,0)) AS not_course_type_data
              ,SUM(IF(module_code IN ('course', 'prepare_lesson', 'basicWork', 'exercises', 'experiment'), visit_times, 0)) / SUM(visit_times) AS course_type_number
            , SUM(IF(module_code IN ('teacherTraining', 'home', 'tchMaterial', 'sedu', 'sport', 'schoolService', 'art', 'labourEdu', 'family', 'localChannel', 'eduReform', 'topic'), visit_times,0)) / SUM(visit_times) AS not_course_type_number
from dwm__pv__event_detail__dd__incr
WHERE stat_date = CURDATE()
 AND module_code IN
           ('course', 'prepare_lesson', 'basicWork', 'exercises', 'experiment'
           , 'teacherTraining', 'home', 'tchMaterial', 'sedu', 'sport', 'schoolService', 'art', 'labourEdu', 'family', 'localChannel', 'eduReform', 'topic')
           and identity='STUDENT'