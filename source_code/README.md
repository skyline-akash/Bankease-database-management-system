# BankEase — Banking Database Management System

> **Course:** Database Systems 2026-II
>
> **Institution:** Department of Computer Science and Engineering, Khulna University
>
> **Client Organization Studied:** BRAC Bank (Branch General Banking Operations & KYC Compliance)
>
> **Database Name:** `bankease`

## 👥 Project Team

* **Akash Kumer Dey** (`240230`)
* **Joyee Mitra Roti** (`240237`)

## 🎥 Project Presentation Video

▶️ **YouTube:** [https://youtu.be/MYuwq4_8XJg](https://youtu.be/MYuwq4_8XJg)

## 📑 Table of Contents

* [1. Project Overview](#-1-project-overview)
* [2. Project Repository Structure](#-2-project-repository-structure)
* [3. Technical Requirements](#-3-technical-requirements)
* [4. Database Installation Guide](#-4-database-installation-guide)
* [5. Database Architecture & Entity-Relationship Diagram](#-5-database-architecture--entity-relationship-diagram)
  * [Entity-Relationship Diagram (ERD)](#entity-relationship-diagram-erd)
  * [Schema Breakdown by Domain](#schema-breakdown-by-domain)
  * [Key Database Features](#key-database-features)
  * [Reporting Views](#reporting-views)
* [6. Application Configuration](#-6-application-configuration)
* [7. Running the Applications](#-7-running-the-applications)
* [8. Demo Login Credentials](#-8-demo-login-credentials)
* [9. Important Notes & Limitations](#-9-important-notes--limitations)
* [10. Included Submission Documents](#-10-included-submission-documents)

---

## 📋 1. Project Overview

**BankEase** is a comprehensive academic banking database management system paired with two web applications:

1. **Customer Site:** Provides customer-facing banking functions (account overview, fund transfers, saved beneficiaries, card details, and loan repayment tracking).
2. **Staff Portal:** Provides employee and administrator tools for managing branch operations (customer onboarding, KYC verification, account approvals, transaction processing, loan approvals, and branch reporting).

The database schema and operational workflows were designed following a requirements-determination study with **BRAC Bank**, informed by an interview with a branch General Banking Manager and analysis of a real-world *KYC Form for Beneficial Owner*.

*Disclaimer: BankEase is an academic project developed for coursework and is not an official BRAC Bank production system.*

## 📂 2. Project Repository Structure

```text
19_BankEase_FinalDB/
│
├── 19_BankEase_Report.docx             # Comprehensive project report
├── 19_BankEase_ER_Diagram.pdf          # Complete Entity-Relationship diagram
│
├── database/
│   ├── schema.sql                      # Database DDL (23 tables, constraints, indexes, 4 views)
│   └── sample_data.sql                 # Fictional demonstration DML records & consistency checks
│
└── source_code/
    ├── README.md                       # Project documentation
    │
    ├── BankEase_Customer_Site/         # Customer-facing web application
    │   ├── index.php
    │   ├── login.php
    │   ├── register.php
    │   ├── logout.php
    │   ├── config/
    │   │   ├── config.php
    │   │   └── db.php
    │   ├── includes/
    │   │   ├── auth.php
    │   │   ├── header.php
    │   │   └── footer.php
    │   ├── customer/
    │   │   └── [customer pages]
    │   └── assets/
    │       ├── css/
    │       └── js/
    │
    └── BankEase_Staff_Portal/          # Employee & Administrator portal
        ├── index.php
        ├── login.php
        ├── logout.php
        ├── config/
        │   ├── config.php
        │   └── db.php
        ├── includes/
        │   ├── helpers.php
        │   ├── loans.php
        │   ├── slip_pdf.php
        │   └── [header/footer/menu files]
        ├── dashboard/
        ├── customers/
        ├── accounts/
        ├── approvals/
        ├── transactions/
        ├── loans/
        ├── cards/
        ├── branches/
        ├── employees/
        ├── reports/
        ├── settings/
        ├── notifications/
        ├── api/
        └── assets/
            ├── css/
            └── js/
```

## ⚙️ 3. Technical Requirements

* **Database Server:** MySQL **8.0.16 or later**, or MariaDB **10.4 or later** (required for strict `CHECK` constraint enforcement and InnoDB support).
* **Web Server & Runtime:** PHP **8.x** with PDO/MySQLi enabled (compatible with XAMPP, WAMP, or LAMP).
* **Character Encoding:** `utf8mb4` collation to support Unicode characters, including customer names in **Bangla**.

## 🚀 4. Database Installation Guide

### Step 1: Start the Local Server

1. Open **XAMPP Control Panel** (or an equivalent local PHP/MySQL stack).
2. Start **Apache** and **MySQL**.
3. Open **phpMyAdmin** at `http://localhost/phpmyadmin/`, or prepare your MySQL command-line client.

### Step 2: Import the Database Schema

Import `database/schema.sql` first to create the `bankease` database, tables, constraints, indexes, and views.

> ⚠️ **Warning:** `schema.sql` starts with `DROP DATABASE IF EXISTS bankease;`. Importing it will permanently wipe and recreate any existing `bankease` database. Back up your data before running it.

* **Via phpMyAdmin:** Go to **Import**, select `database/schema.sql`, and click **Go**.
* **Via Terminal:**

  ```bash
  mysql -u root -p < database/schema.sql
  ```

### Step 3: Import the Sample Data

Once the schema import succeeds, populate the database by importing `database/sample_data.sql`.

* **Via phpMyAdmin:** Select the `bankease` database, go to **Import**, select `database/sample_data.sql`, and click **Go**.
* **Via Terminal:**

  ```bash
  mysql -u root -p bankease < database/sample_data.sql
  ```

*Note: The sample data script inserts records in foreign-key-safe order and executes two built-in consistency-check queries at the end. Both queries return **0 rows** when loaded properly.*

### Step 4: Verify Installation

Open the `bankease` database in phpMyAdmin and verify that **23 tables** and **4 reporting views** are present.

## 📊 5. Database Architecture & Entity-Relationship Diagram

### Entity-Relationship Diagram (ERD)

The interactive diagram below maps all **23 entities**, primary/foreign keys, and cardinalities across the five functional domains (you can also view the full vector diagram in [`19_BankEase_ER_Diagram.pdf`](../19_BankEase_ER_Diagram.pdf)):

```mermaid
erDiagram
    %% Customer & Staff Domain
    CUSTOMER {
        int customer_id PK
        varchar cif_number UK
        varchar full_name
        varchar full_name_bn
        varchar father_name
        varchar mother_name
        varchar spouse_name
        date date_of_birth
        enum gender
        varchar nationality
        varchar profession
        decimal monthly_income
        varchar source_of_fund
        varchar tin_number UK
        varchar phone UK
        varchar email UK
        enum id_type
        varchar id_number UK
        int branch_id FK
        enum status
        enum kyc_status
        int kyc_verified_by_employee_id FK
        datetime kyc_verified_at
        datetime registration_date
    }
    ADDRESS {
        int address_id PK
        int customer_id FK
        enum address_type
        varchar address_line
        varchar post_office
        varchar thana
        varchar city
        varchar district
        varchar postal_code
        varchar country
        boolean is_primary
    }
    CUSTOMER_CONTACT {
        int contact_id PK
        int customer_id FK
        varchar contact_type
        varchar contact_value
    }
    BRANCH {
        int branch_id PK
        varchar branch_name UK
        varchar address
        varchar phone
        int manager_employee_id FK
        date opening_date
        enum status
    }
    EMPLOYEE {
        int employee_id PK
        varchar full_name
        varchar phone
        varchar email UK
        varchar position
        int branch_id FK
        date hire_date
        enum employment_status
    }
    BRANCH_ASSIGNMENT {
        int assignment_id PK
        int branch_id FK
        int employee_id FK
        date start_date
        date end_date
    }

    %% Accounts Domain
    ACCOUNT_TYPE {
        int account_type_id PK
        varchar type_name UK
        decimal minimum_balance
        decimal interest_rate
        boolean single_per_customer
    }
    ACCOUNT {
        int account_id PK
        varchar account_number UK
        varchar account_title
        int account_type_id FK
        int branch_id FK
        decimal balance
        varchar currency
        enum status
        date opening_date
        date closing_date
    }
    ACCOUNT_HOLDER {
        int account_id PK, FK
        int customer_id PK, FK
        varchar holder_role
        varchar operating_mode
        datetime added_at
    }
    NOMINEE {
        int nominee_id PK
        int account_id FK
        varchar full_name
        varchar relationship
        date date_of_birth
        decimal share_percentage
    }
    CARD {
        int card_id PK
        int customer_id FK
        int account_id FK
        enum card_type
        varchar masked_number
        varchar card_number_hash UK
        decimal credit_limit
        date issue_date
        date expiry_date
        enum status
    }
    BENEFICIARY {
        int beneficiary_id PK
        int customer_id FK
        int target_account_id FK
        int external_account_id FK
        varchar nickname
        datetime added_at
    }
    EXTERNAL_ACCOUNT {
        int external_account_id PK
        varchar account_number
        varchar account_name
        varchar bank_name
        varchar routing_number
    }

    %% Payments Domain
    TRANSACTION {
        int transaction_id PK
        varchar reference_number UK
        int account_id FK
        int related_account_id FK
        enum transaction_type
        decimal amount
        decimal balance_before
        decimal balance_after
        varchar description
        enum status
        int performed_by_user_id FK
        datetime created_at
    }
    TRANSFER {
        int transfer_id PK
        int debit_transaction_id FK
        int credit_transaction_id FK
        int external_account_id FK
        enum transfer_type
        decimal fee
        enum status
    }

    %% Lending Domain
    LOAN {
        int loan_id PK
        int disbursement_account_id FK
        varchar loan_type
        decimal principal_amount
        decimal interest_rate
        int duration_months
        date application_date
        date approval_date
        decimal monthly_installment
        decimal outstanding_balance
        enum status
        int approved_by_user_id FK
    }
    LOAN_PARTY {
        int loan_id PK, FK
        int customer_id PK, FK
        varchar party_role
        datetime added_at
    }
    LOAN_PAYMENT {
        int payment_id PK
        int loan_id FK
        int related_transaction_id FK
        int installment_number
        date due_date
        decimal scheduled_principal
        decimal scheduled_interest
        decimal paid_amount
        date paid_date
        enum status
    }

    %% System & Security Domain
    USER {
        int user_id PK
        varchar email UK
        varchar password_hash
        int linked_customer_id FK
        int linked_employee_id FK
        int failed_login_attempts
        enum status
        datetime last_login_at
        datetime created_at
    }
    ROLE {
        int role_id PK
        varchar role_name UK
        varchar description
    }
    USER_ROLE {
        int user_id PK, FK
        int role_id PK, FK
        datetime assigned_at
    }
    AUDIT_LOG {
        int audit_id PK
        int user_id FK
        varchar action
        varchar target_table
        int target_id
        varchar description
        varchar ip_address
        enum result
        datetime created_at
    }
    NOTIFICATION {
        int notification_id PK
        int user_id FK
        varchar type
        varchar message
        boolean is_read
        datetime created_at
    }

    %% Relationships
    CUSTOMER ||--o{ ADDRESS : "belongs_to"
    CUSTOMER ||--o{ CUSTOMER_CONTACT : "has_contact"
    BRANCH ||--o{ CUSTOMER : "registers_at"
    EMPLOYEE ||--o{ CUSTOMER : "kyc_verified_by"
    BRANCH ||--o{ BRANCH_ASSIGNMENT : "has_posting"
    EMPLOYEE ||--o{ BRANCH_ASSIGNMENT : "posted_as"
    EMPLOYEE |o--o{ BRANCH : "managed_by"

    CUSTOMER ||--o{ ACCOUNT_HOLDER : "holds"
    ACCOUNT ||--|{ ACCOUNT_HOLDER : "held_in"
    ACCOUNT_TYPE ||--o{ ACCOUNT : "of_type"
    BRANCH ||--o{ ACCOUNT : "managed_by"
    ACCOUNT ||--o{ NOMINEE : "nominee_of"
    ACCOUNT ||--o{ CARD : "linked_to"
    CUSTOMER ||--o{ CARD : "held_by"

    CUSTOMER ||--o{ BENEFICIARY : "saved_by"
    ACCOUNT |o--o{ BENEFICIARY : "points_to"
    EXTERNAL_ACCOUNT |o--o{ BENEFICIARY : "refers_to"

    ACCOUNT ||--o{ TRANSACTION : "posted_to"
    ACCOUNT |o--o{ TRANSACTION : "counterparty"
    TRANSACTION ||--o| TRANSFER : "debit_side"
    TRANSACTION |o--o| TRANSFER : "credit_side"
    EXTERNAL_ACCOUNT |o--o{ TRANSFER : "to_external"

    CUSTOMER ||--o{ LOAN_PARTY : "party_to"
    LOAN ||--|{ LOAN_PARTY : "has_party"
    ACCOUNT |o--o{ LOAN : "disbursed_to"
    LOAN ||--o{ LOAN_PAYMENT : "installment_of"
    TRANSACTION |o--o{ LOAN_PAYMENT : "paid_via"

    CUSTOMER |o--o| USER : "login_for"
    EMPLOYEE |o--o| USER : "login_for"
    USER ||--o{ USER_ROLE : "has_role"
    ROLE ||--o{ USER_ROLE : "role_of"
    USER |o--o{ TRANSACTION : "performed_by"
    USER |o--o{ LOAN : "approved_by"
    USER |o--o{ AUDIT_LOG : "logged_by"
    USER ||--o{ NOTIFICATION : "sent_to"
```

### Schema Breakdown by Domain

The normalized schema comprises **23 tables** grouped across core banking domains:

| Functional Domain | Tables Included |
| :--- | :--- |
| **Organization & Staff** | `roles`, `branches`, `employees`, `branch_assignments`, `user_roles` |
| **Customer & Identity** | `customers`, `addresses`, `customer_contacts` |
| **Authentication** | `users` |
| **Accounts & Ownership** | `account_types`, `accounts`, `account_holders`, `nominees` |
| **Transactions & Transfers** | `transactions`, `transfers`, `beneficiaries`, `external_accounts` |
| **Cards** | `cards` |
| **Lending** | `loans`, `loan_parties`, `loan_payments` |
| **System & Auditing** | `notifications`, `audit_logs` |

### Key Database Features

* **Data Integrity & Constraints:** Strict Primary Keys, Foreign Keys, Unique Keys, and `CHECK` constraints (e.g., non-negative balances, valid date ranges, and mandatory verifier tracking upon KYC updates).
* **Joint Ownership & Nominees:** Supports multi-holder accounts via `account_holders` and designated beneficiaries via `nominees`.
* **Co-Borrowers & Guarantors:** Supports multiple customer roles per loan through the `loan_parties` associative table.
* **Transfer Architecture:** Pairs debit and credit transaction legs in `transfers`, supporting both internal accounts and external bank accounts (`external_accounts`).
* **Security & Traceability:** Card records store a display-safe masked number alongside a cryptographic hash (`card_number_hash`); sensitive actions are logged in `audit_logs`.
* **Performance Indexes:** Composite and single-column indexes optimize transaction histories, KYC queues, due loan installments, and unread notifications.

### Reporting Views

| View Name | Analytical Purpose |
| :--- | :--- |
| `v_daily_transaction_summary` | Completed transaction counts and totals grouped by date and branch |
| `v_account_status_summary` | Account counts and aggregate balances by branch, account type, and status |
| `v_cash_activity` | Daily cash deposit and withdrawal totals per branch |
| `v_customer_kyc_overview` | Customer KYC status, verifying staff member, verification timestamp, and branch |

## 🛠️ 6. Application Configuration

Both web applications maintain separate database configuration files:

```text
BankEase_Customer_Site/config/config.php
BankEase_Customer_Site/config/db.php

BankEase_Staff_Portal/config/config.php
BankEase_Staff_Portal/config/db.php
```

Before launching the applications:

1. Open each application's configuration files.
2. Update the host, database name (`bankease`), username, and password to match your local MySQL setup while preserving the existing variable names and connection structure.
3. Ensure both applications point to the exact same `bankease` database instance.

## 🏃 7. Running the Applications

1. Place the `BankEase_Customer_Site` and `BankEase_Staff_Portal` folders inside your web server's document root (e.g., `C:/xampp/htdocs/`).
2. Confirm that **Apache** and **MySQL** are running.
3. Open your browser and navigate to:
   * **Customer Site:** `http://localhost/BankEase_Customer_Site/`
   * **Staff Portal:** `http://localhost/BankEase_Staff_Portal/`

*(If placed inside a subfolder within `htdocs`, adjust the URLs accordingly.)*

## 🔑 8. Demo Login Credentials

The sample dataset includes pre-configured accounts for testing and evaluation.

> **Shared Demo Password:** `BankEase@2026`

### Customer Site Accounts

| Customer Name | Login Email |
| :--- | :--- |
| **Abdul Karim Mollah** | `akarim.mollah@gmail.com` |
| **Salma Khatun** | `salma.khatun92@gmail.com` |
| **Mohammad Yusuf Ali** | `yusuf.ali78@yahoo.com` |

### Staff Portal Accounts

| Staff Member | Assigned Role | Login Email |
| :--- | :--- | :--- |
| **Md. Rafiqul Islam** | Administrator | `rafiqul.islam@bankease.com.bd` |
| **Farzana Akhter** | Employee | `farzana.akhter@bankease.com.bd` |

## 📌 9. Important Notes & Limitations

* **Academic Scope:** BankEase is strictly an academic prototype built for the Database Systems course at Khulna University. Do not enter real personal data, real card numbers, or production banking credentials.
* **Fresh Imports Only:** `sample_data.sql` is intended to run once on a freshly created schema; running it multiple times without resetting `schema.sql` will trigger duplicate key errors.
* **Credential Security:** Keep local database credentials out of public repositories and shared screenshots.

## 📄 10. Included Submission Documents

* `19_BankEase_Report.docx` — Full project documentation and analysis report.
* `19_BankEase_ER_Diagram.pdf` — Entity-Relationship diagram detailing entities, attributes, cardinalities, and constraints.
* `database/schema.sql` — Data Definition Language (DDL) script.
* `database/sample_data.sql` — Data Manipulation Language (DML) script.