create or replace function pg_temp.url_decode(p text)
returns text
language plpgsql
as $$
declare
  i int := 1;
  len int;
  out_bytes bytea := ''::bytea;
  ch text;
  hex text;
begin
  if p is null then
    return nul;
  end if;
  len := length(p);
  while i <= len loop
    ch := substr(p, i, 1);
    if ch = '+' then
      out_bytes := out_bytes || convert_to(' ', 'UTF8');
      i := i + 1;
    elseif ch = '%' and i + 2 <= len then
      hex := substr(p, i + 1, 2);
      if hex ~ '^[0-9A-Fa-f]{2}$' then
        out_bytes := out_bytes || decode(hex, 'hex');
        i := i + 3;
      else
        out_bytes := out_bytes || convert_to(ch, 'UTF8');
        i := i + 1;
      end if;
    else
      out_bytes := out_bytes || convert_to(ch, 'UTF8');
      i := i + 1;
    end if;
  end loop;
  return convert_from(out_bytes, 'UTF8');
end;
$$;

with unified_ads as (
    select
        ad_date,
        url_parameters,
        coalesce(spend, 0)       as spend,
        coalesce(impressions, 0) as impressions,
        coalesce(reach, 0)       as reach,
        coalesce(clicks, 0)      as clicks,
        coalesce(leads, 0)       as leads,
        coalesce(value, 0)       as value
    from facebook_ads_basic_daily
    union all
    select
        ad_date,
        url_parameters,
        coalesce(spend, 0),
        coalesce(impressions, 0),
        coalesce(reach, 0),
        coalesce(clicks, 0),
        coalesce(leads, 0),
        coalesce(value, 0)
    from google_ads_basic_daily
),
prepared as (
    select
        ad_date,
        case
            when url_parameters is null then null
            when not (url_parameters ~ 'utm_campaign=') then null
            else nullif(
                   lower(
                     pg_temp.url_decode(
                       split_part(
                         split_part(url_parameters, 'utm_campaign=', 2),
                         '&',
                         1
                       )
                     )
                   ),
                   'nan'
                 )
        end as utm_campaign,
        spend,
        impressions,
        clicks,
        value
    from unified_ads
)
select
    ad_date,
    utm_campaign,
    SUM(spend)       as total_spend,
    SUM(impressions) as total_impressions,
    SUM(clicks)      as total_clicks,
    SUM(value)       as total_value,
    case
        when sum(impressions) = 0 then null
        else (sum(clicks)::numeric * 100) / sum(impressions)::numeric
    end as ctr,
    case
        when sum(clicks) = 0 then null
        else sum(spend)::numeric / sum(clicks)::numeric
    end as cpc,
    case
        when sum(impressions) = 0 then null
        else (sum(spend)::numeric * 1000) / sum(impressions)::numeric
    end as cpm,
    case
        when SUM(spend) = 0 then null
        else ((sum(value)::numeric - sum(spend)::numeric) * 100)
             / sum(spend)::numeric
    end as romi
from prepared
group by ad_date, utm_campaign
order by ad_date desc, utm_campaign;
