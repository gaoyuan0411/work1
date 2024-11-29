WITH school_info AS (
    SELECT school_id,school_name
    FROM nddc.dim__whole_school
    WHERE dt = '${full_biz_date}'
      AND area_tag = 'SUNSHINE'
)
     ,all_data AS (
     SELECT school_id
              , SUM(activity_publish_num)                                 AS activity_publish_num
              ,sum(student_participate_num) as student_participate_num
         FROM (
                  SELECT school_id
                       , total_publish_count      AS activity_publish_num
                       , 0                        AS student_participate_num
                  FROM nddc.dws__tala__area_activity_publish_stat__dd__full
                  WHERE dt = '${biz_date}'
                    AND activity_type IN  ('homework') AND area_tag = 'SUNSHINE' AND county_id NOT IN (0, -2) AND activity_internal_type = 'ALL'
                    AND section_type_code = 'ALL' AND class_type_code = 'CLASS' AND subject_code = 'ALL'
                  UNION ALL
                  SELECT school_id
                       , 0                            AS activity_publish_num
                       , total_participate_count      AS student_participate_num
                  FROM nddc.dws__tala__area_activity_participate_stat__dd__full
                  WHERE dt = '${biz_date}'
                    AND activity_type IN('homework') AND area_tag = 'SUNSHINE' AND county_id NOT IN (0, -2) AND activity_internal_type = 'ALL'
                    AND section_type_code = 'ALL' AND class_type_code = 'CLASS' AND subject_code = 'ALL'
              ) ad
         GROUP BY school_id
         )
         select si.school_name,ad.*
         FROM all_data ad
         FULL OUTER JOIN school_info si
         on ad.school_id=si.school_id
