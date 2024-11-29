--http://localhost:8080/v1/page_view/594033008547/analysis?now_date=2024-05-21&period_type_code=10&period_start_date=2024-04-15&period_end_date=2024-04-15&site_type=zxx&app_type=web&identity_code=TEACHER&area=国内&region_type=NT_DISTRICT&channel_code&page_type=group&code&level&type&is_leaf=0
SELECT code, `name`, type, level, is_leaf, SUM(pv) AS pv
FROM (SELECT ifnull(mcg.module_code, 'other') AS code,
             ifnull(mcg.module_name, '其他')    AS `name`,
             'group'                          AS type,
             1                                AS level,
             mcg.is_leaf,
             pv
      FROM ads__platform_tag_stat__d pt
               LEFT JOIN dim__visit_module_channel_group mcg ON pt.module_code = mcg.channel_code
      WHERE 1 = 1
        AND start_date = '2024-04-15'
        AND end_date = '2024-04-15'
        AND period_type_code = 10
        AND app_type = 'web'
        AND site_type = 'zxx'
        AND identity = 'TEACHER'
        AND country = '中国'
        AND province_id = '594033008547'
        AND city_id = 'all'
        AND pt.module_code != 'all') AS a
GROUP BY code, `name`, type, level, is_leaf
--
SELECT code, `name`, type, level, is_leaf, SUM(pv) AS pv
FROM (SELECT tag_code_1 code, tag_name_1 AS `name`, 'tag' AS type, level, is_leaf, pv
      FROM ads__platform_tag_stat__d pt
               LEFT JOIN dim__visit_module_channel_group mcg ON pt.module_code = mcg.channel_code
      WHERE 1 = 1
        AND start_date = '2024-04-15'
        AND end_date = '2024-04-15'
        AND period_type_code = 10
        AND app_type = 'web'
        AND site_type = 'zxx'
        AND identity = 'TEACHER'
        AND country = '中国'
        AND province_id = '594033008547'
        AND city_id = 'all'
        AND pt.module_code = 'localChannel'
        AND tag_code_2 = 'all') AS a
GROUP BY code, `name`, type, level, is_leaf
;
--http://localhost:8080/v1/page_view/594033008547/analysis?now_date=2024-05-21&period_type_code=10&period_start_date=2024-04-15&period_end_date=2024-04-15&site_type=zxx&app_type=web&identity_code=TEACHER&area=国内&region_type=NT_DISTRICT&code=recommend&level=1&type=group&is_leaf=0
SELECT code, `name`, type, level, is_leaf, SUM(pv) AS pv
FROM (SELECT pt.channel_code code, pt.channel_name AS `name`, 2 AS level, 'channel' AS type, pt.is_leaf, pv
      FROM ads__platform_tag_stat__d pt
               LEFT JOIN dim__visit_module_channel_group mcg ON pt.module_code = mcg.channel_code
      WHERE 1 = 1
        AND start_date = '2024-04-15'
        AND end_date = '2024-04-15'
        AND period_type_code = 10
        AND app_type = 'web'
        AND site_type = 'zxx'
        AND identity = 'TEACHER'
        AND country = '中国'
        AND province_id = '594033008547'
        AND city_id = 'all'
        AND tag_code_1 = 'all'
        AND mcg.module_code = 'recommend') AS a
GROUP BY code, `name`, type, level, is_leaf
;
SELECT code, `name`, type, level, is_leaf, SUM(pv) AS pv
FROM (SELECT pt.module_code code, pt.module_name AS `name`, 2 AS level, 'channel' AS type, pt.is_leaf, pv
      FROM ads__platform_tag_stat__d pt
               LEFT JOIN dim__visit_module_channel_group mcg ON pt.module_code = mcg.channel_code
      WHERE 1 = 1
        AND start_date = '2024-04-15'
        AND end_date = '2024-04-15'
        AND period_type_code = 10
        AND app_type = 'web'
        AND site_type = 'zxx'
        AND identity = 'TEACHER'
        AND country = '中国'
        AND province_id = '594033008547'
        AND city_id = 'all'
        AND tag_code_1 = 'all'
        AND mcg.module_code = 'national_resources') AS a
GROUP BY code, `name`, type, level, is_leaf
;
SELECT code, `name`, type, level, is_leaf, SUM(pv) AS pv
FROM (SELECT tag_code_1 code, tag_name_1 AS `name`, 1 AS level, 'tag' AS type, pt.is_leaf, pv
      FROM ads__platform_tag_stat__d pt
      WHERE 1 = 1
        AND start_date = '2024-04-15'
        AND end_date = '2024-04-15'
        AND period_type_code = 10
        AND app_type = 'web'
        AND site_type = 'zxx'
        AND identity = 'TEACHER'
        AND country = '中国'
        AND province_id = '594033008547'
        AND city_id = 'all'
        AND pt.module_code = 'teacherTraining'
        AND tag_code_2 = 'all'
        AND tag_code_1 != 'all') AS a
GROUP BY code, `name`, type, level, is_leaf;
SELECT code, `name`, type, level, is_leaf, SUM(pv) AS pv
FROM (SELECT tag_code_2 code, tag_name_2 AS `name`, 1 AS level, 'tag' AS type, pt.is_leaf, pv
      FROM ads__platform_tag_stat__d pt
      WHERE 1 = 1
        AND start_date = '2024-04-15'
        AND end_date = '2024-04-15'
        AND period_type_code = 10
        AND app_type = 'web'
        AND site_type = 'zxx'
        AND identity = 'TEACHER'
        AND country = '中国'
        AND province_id = '594033008547'
        AND city_id = 'all'
        AND pt.module_code = 'teacherTraining'
        AND tag_code_1 = '7a96c531-2e5b-4553-a662-ea7a641c07fe'
        AND tag_code_3 = 'all'
        AND tag_code_2 != 'all') AS a
GROUP BY code, `name`, type, level, is_leaf
;
SELECT code, `name`, type, level, is_leaf, SUM(pv) AS pv
FROM (SELECT tag_code_3 code, tag_name_3 AS `name`, 1 AS level, 'tag' AS type, pt.is_leaf, pv
      FROM ads__platform_tag_stat__d pt
      WHERE 1 = 1
        AND start_date = '2024-04-15'
        AND end_date = '2024-04-15'
        AND period_type_code = 10
        AND app_type = 'web'
        AND site_type = 'zxx'
        AND identity = 'TEACHER'
        AND country = '中国'
        AND province_id = '594033008547'
        AND city_id = 'all'
        AND pt.module_code = 'teacherTraining'
        AND tag_code_2 = 'd6ceb958-c049-4e76-94a5-3a44c39bbffb'
        AND tag_code_4 = 'all'
        AND tag_code_3 != 'all') AS a
GROUP BY code, `name`, type, level, is_leaf