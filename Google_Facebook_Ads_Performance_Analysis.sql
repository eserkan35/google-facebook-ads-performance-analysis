WITH ads AS (

    SELECT
        ad_date,
        url_parameters,
        COALESCE(spend, 0) AS spend,
        COALESCE(impressions, 0) AS impressions,
        COALESCE(reach, 0) AS reach,
        COALESCE(clicks, 0) AS clicks,
        COALESCE(leads, 0) AS leads,
        COALESCE(value, 0) AS value
    FROM google_ads_basic_daily

    UNION ALL

    SELECT
        ad_date,
        url_parameters,
        COALESCE(spend, 0) AS spend,
        COALESCE(impressions, 0) AS impressions,
        COALESCE(reach, 0) AS reach,
        COALESCE(clicks, 0) AS clicks,
        COALESCE(leads, 0) AS leads,
        COALESCE(value, 0) AS value
    FROM facebook_ads_basic_daily)

SELECT *
FROM ads;

WITH ads AS (
    SELECT
        ad_date,
        url_parameters,
        COALESCE(spend, 0) AS spend,
        COALESCE(impressions, 0) AS impressions,
        COALESCE(clicks, 0) AS clicks,
        COALESCE(value, 0) AS value
    FROM google_ads_basic_daily

    UNION ALL

    SELECT
        ad_date,
        url_parameters,
        COALESCE(spend, 0) AS spend,
        COALESCE(impressions, 0) AS impressions,
        COALESCE(clicks, 0) AS clicks,
        COALESCE(value, 0) AS value
    FROM facebook_ads_basic_daily
)

SELECT
    ad_date,

    CASE
        WHEN LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)')) = 'nan'
        THEN NULL
        ELSE LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)'))
    END AS utm_campaign,

    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(value) AS total_value,

    CASE
        WHEN SUM(impressions) = 0 THEN NULL
        ELSE SUM(clicks)::numeric / SUM(impressions)
    END AS ctr,

    CASE
        WHEN SUM(clicks) = 0 THEN NULL
        ELSE SUM(spend)::numeric / SUM(clicks)
    END AS cpc,

    CASE
        WHEN SUM(impressions) = 0 THEN NULL
        ELSE SUM(spend)::numeric / SUM(impressions) * 1000
    END AS cpm,

    CASE
         WHEN SUM(spend) = 0 THEN NULL
    ELSE (SUM(value) - SUM(spend))::numeric / SUM(spend)
END AS romi
FROM ads
GROUP BY
    ad_date,
    CASE
        WHEN LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)')) = 'nan'
        THEN NULL
        ELSE LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)'))
    END;