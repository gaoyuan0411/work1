-- 1. 所有中小学的资源（课程下的资源）
-- 2. 所需字段：频道、各级标签、资源名称、资源ID、类型、所属课程、所属学时、已学数量、已学次数
-- 3. 取detail_visit_count字段>0的用户数和detail_visit_count总和
DROP TABLE ads__resource_visit__d__test;
CREATE TABLE IF NOT EXISTS ads__resource_visit__d__test
(
    channel_name                   STRING COMMENT '频道',
    tag_name_1                     STRING COMMENT '标签1',
    tag_name_2                     STRING COMMENT '标签2',
    tag_name_3                     STRING COMMENT '标签3',
    tag_name_4                     STRING COMMENT '标签4',
    tag_name_5                     STRING COMMENT '标签5',
    tag_name_6                     STRING COMMENT '标签6',
    tag_name_7                     STRING COMMENT '标签7',
    content_title                  STRING COMMENT '资源名称',
    robject_id                     STRING COMMENT '资源ID',
    content_standard_sub_type_name STRING COMMENT '类型',
    course_title                   STRING COMMENT '所属课程',
    lesson_title                   STRING COMMENT '所属学时',
    user_count                     BIGINT COMMENT '已学数量',
    visit_count                    BIGINT COMMENT '已学次数'
)
    ROW FORMAT DELIMITED
        FIELDS TERMINATED BY ','
        LINES TERMINATED BY '\n'
    STORED AS TEXTFILE
    LOCATION '/user/nddc_uat/ads__resource_visit__d__test'
    TBLPROPERTIES (
        'serialization.null.format' = ''
        );
WITH resource_visit_info AS (
    SELECT resource_id, SUM(detail_visit_count) AS visit_count, COUNT(DISTINCT user_id) AS user_count
    FROM nddc.dws__resource__resource_visit_detail__full t
    WHERE dt = '${biz_date}'
      AND user_id != 0
      AND detail_visit_count > 0
    GROUP BY resource_id
)
   , resource_info_tmp AS (
    SELECT *
    FROM (
             --资源类
             SELECT robject_id
                  , content_title
                  , content_standard_sub_type_name
                  , channel_name
                  , lesson_robject_id
                  , lesson_title
                  , course_robject_id
                  , course_title
                  , tag_name_1
                  , tag_name_2
                  , tag_name_3
                  , tag_name_4
                  , tag_name_5
                  , tag_name_6
                  , tag_name_7
                  , content_type
                  , ROW_NUMBER() OVER (PARTITION BY robject_id,channel_code,tag_id_1,tag_id_2,tag_id_3,tag_id_4,tag_id_5,tag_id_6,tag_id_7 ORDER BY content_last_modified_date DESC) rk
             FROM nddc.dwd__talr__channel_content_tag_flat__d__full
             WHERE dt = '${biz_date}'
               AND site_type = 'zxx'
               AND product_code = 'zxx'
--                AND content_type = 'resource'
               AND robject_status = 1
               AND content_deleted = 0
         ) t
    WHERE rk = 1
)
   , resource_info AS (
    --资源类
    SELECT robject_id
         , content_title
         , content_standard_sub_type_name
         , channel_name
         , lesson_title
         , course_title
         , tag_name_1
         , tag_name_2
         , tag_name_3
         , tag_name_4
         , tag_name_5
         , tag_name_6
         , tag_name_7
    FROM resource_info_tmp
    WHERE content_type = 'resource'
          --课程类
    UNION ALL
    SELECT c.robject_id
         , c.content_title
         , c.content_standard_sub_type_name
         , c.channel_name
         , c.lesson_title
         , c.course_title
         , c.tag_name_1
         , c.tag_name_2
         , c.tag_name_3
         , c.tag_name_4
         , c.tag_name_5
         , c.tag_name_6
         , c.tag_name_7
    FROM (
             SELECT *
             FROM resource_info_tmp
             WHERE content_type = 'course'
         ) c
             LEFT JOIN (
        SELECT distinct lesson_robject_id
        FROM resource_info_tmp
        WHERE content_type = 'resource'
        and lesson_robject_id <>'-1'
    ) r
                       ON c.robject_id = r.lesson_robject_id
    WHERE r.lesson_robject_id IS NULL
)
INSERT OVERWRITE  TABLE  ads__resource_visit__d__test
SELECT NVL(channel_name, '')                   AS channel_name
     , NVL(tag_name_1, '')                     AS tag_name_1
     , NVL(tag_name_2, '')                     AS tag_name_2
     , NVL(tag_name_3, '')                     AS tag_name_3
     , NVL(tag_name_4, '')                     AS tag_name_4
     , NVL(tag_name_5, '')                     AS tag_name_5
     , NVL(tag_name_6, '')                     AS tag_name_6
     , NVL(tag_name_7, '')                     AS tag_name_7
     , NVL(content_title, '')                  AS content_title
     , robject_id
     , NVL(content_standard_sub_type_name, '') AS content_standard_sub_type_name
     , NVL(course_title, '')                   AS course_title
     , NVL(lesson_title, '')                   AS lesson_title
     , user_count
     , visit_count
FROM resource_info ri
         INNER JOIN resource_visit_info rvi
                    ON ri.robject_id = rvi.resource_id
ORDER BY user_count DESC, visit_count DESC