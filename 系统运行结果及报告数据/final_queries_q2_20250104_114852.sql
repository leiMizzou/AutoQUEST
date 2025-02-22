-- Usage: Advanced Analysis, Rows Returned: 1
WITH yearly_malfunctions AS (
  SELECT
    CAST(report_year AS INTEGER) AS report_year,
    COUNT(*) AS total_malfunctions
  FROM "maude"."ASR_2019"
  WHERE event_type IN ('M', 'M-D')
  GROUP BY CAST(report_year AS INTEGER)
)
SELECT
  report_year,
  total_malfunctions,
  LAG(total_malfunctions, 1, CAST(0 AS BIGINT)) OVER (ORDER BY report_year) AS previous_year_malfunctions,
  (total_malfunctions - LAG(total_malfunctions, 1, CAST(0 AS BIGINT)) OVER (ORDER BY report_year)) AS year_over_year_change
FROM yearly_malfunctions
ORDER BY report_year
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 5
WITH latest_year_data AS (
    SELECT
        a.report_year,
        dpc.code AS problem_description
    FROM "maude"."ASR_2019" a
    CROSS JOIN LATERAL UNNEST(string_to_array(a.device_problem_codes, ';')) AS dpc(code)
    WHERE a.event_type IN ('M', 'M-D')
),
ranked_problems AS (
    SELECT
        report_year,
        problem_description,
        COUNT(*) AS malfunction_count,
        RANK() OVER (PARTITION BY report_year ORDER BY COUNT(*) DESC) as rank_num
    FROM latest_year_data
    GROUP BY report_year, problem_description
)
SELECT
    report_year,
    problem_description,
    malfunction_count
FROM ranked_problems
WHERE rank_num <= 5
ORDER BY report_year DESC, malfunction_count DESC
LIMIT 5;;

-- Usage: Advanced Analysis, Rows Returned: 1
-- Query 3: Percentage of malfunctions by device class in the latest year
WITH latest_year_malfunctions AS (
    SELECT
        a.report_year,
        f.deviceclass
    FROM "maude"."ASR_2019" a
    JOIN "maude"."foiclass" f ON a.product_code = f.productcode
    WHERE a.event_type IN ('M', 'M-D')
      AND a.report_year = (SELECT MAX(report_year) FROM "maude"."ASR_2019")
),
total_malfunctions AS (
    SELECT COUNT(*) AS total FROM latest_year_malfunctions
),
class_counts AS (
    SELECT
        deviceclass,
        COUNT(*) AS class_count
    FROM latest_year_malfunctions
    GROUP BY deviceclass
)
SELECT
    cc.deviceclass,
    cc.class_count,
    (cc.class_count::numeric / tm.total) * 100 AS percentage_of_total
FROM class_counts cc, total_malfunctions tm
ORDER BY percentage_of_total DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 2
-- Query 4: Top 5 manufacturers with the highest number of malfunction reports in the latest year
WITH latest_year_malfunctions AS (
  SELECT
    report_year,
    manufacturer_name
  FROM "maude"."ASR_2019"
  WHERE event_type IN ('M', 'M-D')
    AND report_year = (SELECT MAX(report_year) FROM "maude"."ASR_2019")
),
manufacturer_counts AS (
  SELECT
    manufacturer_name,
    COUNT(*) AS malfunction_count,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_num
  FROM latest_year_malfunctions
  GROUP BY manufacturer_name
)
SELECT
  report_year,
  manufacturer_name,
  malfunction_count
FROM latest_year_malfunctions
JOIN manufacturer_counts USING (manufacturer_name)
WHERE rank_num <= 5
GROUP BY report_year, manufacturer_name, malfunction_count
ORDER BY malfunction_count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 1
WITH malfunction_data AS (
    SELECT
        a.report_year
    FROM "maude"."ASR_2019" a
    WHERE a.event_type IN ('M', 'M-D')
)
SELECT
    report_year,
    COUNT(*) AS malfunction_count
FROM malfunction_data
GROUP BY report_year
ORDER BY report_year
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 2
WITH latest_year_top_manufacturers AS (
    SELECT
        manufacturer_name
    FROM "maude"."ASR_2019"
    WHERE event_type IN ('M', 'M-D')
      AND report_year = (SELECT MAX(report_year) FROM "maude"."ASR_2019")
    GROUP BY manufacturer_name
    ORDER BY COUNT(*) DESC
    LIMIT 3
),
yearly_manufacturer_malfunctions AS (
    SELECT
        CAST(a.report_year AS INTEGER) as report_year,
        a.manufacturer_name,
        COUNT(*) AS malfunction_count
    FROM "maude"."ASR_2019" a
    WHERE a.event_type IN ('M', 'M-D')
      AND a.manufacturer_name IN (SELECT manufacturer_name FROM latest_year_top_manufacturers)
    GROUP BY a.report_year, a.manufacturer_name
)
SELECT
    ymm.report_year,
    ymm.manufacturer_name,
    ymm.malfunction_count,
    LAG(CAST(ymm.malfunction_count AS BIGINT), 1, CAST(0 AS BIGINT)) OVER (PARTITION BY ymm.manufacturer_name ORDER BY ymm.report_year) AS previous_year_count,
    (ymm.malfunction_count - LAG(CAST(ymm.malfunction_count AS BIGINT), 1, CAST(0 AS BIGINT)) OVER (PARTITION BY ymm.manufacturer_name ORDER BY ymm.report_year)) AS year_over_year_change
FROM yearly_manufacturer_malfunctions ymm
ORDER BY ymm.manufacturer_name, ymm.report_year
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 1
-- Query 7: Malfunction frequency by medical specialty in the latest year, ranked
WITH latest_year_malfunctions_specialty AS (
    SELECT
        a.report_year,
        f.medicalspecialty
    FROM "maude"."ASR_2019" a
    JOIN "maude"."foiclass" f ON a.product_code = f.productcode
    WHERE a.event_type IN ('M', 'M-D')
      AND a.report_year = (SELECT MAX(report_year) FROM "maude"."ASR_2019")
),
specialty_counts AS (
    SELECT
        medicalspecialty,
        COUNT(*) AS malfunction_count,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_num
    FROM latest_year_malfunctions_specialty
    GROUP BY medicalspecialty
)
SELECT
    report_year,
    medicalspecialty,
    malfunction_count
FROM latest_year_malfunctions_specialty
JOIN specialty_counts USING (medicalspecialty)
GROUP BY report_year, medicalspecialty, malfunction_count, rank_num
ORDER BY rank_num
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 1
-- Query 8: Percentage change in malfunction reports for a specific manufacturer over the last 3 years
WITH specific_manufacturer_malfunctions AS (
    SELECT
        report_year,
        COUNT(*) AS malfunction_count
    FROM "maude"."ASR_2019"
    WHERE event_type IN ('M', 'M-D')
      AND manufacturer_name = 'ALLERGAN' -- Replace with a specific manufacturer
    GROUP BY report_year
),
lagged_malfunctions AS (
    SELECT
        report_year,
        malfunction_count,
        LAG(malfunction_count, 1) OVER (ORDER BY report_year) AS previous_year_count
    FROM specific_manufacturer_malfunctions
)
SELECT
    report_year,
    malfunction_count,
    previous_year_count,
    CASE
        WHEN previous_year_count = 0 THEN NULL
        ELSE ((malfunction_count - previous_year_count)::numeric / previous_year_count) * 100
    END AS percentage_change
FROM lagged_malfunctions
ORDER BY report_year DESC
LIMIT 32;;

