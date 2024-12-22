# Data Quality Control (DQC) Report

## 1. Introduction
This report details the results of a Data Quality Control (DQC) process performed on the MAUDE dataset. The purpose of this DQC is to identify potential issues with data integrity, consistency, and validity before proceeding with any further analysis or use of the data. The report outlines the DQC plan, the execution results of that plan, and analysis of the results leading to recommendations for data cleaning and future improvement.

## 2. Data Quality Check Plan
The DQC plan was designed to assess the quality of data across several key dimensions. These dimensions include:

*   **Field Existence Checks**: Verify that expected columns exist in each table.
*   **Field Type Consistency Checks**: Ensure that data in each column is consistent with its expected data type (as specified in the DQC plan, text fields are not checked for type compatibility with SQL, this must be done externally).
*   **Logical Relationships Between Fields**: Check for inconsistencies and invalid combinations of values within tables.

The DQC plan is implemented using a series of SQL queries detailed in the plan section above. The key aspects of the data quality checks focused on:

*   Validating the presence of required fields in each table.
*   Inspecting a sample of date fields to check they are parseable as dates in python.
*   Checking if columns with flag values (Y/N) contain other values.
*   Looking for unexpected values in coded columns.

## 3. Execution Results
The execution of the DQC plan resulted in the identification of several data quality issues. The results of the DQC queries are presented in the provided JSON and summarized below:

**Field Existence Checks:**
*   Queries 1-10 show that all expected columns exist in the tables as defined.

**Field Type Consistency Checks:**
* Queries 11-28 show samples of non-null values in date/year columns. These results must be further assessed to see if the dates are all valid. Since these fields are text, there is no further way of checking in SQL.

**Logical Relationship Between Fields:**
* **ASR_2011**
    * Query 29 indicates that `event_type` can contain values such as 'D', 'M-D', '\*', 'IN-D', 'IN', and 'M'.
    * Query 30 shows that `initial_report_flag` can contain the values 'S' and 'I'.
    * Queries 31 and 32 show that `impl_avail_for_eval` and `impl_ret_to_mfr` do not just contain 'Y' and 'N' but also '1','2' and '7'.
* **DEVICE2008**
    * Queries 33 and 34 show that the `implant_flag` and `date_removed_flag` fields have no non-null values.
   *  Query 35 shows that the `device_availability` field has unexpected values such as 'R', 'I', '\*' in addition to the expected values of 'Y' and 'N'.
   * Query 36 shows that the `combination_product_flag` field has the expected values of 'Y' and 'N'.
*   **foiclass**
   * Queries 37, 38, 39 and 40 show that `gmpexemptflag`, `thirdpartyflag`, `implant_flag` and `life_sustain_support_flag` all have the expected values of 'Y' and 'N'.
*   **mdrfoiAdd**
    * Query 41 reveals that the `report_source_code` contains values 'P', 'U', 'M', and 'D'.
    * Query 42 demonstrates that `manufacturer_link_flag` has the expected values of 'Y' and 'N', but also other numeric values '45040', '45224'.
    * Queries 43 and 44 show that the `adverse_event_flag` and `product_problem_flag` fields have the expected values of 'Y' and 'N'.
    * Query 45 shows that `reprocessed_and_reused_flag` contains values 'Y', '*', and 'N'.
    * Query 46 shows that `health_professional` contains the values 'I', 'Y', 'N', and '\*'.
    * Query 47 shows that the `single_use_flag` contains date strings as well as 'I', 'Y', and 'N'.

## 4. Analysis and Recommendations

The DQC process has identified several areas where data quality can be improved:

*   **Inconsistent Flag Values:**
   *  Several flags like `impl_avail_for_eval`, `impl_ret_to_mfr` (ASR_2011) and `device_availability` (DEVICE2008) do not strictly contain `Y` or `N`, suggesting either an issue with data entry or a broader definition of these fields that is not documented. `manufacturer_link_flag` (mdrfoiAdd) also has extra numeric values that must be investigated.  The `single_use_flag` (mdrfoiAdd) contains date strings which indicates errors in the data. The values for the flags `reprocessed_and_reused_flag` and `health_professional` (mdrfoiAdd) also have non Y/N values. These fields should be investigated further as part of data cleaning to ensure consistent and reliable values.

*   **Coded Columns Have Unexpected Values:** The `event_type` column of ASR_2011 shows that there are more values than expected. The `report_source_code` has a value 'P' which should be investigated further.

*   **Date Field Validation:** Although the date fields exist and contain a subset of non-null values, it is necessary to validate if the date format is correct and whether dates make sense in the context of other date-based information. This is especially critical for the date fields in `ASR_2011`, `DEVICE2008`, `mdrfoiAdd`, `mdr95`, `patientChange` and `patientproblemcode`, and will need to be done in python as the fields are text. The presence of dates such as "03/26/2024" in fields like `single_use_flag` in mdrfoiAdd is clearly an error and must be addressed.

**Recommendations:**

1.  **Data Cleaning:**
    *   Standardize flag fields (`impl_avail_for_eval`, `impl_ret_to_mfr`, `device_availability`, `manufacturer_link_flag`, `reprocessed_and_reused_flag`, `health_professional`, and `single_use_flag`): Decide on a standard set of values (e.g., 'Y', 'N', NULL) and transform the other values in the dataset into the appropriate categories. The columns that include values like '*' should be investigated to see if this can be remapped.
    *   Investigate, document, and normalize the `event_type` and `report_source_code` fields for ASR_2011 and mdrfoiAdd respectively, to ensure valid and consistent data.
    *   Convert the date fields to a consistent date format, handling and removing invalid or future dates. This should be done using a combination of data cleaning in pandas and additional queries to examine edge cases.

2.  **Data Validation Rules:**
    *   Implement data validation rules within the database or ETL pipeline to enforce consistent data types, valid value ranges, and logical constraints during data entry or updates.  This can be done by adding more complex checks before loading new data.

3.  **Documentation Updates:**
    *   Update the data dictionary with more detail about the meaning and allowed values for coded columns and flags. This will ensure the data is used correctly going forward.

4.  **Further Exploration:**
     * Investigate the `implant_flag` and `date_removed_flag` fields in the `DEVICE2008` table which have no non-null values.

By addressing these issues, the quality and reliability of the MAUDE dataset will be significantly improved. This will enable more accurate analysis and help in gaining more insights from the data.  It's critical that these issues be resolved before further analyses are performed.