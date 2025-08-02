-- Table for activity_types.csv
CREATE TABLE activity_types (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    active VARCHAR(10),
    type VARCHAR(50)
);

-- Table for activity.csv
CREATE TABLE activity (
    activity_id INT,
    type VARCHAR(50),
    assigned_to_user INT,
    deal_id INT,
    done BOOLEAN,
    due_to TIMESTAMP
);

-- Table for deal_changes.csv
CREATE TABLE deal_changes (
    deal_id INT,
    change_time TIMESTAMP,
    changed_field_key VARCHAR(50),
    new_value VARCHAR(255)
);

-- Table for fields.csv
CREATE TABLE fields (
    ID INT PRIMARY KEY,
    FIELD_KEY VARCHAR(50),
    NAME VARCHAR(255),
    FIELD_VALUE_OPTIONS JSONB
);

-- Table for stages.csv
CREATE TABLE stages (
    stage_id INT PRIMARY KEY,
    stage_name VARCHAR(255)
);

-- Table for users.csv
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    modified TIMESTAMP
);

-- Adding _last_synced column to each table and setting default value as CURRENT_TIMESTAMP
ALTER TABLE activity_types ADD COLUMN _last_synced TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE activity ADD COLUMN _last_synced TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE deal_changes ADD COLUMN _last_synced TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE fields ADD COLUMN _last_synced TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE stages ADD COLUMN _last_synced TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE users ADD COLUMN _last_synced TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Create the pgcrypto extension for hashing functions
-- This is necessary for the mask_field macro to work correctly
CREATE EXTENSION IF NOT EXISTS pgcrypto;