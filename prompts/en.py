# ==========================================
# 1. 统一管理所有 Prompt
# ==========================================
PROMPTS = {
    # 1. 生成研究问题
    "RESEARCH_QUESTION": (
        "Based on the following MAUDE database table information, propose a meaningful research question and strategy.\n\n"
        "{prompt_content}\n\n"
        "Additional Table Information: \n{add_content}\n\n"
    ),

    # 2. 规划执行步骤
    "EXECUTION_STEPS": (
        "Based on the following research question, outline specific execution steps, including which tables and fields need to be queried.\n\n"
        "Research Question:\n{research_question}\n\n"
        "Additional Information: \n{add_content}\n\n"
    ),

    # 3. 优化执行步骤
    "OPTIMIZE_STEPS": (
        "Optimize Execution Steps, prevent table, field name and value format from errors according to Table Structures and Data Samples:\n"
        "{table_info_json}\n\n"
        "Additional Table Information:\n{add_content}\n\n"
        "Based on the above Confirmed information of MAUDE Database Structures and Data Samples and the following Execution Steps, "
        "polish the specific execution steps, especially on correcting the name and logic of tables and columns that need to be queried.\n\n"
        "Current Execution Steps:\n{updated_steps}\n\n"
    ),

    # 4. Generate Advanced Analytical SQL
    "ADVANCED_SQL": (
        "Generate advanced analytical SQL queries compatible with PostgreSQL that directly compute statistical results based on the following execution steps "
        "and confirmed table structures with data samples.\n\n"
        "**Execution Steps:**\n{execution_steps_new}\n\n"
        "**Confirmed Table Structures and Data Samples:**\n{table_info}\n\n"
        "**Additional Information:** \n{add_content}\n\n"

        "### Requirements for SQL Queries:\n"
        "1. **Table Naming Convention:**\n"
        "   - Use the format **\"maude\".\"tablename\"** for all table references.\n"
        "2. **Control Result Set Size to Prevent Excessive Output:**\n"
        "   - The system should automatically determine an appropriate limit on the number of results based on the context of the query. Additionally, prioritize generating statistical queries over merely retrieving sample data.\n"
        "   - The maximum number of results should not exceed 64.\n"
        "3. **Query Independence:**\n"
        "   - Ensure that each query is self-contained and does not depend on other queries.\n"
        "4. **Data Modification Restrictions:**\n"
        "   - Do **NOT** include any data modification statements such as `UPDATE`, `DELETE`, `INSERT`, or `CREATE`.\n"
        "5. **Incorporate Advanced SQL Features:**\n"
        "   - **Window Functions:** Utilize for time-series analysis.\n"
        "   - **Complex Aggregations:** Implement using `CASE` statements.\n"
        "   - **Common Table Expressions (CTEs):** Use to enhance readability and organization.\n"
        "   - **Subqueries:** Apply for performing complex calculations.\n"
        "   - **NULL Handling:** Use `NULLIF` and `COALESCE` to manage missing data effectively.\n"
        "   - **Statistical Calculations:** Include computations such as averages, percentiles, etc.\n"
        "   - **Pivot-like Operations:** Achieve using conditional aggregation techniques.\n\n"
        "6. **Provide the SQL queries in code blocks within ```sql``` code fences.**\n"

        "### Example Query Format (PostgreSQL):\n"
        "```sql\n"
        "WITH monthly_stats AS (\n"
        "  SELECT \n"
        "    DATE_TRUNC('month', date_column) AS month,\n"
        "    COUNT(*) AS event_count,\n"
        "    AVG(CASE WHEN numeric_col IS NOT NULL THEN numeric_col END) AS avg_value\n"
        "  FROM \"maude\".\"tablename\"\n"
        "  GROUP BY 1\n"
        ")\n"
        "SELECT * FROM monthly_stats\n"
        "ORDER BY month DESC\n"
        "LIMIT 32;\n"
        "```\n\n"

        "### Task:\n"
        "Based on the provided execution steps and table information, generate **complex analytical SQL queries** compatible with PostgreSQL that deliver direct "
        "statistical insights. Ensure that each query adheres to all the requirements listed above."
    ),

    # 5. 当执行 SQL 出错时的纠正提示
    "CORRECTION_PROMPT": (
        "The following SQL query resulted in an error. Please correct it based on the error message and the table information.\n\n"
        "Original SQL Query:\n{current_query}\n\n"
        "Error Message: {error}\n\n"
        "Table Information: {table_info}\n\n"
        "Addtional Description: {add_content}\n\n"
        "Provide the corrected SQL query enclosed within ```sql``` code fences.\n"
        "Use the format **\"maude\".\"tablename\"** for all table references.\n"
        "Do NOT include any additional commentary or text."
    ),

    # 6. 当查询为空时的重新设计提示
    "REDESIGN_PROMPT": (
        "The following SQL query executed successfully but returned no data. Please redesign the SQL query to retrieve meaningful results "
        "based on the table information.\n\n"
        "Original SQL Query:\n{current_query}\n\n"
        "Table Information: {table_info}\n\n"
        "Addtional Description: {add_content}\n\n"
        "Provide the redesigned SQL query enclosed within ```sql``` code fences.\n"
        "Use the format **\"maude\".\"tablename\"** for all table references.\n"
        "Ensure that the query retrieves relevant data and adheres to best practices.\n"
        "Do NOT include any additional commentary or text."
    ),

    # 7. DQC 计划生成
    "DQC_PLAN": (
        "Please create a detailed Data Quality Check (DQC) plan based on the following execution steps. "
        "Focus only on the fields involved in the execution steps, not all fields of the tables.\n\n"
        "Confirmed MAUDE Database Table Structures and Sample Data:\n{table_info_json}\n\n"
        "Additional Table Information:\n{add_content}\n\n"
        "Optimized Execution Steps:\n{execution_steps}\n\n"
        "The DQC plan should include the following aspects:\n"
        "1. Field Existence Checks\n"
        "2. Field Type Consistency Checks\n"
        "3. Logical Relationships Between Fields\n"
        "4. Data Cleaning and Transformation Validation\n"
        "5. Potential Data Quality Issues and Recommendations\n\n"
        "Please outline the strategies and corresponding SQL queries needed to perform these checks.\n"
        "Provide the SQL queries in code blocks within ```sql``` code fences.\n"
        "Ensure that table names are formatted as **\"maude\".\"tablename\"** and use the correct table/column names.\n"
        "Do NOT generate any SQL queries that may modify data (e.g. UPDATE, DELETE, INSERT...).\n\n"
        "Ensure each query includes a LIMIT 10 or similar technique to avoid returning too many rows.\n"
        "Provide queries in the format:\n\n"
        "```sql\nSELECT * FROM \"maude\".\"tablename\" LIMIT 10;\n```\n"
    ),

    # 8. 生成 DQC 报告
    "DQC_REPORT": (
        "Please generate a detailed Data Quality Control (DQC) report based on the following plan and execution results. "
        "The report should be in Markdown format and include:\n"
        "1. Introduction\n"
        "2. Data Quality Check Plan\n"
        "3. Execution Results\n"
        "4. Analysis and Recommendations\n\n"
        "### Data Quality Check Plan:\n"
        "{dqc_plan}\n\n"
        "### Execution Results:\n"
        "```json\n{dqc_results_str}\n```\n\n"
        "### Analysis and Recommendations:\n"
        "Based on the execution results, analyze the data quality issues identified and provide recommendations for improvement."
    ),

    # 9. 分析执行结果，用于验证研究问题
    "ANALYSIS_PROMPT": (
        "Based on the following research question and data, list the research question firstly, make interpretation and insights on returned data "
        "(use Tables to present the insights if possible, **DO NOT FAKE DATA**) secondly and then analyze the validity and feasibility of the research question.\n\n"
        "Research Question: {research_question}\n\n"
        "Data: {data_json}\n\n"
        "Provide a detailed analysis report:"
    ),
    
    # 10. 优化自定义研究问题
    "CUSTOMIZED_QUESTION_OPTIMIZE": (
        "You are provided with the following research question, database schema, and additional table information. "
        "Please perform the following tasks:\n\n"
        "1. **Validate the Feasibility**: Assess whether the customized research question is feasible to answer using the provided database schema, data samples and other information.\n"
        "2. **Optimize the Research Question**: Refine and improve the research question to ensure clarity, specificity, and alignment with the available data.\n\n"
        "**Research Question:**\n{custom_research_question}\n\n"
        "**MAUDE Database:**\n{prompt_content}\n\n"
        "**Additional Table Information:**\n{add_content}\n\n"
        "Please provide the decomposed sub-questions, validation results, and the optimized research question in a structured format."
    ),
}
