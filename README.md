# Pipedrive CRM Data Model

## Project Setup

To get started with this project locally:

1. Open your **Command Prompt** or **Terminal**, navigate to the project directory, and run:

   ```bash
   docker compose up
   ```

2. Activate your **virtual environment** with `dbt-core` and `dbt-postgres` installed.

3. Install project dependencies (if not already installed):

   ```bash
   dbt deps
   ```

4. Run all DBT models:

   ```bash
   dbt run
   ```

5. Run all tests:

   ```bash
   dbt test
   ```

---

## Documentation

If you'd like to view the documentation locally:

1. Compile the models:

   ```bash
   dbt compile
   ```

2. Generate documentation:

   ```bash
   dbt docs generate
   ```

3. Serve the documentation locally:

   ```bash
   dbt docs serve
   ```

4. Open your browser and navigate to:  
   [http://localhost:8000](http://localhost:8000)




## Project Structure

You can find all the models in the [models](models/) directory

The `models/` directory is organized as follows:

```text
models/
├─ raw/
│  ├─ dimension/
│  │  ├─ raw_dim_activity_types.sql
│  │  ├─ raw_dim_stages.sql
│  ├─ fact/
│  │  ├─ raw_fact_activities.sql
│  │  ├─ raw_fact_deal_changes.sql
├─ intermediate/
│  ├─ int_activity_deals_funnel.sql
│  ├─ int_deal_stage_progression.sql
│  ├─ int_activity_funnel_mapping.sql
│  ├─ int_month_funnel_matrix.sql
├─ final/
│  ├─ rep_sales_funnel_monthly.sql

```

### Raw Layer

The **Raw Layer** can be thought of as the `landing` layer. This is where we ingest data from the source systems and perform minimal or no transformations. It acts as the foundation for further processing in the data pipeline.

The raw layer is divided into two sub-layers:

1. **Dimension**
2. **Fact**

>The models in the raw layer follow a specific naming convention: `raw_<sub_layer>_<model_name>`

#### 1. Dimension

The **dimension** sub-layer contains reference tables that describe the entities involved in our data model.

**Examples:**

- `raw_dim_activity_types.sql`: Contains types of activities.
- `raw_dim_stages.sql`: Represents the different stages in a funnel.

#### 2. Fact

The **fact** sub-layer contains the transactional or event-based data. These tables record measurable events and often contain foreign keys referencing the dimension tables.

**Examples:**

- `raw_fact_activities.sql`: Records activity-level events (e.g., sales calls, meetings).
- `raw_fact_deal_changes.sql`: Captures changes in deal status over time.


### Intermediate Layer

The **Intermediate Layer** acts as the **transformation** or **logic** layer. It sits between the raw ingested data and the final analytical outputs. This layer is responsible for:

- Applying business rules  
- Cleaning and enriching raw data  
- Performing complex joins and aggregations  
- Structuring the data in a way that supports final reporting  

This layer helps reduce complexity in the final models by centralizing repeated transformations. 

>The models in the intermediate layer follow a specific naming convention: `int_<model_name>`


#### Example Models

- `int_activity_deals_funnel.sql`: Maps activities to deals within the sales funnel, helping understand engagement across different funnel stages.
- `int_deal_stage_progression.sql`: Tracks the movement of deals across various stages over time.
- `int_activity_funnel_mapping.sql`: Enriches activities data with the corresponding activity types
- `int_month_funnel_matrix.sql`:A helper table and derives all the possible combination of month_year and funnel_step


### Final Layer

The **Final Layer** consists of curated, presentation-ready models that are used directly in dashboards, reports, or exposed to end-users.

This layer brings together all the cleaned and transformed data from the intermediate layer and organizes it into meaningful business metrics and KPIs.

#### Example Models

- `rep_sales_funnel_monthly.sql`: A reporting model that provides monthly aggregated funnel metrics.



### Model Documentation & Testing

Every model in this project is documented to ensure clarity and maintainability.

- Each model has an accompanying **`<model_name>.md`** file that provides detailed documentation about its logic, purpose, and usage. For [example](models\intermediate\int_deal_stage_progression.md) 

- Within each layer of the `models/` directory, there is a corresponding **`schema.yml`** file. This file includes:
  - **Model descriptions**
  - **Column-level descriptions**
  - **Model- and column-level data tests**

---

### Testing with `dbt-utils`

We leverage the [**dbt-utils**](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/) package (installed via `dbt deps`) to take advantage of prebuilt generic tests such as:

- `unique_combination_of_columns`
- `not_null`
- `accepted_values`

These tests help enforce data integrity and catch issues early in development. Example [schema.yml](models\raw\fact\schema.yml)

---

### Example: Unit Testing

An example of how unit testing is implemented in this project can be found [here](models\final\unit_test.yml)  

### Use of Macros

This project makes extensive use of **DBT macros** to improve scalability and reduce redundancy across models. Macros are defined [here](macros)

### Entity-Relationship Diagram (ERD)

The following diagram provides a high-level overview of the Pipedrive CRM data model architecture, organized into **Raw**, **Intermediate**, and **Final** layers:

![Pipedrive CRM ERD](./ERD%20Diagram.png)

**View the interactive ERD online:**  
[PipeDrive CRM ERD Link](https://www.drawdb.app/editor?shareId=befbda94e35b2c86bce843fd5e92d2d8)

> *Note:* The interactive ERD link might take a few moments to load.


### DBT Docs Lineage

![DBTLineage](./DBT%20Lineage.png)


### Code Quality & Consistency with SQLFluff

To ensure our SQL code is clean, consistent, and follows best practices, this project leverages **[SQLFluff](https://www.sqlfluff.com/)** — a powerful, flexible SQL linter and formatter. The config is defined [here](.sqlfluff)


#### About Files in the Repository

Usually, I would create a `.gitignore` file to exclude files and folders such as logs, `target/`, `dbt_packages/`, and others to keep the repository clean.

However, for the sake of this assignment, I am uploading everything to the repo, including these files.

You can refer to the [logs](logs) folder to verify that the models and tests ran successfully on my local environment.
