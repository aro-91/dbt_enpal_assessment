{% macro first_event_by_grain(cte_name, partition_by, order_by) %}
-- returns the first occurance of a partition

    select *
    from (
        select
            *
            , row_number() over (
                partition by {{ partition_by }}
                order by {{ order_by }} asc
            ) as rn__first_event
        from {{ cte_name }}
    ) as ranked
    where rn__first_event = 1

{% endmacro %}
