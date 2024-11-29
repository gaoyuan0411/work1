SELECT a.school_id,
       a.ptc,
       a.activity_internal_type,
       a.subject_code,
       a.grade_name,
       a.participate_count,
       a.publish_count,
       SUM(IF(user_identity = 'TEACHER', stat_count, NULL))  AS taecher_publish_count,
       SUM(IF(user_identity != 'TEACHER', stat_count, NULL)) AS student_participate_count
FROM nddc.ads__region_app_teaching_activities_overview_stat_d a
         INNER JOIN
    (select school_id,activity_internal_type,subject_code,grade_name,period_type_code,user_id,max(stat_count) as stat_count
    from nddc_uat.ads__school_activity__activity_user_stat__d
        where dt = '${dt}'
        GROUP BY school_id,activity_internal_type,subject_code,grade_name,period_type_code,user_id
        ) b ON  a.school_id = b.school_id
    AND a.activity_internal_type = b.activity_internal_type AND a.subject_code = b.subject_code AND a.grade_name = b.grade_name
    AND a.ptc = b.period_type_code
WHERE a.period_end_date = '${dt}'
  AND a.area_type = 'school'
  AND a.class_type_code = 'CLASS'
  AND a.activity_type = 'homework'
  AND a.section_type_code = 'ALL'
GROUP BY a.school_id, a.ptc, a.activity_internal_type, a.subject_code, a.grade_name, a.participate_count, a.publish_count
HAVING SUM(IF(user_identity = 'TEACHER', stat_count, NULL)) > a.publish_count
    OR SUM(IF(user_identity != 'TEACHER', stat_count, NULL)) > a.participate_count