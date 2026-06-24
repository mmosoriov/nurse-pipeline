# 📖 C3-Pipeline Data Dictionary

This document provides column-level documentation for all tables in the C3-Pipeline analytical database.

---

## Source System Legend
| System | Description |
|:---|:---|
| **EHR** | Electronic Health Record (simulating Epic Clarity/Caboodle) |
| **MSG** | Secure Messaging Platform (simulating TigerConnect/Vocera) |
| **ETL** | Derived during PySpark ETL pipeline |

---

## Table 1: `dim_encounters`
**Source**: EHR  
**Grain**: One row per patient hospital stay (admission to discharge)  
**Approximate Rows**: ~10,000

| Column | Data Type | Nullable | Source | Description |
|:---|:---|:---|:---|:---|
| `encounter_id` | VARCHAR(12) | No | EHR | **Primary Key**. Unique identifier for each hospital visit. Format: `ENC-NNNNNN` |
| `patient_id` | VARCHAR(10) | No | EHR | Anonymized patient identifier. One patient may have multiple encounters. Format: `PAT-NNNNN` |
| `patient_age` | INTEGER | No | EHR | Patient age at admission. Range: 18–95 |
| `patient_sex` | VARCHAR(1) | No | EHR | Patient sex. Values: `M`, `F` |
| `admit_timestamp` | TIMESTAMP | No | EHR | Date and time of patient admission |
| `discharge_timestamp` | TIMESTAMP | Yes | EHR | Date and time of patient discharge. **NULL** if patient is still admitted |
| `discharge_disposition` | VARCHAR(40) | Yes | EHR | Where the patient went after discharge. NULL if still admitted. Values: `Home`, `Skilled Nursing Facility`, `Rehab`, `Expired`, `Against Medical Advice`, `Home with Home Health` |
| `primary_diagnosis_code` | VARCHAR(10) | No | EHR | ICD-10 diagnosis code. Example: `I50.9` |
| `primary_diagnosis_desc` | VARCHAR(100) | No | EHR | Human-readable diagnosis description. Example: `Heart Failure, Unspecified` |
| `admitting_unit` | VARCHAR(30) | No | EHR | Hospital unit where the patient is located. Values: `ICU`, `MedSurg East`, `MedSurg West`, `Telemetry`, `Emergency Dept` |
| `attending_provider_id` | VARCHAR(10) | No | EHR | Primary physician responsible for this patient. Format: `DOC-NNNNN` |

---

## Table 2: `fact_consult_orders`
**Source**: EHR  
**Grain**: One row per physician consult request  
**Approximate Rows**: ~30,000

| Column | Data Type | Nullable | Source | Description |
|:---|:---|:---|:---|:---|
| `consult_order_id` | VARCHAR(14) | No | EHR | **Primary Key**. Format: `CONS-NNNNNNN` |
| `encounter_id` | VARCHAR(12) | No | EHR | **Foreign Key** → `dim_encounters`. Links consult to the patient encounter |
| `requesting_provider_id` | VARCHAR(10) | No | EHR | Doctor who placed the consult order. Format: `DOC-NNNNN` |
| `requesting_provider_specialty` | VARCHAR(30) | No | EHR | Specialty of the requesting doctor. Values: `Internal Medicine`, `Emergency Medicine`, `Hospitalist`, `Family Medicine`, `General Surgery` |
| `target_specialty` | VARCHAR(30) | No | EHR | The specialty being consulted. Values: `Cardiology`, `Nephrology`, `Neurology`, `Pulmonology`, `Infectious Disease`, `Gastroenterology`, `Orthopedics`, `Oncology`, `Psychiatry`, `Palliative Care` |
| `order_timestamp` | TIMESTAMP | No | EHR | When the consult order was placed |
| `priority` | VARCHAR(10) | No | EHR | Clinical urgency. Values: `Routine` (~70%), `Urgent` (~25%), `STAT` (~5%) |
| `order_status` | VARCHAR(15) | No | EHR | Final status. Values: `Completed` (~85%), `Cancelled` (~10%), `Pending` (~5%) |

---

## Table 3: `fact_communication_logs`
**Source**: MSG  
**Grain**: One row per communication attempt by a nurse  
**Approximate Rows**: ~82,000

| Column | Data Type | Nullable | Source | Description |
|:---|:---|:---|:---|:---|
| `message_id` | VARCHAR(14) | No | MSG | **Primary Key**. Format: `MSG-NNNNNNN` |
| `consult_order_id` | VARCHAR(14) | No | MSG | **Foreign Key** → `fact_consult_orders`. The consult this message relates to |
| `sender_id` | VARCHAR(10) | No | MSG | The nurse or clerk who sent the message. Format: `RN-NNNNN` |
| `sender_role` | VARCHAR(20) | No | MSG | Role of the sender. Values: `Registered Nurse` (~90%), `Unit Clerk` (~10%) |
| `recipient_provider_id` | VARCHAR(10) | No | MSG | The specialist the message was sent to. Format: `DOC-NNNN` |
| `message_sent_timestamp` | TIMESTAMP | No | MSG | When the message/page was sent |
| `message_read_timestamp` | TIMESTAMP | Yes | MSG | When the specialist opened the message. **NULL** if never read (~12% of messages) |
| `channel` | VARCHAR(25) | No | MSG | Communication method. Values: `Secure App Chat`, `Legacy Pager`, `Vocera Badge Call`, `Phone Call to Office` |
| `message_outcome` | VARCHAR(20) | No | MSG | Result of the communication attempt. Values: `Read & Acknowledged`, `Read - No Response`, `Unread`, `Left Voicemail`, `Answered Live` |
| `response_lag_minutes` | FLOAT | Yes | ETL | **Derived**. (`message_read_timestamp` - `message_sent_timestamp`) in minutes. NULL if message was unread |

---

## Table 4: `fact_consult_completions`
**Source**: EHR + ETL  
**Grain**: One row per completed specialist consult  
**Approximate Rows**: ~25,500

| Column | Data Type | Nullable | Source | Description |
|:---|:---|:---|:---|:---|
| `completion_id` | VARCHAR(14) | No | EHR | **Primary Key**. Format: `COMP-NNNNNNN` |
| `consult_order_id` | VARCHAR(14) | No | EHR | **Foreign Key** → `fact_consult_orders`. Links to the originating consult order |
| `specialist_id` | VARCHAR(10) | No | EHR | Specialist who performed the consult. Format: `DOC-NNNN` |
| `specialist_name` | VARCHAR(50) | No | EHR | Generated specialist name. Example: `Dr. Ramirez` |
| `bedside_arrival_timestamp` | TIMESTAMP | No | EHR | When the specialist arrived at the patient's bedside |
| `note_signed_timestamp` | TIMESTAMP | No | EHR | When the specialist's consult note was finalized in the EHR |
| `order_timestamp` | TIMESTAMP | No | ETL | Joined from `fact_consult_orders` — when the consult was ordered |
| `target_specialty` | VARCHAR(30) | No | ETL | Joined from `fact_consult_orders` — the consulted specialty |
| `priority` | VARCHAR(10) | No | ETL | Joined from `fact_consult_orders` — order priority |
| `time_to_bedside_hours` | FLOAT | No | ETL | **Derived**. (`bedside_arrival_timestamp` - `order_timestamp`) / 3600 |
| `time_to_note_signed_hours` | FLOAT | No | ETL | **Derived**. (`note_signed_timestamp` - `order_timestamp`) / 3600 |
| `note_writing_duration_minutes` | FLOAT | No | ETL | **Derived**. (`note_signed_timestamp` - `bedside_arrival_timestamp`) / 60 |

---

## Table 5: `agg_consult_friction` (Aggregated)
**Source**: ETL  
**Grain**: One row per consult order  
**Approximate Rows**: ~30,000

| Column | Data Type | Nullable | Source | Description |
|:---|:---|:---|:---|:---|
| `consult_order_id` | VARCHAR(14) | No | ETL | **Primary Key / Foreign Key** → `fact_consult_orders` |
| `total_messages_sent` | INTEGER | No | ETL | Count of all messages sent for this consult |
| `total_messages_read` | INTEGER | No | ETL | Count of messages where `message_read_timestamp` IS NOT NULL |
| `unread_message_count` | INTEGER | No | ETL | Count of messages never read by the specialist |
| `first_message_timestamp` | TIMESTAMP | Yes | ETL | Timestamp of the first message sent |
| `last_message_timestamp` | TIMESTAMP | Yes | ETL | Timestamp of the last message sent |
| `avg_response_lag_minutes` | FLOAT | Yes | ETL | Average response lag across read messages. NULL if all messages unread |
| `dominant_channel` | VARCHAR(25) | Yes | ETL | The communication channel used most frequently for this consult (mode) |
| `friction_score` | INTEGER | No | ETL | Alias for `total_messages_sent`. 1 = ideal, >5 = high friction |

---

## Table 6: `agg_encounter_summary` (Aggregated)
**Source**: ETL  
**Grain**: One row per encounter (only encounters with consults)  
**Approximate Rows**: ~6,000

| Column | Data Type | Nullable | Source | Description |
|:---|:---|:---|:---|:---|
| `encounter_id` | VARCHAR(12) | No | ETL | **Primary Key / Foreign Key** → `dim_encounters` |
| `total_consults_ordered` | INTEGER | No | ETL | Total consult orders placed during this encounter |
| `total_consults_completed` | INTEGER | No | ETL | Number of consults that reached `Completed` status |
| `total_nurse_messages_sent` | INTEGER | No | ETL | Sum of all communication attempts across all consults |
| `avg_time_to_bedside_hours` | FLOAT | Yes | ETL | Average time-to-bedside across all completed consults for this encounter |
| `total_time_to_bedside_hours` | FLOAT | Yes | ETL | Sum of time-to-bedside across all completed consults |
| `length_of_stay_days` | FLOAT | Yes | ETL | (`discharge_timestamp` - `admit_timestamp`) in days. NULL if still admitted |
| `estimated_excess_bed_days` | FLOAT | No | ETL | `total_time_to_bedside_hours` / 24. Estimates bed-days consumed waiting for specialists |

---

## Key Relationships

```
dim_encounters (1) ──────→ (many) fact_consult_orders
                                    │
                                    ├──→ (many) fact_communication_logs
                                    │
                                    ├──→ (1) fact_consult_completions
                                    │
                                    └──→ (1) agg_consult_friction

dim_encounters (1) ──────→ (1) agg_encounter_summary
```
