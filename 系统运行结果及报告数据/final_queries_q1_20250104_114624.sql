-- Usage: Advanced Analysis, Rows Returned: 2
-- Phase 2: Comparative Analysis of Event Types - Step 2.1: Calculate Event Type Frequencies in ASR Data
WITH asr_event_counts AS (
    SELECT
        event_type,
        COUNT(*) AS count
    FROM "maude"."ASR_2019"
    GROUP BY event_type
)
SELECT
    event_type,
    count,
    ROUND((count * 100.0 / SUM(count) OVER()), 2) AS percentage
FROM asr_event_counts
ORDER BY count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 8
-- Phase 2: Comparative Analysis of Event Types - Step 2.2: Calculate Event Type Frequencies in Standard MDR Data
WITH mdr_event_counts AS (
    SELECT
        event_type,
        COUNT(*) AS count
    FROM "maude"."mdrfoiThru2023"
    GROUP BY event_type
)
SELECT
    event_type,
    count,
    ROUND((count * 100.0 / SUM(count) OVER()), 2) AS percentage
FROM mdr_event_counts
ORDER BY count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 22
-- Phase 3: Comparative Analysis of Device Problems - Step 3.1: Analyze Device Problem Codes in ASR Data
WITH asr_problem_codes AS (
    SELECT
        trim(code) AS device_problem_code
    FROM "maude"."ASR_2019"
    CROSS JOIN LATERAL unnest(string_to_array(device_problem_codes, ';')) AS code
)
SELECT
    device_problem_code,
    COUNT(*) AS count,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM asr_problem_codes)), 2) AS percentage
FROM asr_problem_codes
GROUP BY device_problem_code
ORDER BY count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 1
-- Phase 4: Temporal Analysis of ASR Utilization - Step 4.1: Track ASR Reports Over Time
SELECT
    report_year,
    report_quarter,
    COUNT(DISTINCT report_id) AS num_reports
FROM "maude"."ASR_2019"
GROUP BY report_year, report_quarter
ORDER BY report_year DESC, report_quarter DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 5
-- Phase 5: Exploring Other Potential Differences (Secondary Analysis) - Step 5.1: Manufacturer-Specific Analysis (Event Types)
SELECT
    asr.manufacturer_name,
    asr.event_type,
    COUNT(*) AS count,
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY asr.manufacturer_name)), 2) AS percentage
FROM "maude"."ASR_2019" asr
GROUP BY asr.manufacturer_name, asr.event_type
ORDER BY asr.manufacturer_name, count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 27
-- Phase 5: Exploring Other Potential Differences (Secondary Analysis) - Step 5.1: Manufacturer-Specific Analysis (Problem Codes)
WITH manufacturer_problem_codes AS (
    SELECT
        asr.manufacturer_name,
        trim(code) AS device_problem_code
    FROM "maude"."ASR_2019" asr
    CROSS JOIN LATERAL unnest(string_to_array(asr.device_problem_codes, ';')) AS code
)
SELECT
    manufacturer_name,
    device_problem_code,
    COUNT(*) AS count,
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY manufacturer_name)), 2) AS percentage
FROM manufacturer_problem_codes
GROUP BY manufacturer_name, device_problem_code
ORDER BY manufacturer_name, count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 32
-- Phase 5: Exploring Other Potential Differences (Secondary Analysis) - Step 5.2: Device-Specific Analysis (Event Types)
SELECT
    asr.brand_name,
    asr.model_number,
    asr.event_type,
    COUNT(*) AS count,
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY asr.brand_name, asr.model_number)), 2) AS percentage
FROM "maude"."ASR_2019" asr
GROUP BY asr.brand_name, asr.model_number, asr.event_type
ORDER BY asr.brand_name, asr.model_number, count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 32
-- Phase 5: Exploring Other Potential Differences (Secondary Analysis) - Step 5.2: Device-Specific Analysis (Problem Codes)
WITH device_problem_codes AS (
    SELECT
        asr.brand_name,
        asr.model_number,
        trim(code) AS device_problem_code
    FROM "maude"."ASR_2019" asr
    CROSS JOIN LATERAL unnest(string_to_array(asr.device_problem_codes, ';')) AS code
)
SELECT
    brand_name,
    model_number,
    device_problem_code,
    COUNT(*) AS count,
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY brand_name, model_number)), 2) AS percentage
FROM device_problem_codes
GROUP BY brand_name, model_number, device_problem_code
ORDER BY brand_name, model_number, count DESC
LIMIT 32;;

