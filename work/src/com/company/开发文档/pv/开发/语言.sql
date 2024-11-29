-- http://localhost:8080/v1/page_view/language_analysis?now_date=2024-05-01&period_type_code=10&period_start_date=2024-04-15&period_end_date=2024-04-15&site_type=zxx&app_type=web&identity_code=TEACHER&area=国内
SELECT ifnull(language_code, 'other') AS language_code, ifnull(language_name, '其他') AS language_name, pv, uv
FROM ads__platform_area_stat__d t
         LEFT JOIN dim__language dl ON t.language = dl.language_code
WHERE 1 = 1
  AND start_date = '2024-04-15'
  AND end_date = '2024-04-15'
  AND period_type_code = 10
  AND app_type = 'web'
  AND site_type = 'zxx'
  AND identity = 'TEACHER'
  AND country = '中国'
  AND province_id = 'all'
  AND language != 'all'
ORDER BY pv