CREATE TEMPORARY FUNCTION nd_uc_name_dec AS 'com.nd.udf.NdUcNameDecUDF' using jar 'hdfs://cmss/user/nddc/udf/nd-uc-udfdes-0.3.jar';
select
rank
, user_id
, nd_uc_name_dec(user_name) as user_name
, cast(incentive_score as DECIMAL(10, 2))incentive_score
, province_name
, city_name
, area_name
, school_name
, verify_status_name
from (select
*,row_number() over(order by incentive_score desc) as rank
from nddc.ads__incentive__teacher__user_period_stat__d
where dt='2024'
) t where rank <=100