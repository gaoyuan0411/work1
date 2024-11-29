WITH login_event_full AS (
    SELECT cast(account_id as BIGINT) as account_id,count(1) as login_count
    from dwd__uc__user_login_event_full
    where dt='${biz_date}'   --2024-05-05
    GROUP BY  account_id
),
     user_identity AS (
         SELECT lef.account_id,identity,login_count
         from login_event_full lef
         INNER JOIN (
             SELECT account_id,
                    CASE when is_teacher =1 then 'TEACHER'
             when is_teacher =0 and is_student =1 then 'STUDENT'
             when is_teacher =0 and is_student =0 and is_guardian=1 then 'GUARDIAN'
             END AS identity
                    from nddc.dwd__md__person_account__d__full
             where dt='${biz_date}'
             and (is_teacher=1 or is_student =1  or is_guardian =1)
             ) ui
         on lef.account_id=ui.account_id
     )
select identity,sum(login_count) as login_count from user_identity
GROUP BY  identity