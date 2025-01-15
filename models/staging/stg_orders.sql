with source as (

    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_orders') }}

),

staged as (

    select 
        id as order_id,
        user_id as customer_id,
        order_date,
        datediff('day', cast(order_date as DATE), cast({{ dbt.current_timestamp() }} as DATE)) as days_since_ordered,
        status like '%pending%' as is_status_pending,
        case 
            when status like '%shipped%' then 'shipped'
            when status like '%return%' then 'returned'
            when status like '%pending%' then 'placed'
            else status
        end as status
    from source

)

select * from staged