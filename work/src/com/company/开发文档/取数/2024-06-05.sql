-- 资源全国top5
-- 分享
SELECT *
FROM nddc.ads__ri__area_share_object_rank__d__full t
WHERE dt = '2024-06-04'
  AND period_type_code = '99'
  AND province_id = '0'
  AND (
            city_id = 0
        OR city_id IS NULL
    )
  AND object_type = 'resource'
  AND share_method = 'ALL'
  AND resource_id != 'ALL'
  AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
ORDER BY share_total_count DESC
LIMIT 5
;
-- 点赞
SELECT like_object_name,
       like_total_like_count
FROM nddc.ads__ri__like_object_rank__da__full
WHERE dt = '2024-06-04'
  AND period_type_code = '99'
  AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
  AND channel_code = 'ALL'
ORDER BY like_total_like_count DESC
LIMIT 5;
-- 收藏
SELECT favorite_object_name,
       favorite_total_count
FROM nddc.ads__ri__favorite_object_rank__da__full
WHERE dt = '2024-06-04'
  AND province_id = '0'
  AND city_id = 0
  AND county_id = 0
  AND period_type_code = '99'
  AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
  AND channel_code = 'ALL'
ORDER BY favorite_total_count DESC
LIMIT 5;
-- 评价
SELECT assessment_object_name,
       assessment_total_count
FROM nddc.ads__ri__assessment_object_rank__da__full
WHERE dt = '2024-06-04'
  AND province_id = '0'
  AND city_id = 0
  AND county_id = 0
  AND period_type_code = '99'
  AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
  AND channel_code = 'ALL'
ORDER BY assessment_total_count DESC
LIMIT 5;
-- 资源播放
SELECT *
FROM (
         SELECT *, ROW_NUMBER() OVER (PARTITION BY province_id,province_name ORDER BY visit_count DESC) rk
         FROM (
                  SELECT a.province_id,
                         MAX(b.province_name) province_name,
                         channel_code,
                         MAX(channel_name)    channel_name,
                         resource_id,
                         MAX(resource_name)   resource_name,
                         SUM(visit_count) AS  visit_count
                  FROM (
                           SELECT resource_id, MAX(resource_name) resource_name, SUM(detail_visit_count) visit_count
                           FROM nddc.dws__resource__resource_visit_detail__dtd__full t
                           WHERE dt = '${biz_date}'
                             AND NVL(channel_code, '') <> ''
                           GROUP BY resource_id
                       ) a
                           INNER JOIN (SELECT area_id AS province_id, `name` AS province_name
                                       FROM nddc.dim__area
                                       WHERE dt = '${biz_date}'
                                         AND area_level = 1) b
                                      ON a.province_id = b.province_id
                  GROUP BY a.province_id, a.channel_code, a.resource_id
              ) c
     ) d
WHERE rk <= 5
;
--省、频道评价次数
SELECT province_id, province_name, channel_code, channel_name, assessment_total_count
FROM nddc.ads__ri__assessment_stat__dd__full_v2 t
WHERE dt = '${biz_date}'
  AND city_id = 0
  AND province_id <> -2
  AND channel_code != 'ALL'
  AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
ORDER BY province_id, channel_code
;
--省、频道收藏次数

SELECT province_id, province_name, channel_code, channel_name, favorite_total_count
FROM nddc.ads__ri__favorite_stat__dd__full_v2 t
WHERE dt = '${biz_date}'
  AND city_id = 0
  AND province_id <> -2
  AND channel_code != 'ALL'
  AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
ORDER BY province_id, channel_code;
--省、频道分享次数
SELECT province_id, IF(province_id = 0, '全国', province_name) province_name, channel_code, channel_name, share_event_total_count
FROM (
         SELECT NVL(rul.user_province_id, 0)     AS province_id,
                MAX(rul.user_province_name)      AS province_name,
                dcc.channel_code,
                dcc.channel_name,
                SUM(rul.share_event_total_count) AS share_event_total_count

         FROM nddc.dwm__ri__user_share__dd__full rul
                  LEFT JOIN (SELECT *
                             FROM (
                                      SELECT *,
                                             ROW_NUMBER() OVER (PARTITION BY dctf.product_id,dctf.channel_code,dctf.robject_id
                                                 ORDER BY dctf.content_valid_status DESC, dctf.content_last_modified_time DESC ) AS rk
                                      FROM nddc.dwd__talr__channel_content_tag_flat__d__full dctf
                                      WHERE dctf.dt = '${biz_anchor_date}'
                                        AND dctf.site_type = dctf.product_code
                                        AND ((dctf.content_type = 'textbook' AND dctf.channel_code = 'course')
                                          OR dctf.content_type != 'textbook')
                                  ) t1
                             WHERE rk = 1) dcc
                            ON rul.share_object_id = dcc.robject_id
                                AND rul.x_product_id = dcc.product_id
         WHERE rul.dt = '${biz_date}'
           AND (user_province_id NOT IN (594035816785) OR user_province_id IS NULL)
           AND (user_province_id NOT IN (594036056566) OR user_province_id IS NULL)
           AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
           AND user_province_id <> -2
           AND share_object_type = 'resource'
         GROUP BY rul.user_province_id, dcc.channel_code, dcc.channel_name
             GROUPING SETS (( rul.user_province_id, dcc.channel_code, dcc.channel_name),
             ( dcc.channel_code, dcc.channel_name)
             )
     ) a
WHERE channel_code IS NOT NULL
ORDER BY province_id, channel_code;

--省、频道点赞次数
SELECT province_id, IF(province_id = 0, '全国', province_name) province_name, channel_code, channel_name, like_total_like_count
FROM (
         SELECT NVL(t1.user_province_id, 0) AS province_id,
                MAX(t1.user_province_name)  AS province_name,
                like_channel_code           AS channel_code,
                like_channel_name           AS channel_name,
                SUM(t1.like_count)          AS like_total_like_count

         FROM nddc.dwm__ri__user_like__dd__full_v2 t1
         WHERE t1.dt = '${biz_date}'
           AND (user_province_id NOT IN (594035816785) OR user_province_id IS NULL)
           AND (user_province_id NOT IN (594036056566) OR user_province_id IS NULL)
           AND x_product_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
           AND user_province_id <> -2
           AND like_channel_code <> '-1'
         GROUP BY t1.user_province_id, like_channel_code, like_channel_name
             GROUPING SETS (
             ( t1.user_province_id, like_channel_code, like_channel_name),
             ( like_channel_code, like_channel_name)
             )
     ) a
ORDER BY province_id, channel_code
;
--省、频道播放
SELECT province_id, IF(province_id = 0, '全国', province_name) province_name, channel_code, channel_name, visit_count
FROM (
         SELECT NVL(a.province_id, 0) AS province_id,
                MAX(b.province_name)     province_name,
                channel_code,
                MAX(channel_name)        channel_name,
                SUM(visit_count)      AS visit_count
         FROM (
                  SELECT province_id,
                         MAX(province_name) province_name,
                         channel_code,
                         MAX(channel_name)  channel_name,
                         SUM(visit_count)   visit_count
                  FROM (SELECT *
                        FROM nddc.dws__resource__resource_visit_detail__dtd__full
                        WHERE dt = '${biz_date}'
                          AND NVL(channel_code, '') <> ''
                       )t INNER JOIN
                         (SELECT *
                          FROM nddc.dim__talr__channel_content
                          WHERE dt='${dt}'
                            AND content_type<>'course') b ON t.resource_id = b.robject_id
                  GROUP BY t.province_id, t.channel_code
              ) a
                  INNER JOIN (SELECT area_id AS province_id, `name` AS province_name
                              FROM nddc.dim__area
                              WHERE dt = '${biz_date}'
                                AND area_level = 1) b
                             ON a.province_id = b.province_id
         GROUP BY a.province_id, a.channel_code
             GROUPING SETS (
             ( a.province_id, a.channel_code),
             ( a.channel_code)
             )
     ) c
ORDER BY province_id, channel_code;