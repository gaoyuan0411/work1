--至今
WITH visit_data AS (
    SELECT resource_id, SUM(detail_visit_count) AS detail_visit_count
    FROM nddc.dws__resource__resource_visit_detail__dtd__full
    WHERE dt = '${biz_date}'
    GROUP BY resource_id
),
     resource_data AS (
         SELECT robject_id,
                channel_code,
                MAX(channel_name)  AS channel_name,
                MAX(CASE
                        WHEN tag_id_path IS NULL THEN tag_name
                        WHEN tag_id IS NULL THEN tag_name_path
                        ELSE CONCAT(tag_name_path, ',', tag_name)
                    END)           AS tag_name_path,
                MAX(content_title) AS resource_name
         FROM nddc.dwd__talr__channel_content_tag_flat__d__full
         WHERE dt = '${biz_date}'
           AND product_code = 'zxx'
           AND channel_code IN ('course', 'experiment')
           AND content_standard_sub_type = 'lesson'
           AND content_status = 1
           AND content_deleted = 0
           AND robject_status = 1
           AND content_valid_status = 1
         GROUP BY robject_id, channel_code
         UNION ALL
         SELECT robject_id,
                channel_code,
                MAX(channel_name)  AS channel_name,
                MAX(CASE
                        WHEN tag_id_path IS NULL THEN tag_name
                        WHEN tag_id IS NULL THEN tag_name_path
                        ELSE CONCAT(tag_name_path, ',', tag_name)
                    END)           AS tag_name_path,
                MAX(content_title) AS resource_name
         FROM nddc.dwd__talr__channel_content_tag_flat__d__full
         WHERE dt = '${biz_date}'
           AND product_code = 'zxx'
           AND channel_code NOT IN ('course', 'experiment')
           AND content_type = 'resource'
           AND content_status = 1
           AND content_deleted = 0
           AND robject_status = 1
           AND content_valid_status = 1
         GROUP BY robject_id, channel_code
     )
SELECT *
FROM (
         SELECT vd.resource_id
              , rd.resource_name
              , rd.channel_code
              , rd.channel_name
              , rd.tag_name_path
              , vd.detail_visit_count
              , ROW_NUMBER() OVER (PARTITION BY rd.channel_code ORDER BY vd.detail_visit_count DESC) AS rk
         FROM visit_data vd
                  INNER JOIN resource_data rd
                             ON vd.resource_id = rd.robject_id
     ) a
WHERE rk <= 10
;
-- 2024
WITH visit_data AS (
    SELECT resource_id, SUM(detail_visit_count) AS detail_visit_count
    FROM nddc.dws__resource__resource_visit_detail__dd__incr
    WHERE dt BETWEEN '2024-01-01' AND '${biz_date}'
    GROUP BY resource_id
),
     resource_data AS (
         SELECT robject_id,
                channel_code,
                MAX(channel_name)  AS channel_name,
                MAX(CASE
                        WHEN tag_id_path IS NULL THEN tag_name
                        WHEN tag_id IS NULL THEN tag_name_path
                        ELSE CONCAT(tag_name_path, ',', tag_name)
                    END)           AS tag_name_path,
                MAX(content_title) AS resource_name
         FROM nddc.dwd__talr__channel_content_tag_flat__d__full
         WHERE dt = '${biz_date}'
           AND product_code = 'zxx'
           AND channel_code IN ('course', 'experiment')
           AND content_standard_sub_type = 'lesson'
           AND content_status = 1
           AND content_deleted = 0
           AND robject_status = 1
           AND content_valid_status = 1
         GROUP BY robject_id, channel_code
         UNION ALL
         SELECT robject_id,
                channel_code,
                MAX(channel_name)  AS channel_name,
                MAX(CASE
                        WHEN tag_id_path IS NULL THEN tag_name
                        WHEN tag_id IS NULL THEN tag_name_path
                        ELSE CONCAT(tag_name_path, ',', tag_name)
                    END)           AS tag_name_path,
                MAX(content_title) AS resource_name
         FROM nddc.dwd__talr__channel_content_tag_flat__d__full
         WHERE dt = '${biz_date}'
           AND product_code = 'zxx'
           AND channel_code NOT IN ('course', 'experiment')
           AND content_type = 'resource'
           AND content_status = 1
           AND content_deleted = 0
           AND robject_status = 1
           AND content_valid_status = 1
         GROUP BY robject_id, channel_code
     )
SELECT *
FROM (
         SELECT vd.resource_id
              , rd.resource_name
              , rd.channel_code
              , rd.channel_name
              , rd.tag_name_path
              , vd.detail_visit_count
              , ROW_NUMBER() OVER (PARTITION BY rd.channel_code ORDER BY vd.detail_visit_count DESC) AS rk
         FROM visit_data vd
                  INNER JOIN resource_data rd
                             ON vd.resource_id = rd.robject_id
     ) a
WHERE rk <= 10
;
