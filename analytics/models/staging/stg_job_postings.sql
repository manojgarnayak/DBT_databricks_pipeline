{% set extention_keywords = [
    "No degree mentioned",
    "Health insurance",
    "Dental insurance",
    "Paid time off"
]
%}
with source as(
    select * from {{ source('jobs', 'raw_job_postings') }} where error is not true
),
parsed as (
    select *, 
    from_json(job_extensions_raw, 'array<string>') as job_extentions
    from source
),
cleaned as (
    select
        job_id,
        job_title,
        trim(company_name) as company_name,
        job_location,
        regexp_replace(job_via, '^via', '') as job_via,
        job_posted_at,
        job_salary,
        job_schedule_type,
        job_work_from_home,
        search_time as searched_at,
        search_date,
        search_term,
        search_location,
        {% for keyword in extention_keywords -%}
        array_contains(
            job_extentions,
            "{{keyword}}"
        ) as has_{{ slugify(keyword) }}
        {{- "," if not loop.last }}
        {% endfor %}
    from parsed
)
select * from cleaned