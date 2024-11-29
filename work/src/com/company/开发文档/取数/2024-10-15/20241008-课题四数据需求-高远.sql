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
DROP TABLE IF EXISTS `dwd__tmp__teacher__full`;
CREATE TABLE IF NOT EXISTS `dwd__tmp__teacher__full` (
  `teacher_id`       BIGINT COMMENT '教师ID',
  `teacher_id_md5`   STRING COMMENT '教师ID_MD5',
  `degree`   STRING COMMENT '教师学历',
  `degree_name`   STRING COMMENT '教师学历名称',
  `teacher_subject_code`   STRING COMMENT '教师主讲课程',
  `teacher_subject_name`   STRING COMMENT '教师主讲课程名称',
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
    SELECT account_id AS teacher_id,class_id,class_name,school_id FROM nddc.dwd__md__valid_class_member__d__full
    WHERE dt = '${biz_date}'
      AND class_type = 'CLASS'
      AND class_member_type = 'TEACHER'
      AND grade_name in ('七年级')
--       AND school_section in ('$PRIMARY', '$PRIMARY_FIVE', '$MIDDLE', '$MIDDLE_FOUR', '$HIGH', '$COMPLETE', '$NIGHT_YEAR', '$TWELVE_YEAR')
)
INSERT OVERWRITE TABLE dwd__tmp__teacher__full
SELECT a.account_id teacher_id
    , md5(a.account_id)   AS teacher_id_md5
     ,c.degree
    ,NVL(dge.value_name, '未知') AS degree_name
     ,a.teacher_subject_code
     ,nvl(d.subject_name,'未知')  as teacher_subject_name
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
INNER JOIN class_member b ON a.account_id = b.teacher_id AND a.school_id = b.school_id
INNER JOIN nddc.ods__x_user_profile__mysql__teacher_profile_info__full c
    on b.teacher_id=c.user_id
LEFT JOIN nddc.dim_teacher_verify_info_dict AS dge
          ON dge.value_code = c.degree AND dge.attr_code = 'degree'
LEFT JOIN  (
          select distinct t.tag_code_3 as subject_code, t.tag_name_3 as subject_name
            from nddc.dim_channel_tag_tree t
           where t.channel_code = 'course'
           union all
          select distinct subject_code,subject_name from nddc.dim_subject_ref where subject_code not like '$%'
      ) d on a.teacher_subject_code=d.subject_code
WHERE a.dt = '${biz_date}'
  AND a.is_verified_teacher = 1
  AND a.is_canceled = 0
  AND a.school_id IS NOT NULL
and c.dt='${biz_date}'
;
-- 教师基本信息
SELECT
    teacher_id,teacher_id_md5,degree_name,teacher_subject_name
from dwd__tmp__teacher__full
where  class_id in (268963100459009,295631799549953,292182162440193)
//课程的基本信息
select  robject_id ,
case when tag_names[2] in ('数学','英语','信息技术') then  tag_names[2]
when tag_names[1] in ('数学','英语','信息技术') then tag_names[1]
end as subject_name
from (
SELECT *,SPLIT(CONCAT_WS(',', tag_name_path, tag_name), ',') tag_names
from nddc.dwd__resource_structure__course_lesson__d__full t
where dt='${biz_date}'
and content_standard_sub_type='course_package'
and tag_name_path like '%七年级%'
) a where tag_names[2] in ('数学','英语','信息技术') or tag_names[1] in ('数学','英语','信息技术')
group by robject_id ,
case when tag_names[2] in ('数学','英语','信息技术') then  tag_names[2]
when tag_names[1] in ('数学','英语','信息技术') then tag_names[1]
end
;
-- 学生学习情况等信息
SELECT a.student_id_md5,b.subject_name,b.unified_exam_id
,max(nvl(cast(c.score as DOUBLE),0)) as score
from
(SELECT *
    from dwd__tmp__student__full
    where class_id in (268963100459009,295631799549953,292182162440193)
    )a
     inner join (
         SELECT *
         FROM nddc.ods__score_api__mysql__unified_exam_class_user_stat__full t
         WHERE dt = '${biz_date}'
           AND score_mode = 0
           AND status <> 1
           AND t.exam_type <> 4
     ) c on a.student_id=c.user_id
     INNER JOIN (
         SELECT *,GET_JSON_OBJECT(course, '$[0].name')  as subject_name
         from nddc.ods__score_api__mysql__unified_exam__full
         where dt='${biz_date}'
         and exam_type <> 4
         and score_mode=0

     ) b on b.unified_exam_id=c.unified_exam_id
GROUP BY   a.student_id_md5,b.subject_name,b.unified_exam_id
ORDER BY  a.student_id_md5 desc;

--视频部分
SELECT b.content_id,b.robject_id, b.content_title,c.resource_duration
from (
         SELECT content_id,robject_id, content_title
         FROM (
                  SELECT *, SPLIT(CONCAT_WS(',', tag_name_path, tag_name), ',') tag_names
                  FROM nddc.dim__talr__channel_content
                  WHERE dt = '${biz_date}'
                    AND content_type = 'resource'
                    AND content_standard_sub_type = 'audio_video'
                    AND tag_name_path LIKE '%七年级%'
              ) a
         WHERE tag_names[2] IN ('数学', '英语', '信息技术')
            OR tag_names[1] IN ('数学', '英语', '信息技术')
     ) b INNER JOIN (
         select * from nddc.dwd__talr__resource_duration__d__full
         where dt='${biz_date}'
           AND resource_tag_names LIKE '%七年级%'
           and resource_duration <> 0
    )c on b.content_id=c.content_id

;

--学生与资源的交互数据
SELECT b.student_id_md5,resource_id,ay_total_play_duration
from (SELECT user_id
           , resource_id
           , ay_total_play_duration
      FROM nddc.dws__talr__user_resource_duration__dd__full
      WHERE dt = '${biz_date}'
        AND user_is_student = 1
        AND resource_type = 'resource'
        AND resource_standard_sub_type = 'audio_video'
        AND resource_duration <> 0
     ) a INNER JOIN (
    SELECT *
        from dwd__tmp__student__full
        where class_id in (268963100459009,295631799549953,292182162440193)
    )  b on a.user_id=b.student_id
;

--学生与视频交互部分
SELECT b.student_id_md5,content_robject_id,'收藏' as type
from (SELECT user_id
           , content_robject_id
      FROM nddc.dwm__ri__favorite__dn__full
      WHERE dt = '${biz_date}'
        AND user_is_student = 1
        AND content_standard_sub_type IN ('course_package', 'lesson')
     ) a INNER JOIN (
    SELECT *
        from dwd__tmp__student__full
        where class_id in (268963100459009,295631799549953,292182162440193)
    )  b on a.user_id=b.student_id
INNER JOIN (
             SELECT content_id,robject_id, content_title
             FROM (
                      SELECT *, SPLIT(CONCAT_WS(',', tag_name_path, tag_name), ',') tag_names
                      FROM nddc.dim__talr__channel_content
                      WHERE dt = '${biz_date}'
                        AND content_standard_sub_type IN ('course_package', 'lesson')
                        AND tag_name_path LIKE '%七年级%'
                  ) d
             WHERE tag_names[2] IN ('数学', '英语', '信息技术')
                OR tag_names[1] IN ('数学', '英语', '信息技术')
    ) c on a.content_robject_id=c.robject_id
UNION ALL
SELECT b.student_id_md5,content_robject_id,'点赞' as type
from (SELECT user_id
           , like_object_id as content_robject_id
      FROM nddc.dwm__ri__user_like__dd__full_v2
      WHERE dt = '${biz_date}'
        AND user_is_student = 1
--         AND content_standard_sub_type IN ('course_package', 'lesson')
     ) a INNER JOIN (
    SELECT *
        from dwd__tmp__student__full
        where class_id in (268963100459009,295631799549953,292182162440193)
    )  b on a.user_id=b.student_id
INNER JOIN (
             SELECT content_id,robject_id, content_title
             FROM (
                      SELECT *, SPLIT(CONCAT_WS(',', tag_name_path, tag_name), ',') tag_names
                      FROM nddc.dim__talr__channel_content
                      WHERE dt = '${biz_date}'
                        AND content_standard_sub_type IN ('course_package', 'lesson')
                        AND tag_name_path LIKE '%七年级%'
                  ) d
             WHERE tag_names[2] IN ('数学', '英语', '信息技术')
                OR tag_names[1] IN ('数学', '英语', '信息技术')
    ) c on a.content_robject_id=c.robject_id


;
--教师教学相关资源和数据
DROP TABLE IF EXISTS `dwd__tmp__event__incr`;
CREATE TABLE IF NOT EXISTS `dwd__tmp__event__incr`
(
    `user_id`           BIGINT COMMENT '用户名称',
    `resource_id`       STRING COMMENT '资源id',
    `ppt_count`         BIGINT COMMENT 'ppt使用次数',
    `touchScreen_count` BIGINT COMMENT '白板使用次数',
    `stat_date`         STRING COMMENT '统计日期'
) COMMENT '上课所使用的资源情况' PARTITIONED BY (
    `dt` STRING COMMENT '日期'
    ) ROW FORMAT DELIMITED NULL DEFINED AS '';
;

INSERT OVERWRITE TABLE dwd__tmp__event__incr PARTITION (dt='${biz_date}')
SELECT user_id
     , resource_id
     , COUNT(IF(event = 'edu_platform_newGotoClass_choose101PPT_click', event, NULL)) AS ppt_count  --ppt使用次数
     , COUNT(IF(event = 'edu_webPlatform_touchScreen_click', event, NULL))            AS touchScreen_count  --白板使用次数
     , '${biz_date}' as stat_date
FROM (SELECT CAST(COALESCE(t.nduser_id, GET_JSON_OBJECT(t.properties, '$.nduser_id')) AS BIGINT) AS user_id,
             GET_JSON_OBJECT(properties, '$.content_id')                                            resource_id,
             event
      FROM nddc.ods__event_data_detail_v2 t
      WHERE dt = '${biz_date}'
        AND event IN ('edu_webPlatform_touchScreen_click', 'edu_platform_newGotoClass_choose101PPT_click')
        AND COALESCE(t.identity, GET_JSON_OBJECT(t.properties, '$.identity'), '') IN (
          SELECT src_code
          FROM nddc.dim__dict_ref
          WHERE ref_type = 'identity'
            AND target_code = 'TEACHER')
     ) a
GROUP BY user_id, resource_id
;
SELECT b.teacher_id_md5,a.resource_id
from (SELECT user_id,resource_id
             from dwd__tmp__event__incr
    GROUP BY user_id,resource_id ) a
INNER JOIN (
    SELECT
        teacher_id,teacher_id_md5
    from dwd__tmp__teacher__full
    where  class_id in (268963100459009,295631799549953,292182162440193)
    ) b on a.user_id=b.teacher_id
GROUP BY b.teacher_id_md5,a.resource_id
;
-- 课后作业及评分
select b.teacher_id_md5,c.student_id_md5,a.activity_original_id,a.assessment_point

from (
                  SELECT activity_original_id, assessment_teacher_id, assessment_user_id,assessment_point
                  FROM nddc.dwd__tala__assessment_user_activity_info__d__full
                  WHERE dt = '${biz_date}'
              ) a
INNER JOIN (
    select teacher_id,teacher_id_md5 from dwd__tmp__teacher__full
    where  class_id in (268963100459009,295631799549953,292182162440193)
    ) b on a.assessment_teacher_id=b.teacher_id
INNER JOIN (
    select student_id,student_id_md5 from dwd__tmp__student__full
    where  class_id in (268963100459009,295631799549953,292182162440193)
    ) c on a.assessment_user_id=c.student_id
;

-- 课程评价(评分或评语可以是专家反馈、教师自评等数据)
SELECT t3.user_id_md5,t2.assessment_object_id,t2.assessment_score
from (
         SELECt a.resource_id
         from dwd__tmp__event__incr a
         INNER JOIN (
             SELECT
                 teacher_id,teacher_id_md5
             from dwd__tmp__teacher__full
             where  class_id in (268963100459009,295631799549953,292182162440193)
             ) b on a.user_id=b.teacher_id
         GROUP BY a.resource_id
         ) t1
    INNER JOIN (
        select assessment_object_id,user_id,assessment_score
        from nddc.dwd__ri__assessment__d__full_v2
        where dt='${biz_date}'
    ) t2 on t1.resource_id=t2.assessment_object_id
INNER JOIN (
    SELECT teacher_id as user_id,teacher_id_md5 as user_id_md5
    from dwd__tmp__teacher__full
    where  class_id in (268963100459009,295631799549953,292182162440193)
    UNION ALL
    select student_id as user_id,student_id_md5 as user_id_md5  from dwd__tmp__student__full
    where  class_id in (268963100459009,295631799549953,292182162440193)
    ) t3 on t2.user_id=t3.user_id