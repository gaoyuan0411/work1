select * FROM nddc_uat.ads__school_activity__activity_user_stat__d a 
where dt = '${dt}' and stat_count < 0 
school_id='${school_id}' and period_type_code=99
and activity_internal_type='ALL' AND subject_code ='ALL'

--重复性
SELECT 
    period_type_code,
    user_identity,
    school_id,
    user_id,
    class_id,
    activity_type_name,
    activity_internal_type,
    subject_code,
    grade_code,
    COUNT(*) as record_count
FROM 
    nddc_uat.ads__school_activity__activity_user_stat__d where dt =  '${dt}' 
GROUP BY 
    period_type_code,
    user_identity,
    school_id,
    user_id,
    class_id,
    activity_type_name,
    activity_internal_type,
    subject_code,
    grade_code
HAVING 
    COUNT(*) > 1;
    
--异常值1
select * FROM nddc_uat.ads__school_activity__activity_user_stat__d a 
where dt = '${dt}' and stat_count < 0

--异常值2
select a.school_id,a.ptc,a.activity_internal_type,a.subject_code,a.grade_name,b.grade_code,a.participate_count,a.publish_count,
sum(if(user_identity = 'TEACHER',stat_count,null)) AS t_publish_count,
sum(if(user_identity != 'TEACHER',stat_count,null)) AS s_participate_count
from nddc.ads__region_app_teaching_activities_overview_stat_d a
inner join nddc_uat.ads__school_activity__activity_user_stat__d b on b.dt = '${dt}' and a.school_id = b.school_id
and a.activity_internal_type = b.activity_internal_type  and a.subject_code = b.subject_code  and a.grade_name = b.grade_name
and a.ptc =b.period_type_code 
where a.period_end_date  ='${dt}' and a.area_type='school' and a.class_type_code = 'CLASS' and a.activity_type = 'homework' and a.section_type_code ='ALL'
group by a.school_id,a.ptc,a.activity_internal_type,a.subject_code,a.grade_name,b.grade_code,a.participate_count,a.publish_count
having sum(if(user_identity = 'TEACHER',stat_count,null)) > a.publish_count  or sum(if(user_identity != 'TEACHER',stat_count,null)) > a.participate_count 


select * from nddc.ads__region_app_teaching_activities_overview_stat_d  a  where region_id=594033016188 and ptc = '21'
and a.period_end_date  ='${dt}' and a.area_type='school' and a.class_type_code = 'CLASS' and a.activity_type = 'homework' 
and activity_internal_type ='ALL' and subject_code ='$SB0300' and grade_name ='三年级' 
and section_type_code ='ALL'


select *-- sum(if(user_identity = 'TEACHER',stat_count,null)),sum(if(user_identity != 'TEACHER',stat_count,null))
FROM nddc_uat.ads__school_activity__activity_user_stat__d a 
where dt = '${dt}' and 
school_id='594033016188' and period_type_code=21
and activity_internal_type='ALL' and subject_code ='$SB0300'  and grade_name ='三年级' 


---学生参与
WITH AA AS(
select  get_json_object(activity_ext_info,'$.subject') subject,* FROM nddc.dwd__tala__group_activity__d__full ga
        WHERE ga.dt = '${dt}'
          AND ga.activity_publish_date <= '${dt}'
          AND ga.activity_deleted = 0
          AND ga.activity_id <> '-1'
          AND ga.activity_original_id <> '-1'
          AND ga.group_deleted = 0  
          and activity_type='homework' 
          and group_class_type='CLASS'
          and COALESCE(ga.group_province_id, 0) <>594035816785
          ),
class as (
SELECT DISTINCT account_id, grade_name,school_id,class_id,class_name
    FROM nddc.dwd__md__class_member__d__full
    WHERE dt = '${dt}'
      AND class_type = 'CLASS'
      AND is_deleted = 0
      AND class_is_deleted = 0 --and school_id='594033703317'
      --and account_id='452624231448'
      AND class_member_type IN ('STUDENT') ),

BB AS (
SELECT activity_id,event_id,user_id,grade_name,class_id,class_name,school_id
FROM NDDC.dwd__tala__user_activity_submit__d__full B 
inner join class c on b.user_id=c.account_id
WHERe B.DT = '${dt}'  and user_is_student =1 and activity_type='homework'--  and user_id='452624231448'
--AND substr(event_date,1,7)='2024-10'--月
--AND substr(event_date,1,4)='2024'--年
and event_date <= '${dt}'
                AND activity_deleted = 0
                AND activity_id <> '-1'
                AND user_id IS NOT NULL ),
cc as (
SELECT activity_id,concat(activity_id,user_id)event_id,USER_ID,grade_name,class_id,class_name,school_id FROM NDDC.dwd__tala__user_activity_read__d__full B 
inner join class c on b.user_id=c.account_id
WHERe B.DT = '${dt}'   and user_is_student =1  and activity_type='homework' 
--AND substr(event_date,1,7)='2024-10'--月
--AND substr(event_date,1,4)='2024'--年
and event_date <= '${dt}'
                AND activity_deleted = 0
                AND activity_id <> '-1'
                AND user_id IS NOT NULL and not exists ( select 1 from bb where b.activity_id=bb.activity_id and b.user_id = bb.user_id)
 ),

dd as (select * from bb union all select * from cc)

,ee as (
select dd.user_id,class_id,class_name ,grade_name,subject,school_id,
count(distinct dd.event_id ) stat_count 
from aa join dd on aa.activity_id=dd.activity_id 
group by dd.user_id ,grade_name,class_id,subject,school_id,class_name)

select * from nddc_uat.ads__school_activity__activity_user_stat__d a 
inner join ee on ee.user_id = a.user_id and ee.subject=a.subject_code and a.grade_name=ee.grade_name AND A.class_id=EE.class_id and ee.school_id =a.school_id
where a.dt = '${dt}' and period_type_code=99 and user_identity  = 'STUDENT' 
and activity_internal_type='ALL' and a.stat_count <>ee.stat_count 


---教师发布
WITH AA AS(
select  get_json_object(activity_ext_info,'$.subject') subject,* FROM nddc.dwd__tala__group_activity__d__full ga
        WHERE ga.dt = '${dt}'
          AND ga.activity_publish_date <= '${dt}'
          AND ga.activity_deleted = 0
          AND ga.activity_id <> '-1'
          AND ga.activity_original_id <> '-1'
          AND ga.group_deleted = 0  
          and activity_type='homework' 
          and group_class_type='CLASS'
          and COALESCE(ga.group_province_id, 0) <>594035816785
          ),
class as (
SELECT DISTINCT account_id, grade_name,school_id,class_id,class_name
    FROM nddc.dwd__md__class_member__d__full
    WHERE dt = '${dt}'
      AND class_type = 'CLASS'
      AND is_deleted = 0
      AND class_is_deleted = 0 --and school_id='594033703317'
      --and account_id='452624231448'
      AND class_member_type IN ('TEACHER') ),
      
creater as (
select count(distinct activity_id) stat_count,bb.account_id ,grade_name,class_id,subject,school_id,class_name
from aa inner join class bb on aa.activity_created_by = bb.account_id
group by bb.account_id ,grade_name,class_id,subject,school_id,class_name)

select * from nddc_uat.ads__school_activity__activity_user_stat__d a 
inner join creater ee on ee.account_id = a.user_id and ee.subject=a.subject_code and a.grade_name=ee.grade_name 
AND A.class_id=EE.class_id and ee.school_id =a.school_id
where a.dt = '${dt}' and period_type_code=99 and user_identity  = 'TEACHER' 
and activity_internal_type='ALL' and a.stat_count <>ee.stat_count 


select * from nddc.dwd__talr__library_content_duty_school_info__d__full a where dt = '${run_date_std}' and
content_id='0052a760-6b4d-4f51-99c4-d188ee716cd6' and library_id='182c63cf-ebf1-4929-8558-b84341bf063a' 
and duty_school_id='afa45b33-281d-4d21-8bca-3ca55d9b08eb'  

select * from nddc.dwd__talr__e_library_content__d a where dt = '${run_date_std}'and content_id='0052a760-6b4d-4f51-99c4-d188ee716cd6'

select * from nddc.ods__elearning_library__e_library_content__mysql__full where dt = '${biz_date}' and id = '182c63cf-ebf1-4929-8558-b84341bf063a' 

select tag_code,scope_id,tag_id_path,COUNT(1) from nddc.dwd__talr__auxo_tag__channel_tag__d t
where t.dt = '${biz_date}' and t.is_leaf = 1  --and tag_id_path='7c08c4bd-4100-43dc-bd5d-31eaba2fc609,0269634c-2a84-430a-ab3c-c36f790ffbe9'
group by tag_code,scope_id,tag_id_path having count(1)>1
    
select duty_school_id,content_id,library_id,COUNT(1) from nddc.dwd__talr__library_content_duty_school_info__d__full t
where t.dt = '${biz_date}'
group by duty_school_id,content_id,library_id having count(1)>1  
    
select * from nddc.dwd__talr__auxo_tag__channel_tag__d t
where t.dt = '${biz_date}' and t.is_leaf = 1  and tag_id_path='7c08c4bd-4100-43dc-bd5d-31eaba2fc609,0269634c-2a84-430a-ab3c-c36f790ffbe9';

where evt.dt = '${biz_date}' and evt.status = 1  GROUP BY ID HAVING COUNT(1)>1


select tag_code,scope_id,tag_id_path,tag_level,COUNT(1) from nddc.dwd__talr__auxo_tag__channel_tag__d t
where t.dt = '${biz_date}'   --and tag_id_path='e5649925-441d-4a53-b525-51a2f1c4e0a8-teach-studio'
group by tag_code,scope_id,tag_id_path,tag_level having count(1)>1


select duty_school_id,content_id,library_id,COUNT(1) from nddc.dwd__talr__library_content_duty_school_info__d__full t
where t.dt = '${dt}'
group by duty_school_id,content_id,library_id having count(1)>1  ;
