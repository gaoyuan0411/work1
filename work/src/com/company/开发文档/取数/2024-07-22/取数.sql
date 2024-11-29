--智育('basicWork','exercises','experiment','course','prepare_lesson')
--体美劳育('labourEdu','art','sport')
--德育 sedu
--转发资源次数
SELECT *
     , ROW_NUMBER() OVER (PARTITION BY period_code,map_channel_name ORDER BY share_total_count DESC ) AS rk
FROM (
         SELECT period_code,
                CASE
                    WHEN channel_code IN ('basicWork', 'exercises', 'experiment', 'course', 'prepare_lesson') THEN '智育'
                    WHEN channel_code IN ('labourEdu', 'art', 'sport') THEN '体美劳育'
                    ELSE channel_name END AS map_channel_name,
                channel_code,
                channel_name,
                resource_id,
                resource_name,
                share_total_count
         FROM nddc.ads__ri__area_share_object_rank2__d__full
         WHERE period_type_code = '30'
           AND period_code BETWEEN '202402' AND '202406'
           AND province_id = '0'
           AND (
                     city_id = 0
                 OR city_id IS NULL
             )
           AND object_type = 'resource'
           AND share_method = 'ALL'
           AND resource_id != 'ALL'
           AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
           AND channel_code IN
               ('basicWork', 'exercises', 'experiment', 'course', 'prepare_lesson', 'labourEdu', 'art', 'sport', 'sedu')
     ) t
HAVING rk <= 10
;
--点赞资源数据
SELECT *
FROM (
         SELECT t.*, ROW_NUMBER() OVER (PARTITION BY period_code,map_channel_name ORDER BY like_count DESC ) AS rk
         FROM (SELECT a.period_code,
                      CASE
                          WHEN b.channel_code IN
                               ('basicWork', 'exercises', 'experiment', 'course', 'prepare_lesson') THEN '智育'
                          WHEN b.channel_code IN ('labourEdu', 'art', 'sport') THEN '体美劳育'
                          ELSE b.channel_name END AS map_channel_name,
                      a.like_object_id,
                      b.content_title,
                      b.channel_code,
                      b.channel_name,
                      a.like_count
               FROM (SELECT like_object_id,
                            DATE_FORMAT(like_created_date, 'yyyyMM') AS period_code,
                            SUM(like_count)                             like_count
                     FROM nddc.dwm__ri__user_like__dd__incr_v2
                     WHERE like_created_date BETWEEN '2024-02-01' AND '2024-06-31'
                       AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
                     GROUP BY like_object_id, DATE_FORMAT(like_created_date, 'yyyyMM')
                    ) a
               INNER JOIN (SELECT robject_id, content_title, channel_code, channel_name
                                    FROM nddc.dim__talr__channel_content t
                                    WHERE dt = '2024-05-05'
                                      AND channel_code IN
                                          ('basicWork', 'exercises', 'experiment', 'course', 'prepare_lesson',
                                           'labourEdu', 'art', 'sport',
                                           'sedu')
                                    GROUP BY robject_id, content_title, channel_code, channel_name
               ) b ON a.like_object_id = b.robject_id
              ) t
     ) c
WHERE rk <= 10
;
--收藏资源数据
SELECT *
FROM (
         SELECT *,
                ROW_NUMBER() OVER (PARTITION BY period_code,map_channel_name ORDER BY favorite_total_count DESC ) AS rk
         FROM (
                  SELECT DATE_FORMAT(favorite_create_date, 'yyyyMM') AS period_code,
                         CASE
                             WHEN content_channel_code IN
                                  ('basicWork', 'exercises', 'experiment', 'course', 'prepare_lesson') THEN '智育'
                             WHEN content_channel_code IN ('labourEdu', 'art', 'sport') THEN '体美劳育'
                             ELSE content_channel_name END           AS map_channel_name,
                         content_robject_id,
                         content_title,
                         content_channel_code,
                         content_channel_name,
                         SUM(favorite_total_count)                      favorite_total_count
                  FROM nddc.dwm__ri__favorite_channel__dn__full
                  WHERE dt = '${full_biz_date}'
                    AND favorite_create_date BETWEEN '2024-02-01' AND '2024-06-31'
                    AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
                    AND content_channel_code IN
                        ('basicWork', 'exercises', 'experiment', 'course', 'prepare_lesson',
                         'labourEdu', 'art', 'sport',
                         'sedu')
                  GROUP BY content_robject_id, content_title, content_channel_code, content_channel_name,
                           DATE_FORMAT(favorite_create_date, 'yyyyMM')
              ) a
     ) b
WHERE rk <= 10
;
--评价资源数据
SELECT *
FROM (
         SELECT *,
                ROW_NUMBER() OVER (PARTITION BY period_code,map_channel_name ORDER BY assessment_total_count DESC ) AS rk
         FROM (
                  SELECT DATE_FORMAT(assessment_create_date, 'yyyyMM') AS period_code,
                         CASE
                             WHEN content_channel_code IN
                                  ('basicWork', 'exercises', 'experiment', 'course', 'prepare_lesson') THEN '智育'
                             WHEN content_channel_code IN ('labourEdu', 'art', 'sport') THEN '体美劳育'
                             ELSE content_channel_name END             AS map_channel_name,
                         content_robject_id,
                         content_title,
                         content_channel_code,
                         content_channel_name,
                         SUM(assessment_total_count)                      assessment_total_count
                  FROM nddc.dwm__ri__assessment_channel__dn__full
                  WHERE dt = '${full_biz_date}'
                    AND assessment_create_date BETWEEN '2024-02-01' AND '2024-06-31'
                    AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
                    AND content_channel_code IN
                        ('basicWork', 'exercises', 'experiment', 'course', 'prepare_lesson',
                         'labourEdu', 'art', 'sport',
                         'sedu')
                  GROUP BY content_robject_id, content_title, content_channel_code, content_channel_name,
                           DATE_FORMAT(assessment_create_date, 'yyyyMM')
              ) a
     ) b
WHERE rk <= 10

