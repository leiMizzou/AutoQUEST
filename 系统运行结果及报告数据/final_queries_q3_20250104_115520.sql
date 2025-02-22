-- Usage: Advanced Analysis, Rows Returned: 12
-- Phase 1: Data Extraction and Preparation - Combining ASR data with device problem descriptions
WITH exploded_problems AS (
    SELECT
        asr.manufacturer_name,
        asr.report_year,
        asr.event_type,
        trim(prob_code) AS device_problem_code,
        asr.report_id,
        asr.initial_report_flag
    FROM
        "maude"."ASR_2019" asr
    CROSS JOIN LATERAL UNNEST(string_to_array(asr.device_problem_codes, ';')) as prob_code
    WHERE asr.event_type IN ('M', 'M-D')
)
SELECT
    ep.manufacturer_name,
    ep.report_year,
    ep.event_type,
    dp.old_to_be_deactivated AS device_problem_description,
    COUNT(*) AS report_count
FROM exploded_problems ep
JOIN "maude"."deviceproblemcodes" dp ON ep.device_problem_code = dp.ï_1
GROUP BY ep.manufacturer_name, ep.report_year, ep.event_type, dp.old_to_be_deactivated
ORDER BY ep.manufacturer_name, ep.report_year, ep.event_type DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 2
-- Phase 2: Temporal Analysis of Malfunctions by Manufacturer - Annual Malfunction Counts
SELECT
    manufacturer_name,
    report_year,
    event_type,
    COUNT(*) AS malfunction_count
FROM
    "maude"."ASR_2019"
WHERE
    event_type IN ('M', 'M-D')
GROUP BY
    manufacturer_name,
    report_year,
    event_type
ORDER BY
    manufacturer_name,
    report_year
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 2
WITH annual_counts AS (
    SELECT
        manufacturer_name,
        CAST(report_year AS INTEGER) AS report_year,
        COUNT(*) AS malfunction_count
    FROM
        "maude"."ASR_2019"
    WHERE
        event_type IN ('M', 'M-D')
    GROUP BY
        manufacturer_name,
        CAST(report_year AS INTEGER)
)
SELECT
    ac1.manufacturer_name,
    ac1.report_year,
    ac1.malfunction_count,
    LAG(ac1.malfunction_count, 1, CAST(0 AS BIGINT)) OVER (PARTITION BY ac1.manufacturer_name ORDER BY ac1.report_year) AS previous_year_count,
    (ac1.malfunction_count - LAG(ac1.malfunction_count, 1, CAST(0 AS BIGINT)) OVER (PARTITION BY ac1.manufacturer_name ORDER BY ac1.report_year)) AS year_over_year_change
FROM annual_counts ac1
ORDER BY ac1.manufacturer_name, ac1.report_year
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 2
-- Phase 3: Comparative Analysis Across Manufacturers - Total Malfunction Counts
SELECT
    manufacturer_name,
    COUNT(*) AS total_malfunction_count
FROM
    "maude"."ASR_2019"
WHERE
    event_type IN ('M', 'M-D')
GROUP BY
    manufacturer_name
ORDER BY
    total_malfunction_count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 2
-- Phase 3: Comparative Analysis Across Manufacturers - Percentage of total malfunctions by manufacturer
WITH total_malfunctions AS (
    SELECT COUNT(*) AS total FROM "maude"."ASR_2019" WHERE event_type IN ('M', 'M-D')
)
SELECT
    asr.manufacturer_name,
    COUNT(*) AS manufacturer_malfunction_count,
    (COUNT(*) * 100.0 / tm.total) AS percentage_of_total
FROM
    "maude"."ASR_2019" asr,
    total_malfunctions tm
WHERE
    asr.event_type IN ('M', 'M-D')
GROUP BY
    asr.manufacturer_name, tm.total
ORDER BY
    percentage_of_total DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 9
-- Phase 3: Comparative Analysis Across Manufacturers - Top device problems reported by each manufacturer
WITH exploded_problems AS (
    SELECT
        asr.manufacturer_name,
        trim(prob_code) AS device_problem_code
    FROM
        "maude"."ASR_2019" asr
    CROSS JOIN LATERAL UNNEST(string_to_array(asr.device_problem_codes, ';')) as prob_code
    WHERE asr.event_type IN ('M', 'M-D')
),
problem_counts AS (
    SELECT
        ep.manufacturer_name,
        dp.old_to_be_deactivated AS device_problem_description,
        COUNT(*) AS problem_count,
        ROW_NUMBER() OVER (PARTITION BY ep.manufacturer_name ORDER BY COUNT(*) DESC) as rn
    FROM exploded_problems ep
    JOIN "maude"."deviceproblemcodes" dp ON ep.device_problem_code = dp.ï_1
    GROUP BY ep.manufacturer_name, dp.old_to_be_deactivated
)
SELECT
    manufacturer_name,
    device_problem_description,
    problem_count
FROM problem_counts
WHERE rn <= 5
ORDER BY manufacturer_name, problem_count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 1
WITH mfr1_counts AS (
    SELECT
        report_year,
        COUNT(*) AS mfr1_count
    FROM "maude"."ASR_2019"
    WHERE manufacturer_name = 'ALLERGAN' AND event_type IN ('M', 'M-D')
    GROUP BY report_year
),
mfr2_counts AS (
    SELECT
        report_year,
        COUNT(*) AS mfr2_count
    FROM "maude"."ASR_2019"
    WHERE manufacturer_name = 'ABBVIE MEDICAL DEVICE CENTRE' AND event_type IN ('M', 'M-D')
    GROUP BY report_year
)
SELECT
    COALESCE(m1.report_year, m2.report_year) AS report_year,
    COALESCE(m1.mfr1_count, 0) AS allergan_malfunctions,
    COALESCE(m2.mfr2_count, 0) AS abbvie_malfunctions
FROM mfr1_counts m1
FULL OUTER JOIN mfr2_counts m2 ON m1.report_year = m2.report_year
ORDER BY report_year
LIMIT 32;;

