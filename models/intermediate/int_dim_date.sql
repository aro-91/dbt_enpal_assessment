with raw_dates as (
    select 
        dateadd(day, seq4(), '2020-01-01') as the_date
    from table(generator(rowcount => 7500))
    -- takes roughly 20 years of dates, could potentially also be built via a dbt_date package
)
select
    the_date,
    to_char(the_date, 'YYYYMMDD')::int as date_key,
    year(the_date) as year,
    month(the_date) as month,
    day(the_date) as day,
    dayofweek(the_date) as day_of_week,          
    dayofyear(the_date) as day_of_year,
    weekofyear(the_date) as week_of_year,
    case when dayofweek(the_date) in (1,7) then 1 else 0 end as is_weekend,
    to_char(the_date, 'MON') as month_abbrev,
    to_char(the_date, 'DY') as day_abbrev,
    to_char(the_date, 'YYYY-MM-DD') as date_formatted
from raw_dates
where the_date between '2020-01-01' and '2040-01-01'
order by the_date