PROMPTS = {
    # 1. 生成研究问题
    "RESEARCH_QUESTION": (
        "基于以下 MAUDE 数据库表信息，用中文提出一个有意义的研究问题和策略。\n\n"
        "{prompt_content}\n\n"
        "附加表信息：\n{add_content}\n\n"
    ),

    # 2. 规划执行步骤
    "EXECUTION_STEPS": (
        "基于以下研究问题，用中文概述具体的执行步骤，包括需要查询的表和字段。\n\n"
        "研究问题：\n{research_question}"
    ),

    # 3. 优化执行步骤
    "OPTIMIZE_STEPS": (
        "优化执行步骤，根据表结构和数据样本防止表名、字段名和数值格式的错误：\n"
        "{table_info_json}\n\n"
        "附加表信息：\n{add_content}\n\n"
        "基于上述确认的 MAUDE 数据库结构和数据样本，以及以下执行步骤，"
        "润色具体的执行步骤，特别是纠正需要查询的表和列的名称及逻辑。\n\n"
        "当前执行步骤：\n{updated_steps}\n\n"
    ),

    # 4. 生成高级分析 SQL
    "ADVANCED_SQL": (
        "根据以下执行步骤和确认的表结构及数据样本，生成直接计算统计结果的高级分析 SQL 查询。\n\n"
        "**执行步骤：**\n{execution_steps_new}\n\n"
        "**确认的表结构和数据样本：**\n{table_info}\n\n"

        "### SQL 查询要求：\n"
        "1. **表命名规范：**\n"
        "   - 所有表引用使用 **\"maude\".\"tablename\"** 格式。\n"
        "2. **控制结果集大小以防止输出过多：**\n"
        "   - 系统应根据查询上下文自动确定适当的结果限制。此外，优先生成统计查询而不仅仅是检索示例数据。\n"
        "3. **查询独立性：**\n"
        "   - 确保每个查询是独立的，不依赖于其他查询。\n"
        "4. **数据修改限制：**\n"
        "   - 不要包含任何数据修改语句，如 `UPDATE`、`DELETE`、`INSERT` 或 `CREATE`。\n"
        "5. **结合高级 SQL 功能：**\n"
        "   - **窗口函数：** 用于时间序列分析。\n"
        "   - **复杂聚合：** 使用 `CASE` 语句实现。\n"
        "   - **公用表表达式 (CTE)：** 用于增强可读性和组织性。\n"
        "   - **子查询：** 用于执行复杂计算。\n"
        "   - **NULL 处理：** 使用 `NULLIF` 和 `COALESCE` 有效管理缺失数据。\n"
        "   - **统计计算：** 包括平均值、百分位数等计算。\n"
        "   - **类似透视的操作：** 使用条件聚合技术实现。\n\n"
        "6. **在 ```sql``` 代码块内提供 SQL 查询。**\n"

        "### 示例查询格式：\n"
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
        "LIMIT 10;\n"
        "```\n\n"

        "### 任务：\n"
        "基于提供的执行步骤和表信息，生成 **复杂的分析 SQL 查询**，以提供直接的统计见解。确保每个查询符合上述所有要求。"
    ),

    # 5. 当执行 SQL 出错时的纠正提示
    "CORRECTION_PROMPT": (
        "以下 SQL 查询执行时出现错误。请根据错误信息和表信息进行纠正。\n\n"
        "原始 SQL 查询：\n{current_query}\n\n"
        "错误信息：{error}\n\n"
        "表信息：{table_info}\n\n"
        "请在 ```sql``` 代码块内提供修正后的 SQL 查询。\n"
        "所有表引用使用 **\"maude\".\"tablename\"** 格式。\n"
        "不要包含任何额外的评论或文本。"
    ),

    # 6. 当查询为空时的重新设计提示
    "REDESIGN_PROMPT": (
        "以下 SQL 查询执行成功但未返回数据。请根据表信息重新设计 SQL 查询以检索有意义的结果。\n\n"
        "原始 SQL 查询：\n{current_query}\n\n"
        "表信息：{table_info}\n\n"
        "请在 ```sql``` 代码块内提供重新设计的 SQL 查询。\n"
        "所有表引用使用 **\"maude\".\"tablename\"** 格式。\n"
        "确保查询检索相关数据并遵循最佳实践。\n"
        "不要包含任何额外的评论或文本。"
    ),

    # 7. DQC 计划生成
    "DQC_PLAN": (
        "请根据以下执行步骤创建详细的数据质量检查 (DQC) 计划。 "
        "仅关注执行步骤中涉及的字段，而非表的所有字段。\n\n"
        "确认的 MAUDE 数据库表结构和样本数据：\n{table_info_json}\n\n"
        "附加表信息：\n{add_content}\n\n"
        "优化后的执行步骤：\n{execution_steps}\n\n"
        "DQC 计划应包括以下方面：\n"
        "1. 字段存在性检查\n"
        "2. 字段类型一致性检查\n"
        "3. 字段之间的逻辑关系\n"
        "4. 数据清洗和转换验证\n"
        "5. 潜在的数据质量问题和建议\n\n"
        "请概述执行这些检查所需的策略和相应的 SQL 查询。\n"
        "在 ```sql``` 代码块内提供 SQL 查询。\n"
        "确保表名格式为 **\"maude\".\"tablename\"** 并使用正确的表/列名。\n"
        "不要生成任何可能修改数据的 SQL 查询（例如 UPDATE、DELETE、INSERT 等）。\n\n"
        "确保每个查询包含 LIMIT 10 或类似技术以避免返回过多行。\n"
        "以以下格式提供查询：\n\n"
        "```sql\nSELECT * FROM \"maude\".\"tablename\" LIMIT 10;\n```\n"
    ),

    # 8. 生成 DQC 报告
    "DQC_REPORT": (
        "请根据以下计划和执行结果生成详细的数据质量控制 (DQC) 报告。 "
        "报告应采用 Markdown 格式，并包括：\n"
        "1. 引言\n"
        "2. 数据质量检查计划\n"
        "3. 执行结果\n"
        "4. 分析与建议\n\n"
        "### 数据质量检查计划：\n"
        "{dqc_plan}\n\n"
        "### 执行结果：\n"
        "```json\n{dqc_results_str}\n```\n\n"
        "### 分析与建议：\n"
        "根据执行结果，分析识别出数据质量问题并提供改进建议。"
    ),

    # 9. 分析执行结果，用于验证研究问题
    "ANALYSIS_PROMPT": (
        "基于以下研究问题和数据，首先列出研究问题，接着对返回的数据进行解释和洞察（如果可能，使用表格呈现见解，**不要伪造数据**），其次分析研究问题的有效性和可行性。\n\n"
        "研究问题：{research_question}\n\n"
        "数据：{data_json}\n\n"
        "请提供详细的分析报告："
    ),
    
        # 10. 优化自定义研究问题
    "CUSTOMIZED_QUESTION_OPTIMIZE": (
        "您提供了以下研究问题、数据库模式和附加表信息。"
        "请执行以下任务：\n\n"
        "1. **验证可行性**：评估使用提供的数据库模式、数据样本和其他信息是否可以回答自定义的研究问题。\n"
        "2. **优化研究问题**：润色和改进研究问题，以确保其清晰、具体，并与可用数据保持一致。\n\n"
        "**研究问题：**\n{custom_research_question}\n\n"
        "**MAUDE数据库：**\n{prompt_content}\n\n"
        "**附加表信息：**\n{add_content}\n\n"
        "请以结构化格式提供分解的子问题、验证结果和优化后的研究问题。"
    ),
}
