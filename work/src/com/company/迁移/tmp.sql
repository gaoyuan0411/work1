
WITH tmp__dim__talr__channel AS (
    --拆分国家课、精品课
    SELECT stat_time,
           created_time,
           created_date,
           last_modified_time,
           last_modified_date,
           channel_code,
           channel_name,
           channel_type,
           channel_order,
           disabled,
           default_generate_type,
           default_generate_type_name,
           product_id,
           product_name,
           product_code
    FROM nddc.dim__talr__channel
    WHERE channel_code != 'course'
          -- 拆分自主学习下的国家课和精品课
    UNION ALL
    SELECT NULL                                      stat_time,
           NULL                                      created_time,
           NULL                                      created_date,
           NULL                                      last_modified_time,
           NULL                                      last_modified_date,
           'course_national'                      AS channel_code,
           '学生自主学习(国家课)'                          AS channel_name,
           'normal'                               AS channel_type,
           3                                      AS channel_order,
           0                                      AS disabled,
           'national'                             AS default_generate_type,
           '国家课程'                                 AS default_generate_type_name,
           'e5649925-441d-4a53-b525-51a2f1c4e0a8' AS product_id,
           '国家中小学智慧教育平台'                          AS product_name,
           'zxx'                                  AS product_code
    UNION ALL
    SELECT NULL                                      stat_time,
           NULL                                      created_time,
           NULL                                      created_date,
           NULL                                      last_modified_time,
           NULL                                      last_modified_date,
           'course_elite'                         AS channel_code,
           '学生自主学习(精品课)'                          AS channel_name,
           'normal'                               AS channel_type,
           3                                      AS channel_order,
           0                                      AS disabled,
           'national'                             AS default_generate_type,
           '国家课程'                                 AS default_generate_type_name,
           'e5649925-441d-4a53-b525-51a2f1c4e0a8' AS product_id,
           '国家中小学智慧教育平台'                          AS product_name,
           'zxx'                                  AS product_code
),
     resource_info AS (
         select a.* from (
                             SELECT content_id,
                                    robject_id,
                                    content_type,
                                    content_type_name,
                                    content_standard_sub_type,
                                    content_standard_sub_type_name,
                                    content_sub_type,
                                    content_sub_type_name,
                                    channel_code,
                                    channel_name,
                                    new_tag_id                           AS tag_id,
                                    CONCAT(tag_id_path, ',', cct.tag_id) AS full_tag_id_path,
                                    product_id,
                                    product_name,
                                    product_code,
                                    generate_type,
                                    unational_quality_course,
                                    lesson_type,
                                    CASE
                                        WHEN cct.channel_code = 'course' AND cct.lesson_type = 'national_lesson'
                                            THEN 'course_national'
                                        WHEN cct.channel_code = 'course' AND cct.lesson_type = 'elite_lesson' THEN 'course_elite'
                                        ELSE cct.channel_code END        AS show_channel_code
                             FROM (
                                      SELECT content_id,
                                             robject_id,
                                             content_type,
                                             content_type_name,
                                             content_standard_sub_type,
                                             content_standard_sub_type_name,
                                             content_sub_type,
                                             content_sub_type_name,
                                             channel_code,
                                             channel_name,
                                             tag_id,
                                             tag_id_path,
                                             product_id,
                                             product_name,
                                             product_code,
                                             generate_type,
                                             unational_quality_course,
                                             lesson_type
                                      FROM dim__talr__channel_content
                                      WHERE dt = '${biz_date}'
                                        AND site_type = 'zxx'
                                        AND product_code = 'zxx'
                                        AND content_type IS NOT NULL
                                        AND has_parent_resource IS NOT NULL
                                        AND content_standard_sub_type IS NOT NULL
                                        AND content_status = 1
                                        AND content_type = 'resource'
                                        AND unational_quality_course = 0
                                        and  container_id <> 'elearning-library_ncet-xedu_c3ad12f9-1139-4f39-815e-5eae8a4c7824'
                                        AND ((tag_visible = 1
                                          AND channel_code IN
                                              ('basicWork', 'experiment', 'eduReform', 'family', 'schoolService', 'sedu', 'sport',
                                               'teacherTraining',
                                               'localChannel', 'art', 'labourEdu', 'prepare_lesson', 'tchMaterial',
                                               'resourceProvider')
                                                 )
                                          OR (tag_visible = 1 AND channel_code = 'course' AND lesson_type = 'national_lesson')
                                          OR (channel_code = 'course' AND lesson_type = 'elite_lesson')
                                          )
                                      UNION ALL
                                      SELECT content_id,
                                             robject_id,
                                             content_type,
                                             content_type_name,
                                             content_standard_sub_type,
                                             content_standard_sub_type_name,
                                             content_sub_type,
                                             content_sub_type_name,
                                             channel_code,
                                             channel_name,
                                             tag_id,
                                             tag_id_path,
                                             product_id,
                                             product_name,
                                             product_code,
                                             generate_type,
                                             unational_quality_course,
                                             lesson_type
                                      FROM dwd__talr__channel_content_tag_flat__d__full
                                      WHERE dt = '${biz_date}'
                                        AND site_type = 'zxx'
                                        AND product_code = 'zxx'
                                        AND content_sub_type = 'x_url'
                                        AND content_type IS NOT NULL
                                        AND has_parent_resource IS NOT NULL
                                        AND content_standard_sub_type IS NOT NULL
                                        AND content_status = 0
                                        AND content_type = 'resource'
                                        AND unational_quality_course = 0
                                        AND tag_visible = 1
                                        and  container_id <> 'elearning-library_ncet-xedu_c3ad12f9-1139-4f39-815e-5eae8a4c7824'
                                        AND channel_code IN
                                            ('course', 'basicWork', 'experiment', 'eduReform', 'family', 'schoolService', 'sedu',
                                             'sport',
                                             'teacherTraining',
                                             'localChannel', 'art', 'labourEdu', 'prepare_lesson', 'tchMaterial',
                                             'resourceProvider')
                                      UNION ALL
                                      SELECT content_id,
                                             robject_id,
                                             content_type,
                                             content_type_name,
                                             content_standard_sub_type,
                                             content_standard_sub_type_name,
                                             content_sub_type,
                                             content_sub_type_name,
                                             channel_code,
                                             channel_name,
                                             tag_id,
                                             tag_id_path,
                                             product_id,
                                             product_name,
                                             product_code,
                                             generate_type,
                                             unational_quality_course,
                                             lesson_type
                                      FROM dim__talr__channel_content
                                      WHERE dt = '${biz_date}'
                                        AND site_type = 'zxx'
                                        AND product_code = 'zxx'
                                        AND content_type = 'course'
                                        AND has_parent_resource IS NOT NULL
                                        AND content_standard_sub_type IS NOT NULL
                                        AND content_status = 1
                                        AND unational_quality_course = 0
                                        and  container_id <> 'elearning-library_ncet-xedu_c3ad12f9-1139-4f39-815e-5eae8a4c7824'
                                        AND tag_visible = 1
                                        AND channel_code IN ('labourEdu')
                                  ) cct
                                      LATERAL VIEW EXPLODE(
                                              SPLIT(IF(tag_id_path IS NULL, tag_id, CONCAT(tag_id_path, ',', tag_id)),
                                                    ',')) new_tag AS new_tag_id
                         ) a
                           where a.robject_id NOT IN (select  resource_id  from nddc.dwt__talr__static_no_include_content__full )
     )
        ,
--容量
     capacity_data AS (
         SELECT t.resource_id, CAST(MAX(t.capacity) AS BIGINT) AS capacity
         FROM (
                  SELECT COALESCE(t1.resource_id, t2.resource_id) AS resource_id,
                         COALESCE(t1.capacity, t2.capacity)       AS capacity
                  FROM (
                           SELECT t.resource_id, t.ti_size AS capacity
                           FROM nddc.dwt__xedu_ndr_resource__resource_version__mdb__full t
                           WHERE t.dt = '${biz_date}'
                             AND t.ti_file_flag = 'source'
                       ) t1
                           FULL OUTER JOIN (
                      SELECT t.identity AS resource_id, t.filesize AS capacity
                      FROM nddc.ods__xedu_cloud__mysql__c_document t
                      WHERE t.dt = '${biz_date}'
                      UNION ALL
                      SELECT t.identity AS resource_id, t.filesize AS capacity
                      FROM nddc.ods__xedu_cloud__mysql__c_video t
                      WHERE t.dt = '${biz_date}'
                  ) t2 ON t1.resource_id = t2.resource_id
              ) t
         GROUP BY t.resource_id
     )

     -- 资源与资源实际存储在ndr和基础平台的id关系
        ,
     resource_src_data AS (
         SELECT id AS resource_id, GET_JSON_OBJECT(t.ext_info, '$.target_id') AS src_resource_id
         FROM nddc.ods__x_activity_api__activ_ext__mysql__full t
         WHERE t.dt = '${biz_date}'
           AND GET_JSON_OBJECT(t.ext_info, '$.target_id') IS NOT NULL
         UNION ALL
         SELECT id AS resource_id, GET_JSON_OBJECT(t.property_values, '$.resourceId.value') AS src_resource_id
         FROM nddc.ods__content_mgr__mysql__content t
         WHERE t.dt = '${biz_date}'
           AND GET_JSON_OBJECT(t.property_values, '$.resourceId.value') IS NOT NULL
     ),
     capacity_info AS (
         SELECT t1.*, tag.is_leaf AS is_leaf, CAST(COALESCE(t2.capacity, t3.capacity) AS BIGINT) AS capacity
         FROM (
                  SELECT t1.*, t1.robject_id AS resource_id, t2.src_resource_id
                  FROM resource_info t1
                           LEFT JOIN resource_src_data t2 ON t1.robject_id = t2.resource_id
                  WHERE t1.content_standard_sub_type IN ('document', 'audio_video', 'image')
              ) t1
                  LEFT JOIN capacity_data t2 ON COALESCE(t1.resource_id,'') = COALESCE(t2.resource_id,'')
                  LEFT JOIN capacity_data t3 ON COALESCE(t1.src_resource_id,'') = COALESCE(t3.resource_id,'')
                  LEFT JOIN
              (SELECT *
               FROM dim__talr__channel_tag
               WHERE dt = '${biz_date}'
--                  and tag_visible = 1
              ) tag ON COALESCE(t1.tag_id,'') = COALESCE(tag.tag_id,'')
     ),
     --特殊资源信息（学习任务单，课后练习,精品课下微课视频）
     special_resouece_info AS (
         SELECT ri.*, t4.title
         FROM resource_info ri
                  INNER JOIN (
             SELECT DISTINCT t3.resource_id, t3.tag, t1.title
             FROM (
                      SELECT *
                      FROM nddc.ods__auxo_tag__e_view_tag__mysql__full evt
                      WHERE evt.dt = '${biz_date}'
                        AND evt.parent_id = 'bklx'
                        AND evt.title IN ('课后练习', '学习任务单', '微课视频', '作业练习','实验视频')
                  ) t1
                      INNER JOIN (
                 SELECT *
                 FROM (
                          SELECT resource_id, tag_ids
                          FROM nddc.dwt__talr__ndr_container_resource_relation__d__full pcrt
                          WHERE dt = '${biz_date}'
                            AND tenant_id = '1'
                      ) t2
                          LATERAL VIEW POSEXPLODE(tag_ids) t AS pos, tag
             ) t3 ON t1.tag_id = t3.tag
         ) t4 ON ri.robject_id = t4.resource_id
     ),
     --课时课包资源信息
     lesson_resource AS (
         SELECT *,
                CASE
                    WHEN channel_code = 'course' AND content_sub_type = 'national_lesson' THEN 'course_national'
                    WHEN channel_code = 'course' AND content_sub_type = 'elite_lesson' THEN 'course_elite'
                    ELSE channel_code END AS show_channel_code
         FROM dwd__resource_structure__course_lesson__d__full t
                  LATERAL VIEW EXPLODE(
                          SPLIT(IF(tag_id_path IS NULL, tag_id, CONCAT(tag_id_path, ',', tag_id)), ',')) new_tag AS new_tag_id
         WHERE dt = '${biz_date}'
           AND site_type = 'zxx'
           AND product_code = 'zxx'
           and (
               (channel_code = 'prepare_lesson' and is_catalog_visible =1 )
                   or (channel_code='course' and content_sub_type = 'national_lesson' and is_catalog_visible =1)
               or (channel_code = 'course' AND content_sub_type = 'elite_lesson')
               )
--            AND channel_code IN ('course', 'prepare_lesson')
--            AND unational_quality_course = 0
     ),
     resource_stat AS (
         --资源分类型统计
         SELECT NVL(generate_type, 'ALL')             AS generate_type
              , NVL(show_channel_code, 'ALL')         AS show_channel_code
              , NVL(content_sub_type, 'ALL')          AS content_sub_type
              , NVL(content_standard_sub_type, 'ALL') AS content_standard_sub_type
              , NVL(tag_id, 'ALL')                    AS tag_id
              , COUNT(DISTINCT content_id)            AS resource_count
         FROM resource_info
         GROUP BY generate_type, show_channel_code, content_sub_type, content_standard_sub_type, tag_id
             GROUPING SETS (
             ( generate_type, show_channel_code, content_sub_type, content_standard_sub_type, tag_id),
             ( generate_type, show_channel_code, content_sub_type, content_standard_sub_type),
             ( generate_type, show_channel_code, tag_id),
             ( generate_type, show_channel_code)
             )
         UNION ALL
         SELECT NVL(generate_type, 'ALL')             AS generate_type
              , NVL(show_channel_code, 'ALL')         AS show_channel_code
              , NVL(content_sub_type, 'ALL')          AS content_sub_type
              , NVL(content_standard_sub_type, 'ALL') AS content_standard_sub_type
              , NVL(new_tag_id, 'ALL')                AS tag_id
              , COUNT(DISTINCT content_id)            AS resource_count
         FROM lesson_resource a
         GROUP BY generate_type, show_channel_code, content_sub_type, content_standard_sub_type, new_tag_id
             GROUPING SETS (
             ( generate_type, show_channel_code, content_sub_type, content_standard_sub_type, new_tag_id),
             ( generate_type, show_channel_code, content_sub_type, content_standard_sub_type),
             ( generate_type, show_channel_code, new_tag_id),
             ( generate_type, show_channel_code)
             )

         UNION ALL
         SELECT NVL(generate_type, 'ALL')     AS generate_type
              , NVL(show_channel_code, 'ALL') AS show_channel_code
              , '1'                           AS content_sub_type
              , '1'                           AS content_standard_sub_type
              , NVL(new_tag_id, 'ALL')        AS tag_id
              , COUNT(DISTINCT content_id)    AS resource_count
         FROM lesson_resource a
         WHERE is_catalog_visible = 1
           AND content_standard_sub_type = 'lesson'
         and show_channel_code='course_elite'
         GROUP BY generate_type, show_channel_code, content_sub_type, content_standard_sub_type, new_tag_id
             GROUPING SETS (
             ( generate_type, show_channel_code, content_sub_type, content_standard_sub_type, new_tag_id),
             ( generate_type, show_channel_code, content_sub_type, content_standard_sub_type)
             )
         UNION ALL
         SELECT NVL(generate_type, 'ALL')     AS generate_type
              , NVL(show_channel_code, 'ALL') AS show_channel_code
              , NVL(title, 'ALL')             AS content_sub_type
              , NVL(title, 'ALL')             AS content_standard_sub_type
              , NVL(tag_id, 'ALL')            AS tag_id
              , COUNT(DISTINCT content_id)    AS resource_count
         FROM special_resouece_info
         GROUP BY generate_type, show_channel_code, title, tag_id
             GROUPING SETS (
             ( generate_type, show_channel_code, title, tag_id),
             ( generate_type, show_channel_code, title),
             ( generate_type, show_channel_code, tag_id),
             ( generate_type, show_channel_code)
             )
     ),
     resource_stat_tmp01 AS (
         SELECT generate_type
              , show_channel_code
              , tag_id
--               , SUM(IF(content_sub_type = 'ALL', resource_count, 0))                     AS resource_total_count
              , SUM(IF(content_sub_type = 'ALL' AND
                       show_channel_code NOT IN ('course_national', 'course_elite', 'prepare_lesson'), resource_count,
                       0))                                                                                      AS resource_count
              , SUM(IF(content_standard_sub_type = 'lesson', resource_count, 0))                                AS lesson_count
              , SUM(IF(content_standard_sub_type = '1', resource_count, 0))                                     AS catalog_visible_lesson_count
              , SUM(IF(content_sub_type = 'ALL' AND (show_channel_code = 'basicWork' OR show_channel_code = 'tchMaterial'),
                       resource_count, 0))                                                                      AS volume_count
              , SUM(IF(content_standard_sub_type = 'course_package', resource_count, 0))                        AS course_package_count
              , SUM(IF(content_sub_type = 'assets_video', resource_count, 0))                                   AS video_course_count
              , SUM(IF(content_sub_type = 'coursewares' OR content_sub_type = '课件', resource_count,
                       0))                                                                                      AS courseware_count
              , SUM(IF(content_sub_type = 'lesson_plandesign' OR content_sub_type = '教学设计', resource_count,
                       0))                                                                                      AS instructional_design_count
              , SUM(IF(content_sub_type = '学习任务单', resource_count, 0))                                          AS task_sheet_count
              , SUM(IF(content_sub_type = '课后练习' OR content_sub_type = '作业练习', resource_count, 0))              AS afterclass_exercises_count
              , SUM(IF(content_standard_sub_type = 'exercises', resource_count, 0))                             AS exercises_count
              , SUM(IF(content_sub_type = 'micro_lesson' OR content_sub_type = '微课视频', resource_count,
                       0))                                                                                      AS micro_lesson_count
              ,SUM(IF(content_sub_type = '实验视频', resource_count, 0))                                          AS experiment_video_count
              , SUM(IF(content_sub_type = 'classroom_record', resource_count, 0))                               AS classroom_recording_count
              , SUM(IF(content_sub_type IN ('coursewares', 'assets_teaching', 'micro_lesson', 'homework_assignment'),
                       resource_count,
                       0))                                                                                      AS teaching_resource_count
              , SUM(IF(content_standard_sub_type = 'exercises', resource_count, 0))                             AS course_exercises_count
              , SUM(IF(content_standard_sub_type = 'internal_url', resource_count, 0))                          AS internal_url_count
              , SUM(IF(content_standard_sub_type = 'url', resource_count, 0))                                   AS out_url_count
              , SUM(IF(content_standard_sub_type = 'document', resource_count, 0))                              AS document_count
              , SUM(IF(content_standard_sub_type = 'audio_video', resource_count, 0))                           AS audio_video_count
              , SUM(IF(content_standard_sub_type = 'article', resource_count, 0))                               AS article_count
              , SUM(IF(content_standard_sub_type = 'image', resource_count, 0))                                 AS image_count
              , SUM(IF(content_standard_sub_type = 'special_course', resource_count, 0))                        AS course_count
         FROM resource_stat
         GROUP BY generate_type, show_channel_code, tag_id
     )
        ,
     --册次数
     volume AS (
         SELECT NVL(generate_type, 'ALL')        AS generate_type
              , NVL(show_channel_code, 'ALL')    AS show_channel_code
              , NVL(tag_id, 'ALL')               AS tag_id
              , COUNT(DISTINCT full_tag_id_path) AS volume_count
         FROM resource_info
         WHERE channel_code IN ('course', 'prepare_lesson')
         GROUP BY generate_type, show_channel_code, tag_id
             GROUPING SETS (
             ( generate_type, show_channel_code, tag_id),
             ( generate_type, show_channel_code)
             )
     )
        ,
     --版本数
     textbook_edition AS (
         SELECT NVL(generate_type, 'ALL')     AS generate_type
              , NVL(show_channel_code, 'ALL') AS show_channel_code
              , NVL(tag_id, 'ALL')            AS tag_id
              , COUNT(DISTINCT edition_id)    AS textbook_edition_count
         FROM (
                  SELECT DISTINCT tag_id_4                      AS edition_id
                                , channel_code
                                , channel_name
                                , new_tag_id                    AS tag_id
                                , generate_type
                                , CASE
                                      WHEN cct.channel_code = 'course' AND cct.lesson_type = 'national_lesson'
                                          THEN 'course_national'
                                      WHEN cct.channel_code = 'course' AND cct.lesson_type = 'elite_lesson' THEN 'course_elite'
                                      ELSE cct.channel_code END AS show_channel_code
                  FROM dwd__talr__channel_content_tag_flat__d__full cct
                           LATERAL VIEW EXPLODE(
                                   SPLIT(IF(tag_id_path IS NULL, tag_id, CONCAT(tag_id_path, ',', tag_id)),
                                         ',')) new_tag AS new_tag_id
                  WHERE dt = '${biz_date}'
--                     AND channel_code IN ('course', 'prepare_lesson')
                    AND tag_original_id_1 <> 'e7bbcefe-0590-11ed-9c79-92fc3b3249d5'
                    AND cct.site_type = 'zxx'
                    AND cct.product_code = 'zxx'
                    AND cct.unational_quality_course = 0
--                     and cct.tag_visible = 1
                    AND ((tag_visible = 1
                      AND channel_code ='prepare_lesson')
                        or (tag_visible=1 and channel_code='course' and lesson_type = 'national_lesson')
                        or (channel_code='course' and lesson_type = 'elite_lesson')
                        )
                  UNION ALL
                  SELECT DISTINCT tag_id_3                      AS edition_id
                                , channel_code
                                , channel_name
                                , new_tag_id                    AS tag_id
                                , generate_type
                                , CASE
                                      WHEN cct.channel_code = 'course' AND cct.lesson_type = 'national_lesson'
                                          THEN 'course_national'
                                      WHEN cct.channel_code = 'course' AND cct.lesson_type = 'elite_lesson' THEN 'course_elite'
                                      ELSE cct.channel_code END AS show_channel_code
                  FROM dwd__talr__channel_content_tag_flat__d__full cct
                           LATERAL VIEW EXPLODE(
                                   SPLIT(IF(tag_id_path IS NULL, tag_id, CONCAT(tag_id_path, ',', tag_id)),
                                         ',')) new_tag AS new_tag_id
                  WHERE dt = '${biz_date}'
--                     AND channel_code IN ('course', 'prepare_lesson')
                    AND tag_original_id_1 = 'e7bbcefe-0590-11ed-9c79-92fc3b3249d5'
                    AND cct.site_type = 'zxx'
                    AND cct.product_code = 'zxx'
                    AND cct.unational_quality_course = 0
                    AND ((tag_visible = 1
                      AND channel_code ='prepare_lesson')
                        or (tag_visible=1 and channel_code='course' and lesson_type = 'national_lesson')
                        or (channel_code='course' and lesson_type = 'elite_lesson')
                        )
              ) a
         GROUP BY generate_type, show_channel_code, tag_id
             GROUPING SETS (
             ( generate_type, show_channel_code, tag_id),
             ( generate_type, show_channel_code)
             )
     ),
--覆盖版本数
     cover_edition AS (
         SELECT 'national'                           AS generate_type
              , channel_code                         AS show_channel_code
              , 'ALL'                                AS tag_id
              , COUNT(DISTINCT teaching_material_id) AS cover_edition_count
         FROM (
                  SELECT t.channel_code
                       , t.channel_name
                       , t.teaching_material_id
                       , t.teaching_material_name
                       , COUNT(DISTINCT t.chapter_id)                                                      chapter_num
                       , COUNT(DISTINCT CASE WHEN t.is_mount_resource = 1 THEN t.chapter_id ELSE NULL END) mount_chapter_num
                       , COUNT(DISTINCT CASE
                                            WHEN t.is_mount_resource = 0 AND t.is_parent_mount_resource = 1 THEN t.chapter_id
                                            ELSE NULL END)                                AS               parent_mount_chapter_num
                       , COUNT(DISTINCT CASE
                                            WHEN t.is_mount_resource = 1 OR t.is_parent_mount_resource = 1 THEN t.chapter_id
                                            ELSE NULL END)                                AS               total_mount_chapter_num
                       , COUNT(DISTINCT CASE
                                            WHEN t.is_mount_resource = 1 OR t.is_parent_mount_resource = 1 THEN t.chapter_id
                                            ELSE NULL END) / COUNT(DISTINCT t.chapter_id) AS               cover_rate
                  FROM nddc.dws__talr__channel_content_chapter_stat__da__full t
                  WHERE dt = '${biz_date}'
                  GROUP BY t.channel_code, t.channel_name, t.teaching_material_id, t.teaching_material_name
              ) b
         WHERE b.cover_rate >= 0.75
         GROUP BY channel_code
     ),
     --全部频道资源总数计算
     all_channel_resource AS (
         SELECT generate_type
              , 'ALL'                      AS show_channel_code
              , 'ALL'                      AS tag_id
              , COUNT(DISTINCT content_id) AS resource_total_count
         FROM (
                  SELECT generate_type, show_channel_code, content_id
                  FROM lesson_resource
                  WHERE channel_code = 'course'
                    AND content_standard_sub_type = 'lesson'
                  UNION ALL
                  SELECT generate_type, show_channel_code, content_id
                  FROM lesson_resource
                  WHERE channel_code = 'prepare_lesson'
                    AND content_standard_sub_type = 'course_package'
                  UNION ALL
                  SELECT generate_type, show_channel_code, content_id
                  FROM resource_info
                  WHERE channel_code NOT IN ('course', 'prepare_lesson', 'basicWork')
                    AND content_standard_sub_type NOT IN ('url', 'internal_url')
                    AND generate_type <> 'ugc'
                  UNION ALL
                  SELECT generate_type, show_channel_code, content_id
                  FROM resource_info
                  WHERE channel_code = 'basicWork'
--                         AND content_standard_sub_type NOT IN ('url', 'internal_url')
--                         AND generate_type <> 'ugc'
              ) t
         GROUP BY generate_type
     ),
     capacity_stat AS (
         SELECT generate_type
              , show_channel_code
              , tag_id
              , SUM(capacity) AS capacity
         FROM capacity_info
         GROUP BY generate_type, show_channel_code, tag_id
         UNION ALL
         SELECT generate_type
              , NVL(show_channel_code, 'ALL') AS show_channel_code
              , NVL(tag_id, 'ALL')            AS tag_id
              , SUM(capacity)                 AS capacity
         FROM capacity_info
         WHERE is_leaf = 1
           AND generate_type <> 'ugc'
         GROUP BY generate_type, show_channel_code, tag_id
             GROUPING SETS (
                (generate_type, show_channel_code)
                , (generate_type)
             )
         UNION ALL
         SELECT generate_type
              , NVL(show_channel_code, 'ALL') AS show_channel_code
              , NVL(tag_id, 'ALL')            AS tag_id
              , SUM(capacity)                 AS capacity
         FROM capacity_info
         WHERE generate_type = 'ugc'
           AND tag_id IN ('resourceProvider/e5649925-441d-4a53-b525-51a2f1c4e0a8-inst-studio',
                          'teacherTraining/dae2b8ef-87c4-4d49-b49a-a898fba01c65/e5649925-441d-4a53-b525-51a2f1c4e0a8-teach-studio/2-e5649925-441d-4a53-b525-51a2f1c4e0a8-teach-studio-2',
                          'teacherTraining/dae2b8ef-87c4-4d49-b49a-a898fba01c65/e5649925-441d-4a53-b525-51a2f1c4e0a8-teach-studio/1-e5649925-441d-4a53-b525-51a2f1c4e0a8-teach-studio-1',
                          'teacherTraining/e5649925-441d-4a53-b525-51a2f1c4e0a8-expert-studio/edb3116b-cb12-4094-9117-c46ccda9c0be'
             )
         GROUP BY generate_type, show_channel_code, tag_id
             GROUPING SETS (
                (generate_type, show_channel_code)
                , (generate_type)
             )
     )
        ,
     resource_stat_tmp_02 AS (
         SELECT generate_type
              , show_channel_code
              , tag_id
              , SUM(resource_total_count - internal_url_count - out_url_count) AS resource_total_count
              , SUM(resource_count - course_count)                             AS resource_count
              , SUM(lesson_count)                                              AS lesson_count
              , SUM(catalog_visible_lesson_count)                              AS catalog_visible_lesson_count
              , SUM(volume_count)                                              AS volume_count
              , SUM(textbook_edition_count)                                    AS textbook_edition_count
              , SUM(course_package_count)                                      AS course_package_count
              , SUM(video_course_count)                                        AS video_course_count
              , SUM(courseware_count)                                          AS courseware_count
              , SUM(instructional_design_count)                                AS instructional_design_count
              , SUM(task_sheet_count)                                          AS task_sheet_count
              , SUM(afterclass_exercises_count)                                AS afterclass_exercises_count
              , SUM(exercises_count)                                           AS exercises_count
              , SUM(micro_lesson_count)                                        AS micro_lesson_count
              , sum(experiment_video_count) as experiment_video_count
              , SUM(cover_edition_count)                                       AS cover_edition_count
              , SUM(classroom_recording_count)                                 AS classroom_recording_count
              , SUM(teaching_resource_count)                                   AS teaching_resource_count
              , SUM(course_exercises_count)                                    AS course_exercises_count
              , SUM(teaching_exercises_count)                                  AS teaching_exercises_count
              , SUM(internal_url_count)                                        AS internal_url_count
              , SUM(out_url_count)                                             AS out_url_count
              , SUM(document_count)                                            AS document_count
              , SUM(audio_video_count)                                         AS audio_video_count
              , SUM(article_count)                                             AS article_count
              , SUM(image_count)                                               AS image_count
              , SUM(capacity)                                                  AS capacity
         FROM (
                  SELECT generate_type
                       , show_channel_code
                       , tag_id

                       , CASE
                             WHEN show_channel_code IN ('course_national', 'course_elite') THEN lesson_count
                             WHEN show_channel_code = 'prepare_lesson' THEN course_package_count
                             WHEN generate_type = 'ugc' THEN audio_video_count + document_count + article_count + image_count +
                                                             out_url_count + internal_url_count
                             ELSE resource_count END AS resource_total_count
                       , resource_count
                       , lesson_count
                       , catalog_visible_lesson_count
                       , volume_count
                       , 0                           AS textbook_edition_count
                       , course_package_count
                       , video_course_count
                       , courseware_count
                       , instructional_design_count
                       , task_sheet_count
                       , afterclass_exercises_count
                       , exercises_count
                       , micro_lesson_count
                       ,experiment_video_count
                       , 0                           AS cover_edition_count
                       , classroom_recording_count
                       , teaching_resource_count
                       , course_exercises_count
                       , 0                           AS teaching_exercises_count
                       , internal_url_count
                       , out_url_count
                       , document_count
                       , audio_video_count
                       , article_count
                       , image_count
                       , course_count
                       , 0                           AS capacity
                  FROM resource_stat_tmp01
--                   UNION ALL
--                   SELECT generate_type
--                        , 'course_national'                      AS show_channel_code
--                        , REPLACE(tag_id, 'exercises', 'course') AS tag_id
--
--                        , 0                                      AS resource_total_count
--                        , 0                                      AS resource_count
--                        , 0                                      AS lesson_count
--                        , 0 as  catalog_visible_lesson_count
--                        , 0                                      AS volume_count
--                        , 0                                      AS textbook_edition_count
--                        , 0                                      AS course_package_count
--                        , 0                                      AS video_course_count
--                        , 0                                      AS courseware_count
--                        , 0                                      AS instructional_design_count
--                        , 0                                      AS task_sheet_count
--                        , 0                                      AS afterclass_exercises_count
--                        , exercises_count
--                        , 0                                      AS micro_lesson_count
--                        , 0                                      AS cover_edition_count
--                        , 0                                      AS classroom_recording_count
--                        , 0                                      AS teaching_resource_count
--                        , 0                                      AS course_exercises_count
--                        , 0                                      AS teaching_exercises_count
--                        , 0                                      AS internal_url_count
--                        , 0                                      AS out_url_count
--                        , 0                                      AS document_count
--                        , 0                                      AS audio_video_count
--                        , 0                                      AS article_count
--                        , 0                                      AS image_count
--                        , 0                                      AS course_count
--                        ,0 as capacity
--                   FROM resource_stat_tmp01
--                   WHERE show_channel_code = 'exercises'
                  UNION ALL
                  SELECT generate_type
                       , show_channel_code
                       , tag_id

                       , 0 AS resource_total_count
                       , 0 AS resource_count
                       , 0 AS lesson_count
                       , 0 AS catalog_visible_lesson_count
                       , volume_count
                       , 0 AS textbook_edition_count
                       , 0 AS course_package_count
                       , 0 AS video_course_count
                       , 0 AS courseware_count
                       , 0 AS instructional_design_count
                       , 0 AS task_sheet_count
                       , 0 AS afterclass_exercises_count
                       , 0 AS exercises_count
                       , 0 AS micro_lesson_count
                       ,0 as experiment_video_count
                       , 0 AS cover_edition_count
                       , 0 AS classroom_recording_count
                       , 0 AS teaching_resource_count
                       , 0 AS course_exercises_count
                       , 0 AS teaching_exercises_count
                       , 0 AS internal_url_count
                       , 0 AS out_url_count
                       , 0 AS document_count
                       , 0 AS audio_video_count
                       , 0 AS article_count
                       , 0 AS image_count
                       , 0 AS course_count
                       , 0 AS capacity
                  FROM volume
                  UNION ALL
                  SELECT generate_type
                       , show_channel_code
                       , tag_id

                       , 0 AS resource_total_count
                       , 0 AS resource_count
                       , 0 AS lesson_count
                       , 0 AS catalog_visible_lesson_count
                       , 0 AS volume_count
                       , textbook_edition_count
                       , 0 AS course_package_count
                       , 0 AS video_course_count
                       , 0 AS courseware_count
                       , 0 AS instructional_design_count
                       , 0 AS task_sheet_count
                       , 0 AS afterclass_exercises_count
                       , 0 AS exercises_count
                       , 0 AS micro_lesson_count
                       ,0 as experiment_video_count
                       , 0 AS cover_edition_count
                       , 0 AS classroom_recording_count
                       , 0 AS teaching_resource_count
                       , 0 AS course_exercises_count
                       , 0 AS teaching_exercises_count
                       , 0 AS internal_url_count
                       , 0 AS out_url_count
                       , 0 AS document_count
                       , 0 AS audio_video_count
                       , 0 AS article_count
                       , 0 AS image_count
                       , 0 AS course_count
                       , 0 AS capacity
                  FROM textbook_edition
                  UNION ALL
                  SELECT generate_type
                       , show_channel_code
                       , tag_id

                       , 0 AS resource_total_count
                       , 0 AS resource_count
                       , 0 AS lesson_count
                       , 0 AS catalog_visible_lesson_count
                       , 0 AS volume_count
                       , 0 AS textbook_edition_count
                       , 0 AS course_package_count
                       , 0 AS video_course_count
                       , 0 AS courseware_count
                       , 0 AS instructional_design_count
                       , 0 AS task_sheet_count
                       , 0 AS afterclass_exercises_count
                       , 0 AS exercises_count
                       , 0 AS micro_lesson_count
                       ,0 as experiment_video_count
                       , cover_edition_count
                       , 0 AS classroom_recording_count
                       , 0 AS teaching_resource_count
                       , 0 AS course_exercises_count
                       , 0 AS teaching_exercises_count
                       , 0 AS internal_url_count
                       , 0 AS out_url_count
                       , 0 AS document_count
                       , 0 AS audio_video_count
                       , 0 AS article_count
                       , 0 AS image_count
                       , 0 AS course_count
                       , 0 AS capacity
                  FROM cover_edition
                  UNION ALL
                  SELECT generate_type
                       , show_channel_code
                       , tag_id

                       , resource_total_count
                       , 0 AS resource_count
                       , 0 AS lesson_count
                       , 0 AS catalog_visible_lesson_count
                       , 0 AS volume_count
                       , 0 AS textbook_edition_count
                       , 0 AS course_package_count
                       , 0 AS video_course_count
                       , 0 AS courseware_count
                       , 0 AS instructional_design_count
                       , 0 AS task_sheet_count
                       , 0 AS afterclass_exercises_count
                       , 0 AS exercises_count
                       , 0 AS micro_lesson_count
                       ,0 as experiment_video_count
                       , 0 AS cover_edition_count
                       , 0 AS classroom_recording_count
                       , 0 AS teaching_resource_count
                       , 0 AS course_exercises_count
                       , 0 AS teaching_exercises_count
                       , 0 AS internal_url_count
                       , 0 AS out_url_count
                       , 0 AS document_count
                       , 0 AS audio_video_count
                       , 0 AS article_count
                       , 0 AS image_count
                       , 0 AS course_count
                       , 0 AS capacity
                  FROM all_channel_resource
                  UNION ALL
                  SELECT generate_type
                       , 'ALL'                   AS show_channel_code
                       , 'ALL'                      tag_id

                       , SUM(audio_video_count + document_count + article_count + image_count + out_url_count +
                             internal_url_count) AS resource_total_count
                       , 0                       AS resource_count
                       , 0                       AS lesson_count
                       , 0                       AS catalog_visible_lesson_count
                       , 0                       AS volume_count
                       , 0                       AS textbook_edition_count
                       , 0                       AS course_package_count
                       , 0                       AS video_course_count
                       , 0                       AS courseware_count
                       , 0                       AS instructional_design_count
                       , 0                       AS task_sheet_count
                       , 0                       AS afterclass_exercises_count
                       , 0                       AS exercises_count
                       , 0                       AS micro_lesson_count
                       ,0 as experiment_video_count
                       , 0                       AS cover_edition_count
                       , 0                       AS classroom_recording_count
                       , 0                       AS teaching_resource_count
                       , 0                       AS course_exercises_count
                       , 0                       AS teaching_exercises_count
                       , 0                       AS internal_url_count
                       , 0                       AS out_url_count
                       , 0                       AS document_count
                       , 0                       AS audio_video_count
                       , 0                       AS article_count
                       , 0                       AS image_count
                       , 0                       AS course_count
                       , 0                       AS capacity
                  FROM resource_stat_tmp01
                  WHERE generate_type = 'ugc'
                    AND tag_id = 'ALL'
                  GROUP BY generate_type
                  UNION ALL
                  SELECT generate_type
                       , show_channel_code
                       , tag_id

                       , 0 AS resource_total_count
                       , 0 AS resource_count
                       , 0 AS lesson_count
                       , 0 AS catalog_visible_lesson_count
                       , 0 AS volume_count
                       , 0 AS textbook_edition_count
                       , 0 AS course_package_count
                       , 0 AS video_course_count
                       , 0 AS courseware_count
                       , 0 AS instructional_design_count
                       , 0 AS task_sheet_count
                       , 0 AS afterclass_exercises_count
                       , 0 AS exercises_count
                       , 0 AS micro_lesson_count
                       ,0 as experiment_video_count
                       , 0 AS cover_edition_count
                       , 0 AS classroom_recording_count
                       , 0 AS teaching_resource_count
                       , 0 AS course_exercises_count
                       , 0 AS teaching_exercises_count
                       , 0 AS internal_url_count
                       , 0 AS out_url_count
                       , 0 AS document_count
                       , 0 AS audio_video_count
                       , 0 AS article_count
                       , 0 AS image_count
                       , 0 AS course_count
                       , capacity
                  FROM capacity_stat
              ) tmp
         GROUP BY generate_type, show_channel_code, tag_id
     ),
     --补充标签信息
     tag_resource AS (
         SELECT rst02.generate_type
              , tdtc1.default_generate_type_name AS generate_type_name
              , rst02.show_channel_code          AS channel_code
              , tdtc.channel_name
              , rst02.tag_id
              , tag.tag_original_id
              , tag.tag_name
              , tag.parent_tag_id
              , tag.parent_tag_original_id
              , tag.parent_tag_name
              , tag.full_parent_tag_ids
              , tag.full_parent_tag_original_ids
              , tag.full_parent_tag_names
              , tag.tag_id_path
              , tag.tag_original_id_path
              , tag.tag_name_path
              , tag.tag_order
              , tag.tag_level
              , IF(tag.tag_original_id IN
                   ('87bc7f7d-2f34-4e42-8fc6-ed6a11755cf9' -- 旧：'2f76b176-0c2b-47bf-83f9-8c532cab5808'      --案例集锦,清单方案要是子节点,变成1
                       , 'fb316f13-1080-4307-b540-e18bed7d90b4' --  旧：'b19c81b3-1fba-415b-a91e-4e186d493a07'
                       , 'edb3116b-cb12-4094-9117-c46ccda9c0be') -- 专家工作室-平台应用
                       OR tag.channel_code IN ('exhibition', 'application', 'elder'), 1, tag.is_leaf)
                                                 AS is_leaf
              , resource_total_count
              , resource_count
              , lesson_count
              , catalog_visible_lesson_count
              , volume_count
              , textbook_edition_count
              , course_package_count
              , video_course_count
              , courseware_count
              , instructional_design_count
              , task_sheet_count
              , afterclass_exercises_count
              , exercises_count
              , micro_lesson_count
              ,experiment_video_count
              , cover_edition_count
              , classroom_recording_count
              , teaching_resource_count
              , course_exercises_count
              , teaching_exercises_count
              , internal_url_count
              , out_url_count
              , document_count
              , audio_video_count
              , article_count
              , image_count
              , capacity
         FROM resource_stat_tmp_02 rst02
                  LEFT JOIN
              (SELECT *
               FROM dim__talr__channel_tag
               WHERE dt = '${biz_date}'
--                  and tag_visible = 1
              ) tag ON rst02.tag_id = tag.tag_id
                  LEFT JOIN (SELECT DISTINCT channel_code, channel_name FROM tmp__dim__talr__channel) tdtc
                            ON rst02.show_channel_code = tdtc.channel_code
                  LEFT JOIN (SELECT DISTINCT default_generate_type, default_generate_type_name FROM tmp__dim__talr__channel) tdtc1
                            ON rst02.generate_type = tdtc1.default_generate_type
     )

    ,
    all_data AS (
SELECT *
              FROM tag_resource
              -- UNION ALL
              -- SELECT *
              -- FROM null_tag_data
              -- ) a
        WHERE tag_original_id NOT IN (
            SELECT tag_id FROM nddc.dwt__talr__front_platform_no_include_tag__full GROUP BY tag_id
        )
          AND channel_code <> 'exercises'
    )
--生成类型特殊处理
INSERT OVERWRITE TABLE ads__resource_structure_content_stat__da__full PARTITION(dt = '${biz_date}')

SELECT CURRENT_TIMESTAMP()                                                                    AS stat_time                    --数据生成时间,
    , t.generate_type                                                                        AS generate_type
    , generate_type_name                                                                     AS generate_type_name
    , channel_code_new                                                                       AS channel_code
    , channel_name_new                                                                       AS channel_name
    -- 生成性类型-需要特殊处理
    , CASE
--            WHEN generate_type = 'ugc' AND channel_code = 'teacherTraining' AND tag_id = 'ALL' THEN 'ALL-0'
          WHEN t.generate_type = 'ugc' AND channel_code_new IN ('expStudio', 'teachStudio') AND tag_level = 1 THEN 'ALL'
    -- 语博空数据的频道处理
          WHEN t.generate_type = 'national' AND
                channel_code IN ('application', 'exhibition') AND tag_level = 0 THEN 'ALL'
          ELSE t.tag_id END
                                                                                              AS tag_id                       --所属频道名称
-- 生成性类型-需要特殊处理
    , CASE
          WHEN t.generate_type = 'ugc' AND channel_code = 'teacherTraining' AND tag_original_id = 'ALL' THEN 'ALL-0'
          WHEN t.generate_type = 'ugc' AND channel_code_new IN ('expStudio', 'teachStudio') AND tag_level = 1 THEN 'ALL'
    -- 语博空数据的频道处理
          WHEN t.generate_type = 'national' AND
                channel_code IN ('application', 'exhibition') AND tag_level = 0 THEN 'ALL'
          ELSE tag_original_id END
                                                                                              AS tag_original_id              --标签原始标识
-- 生成性类型-需要特殊处理
    , CASE
          WHEN t.generate_type = 'ugc' AND channel_code = 'teacherTraining' AND tag_name = '全部' THEN '全部-0'
          WHEN t.generate_type = 'ugc' AND channel_code_new IN ('expStudio', 'teachStudio') AND tag_level = 1 THEN '全部'
    -- 语博空数据的频道处理
          WHEN t.generate_type = 'national' AND
                channel_code IN ('application', 'exhibition') AND tag_level = 0 THEN '全部'
          ELSE tag_name END
                                                                                              AS tag_name                     --标签名称
-- 生成性类型-需要特殊处理
    , CASE
          WHEN t.generate_type = 'ugc' AND channel_code_new IN ('expStudio', 'teachStudio') AND tag_level = 1 THEN NULL
          WHEN t.generate_type = 'ugc' AND
                ((channel_code_new = 'expStudio' AND tag_level = 2) OR (channel_code_new = 'teachStudio' AND tag_level = 3))
              THEN 0
          ELSE parent_tag_id END
                                                                                              AS parent_tag_id                --上级标签标识
-- 生成性类型-需要特殊处理
    , CASE
          WHEN t.generate_type = 'ugc' AND channel_code_new IN ('expStudio', 'teachStudio') AND tag_level = 1 THEN NULL
          WHEN t.generate_type = 'ugc' AND
                ((channel_code_new = 'expStudio' AND tag_level = 2) OR (channel_code_new = 'teachStudio' AND tag_level = 3))
              THEN 0
          ELSE parent_tag_original_id END
                                                                                              AS parent_tag_original_id       --上级标签原始标识
    , parent_tag_name                                                                        AS parent_tag_name              --上级标签名称
    , full_parent_tag_ids                                                                    AS full_parent_tag_ids          --完整上级标签标识
    , full_parent_tag_original_ids                                                           AS full_parent_tag_original_ids --完整上级标签原始标识
    , full_parent_tag_names                                                                  AS full_parent_tag_names        --完整上级标签名称
    , tag_id_path                                                                            AS tag_id_path                  --标签标识路径
    , tag_original_id_path                                                                   AS tag_original_id_path         --标签原始标识路径
    , tag_name_path                                                                          AS tag_name_path                --标签名称路径
    , tag_order                                                                              AS tag_order                    --标签排序
-- 生成性类型-需要特殊处理
    , CASE
          WHEN t.generate_type = 'ugc' AND channel_code_new = 'expStudio'
              THEN CASE WHEN tag_level = 1 THEN NULL ELSE tag_level - 1 END
          WHEN t.generate_type = 'ugc' AND channel_code_new = 'teachStudio'
              THEN CASE WHEN tag_level = 1 THEN NULL ELSE tag_level - 2 END -- 由于名师工作室原来标签还有挂有上一级名师名校长标签下，故需要多去除一层关系
          ELSE tag_level END
                                                                                              AS tag_level                    --标签层级
    ,  if (tag_id <> 'ALL' and (internal_url_count+out_url_count+audio_video_count+article_count+image_count+document_count)=0,1,is_leaf)is_leaf                      --是否叶子节点
    , IF(channel_code_new = 'basicWork', resource_count,
          IF(t.generate_type = 'ugc', 0, resource_total_count))                               AS resource_total_count
    , IF(channel_code = 'ALL', resource_total_count, resource_count)                         AS resource_count
    , lesson_count
    , catalog_visible_lesson_count
    , volume_count
    , textbook_edition_count
    , course_package_count
    , video_course_count
    , courseware_count
    , instructional_design_count
    , task_sheet_count
    , afterclass_exercises_count
    , exercises_count
    , micro_lesson_count
    ,experiment_video_count
    , cover_edition_count
    , classroom_recording_count
    , teaching_resource_count
    , course_exercises_count
    , teaching_exercises_count
    , internal_url_count
    , out_url_count
    , document_count
    , audio_video_count
    , article_count
    , image_count
    , capacity
FROM (
        SELECT *,
                -- 生成性类型-频道需要特殊处理
                CASE
                    WHEN generate_type = 'ugc' AND channel_code = 'teacherTraining'
                        THEN CASE
                                WHEN tag_original_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8-expert-studio' OR
                                      full_parent_tag_ids LIKE '%e5649925-441d-4a53-b525-51a2f1c4e0a8-expert-studio%' OR
                                      tag_id_path LIKE '%e5649925-441d-4a53-b525-51a2f1c4e0a8-expert-studio%'
                                    THEN 'expStudio'
                                ELSE 'teachStudio' END
                    ELSE channel_code END AS channel_code_new,
                -- 生成性类型-频道需要特殊处理
                CASE
                    WHEN generate_type = 'ugc' AND channel_code = 'teacherTraining'
                        THEN CASE
                                WHEN tag_original_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8-expert-studio' OR
                                      full_parent_tag_ids LIKE '%e5649925-441d-4a53-b525-51a2f1c4e0a8-expert-studio%' OR
                                      tag_id_path LIKE '%e5649925-441d-4a53-b525-51a2f1c4e0a8-expert-studio%'
                                    THEN '专家工作室'
                                ELSE '名师工作室' END
                    ELSE channel_name END AS channel_name_new
        FROM ( -- 过滤名师工作室或专家工作室下没有的标签（由于教师研修频道下有部分空数据的标签归属问题，需过滤）

                  SELECT *
                  FROM all_data
                  WHERE generate_type != 'ugc'
                    OR (generate_type = 'ugc'
                      AND channel_code IN ('resourceProvider', 'ALL'))
                    OR (generate_type = 'ugc'
                      AND channel_code = 'teacherTraining'
                      AND (tag_original_id IN
                          ('dae2b8ef-87c4-4d49-b49a-a898fba01c65',
                            '1-e5649925-441d-4a53-b525-51a2f1c4e0a8-teach-studio') -- 名师工作室
                          OR full_parent_tag_ids LIKE '%e5649925-441d-4a53-b525-51a2f1c4e0a8-teach-studio%' -- 名师工作室
                          OR tag_original_id =
                            'e5649925-441d-4a53-b525-51a2f1c4e0a8-expert-studio' -- 旧： '9f9a8056-8327-4c78-a6a0-27a8aa56df70'  -- 专家工作室
                          OR full_parent_tag_ids LIKE
                            '%e5649925-441d-4a53-b525-51a2f1c4e0a8-expert-studio%' -- 旧：  '%9f9a8056-8327-4c78-a6a0-27a8aa56df70%'   -- 专家工作室
                            ))
              ) t1
    ) t
WHERE NVL(parent_tag_name, '') <> '平台应用'
