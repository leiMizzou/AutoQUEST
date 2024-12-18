Here’s the updated **README** with the explanation of the **QUEST** acronym integrated:

---

# AutoQUEST: A Task-oriented Agent for Informatics Research

![License](https://img.shields.io/badge/license-MIT-blue.svg)

This repository demonstrates **AutoQUEST**, a task-oriented agent designed to streamline informatics research workflows. Using the **MAUDE** (Manufacturer and User Facility Device Experience) database as an example data source, AutoQUEST automates research question generation, data integration, querying, and analysis to uncover actionable insights.

## Overview
The **MAUDE** database, maintained by the U.S. FDA, contains detailed records of medical device failures, patient problems, and adverse events. Despite its potential, its size and complexity make it challenging to extract meaningful insights efficiently. 

AutoQUEST simplifies this process by automating key aspects of data querying and analysis, allowing researchers to explore trends, identify high-risk devices, and generate evidence-based insights.

---

## Problem Statement
Medical device safety is critical in healthcare. The vast and complex MAUDE database provides valuable insights into device-related adverse events but poses significant challenges:
- **Data Volume**: Millions of records spanning decades.  
- **Complex Schema**: Multiple linked tables and inconsistent formats.  
- **Manual Overhead**: Significant time and expertise required for analysis.  

---

## Solution: AutoQUEST
AutoQUEST addresses these challenges with:
- **Dynamic Research Question Generation**: Automatically formulates research questions based on user goals and database structure.
- **SQL Query Automation**: Generates optimized queries for extracting data from complex tables like MAUDE. 
- **Data Integration and Analysis**: Handles data cleaning, merging, and trend analysis across large datasets.
- **Reporting and Visualization**: Produces actionable insights with dynamic visualizations and structured reports.

---

## What is AutoQUEST?

**AutoQUEST** is an intelligent agent built for automating research workflows. It operates through a modular **THINK/DO Chain** framework, optimizing both cognitive and operational processes:

1. **THINK Chain**  
   - Focuses on **reasoning**, **planning**, and **memory** to generate and refine research questions, develop execution plans, and manage contextual knowledge.
   - Example in MAUDE: AutoQUEST identifies key fields such as device problem codes or event types, ensuring targeted analysis.

2. **DO Chain**  
   - Executes SQL queries, retrieves data, handles errors, and performs analysis. 
   - Example in MAUDE: Extracts longitudinal trends in adverse events by querying `Merged_Table_1` and visualizing outcomes.

This separation ensures scalability and adaptability to other datasets while maintaining the MAUDE database as a benchmark for its capabilities.

### The Meaning of "QUEST"
The term **QUEST** reflects the core functionalities of the AutoQUEST system and can be understood as:  
- **Query**: Formulating precise research questions and extracting relevant data.  
- **Understand**: Analyzing the input and context to guide planning.  
- **Execute**: Running queries and retrieving results.  
- **Synthesize**: Processing and summarizing the data into actionable insights.  
- **Transform**: Converting the findings into meaningful outputs such as reports or visualizations.  

These components work together seamlessly to streamline complex informatics research workflows.

---

## Automated Workflow with MAUDE Example

### 1. **Research Question Formulation**
   - User input: "Analyze adverse event trends by device type."
   - AutoQUEST generates specific research questions, such as:
     - "Which devices have the highest frequency of adverse events over the last five years?"
     - "What trends exist in device failure rates across medical specialties?"

### 2. **SQL Query Generation**
   - AutoQUEST dynamically generates SQL queries:
     - Fetching adverse events by `device_problem_code` and `event_type` from `Merged_Table_3`.
     - Analyzing event frequency over time from `Merged_Table_1`.

### 3. **Data Processing and Integration**
   - MAUDE datasets from multiple years are cleaned and merged.
   - Example: `Merged_Table_8` consolidates patient demographics to correlate adverse events with age or gender.

### 4. **Automated Analysis and Visualization**
   - AutoQUEST executes the queries and generates visualizations:
     - Heatmaps of adverse event frequencies by device type.
     - Trend graphs showing longitudinal changes in event rates.

### 5. **Reporting and Documentation**
   - The results are summarized into dynamic reports tailored to the research question, such as:
     - "Top 5 High-Risk Devices by Event Frequency."
     - "Correlation Between Adverse Events and Patient Demographics."

---

## THINK/DO Chain in MAUDE Context

### THINK Chain (Cognitive Layer)
1. **Reasoning**: Generates targeted research questions based on MAUDE schema and user goals.  
   *Example*: Identifies relevant tables like `Merged_Table_1` and `Merged_Table_3` for event frequency analysis.
2. **Planning**: Designs the workflow to query and analyze adverse events by device type and timeframe.
3. **Memory**: Stores and recalls prior query results or reusable SQL snippets for iterative research.

### DO Chain (Operational Layer)
1. **Execution**: Runs SQL queries on the MAUDE database to fetch relevant data.
2. **Error Handling**: Automatically corrects invalid queries using feedback from database errors.
3. **Analysis**: Processes extracted data into insights, such as device safety trends or risk matrices.

---

## Contents

### Files
- **`sql.ipynb`**: Jupyter notebook demonstrating SQL query generation and analysis with MAUDE data.  
- **`prompt.txt`**: Describes MAUDE table schemas and fields for reference during query generation.

### Key Tables and Fields in MAUDE
- **`Merged_Table_1`**: Longitudinal view of device-related events.  
- **`Merged_Table_3`**: Focuses on event reports and device problems.  
- **`Merged_Table_8`**: Consolidates patient data for demographic analysis.  
- **`Merged_Table_9`**: Captures free-text narratives of adverse events.  

---

## Applications
AutoQUEST, demonstrated with MAUDE, can be applied to other datasets requiring dynamic research workflows. Common use cases include:
- Trend analysis of medical device adverse events.
- Identification of high-risk devices and failure patterns.
- Analysis of correlations between patient demographics and outcomes.

---

## License and Acknowledgments
This project is licensed under the [MIT License](LICENSE). It leverages publicly available data from the FDA's MAUDE database to demonstrate the capabilities of AutoQUEST.

For more details on the MAUDE database, refer to the [FDA MAUDE Documentation](https://www.fda.gov/medical-devices/medical-device-reporting-mdr/how-search-maude).

---

This version incorporates the **QUEST** acronym meaning into the core explanation of AutoQUEST. Let me know if further refinements are needed!
