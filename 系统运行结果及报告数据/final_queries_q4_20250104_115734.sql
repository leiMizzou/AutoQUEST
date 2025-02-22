-- Usage: Advanced Analysis, Rows Returned: 10
-- Query for Step 2.1: Top 10 most frequent device problem codes in ASR data for a specific product code in 2019
WITH split_codes AS (
  SELECT
    "maude"."ASR_2019".product_code,
    "maude"."ASR_2019".report_year,
    TRIM(unnest(string_to_array("maude"."ASR_2019".device_problem_codes, ';'))) AS device_problem_code
  FROM "maude"."ASR_2019"
  WHERE "maude"."ASR_2019".report_year = '2019'
  AND "maude"."ASR_2019".product_code = 'FTR' -- Example product code
)
SELECT
  product_code,
  device_problem_code,
  COUNT(*) AS frequency
FROM split_codes
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10;;

-- Usage: Advanced Analysis, Rows Returned: 32
SELECT
  d.device_report_product_code,
  EXTRACT(YEAR FROM TO_DATE(m.date_of_event, 'MM/DD/YYYY')) AS event_year,
  COUNT(*) AS frequency
FROM "maude"."DEVICE2023" d
JOIN "maude"."mdrfoiThru2023" m ON d.mdr_report_key = m.mdr_report_key
WHERE m.event_type = 'M'
  AND m.date_of_event IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2 DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 1
-- Query for Step 2.2: Temporal trend of a specific device problem code in ASR data
WITH split_codes AS (
  SELECT
    "maude"."ASR_2019".product_code,
    "maude"."ASR_2019".report_year,
    TRIM(unnest(string_to_array("maude"."ASR_2019".device_problem_codes, ';'))) AS device_problem_code
  FROM "maude"."ASR_2019"
  WHERE "maude"."ASR_2019".product_code = 'FTR' -- Example product code
)
SELECT
  report_year,
  COUNT(*) AS frequency
FROM split_codes
WHERE device_problem_code = '2682' -- Example device problem code
GROUP BY 1
ORDER BY 1
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 6
SELECT
    d.device_report_product_code,
    EXTRACT(YEAR FROM TO_DATE(m.date_of_event, 'MM/DD/YYYY')) AS event_year,
    COUNT(*) AS current_year_count,
    AVG(COUNT(*)) OVER (ORDER BY EXTRACT(YEAR FROM TO_DATE(m.date_of_event, 'MM/DD/YYYY')) ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg_3yr
FROM "maude"."DEVICE2023" d
JOIN "maude"."mdrfoiThru2023" m ON d.mdr_report_key = m.mdr_report_key
WHERE m.event_type = 'M'
  AND d.device_report_product_code = 'KNT'
  AND m.date_of_event IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 32
SELECT
  f.foi_text
FROM "maude"."foitext2023" f
JOIN "maude"."DEVICE2023" d ON f.mdr_report_key = d.mdr_report_key
JOIN "maude"."mdrfoiThru2023" m ON d.mdr_report_key = m.mdr_report_key
WHERE d.device_report_product_code = 'KNT'
  AND m.date_of_event <> 'NI'
  AND EXTRACT(YEAR FROM to_date(m.date_of_event, 'MM/DD/YYYY')) = 2023
  AND m.event_type = 'M'
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 29
-- Query for Step 2.1: Compare the proportion of specific device problem codes within different event types in ASR data
WITH split_codes AS (
  SELECT
    product_code,
    event_type,
    TRIM(unnest(string_to_array(device_problem_codes, ';'))) AS device_problem_code
  FROM "maude"."ASR_2019"
  WHERE report_year = '2019'
),
code_counts AS (
  SELECT
    product_code,
    event_type,
    device_problem_code,
    COUNT(*) AS code_frequency
  FROM split_codes
  GROUP BY 1, 2, 3
),
total_events AS (
  SELECT
    product_code,
    event_type,
    COUNT(*) AS total_events_per_type
  FROM "maude"."ASR_2019"
  WHERE report_year = '2019'
  GROUP BY 1, 2
)
SELECT
  cc.product_code,
  cc.event_type,
  cc.device_problem_code,
  cc.code_frequency,
  te.total_events_per_type,
  (cc.code_frequency::decimal / te.total_events_per_type) * 100 AS percentage_of_event_type
FROM code_counts cc
JOIN total_events te ON cc.product_code = te.product_code AND cc.event_type = te.event_type
WHERE cc.product_code = 'FTR' -- Example product code
ORDER BY 1, 2, 6 DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 32
WITH yearly_counts AS (
    SELECT
        d.device_report_product_code,
        EXTRACT(YEAR FROM TO_DATE(m.date_of_event, 'MM/DD/YYYY')) AS event_year,
        COUNT(*) AS num_malfunctions
    FROM "maude"."DEVICE2023" d
    JOIN "maude"."mdrfoiThru2023" m ON d.mdr_report_key = m.mdr_report_key
    WHERE m.event_type = 'M' AND m.date_of_event IS NOT NULL
    GROUP BY 1, 2
),
ranked_products AS (
    SELECT
        device_report_product_code,
        SUM(num_malfunctions) AS total_malfunctions,
        RANK() OVER (ORDER BY SUM(num_malfunctions) DESC) AS product_rank
    FROM yearly_counts
    GROUP BY 1
),
lagged_counts AS (
    SELECT
        yc.device_report_product_code,
        yc.event_year,
        yc.num_malfunctions,
        LAG(yc.num_malfunctions, 1, 0::bigint) OVER (PARTITION BY yc.device_report_product_code ORDER BY yc.event_year) AS previous_year_malfunctions
    FROM yearly_counts yc
    WHERE yc.device_report_product_code IN (SELECT device_report_product_code FROM ranked_products WHERE product_rank <= 5)
)
SELECT
    device_report_product_code,
    event_year,
    num_malfunctions,
    previous_year_malfunctions,
    (num_malfunctions - previous_year_malfunctions) AS year_over_year_change
FROM lagged_counts
ORDER BY device_report_product_code, event_year
LIMIT 32;;

