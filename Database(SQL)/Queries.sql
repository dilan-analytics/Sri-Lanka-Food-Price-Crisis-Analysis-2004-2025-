--Which markets have missing reporting periods?
SELECT
    market_id,
    substr(date,-4) AS year,
    COUNT(*) AS record_count
FROM prices
GROUP BY market_id, year
ORDER BY market_id, year;

WITH yearly_prices AS (
    SELECT
        commodity,
        substr(date,-4) AS year,
        AVG(price) AS avg_price
    FROM prices
    WHERE substr(date,-4) IN ('2021','2022')
    GROUP BY commodity, year
)

--Which commodities increased most from 2021 to 2022?

WITH yearly_prices AS (
    SELECT
        commodity,
        substr(date,-4) AS year,
        AVG(price) AS avg_price
    FROM prices
    WHERE substr(date,-4) IN ('2021','2022')
    GROUP BY commodity, year
)

SELECT
    a.commodity,
    round(a.avg_price,2) AS avg_2021,
    round(b.avg_price,2) AS avg_2022,
    ROUND(
        ((b.avg_price-a.avg_price)/a.avg_price)*100,
        2
    ) AS pct_increase
FROM yearly_prices a
JOIN yearly_prices b
ON a.commodity=b.commodity
WHERE a.year='2021'
AND b.year='2022'
ORDER BY pct_increase DESC
LIMIT 10;

--Which provinces experienced the highest food prices?
SELECT
    m.admin1,
    ROUND(AVG(p.price),2) AS avg_price
FROM prices p
JOIN markets m
ON p.market_id = m.market_id
GROUP BY m.admin1
ORDER BY avg_price DESC;

--yoy_inflation
WITH yearly AS (
    SELECT
        commodity,
        substr(date,-4) AS year,
        AVG(price) AS avg_price
    FROM prices
    GROUP BY commodity, year
)

SELECT
    commodity,
    year,
    ROUND(avg_price,2) AS avg_price,

    ROUND(
        (
            avg_price - previous_price
        ) / previous_price * 100,
        2
    ) AS yoy_pct_change

FROM (
    SELECT
        commodity,
        year,
        avg_price,

        LAG(avg_price)
        OVER(
            PARTITION BY commodity
            ORDER BY year
        ) AS previous_price

    FROM yearly
)

ORDER BY commodity, year;

--How much did prices increase relative to 2004?

WITH base_year AS (

    SELECT
        commodity,
        AVG(price) AS base_price

    FROM prices

    WHERE substr(date,-4) = '2004'

    GROUP BY commodity
)

SELECT
    p.commodity,
    substr(p.date,-4) AS year,

    ROUND(
        AVG(p.price) / b.base_price * 100,
        2
    ) AS price_index

FROM prices p

JOIN base_year b
    ON p.commodity = b.commodity

GROUP BY
    p.commodity,
    year

ORDER BY
    p.commodity,
    year;
	
--Attach coordinates to every price record.
SELECT
p.*,
m.market,
m.admin1,
m.admin2,
m.latitude,
m.longitude

FROM prices p

JOIN markets m
ON p.market_id = m.market_id;