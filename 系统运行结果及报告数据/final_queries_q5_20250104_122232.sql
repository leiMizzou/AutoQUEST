-- Usage: Advanced Analysis, Rows Returned: 2
-- Query 1: Distribution of Event Types in ASR_2019
SELECT
    asr.event_type,
    COUNT(*) AS event_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM "maude"."ASR_2019" asr
GROUP BY asr.event_type
ORDER BY event_count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 8
-- Query 2: Distribution of Event Types in mdrfoiThru2023
SELECT
    mdr.event_type,
    COUNT(*) AS event_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM "maude"."mdrfoiThru2023" mdr
GROUP BY mdr.event_type
ORDER BY event_count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 3
-- Query 3: Top 10 Manufacturers by Report Count in ASR_2019
SELECT
    asr.manufacturer_name,
    COUNT(*) AS report_count
FROM "maude"."ASR_2019" asr
GROUP BY asr.manufacturer_name
ORDER BY report_count DESC
LIMIT 10;;

-- Usage: Advanced Analysis, Rows Returned: 10
-- Query 4: Top 10 Manufacturers by Report Count in DEVICE2023
SELECT
    dev.manufacturer_d_name,
    COUNT(DISTINCT dev.mdr_report_key) AS report_count
FROM "maude"."DEVICE2023" dev
GROUP BY dev.manufacturer_d_name
ORDER BY report_count DESC
LIMIT 10;;

-- Usage: Advanced Analysis, Rows Returned: 1
-- Query 5: Count of distinct Product Codes in ASR_2019 over time
SELECT
    asr.report_year,
    COUNT(DISTINCT asr.product_code) AS distinct_product_code_count
FROM "maude"."ASR_2019" asr
GROUP BY asr.report_year
ORDER BY asr.report_year
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 6
-- Query 6: Count of distinct Device Report Product Codes in DEVICE2023 over time
SELECT
    SUBSTRING(dev.date_received, 1, 4) AS report_year,
    COUNT(DISTINCT dev.device_report_product_code) AS distinct_product_code_count
FROM "maude"."DEVICE2023" dev
GROUP BY report_year
ORDER BY report_year
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 32
-- Query 7: Comparison of Brand Names between ASR_2019 and DEVICE2023
SELECT
    'ASR_2019' AS source,
    brand_name,
    COUNT(*) AS count
FROM "maude"."ASR_2019"
GROUP BY brand_name
UNION ALL
SELECT
    'DEVICE2023' AS source,
    brand_name,
    COUNT(*) AS count
FROM "maude"."DEVICE2023"
GROUP BY brand_name
ORDER BY brand_name, source
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 22
-- Query 8: Analysis of Device Problem Codes in ASR_2019
SELECT
    dp_code,
    COUNT(*) AS count
FROM "maude"."ASR_2019"
CROSS JOIN UNNEST(STRING_TO_ARRAY(device_problem_codes, ';')) AS dp_code
GROUP BY dp_code
ORDER BY count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 32
-- Query 9:  Yearly trend of Adverse Event Flags in mdrfoiThru2023
SELECT
    SUBSTRING(mdr.date_received, 1, 4) AS report_year,
    SUM(CASE WHEN mdr.adverse_event_flag = 'Y' THEN 1 ELSE 0 END) AS adverse_event_count,
    COUNT(*) AS total_reports,
    ROUND(SUM(CASE WHEN mdr.adverse_event_flag = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS adverse_event_percentage
FROM "maude"."mdrfoiThru2023" mdr
GROUP BY report_year
ORDER BY report_year
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 32
-- Query 10: Yearly trend of Product Problem Flags in mdrfoiThru2023
SELECT
    SUBSTRING(mdr.date_received, 1, 4) AS report_year,
    SUM(CASE WHEN mdr.product_problem_flag = 'Y' THEN 1 ELSE 0 END) AS product_problem_count,
    COUNT(*) AS total_reports,
    ROUND(SUM(CASE WHEN mdr.product_problem_flag = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS product_problem_percentage
FROM "maude"."mdrfoiThru2023" mdr
GROUP BY report_year
ORDER BY report_year
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 2
-- Query 11:  Most frequent Text Type Codes in foitext2023
SELECT
    ft.text_type_code,
    COUNT(*) AS text_count
FROM "maude"."foitext2023" ft
GROUP BY ft.text_type_code
ORDER BY text_count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 7
-- Query 12: Count of reports by Report Source Code in mdrfoiThru2023
SELECT
    mdr.report_source_code,
    COUNT(*) AS report_count
FROM "maude"."mdrfoiThru2023" mdr
GROUP BY mdr.report_source_code
ORDER BY report_count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 14
-- Query 13:  Distribution of Device Operators in DEVICE2023
SELECT
    dev.device_operator,
    COUNT(*) AS count
FROM "maude"."DEVICE2023" dev
GROUP BY dev.device_operator
ORDER BY count DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 5
-- Query 14:  Top 5 Brand Names with 'Failure' mentioned in foi_text
SELECT
    d.brand_name,
    COUNT(DISTINCT t.mdr_report_key) AS report_count
FROM "maude"."DEVICE2023" d
JOIN "maude"."foitext2023" t ON d.mdr_report_key = t.mdr_report_key
WHERE LOWER(t.foi_text) LIKE '%failure%'
GROUP BY d.brand_name
ORDER BY report_count DESC
LIMIT 5;;

-- Usage: Advanced Analysis, Rows Returned: 2
-- Query 15:  Comparison of Date of Event between ASR and MDR within a specific year (e.g., 2018)
SELECT
    'ASR' AS source,
    COUNT(*)
FROM "maude"."ASR_2019"
WHERE SUBSTRING(date_of_event, -4, 4) = '2018'
UNION ALL
SELECT
    'MDR',
    COUNT(*)
FROM "maude"."mdrfoiThru2023"
WHERE SUBSTRING(date_of_event, 1, 4) = '2018'
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 1
-- Query 16: Count of distinct Manufacturer Registration Numbers in ASR_2019
SELECT
    COUNT(DISTINCT manufacturer_registration_number) AS distinct_mfr_reg_count
FROM "maude"."ASR_2019"
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 2
-- Query 17: Count of reports with 'Implant' mentioned in Brand Name in both tables
SELECT
    'ASR' AS source,
    COUNT(*)
FROM "maude"."ASR_2019"
WHERE LOWER(brand_name) LIKE '%implant%'
UNION ALL
SELECT
    'DEVICE2023',
    COUNT(*)
FROM "maude"."DEVICE2023"
WHERE LOWER(brand_name) LIKE '%implant%'
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 1
-- Query 18:  Distribution of Report Years in ASR_2019
SELECT
    report_year,
    COUNT(*) AS report_count
FROM "maude"."ASR_2019"
GROUP BY report_year
ORDER BY report_year
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 3
SELECT
    implant_available_for_evaluation,
    COUNT(*)
FROM "maude"."ASR_2019"
GROUP BY implant_available_for_evaluation
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 11
-- Query 20: Number of reports where the device was available for evaluation (DEVICE)
SELECT
    device_availability,
    COUNT(*)
FROM "maude"."DEVICE2023"
GROUP BY device_availability
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 5
-- Query 21:  Top 5 Generic Names in DEVICE2023
SELECT
    generic_name,
    COUNT(*) AS count
FROM "maude"."DEVICE2023"
GROUP BY generic_name
ORDER BY count DESC
LIMIT 5;;

-- Usage: Advanced Analysis, Rows Returned: 1
-- Query 22:  Count of reports with a specific Device Problem Code in ASR_2019 (e.g., '2682')
SELECT
    COUNT(*)
FROM "maude"."ASR_2019"
WHERE device_problem_codes LIKE '%2682%'
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 32
-- Query 23:  Yearly count of reports with manufacturer link flag 'Y' in mdrfoiThru2023
SELECT
    SUBSTRING(date_received, 1, 4) AS report_year,
    COUNT(*)
FROM "maude"."mdrfoiThru2023"
WHERE manufacturer_link_flag = 'Y'
GROUP BY report_year
ORDER BY report_year
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 32
-- Query 24:  Distribution of Reporter Occupation Codes in mdrfoiThru2023
SELECT
    reporter_occupation_code,
    COUNT(*)
FROM "maude"."mdrfoiThru2023"
GROUP BY reporter_occupation_code
ORDER BY COUNT(*) DESC
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 1
-- Query 25: Count of reports with specific event types and device problem codes in ASR_2019
SELECT
    event_type,
    COUNT(*)
FROM "maude"."ASR_2019"
WHERE event_type IN ('IN', 'D') AND device_problem_codes LIKE '%2616%'
GROUP BY event_type
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 5
-- Query 26:  Top 5 Model Numbers in DEVICE2023
SELECT
    model_number,
    COUNT(*)
FROM "maude"."DEVICE2023"
GROUP BY model_number
ORDER BY COUNT(*) DESC
LIMIT 5;;

-- Usage: Advanced Analysis, Rows Returned: 2
SELECT
    implant_returned_to_manufacturer,
    COUNT(*)
FROM "maude"."ASR_2019"
GROUP BY implant_returned_to_manufacturer
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 1
-- Query 28: Count of reports where the device was returned to the manufacturer (DEVICE)
SELECT
    COUNT(*)
FROM "maude"."DEVICE2023"
WHERE device_availability = 'R'
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 8
-- Query 29:  Distribution of Health Professional flag in mdrfoiThru2023
SELECT
    health_professional,
    COUNT(*)
FROM "maude"."mdrfoiThru2023"
GROUP BY health_professional
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 1
-- Query 30: Count of distinct Catalog Numbers in ASR_2019
SELECT
    COUNT(DISTINCT catalog_number)
FROM "maude"."ASR_2019"
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 1
-- Query 31: Count of distinct Catalog Numbers in DEVICE2023
SELECT
    COUNT(DISTINCT catalog_number)
FROM "maude"."DEVICE2023"
LIMIT 32;;

-- Usage: Advanced Analysis, Rows Returned: 32
-- Query 32: Trend of reports reported to FDA in mdrfoiThru2023
SELECT
    SUBSTRING(date_received, 1, 4) AS report_year,
    SUM(CASE WHEN report_to_fda = 'Y' THEN 1 ELSE 0 END) AS reported_to_fda_count,
    COUNT(*) AS total_reports,
    ROUND(SUM(CASE WHEN report_to_fda = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS reported_to_fda_percentage
FROM "maude"."mdrfoiThru2023"
GROUP BY report_year
ORDER BY report_year
LIMIT 32;;

