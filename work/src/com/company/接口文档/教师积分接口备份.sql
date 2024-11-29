-- v1/incentive/teacher/uesr_rank
SELECT *
FROM (SELECT user_id
           , user_name
           , incentive_score
           , DENSE_RANK() OVER ( <IF test = "  direct == 'asc' or direct == 'ASC'" >
   ORDER BY incentive_score ASC
</IF>
<IF test = " null == direct or '' == direct or direct == 'desc' or direct == 'DESC' " >
   ORDER BY incentive_score DESC
</IF>
                   ) AS rank
      FROM (SELECT user_id
                 , user_name
                 , incentive_score

            FROM ads__incentive__teacher__user_period_stat__d
            WHERE 1 = 1
                      < if test="period_code != null and period_code != '' ">
  AND period_code = #{period_code}
</IF>
<IF test="period_code == null or period_code == '' ">
  AND period_code = date_format(date_sub(CURDATE(),INTERVAL 1 DAY),'%Y')
</IF>
<IF test="region_id != null and region_id != '' ">
  AND (province_id = #{region_id} OR city_id = #{region_id} OR area_id = #{region_id} )
</IF>
<IF test = "  direct == 'asc' or direct == 'ASC'" >
            ORDER BY incentive_score ASC </ IF > < IF test = " null == direct or '' == direct or direct == 'desc' or direct == 'DESC' " >
            ORDER BY incentive_score DESC </ IF > < IF test = " null != limit and '' != limit" >
            LIMIT #{LIMIT}0 </IF> <IF test = " null == limit or '' == limit" > LIMIT 500 </IF>
           ) t
     ) a
WHERE rank & lt;
<IF test = " null != limit and '' != limit" >
#{LIMIT} + 1
</IF>
<IF test = " null == limit or '' == limit" >
      50+1
</IF>
-- 参数
{
  "region_id": 0,// 地区编码，0：全国，
  "period_code": "2024",//周期代码：2024:2024年，2023:2023年
  "direct":"排序方向,//升序：asc；降序：desc，默认为desc"
  "limit":10 //展示条数，可以不传默认10条
}
--v1/incentive/teacher/distribute
SELECT parent_id
     , region_id
     , region_name
     , region_level
     , is_leaf
     , incentive_number
     , incentive_score
     , incentive_avg_score
FROM ads__incentive__teacher__overview_period_stat__d
WHERE 1 = 1
          < if test="period_code != null and period_code != '' ">
  AND period_code = #{period_code}
</IF>
<IF test="period_code == null or period_code == '' ">
  AND period_code = date_format(date_sub(CURDATE(),INTERVAL 1 DAY),'%Y')
</IF>
<IF test="parent_id != null and parent_id != '' ">
  AND parent_id = #{parent_id}
  AND region_id != #{parent_id}
</IF>
<IF test="parent_id == null or parent_id == '' ">
  AND parent_id = 0
  AND region_id != 0
</IF>
AND type_code_1 ='all'
<IF test = "null != sort and '' != sort and null != direct and '' != direct" >
ORDER BY #{SORT} #{direct}
</IF>
<IF test = "(null == sort or '' == sort) and ( null != direct and '' != direct)" >
ORDER BY incentive_score #{direct}
</IF>
	<IF test = "(null != sort and '' != sort) and ( null == direct or '' == direct)" >
ORDER BY #{SORT}
DESC
    </ IF >
    < IF test = "(null == sort or '' == sort) and (null == direct or '' == direct)" >
    ORDER BY incentive_score
DESC
    </ IF >
-- 参数
    {
    "parent_id": 0,// 父级地区编码，0：全国，点击下钻时传返回对象中的region_id
    "period_code": "2024",//周期代码：2024:2024年，2023:2023年
    "sort":"排序字段，取返回值中的key，默认为查询字段中的第一个聚合结果的字段",
    "direct":"排序方向，升序：asc；降序：desc，默认为desc"
    }
;
