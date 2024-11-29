/*
需求：https://docs.qq.com/sheet/DZG1xS1dtYUZ1VHFC?tab=BB08J2
工作量评估：https://docs.qq.com/sheet/DRXdXYWVBb3VEUWV6?tab=6muujt
数据范围：
1.课程：七年级（上、下）《数学》、《英语》、《信息技术》
2.用户：随机2-3个班的学生用户
*/
/*
学生、教师、学校等基本信息:
学生ID 学生ID_MD5 学校ID 学校名称 省 市 区
*/
DROP TABLE IF EXISTS `dwd__tmp__student__full`;
CREATE TABLE IF NOT EXISTS `dwd__tmp__student__full` (
  `student_id`       BIGINT COMMENT '学生ID',
  `student_id_md5`   STRING COMMENT '学生ID_MD5',
  `school_id`        BIGINT COMMENT '学校ID',
  `school_name`      STRING COMMENT '学校名称',
  `class_id`         BIGINT COMMENT '班级ID',
  `class_name`       STRING COMMENT '班级名称',
  `province_id`      BIGINT COMMENT '省ID',
  `province_name`    STRING COMMENT '省名称',
  `city_id`          BIGINT COMMENT '市ID',
  `city_name` STRING COMMENT '市名称',
  `county_id` BIGINT COMMENT '区ID',
  `county_name`      STRING COMMENT '区名称'
) COMMENT '学生、教师、学校等基本信息'
;
WITH class_member AS (
    SELECT account_id AS student_id,class_id,class_name,school_id FROM nddc.dwd__md__valid_class_member__d__full
    WHERE dt = '${biz_date}'
      AND class_type = 'CLASS'
      AND class_member_type = 'STUDENT'
      AND grade_name in ('七年级')
--       AND school_section in ('$PRIMARY', '$PRIMARY_FIVE', '$MIDDLE', '$MIDDLE_FOUR', '$HIGH', '$COMPLETE', '$NIGHT_YEAR', '$TWELVE_YEAR')
)
INSERT OVERWRITE TABLE dwd__tmp__student__full
SELECT a.account_id user_id
    , md5(a.account_id)   AS user_id_md5
    , a.school_id
    , a.school_name
    , b.class_id
    , b.class_name
    , a.school_province_id   AS province_id
    , a.school_province_name AS province_name
    , a.school_city_id       AS city_id
    , a.school_city_name     AS city_name
    , a.school_county_id     AS county_id
    , a.school_county_name   AS county_name
FROM nddc.dwd__md__person_account__d__full a
INNER JOIN class_member b ON a.account_id = b.student_id AND a.school_id = b.school_id
WHERE a.dt = '${biz_date}'
  AND a.is_student = 1
  AND a.is_canceled = 0
  AND a.school_id IS NOT NULL
;

-- DROP TABLE IF EXISTS `dwd__tmp__student__full__export`;
-- CREATE TABLE IF NOT EXISTS `dwd__tmp__student__full__export` (
--   `student_id_md5`   STRING COMMENT '学生ID_MD5',
--   `school_name`      STRING COMMENT '学校名称',
--   `province_name`    STRING COMMENT '省名称',
--   `city_name` STRING COMMENT '市名称',
--   `county_name`      STRING COMMENT '区名称'
-- ) COMMENT '学生、教师、学校等基本信息-导出'
-- row format delimited fields terminated by ','
--                       NULL DEFINED AS ''
-- stored as textfile
-- ;
-- SET mapreduce.job.reduces=1;
-- INSERT OVERWRITE TABLE dwd__tmp__student__full__export
SELECT student_id_md5
    , school_name
    , province_name
    , city_name
    , county_name
FROM dwd__tmp__student__full
WHERE class_id in (268963100459009,295631799549953,292182162440193)
ORDER BY school_name
;
/*
习题推荐部分:
习题ID 题干
*/
DROP TABLE IF EXISTS `dwd__tmp__exercise__full`;
CREATE TABLE IF NOT EXISTS `dwd__tmp__exercise__full` (
  `exercise_id` STRING COMMENT '习题ID',
  `exercise_content` STRING COMMENT '题干'
) COMMENT '习题推荐部分';
INSERT OVERWRITE TABLE dwd__tmp__exercise__full
SELECT robject_id AS exercise_id,content_title AS exercise_content
FROM nddc.dwd__talr__channel_content_paper_tag_flat__d__full a
WHERE dt = '${biz_date}'
AND tag_name_path LIKE '%七年级%'
AND (tag_name_path LIKE '%数学%'
     OR tag_name_path LIKE '%英语%'
     OR tag_name_path LIKE '%信息技术%')
-- AND nvl(tag_name_6,'') != '新教材'
;

SELECT exercise_id,
    regexp_replace(regexp_replace(exercise_content, '<[^>]+>', ''),'\\\\','') exercise_content
FROM dwd__tmp__exercise__full;

-- DROP TABLE IF EXISTS `dwd__tmp__exercise__full__export`;
-- CREATE TABLE IF NOT EXISTS `dwd__tmp__exercise__full__export` (
--   `exercise_id` BIGINT COMMENT '习题ID',
--   `exercise_content` STRING COMMENT '题干'
-- ) COMMENT '习题推荐部分-导出'
-- row format delimited fields terminated by ','
--                       NULL DEFINED AS ''
-- stored as textfile
-- ;
-- SET mapreduce.job.reduces=1;
-- INSERT OVERWRITE TABLE dwd__tmp__exercise__full__export
-- SELECT exercise_id
--     , exercise_content
-- FROM dwd__tmp__exercise__full
;
/*
 学生与资源的交互数据:
 学生ID 资源ID 资源名称 答题开始时间 答题完成时间
 */
-- DROP TABLE IF EXISTS `dwd__tmp__student_resource_interaction__full`;
-- CREATE TABLE IF NOT EXISTS `dwd__tmp__student_resource_interaction__full` (
--   `student_id` BIGINT COMMENT '学生ID',
--   `resource_id` BIGINT COMMENT '资源ID',
--   `resource_name` STRING COMMENT '资源名称',
--   `start_time` STRING COMMENT '答题开始时间',
--   `end_time` STRING COMMENT '答题完成时间'
-- ) COMMENT '学生与资源的交互数据'
;

/*
 学生与习题交互部分:
 学生ID 习题ID 题干 答题是否正确 答题次数
 */
DROP TABLE IF EXISTS `dwd__tmp__student_exercise_interaction__full`;
CREATE TABLE IF NOT EXISTS `dwd__tmp__student_exercise_interaction__full` (
  `student_id` BIGINT COMMENT '学生ID',
  `student_id_md5` STRING COMMENT '学生ID_MD5',
  `question_id` STRING COMMENT '题目ID',
  `answer_count` INT COMMENT '答题次数',
  `right_count` INT COMMENT '正确题数'
) COMMENT '学生与习题交互部分';

WITH resource AS (
    SELECT robject_id AS resource_id
    FROM nddc.dwd__talr__channel_content_paper_tag_flat__d__full a
    WHERE dt = '${biz_date}'
    AND tag_name_path LIKE '%七年级%'
    AND (tag_name_path LIKE '%数学%'
         OR tag_name_path LIKE '%英语%'
         OR tag_name_path LIKE '%信息技术%')
--     AND nvl(tag_name_6,'') != '新教材'
)
, user_do_question_record AS (
    SELECT a.user_id AS student_id,a.question_id,a.scope_id, SUM(a.exercises_num) AS answer_num
    FROM nddc.ods__e_exercise_study_reord_api__mysql__user_do_question_record__full a
    INNER JOIN resource b ON a.question_id = b.resource_id
    WHERE dt = '${biz_date}'
--     AND a.create_time >= '2022-09-01 00:00:00' AND a.create_time < '2023-09-01 00:00:00'
    GROUP BY a.user_id,a.question_id,a.scope_id)
, user_wrong_question_record AS (
    SELECT a.user_id AS student_id,a.question_id,a.scope_id, SUM(a.wrong_num) AS wrong_num
    FROM nddc.ods__e_exercise_study_reord_api__mysql__user_wrong_question_record__full a
    INNER JOIN resource b ON a.question_id = b.resource_id
    WHERE a.dt = '${biz_date}'
--     AND a.create_time >= '2022-09-01 00:00:00' AND a.create_time < '2023-09-01 00:00:00'
    GROUP BY a.user_id,a.question_id,a.scope_id)

INSERT OVERWRITE TABLE dwd__tmp__student_exercise_interaction__full
SELECT a.student_id,md5(a.student_id) AS student_id_md5,a.question_id,a.answer_num,a.answer_num - COALESCE(b.wrong_num,0) AS right_num
FROM user_do_question_record a
LEFT JOIN user_wrong_question_record b
ON a.student_id = b.student_id
AND a.question_id = b.question_id
AND a.scope_id = b.scope_id
;
-- DROP TABLE IF EXISTS `dwd__tmp__student_exercise_interaction__full__export`;
-- CREATE TABLE IF NOT EXISTS `dwd__tmp__student_exercise_interaction__full__export` (
--   `student_id_md5` STRING COMMENT '学生ID_MD5',
--   `question_id` STRING COMMENT '题目ID',
--   `answer_count` INT COMMENT '答题次数',
--   `right_count` INT COMMENT '正确题数'
-- ) COMMENT '学生与习题交互部分-导出'
-- row format delimited fields terminated by ','
--                       NULL DEFINED AS ''
-- stored as textfile
-- ;
-- SET mapreduce.job.reduces=1;
WITH class_member AS (
    SELECT student_id FROM dwd__tmp__student__full
    WHERE class_id in (268963100459009,295631799549953,292182162440193)
)
-- INSERT OVERWRITE TABLE dwd__tmp__student_exercise_interaction__full__export
SELECT a.student_id_md5
    , a.question_id
    , a.answer_count
    , a.right_count
FROM dwd__tmp__student_exercise_interaction__full a
INNER JOIN class_member b ON a.student_id = b.student_id
;
/*
 知识图谱:
 教材ID 教材名称 章节ID 章节名称 父章节ID 父章节名称 父章节排序 章节路径 层级 是否叶子节点 排序
 */
DROP TABLE IF EXISTS `dwd__tmp__knowledge_graph__full`;
CREATE TABLE IF NOT EXISTS `dwd__tmp__knowledge_graph__full` (
  `teaching_material_id` STRING COMMENT '教材ID',
  `teaching_material_name` STRING COMMENT '教材名称',
  `chapter_id` STRING COMMENT '章节ID',
  `chapter_name` STRING COMMENT '章节名称',
  `parent_chapter_id` STRING COMMENT '父章节ID',
  `parent_chapter_name` STRING COMMENT '父章节名称',
  `node_path_name` STRING COMMENT '章节路径',
  `level` INT COMMENT '层级',
  `is_leaf` STRING COMMENT '是否叶子节点',
  `sort_str` STRING COMMENT '排序'
) COMMENT '知识图谱'
;

WITH chapter_table AS (
    SELECT t.chapter_id,
        t.chapter_name, t.sort_num
    FROM nddc.dwd__talr__chapter_resource_relation__d__full t
    where t.dt = '${biz_date}'
    AND t.source_type = 'teachingmaterials'
    GROUP BY t.chapter_id,
        t.chapter_name, t.sort_num
)
,teachingmaterials AS (
    SELECT cctf.robject_id AS teaching_material_id
    FROM nddc.dwd__talr__channel_content_tag_flat__d__full cctf
    WHERE cctf.dt = '${biz_date}'
    AND cctf.site_type = 'zxx'
    AND cctf.content_type_name = '课本'
    AND cctf.tag_name_path LIKE '%七年级%'
    AND (tag_name_path LIKE '%数学%'
        OR tag_name_path LIKE '%英语%'
        OR tag_name_path LIKE '%信息技术%')
--     AND nvl(tag_name_6,'') != '新教材'
    AND cctf.channel_code = 'course'
)
,exploded_paths AS (
    SELECT
        t.teaching_material_id,
        t.teaching_material_name,
        t.chapter_id,
        t.chapter_name,
        t.node_path,
        split(t.node_path, '/') AS path_array
    FROM nddc.dwd__talr__chapter_resource_relation__d__full t
    INNER JOIN teachingmaterials tm ON t.teaching_material_id = tm.teaching_material_id
    WHERE t.dt = '${biz_date}'
    AND t.source_type = 'teachingmaterials'
    AND (get_json_object(t.resource_container_status,'$.c2902adb-60f3-465f-a2dd-010be9eed835') = 'ONLINE'
    OR get_json_object(t.resource_container_status,'$.261d3f49-af55-49a0-b0f7-559dfcce514a') = 'ONLINE'
    OR get_json_object(t.resource_container_status,'$.f653886d-4a16-4534-909e-142f8031c6fc') = 'ONLINE'
    OR t.resource_container_status IS NULL)
    GROUP BY t.teaching_material_id,
        t.teaching_material_name,
        t.chapter_id,
        t.chapter_name,
        t.node_path
)
,flattened_paths AS (
    SELECT
        e.teaching_material_id,
        e.teaching_material_name,
        e.chapter_id,
        e.chapter_name,
        e.node_path,
        p.pos,
        p.path_element
    FROM
        exploded_paths e
    LATERAL VIEW posexplode(e.path_array) p AS pos, path_element
)
,joined_names AS (
    SELECT
        f.teaching_material_id,
        f.teaching_material_name,
        f.chapter_id,
        f.chapter_name,
        f.node_path,
        f.pos,
        f.path_element,
        c.chapter_name AS name_part,
        LPAD(c.sort_num, 2, '0') sort
    FROM
        flattened_paths f
    LEFT JOIN
        chapter_table c ON f.path_element = c.chapter_id
)
, resource_chapter AS (
    SELECT
        teaching_material_id,
        teaching_material_name,
        chapter_id,
        node_path,
        concat_ws('->', collect_list(name_part)) AS node_path_name,
        concat_ws('_', collect_list(sort)) AS sort_str
    FROM joined_names
    GROUP BY teaching_material_id,
        teaching_material_name,
        chapter_id,
        node_path
)
, resource_chapter_with_level AS (
    SELECT a.teaching_material_id
    , a.teaching_material_name
    , a.chapter_id
    , a.chapter_name
    , a.parent as parent_chapter_id
    , ct.chapter_name as parent_chapter_name
    , NVL(rc.node_path_name,a.chapter_name) AS node_path_name
    , size(split(a.node_path,'/')) as level
    , IF(a.is_leaf=1,'是','否') as is_leaf
    , rc.sort_str
FROM nddc.dwd__talr__chapter_resource_relation__d__full a
INNER JOIN teachingmaterials tm ON a.teaching_material_id = tm.teaching_material_id
LEFT JOIN chapter_table ct ON a.parent = ct.chapter_id
LEFT JOIN resource_chapter rc ON a.chapter_id = rc.chapter_id AND a.teaching_material_id = rc.teaching_material_id AND a.node_path = rc.node_path
WHERE a.dt = '${biz_date}'
AND a.source_type = 'teachingmaterials'
AND (get_json_object(a.resource_container_status,'$.c2902adb-60f3-465f-a2dd-010be9eed835') = 'ONLINE'
    OR get_json_object(a.resource_container_status,'$.261d3f49-af55-49a0-b0f7-559dfcce514a') = 'ONLINE'
    OR get_json_object(a.resource_container_status,'$.f653886d-4a16-4534-909e-142f8031c6fc') = 'ONLINE'
    OR resource_container_status IS NULL)
GROUP BY a.teaching_material_id
    , a.teaching_material_name
    , a.chapter_id
    , a.chapter_name
    , a.parent
    , ct.chapter_name
    , NVL(rc.node_path_name,a.chapter_name)
    , size(split(a.node_path,'/'))
    , a.is_leaf
    , rc.sort_str
)
INSERT OVERWRITE TABLE dwd__tmp__knowledge_graph__full
SELECT teaching_material_id
    , teaching_material_name
    , chapter_id
    , chapter_name
    , parent_chapter_id
    , parent_chapter_name
    , node_path_name
    , level
    , is_leaf
    , sort_str
FROM resource_chapter_with_level t
;
-- DROP TABLE IF EXISTS `dwd__tmp__knowledge_graph__full__export`;
-- CREATE TABLE IF NOT EXISTS `dwd__tmp__knowledge_graph__full__export` (
--   `teaching_material_name` STRING COMMENT '教材名称',
--   `chapter_name` STRING COMMENT '章节名称',
--   `parent_chapter_name` STRING COMMENT '父章节名称',
--   `node_path_name` STRING COMMENT '章节路径',
--   `level` INT COMMENT '层级',
--   `is_leaf` STRING COMMENT '是否叶子节点',
--   `sort_str` STRING COMMENT '排序'
-- ) COMMENT '知识图谱-导出'
-- row format delimited fields terminated by ','
--                       NULL DEFINED AS ''
-- stored as textfile
-- ;
-- SET mapreduce.job.reduces=1;
-- INSERT OVERWRITE TABLE dwd__tmp__knowledge_graph__full__export
SELECT teaching_material_name
    , chapter_name
    , NVL(parent_chapter_name,'') AS parent_chapter_name
    , node_path_name
    , level
    , is_leaf
    , sort_str FROM dwd__tmp__knowledge_graph__full a
ORDER BY a.teaching_material_id, a.sort_str, a.chapter_name;



