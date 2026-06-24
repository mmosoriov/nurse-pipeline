-- ============================================================
-- C3-Pipeline: Schema Creation (DuckDB)
-- ============================================================
-- This DDL creates all tables used in the C3 analytics pipeline.
-- Run this first before loading data or executing analytics queries.
-- ============================================================

-- Table 1: dim_encounters
-- Source: EHR System
-- Each row = one patient hospital stay
CREATE TABLE IF NOT EXISTS dim_encounters (
    encounter_id          VARCHAR(12) PRIMARY KEY,
    patient_id            VARCHAR(10) NOT NULL,
    patient_age           INTEGER NOT NULL,
    patient_sex           VARCHAR(1) NOT NULL,
    admit_timestamp       TIMESTAMP NOT NULL,
    discharge_timestamp   TIMESTAMP,          -- NULL if still admitted
    discharge_disposition VARCHAR(40),
    primary_diagnosis_code VARCHAR(10) NOT NULL,
    primary_diagnosis_desc VARCHAR(100) NOT NULL,
    admitting_unit        VARCHAR(30) NOT NULL,
    attending_provider_id VARCHAR(10) NOT NULL
);

-- Table 2: fact_consult_orders
-- Source: EHR System
-- Each row = a physician requesting a specialist consultation
CREATE TABLE IF NOT EXISTS fact_consult_orders (
    consult_order_id           VARCHAR(14) PRIMARY KEY,
    encounter_id               VARCHAR(12) NOT NULL REFERENCES dim_encounters(encounter_id),
    requesting_provider_id     VARCHAR(10) NOT NULL,
    requesting_provider_specialty VARCHAR(30) NOT NULL,
    target_specialty           VARCHAR(30) NOT NULL,
    order_timestamp            TIMESTAMP NOT NULL,
    priority                   VARCHAR(10) NOT NULL,
    order_status               VARCHAR(15) NOT NULL
);

-- Table 3: fact_communication_logs
-- Source: Secure Messaging Platform (TigerConnect / Vocera)
-- Each row = one communication attempt by a nurse
CREATE TABLE IF NOT EXISTS fact_communication_logs (
    message_id              VARCHAR(14) PRIMARY KEY,
    consult_order_id        VARCHAR(14) NOT NULL REFERENCES fact_consult_orders(consult_order_id),
    sender_id               VARCHAR(10) NOT NULL,
    sender_role             VARCHAR(20) NOT NULL,
    recipient_provider_id   VARCHAR(10) NOT NULL,
    message_sent_timestamp  TIMESTAMP NOT NULL,
    message_read_timestamp  TIMESTAMP,          -- NULL if never read
    channel                 VARCHAR(25) NOT NULL,
    message_outcome         VARCHAR(20) NOT NULL,
    response_lag_minutes    FLOAT               -- Calculated: read - sent in minutes
);

-- Table 4: fact_consult_completions
-- Source: EHR System
-- Each row = a specialist completing their consult
CREATE TABLE IF NOT EXISTS fact_consult_completions (
    completion_id               VARCHAR(14) PRIMARY KEY,
    consult_order_id            VARCHAR(14) NOT NULL REFERENCES fact_consult_orders(consult_order_id),
    specialist_id               VARCHAR(10) NOT NULL,
    specialist_name             VARCHAR(50) NOT NULL,
    bedside_arrival_timestamp   TIMESTAMP NOT NULL,
    note_signed_timestamp       TIMESTAMP NOT NULL,
    -- Enriched columns from ETL
    order_timestamp             TIMESTAMP,
    target_specialty            VARCHAR(30),
    priority                    VARCHAR(10),
    time_to_bedside_hours       FLOAT,
    time_to_note_signed_hours   FLOAT,
    note_writing_duration_minutes FLOAT
);

-- Table 5: agg_consult_friction (Aggregated)
-- One row per consult order with messaging friction metrics
CREATE TABLE IF NOT EXISTS agg_consult_friction (
    consult_order_id        VARCHAR(14) PRIMARY KEY REFERENCES fact_consult_orders(consult_order_id),
    total_messages_sent     INTEGER NOT NULL,
    total_messages_read     INTEGER NOT NULL,
    unread_message_count    INTEGER NOT NULL,
    first_message_timestamp TIMESTAMP,
    last_message_timestamp  TIMESTAMP,
    avg_response_lag_minutes FLOAT,
    dominant_channel        VARCHAR(25),
    friction_score          INTEGER NOT NULL     -- Alias for total_messages_sent
);

-- Table 6: agg_encounter_summary (Aggregated)
-- One row per encounter with consult and communication summary
CREATE TABLE IF NOT EXISTS agg_encounter_summary (
    encounter_id                VARCHAR(12) PRIMARY KEY REFERENCES dim_encounters(encounter_id),
    total_consults_ordered      INTEGER,
    total_consults_completed    INTEGER,
    total_nurse_messages_sent   INTEGER,
    avg_time_to_bedside_hours   FLOAT,
    total_time_to_bedside_hours FLOAT,
    length_of_stay_days         FLOAT,
    estimated_excess_bed_days   FLOAT
);
