-- ============================================================
-- BankEase -- Banking Management System
-- Data Definition Language (DDL)
-- Group 19: Akash Kumer Dey (240230), Joyee Mitra Roti (240237)
-- Target: MySQL 8.0.16+ or MariaDB 10.4+ (XAMPP). CHECK constraints are enforced.
--
-- Updated to match the revised ER diagram (bankease_er_diagram_updated.pdf):
--   * new tables: customer_contacts, branch_assignments, account_holders (joint
--     accounts), nominees, external_accounts, loan_parties (co-borrowers), user_roles
--   * accounts no longer carry customer_id (ownership is through account_holders);
--     loans no longer carry customer_id (borrowers are through loan_parties);
--     employees no longer carry branch_id (postings are through branch_assignments);
--     users no longer carry email / role_id (roles are through user_roles)
--   * beneficiaries point to an internal account OR an external account;
--     transfers credit an internal transaction OR go to an external account
--   * addresses lose city / is_primary; transfers lose status
--
-- Customer table includes KYC details (CIF number, Bangla name, father / mother /
-- spouse name, nationality, profession, monthly income, source of fund, TIN,
-- KYC status, KYC verifier and verified-at time); addresses are stored as
-- present / permanent with post office and thana.
-- These follow the BRAC Bank "KYC Form for Beneficial Owner".
-- Also included: performance indexes and reporting views.
--
-- Note: MySQL does not allow a referential action (ON DELETE ...) on a column that
-- is also used in a CHECK constraint, so those FKs use the default (RESTRICT).
-- ============================================================

DROP DATABASE IF EXISTS bankease;
CREATE DATABASE bankease CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bankease;

-- ------------------------------------------------------------
-- 1. roles
-- ------------------------------------------------------------
CREATE TABLE roles (
    role_id     INT AUTO_INCREMENT PRIMARY KEY,
    role_name   VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 2. branches  (managed_by employee 0..1 -- FK added later because of the
--    circular reference with employees, see ALTER TABLE below)
-- ------------------------------------------------------------
CREATE TABLE branches (
    branch_id            INT AUTO_INCREMENT PRIMARY KEY,
    branch_name          VARCHAR(100) NOT NULL UNIQUE,
    address              VARCHAR(255) NOT NULL,
    phone                VARCHAR(20) NOT NULL,
    manager_employee_id  INT UNIQUE,
    opening_date         DATE NOT NULL,
    status               ENUM('active','closed','under_renovation') NOT NULL DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 3. employees
--    position holds the job title: Branch Manager, Teller,
--    Senior Teller, Customer Service Officer, Loan Officer ...
--    Which branch an employee works at is recorded in branch_assignments.
-- ------------------------------------------------------------
CREATE TABLE employees (
    employee_id        INT AUTO_INCREMENT PRIMARY KEY,
    full_name          VARCHAR(100) NOT NULL,
    phone              VARCHAR(20) NOT NULL,
    email              VARCHAR(100) NOT NULL UNIQUE,
    position           VARCHAR(100) NOT NULL,
    hire_date          DATE NOT NULL,
    employment_status  ENUM('active','on_leave','terminated') NOT NULL DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Close the circular reference: branches.manager_employee_id -> employees
-- ------------------------------------------------------------
ALTER TABLE branches
    ADD CONSTRAINT fk_branches_manager FOREIGN KEY (manager_employee_id)
        REFERENCES employees(employee_id) ON DELETE SET NULL;

-- ------------------------------------------------------------
-- 4. branch_assignments  (weak entity: has_posting / posted_as)
--    Key is inherited from branch + employee; start_date is the partial key.
--    end_date IS NULL means the posting is current.
-- ------------------------------------------------------------
CREATE TABLE branch_assignments (
    branch_id    INT  NOT NULL,
    employee_id  INT  NOT NULL,
    start_date   DATE NOT NULL,
    end_date     DATE,
    PRIMARY KEY (branch_id, employee_id, start_date),
    CONSTRAINT fk_assign_branch FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    CONSTRAINT fk_assign_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT chk_assign_dates CHECK (end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 5. customers  (registers_at, kyc_verified_by)
--    Personal / identity / KYC details of a customer.
-- ------------------------------------------------------------
CREATE TABLE customers (
    customer_id                  INT AUTO_INCREMENT PRIMARY KEY,
    cif_number                   VARCHAR(20) NOT NULL UNIQUE,
    full_name                    VARCHAR(100) NOT NULL,
    full_name_bn                 VARCHAR(100),
    father_name                  VARCHAR(100) NOT NULL,
    mother_name                  VARCHAR(100) NOT NULL,
    spouse_name                  VARCHAR(100),
    date_of_birth                DATE NOT NULL,
    gender                       ENUM('male','female','other') NOT NULL,
    nationality                  VARCHAR(50) NOT NULL DEFAULT 'Bangladeshi',
    profession                   VARCHAR(100) NOT NULL,
    monthly_income               DECIMAL(12,2) CHECK (monthly_income IS NULL OR monthly_income >= 0),
    source_of_fund               VARCHAR(255) NOT NULL,
    tin_number                   VARCHAR(20) UNIQUE,
    phone                        VARCHAR(20) NOT NULL UNIQUE,
    email                        VARCHAR(100) UNIQUE,
    id_type                      ENUM('nid','passport','birth_certificate','driving_license','other') NOT NULL,
    id_number                    VARCHAR(50) NOT NULL UNIQUE,
    branch_id                    INT NOT NULL,
    status                       ENUM('active','inactive','blocked') NOT NULL DEFAULT 'active',
    kyc_status                   ENUM('pending','verified','expired','rejected') NOT NULL DEFAULT 'pending',
    kyc_verified_by_employee_id  INT,
    kyc_verified_at              DATETIME,
    registration_date            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_customers_branch FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    -- no ON DELETE action here: MySQL does not allow a referential action on a column that is
    -- also used in a CHECK constraint, and a verifier's record should not vanish anyway
    CONSTRAINT fk_customers_kyc_employee FOREIGN KEY (kyc_verified_by_employee_id)
        REFERENCES employees(employee_id),
    -- any customer whose KYC has been looked at must record who did it and when
    CONSTRAINT chk_customers_kyc CHECK (
        kyc_status = 'pending'
        OR (kyc_verified_by_employee_id IS NOT NULL AND kyc_verified_at IS NOT NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 6. addresses  (belongs_to)
--    The KYC form asks for a present and a permanent address:
--    Road/Vill, P.O, Thana, District.
-- ------------------------------------------------------------
CREATE TABLE addresses (
    address_id    INT AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT NOT NULL,
    address_type  ENUM('present','permanent') NOT NULL DEFAULT 'present',
    address_line  VARCHAR(255) NOT NULL,
    post_office   VARCHAR(100),
    thana         VARCHAR(100),
    district      VARCHAR(100) NOT NULL,
    postal_code   VARCHAR(20),
    country       VARCHAR(100) NOT NULL DEFAULT 'Bangladesh',
    CONSTRAINT fk_addresses_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 7. customer_contacts  (has_contact)
--    Additional phone numbers / e-mail addresses beyond the main
--    phone and email stored on customers.
-- ------------------------------------------------------------
CREATE TABLE customer_contacts (
    contact_id     INT AUTO_INCREMENT PRIMARY KEY,
    customer_id    INT NOT NULL,
    contact_type   ENUM('mobile','home_phone','office_phone','email','emergency') NOT NULL,
    contact_value  VARCHAR(100) NOT NULL,
    CONSTRAINT fk_contacts_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 8. users  (login_for customer / login_for employee)
--    Exactly one of linked_customer_id / linked_employee_id is set.
--    The login name is the e-mail of the linked customer / employee;
--    roles are assigned through user_roles.
-- ------------------------------------------------------------
CREATE TABLE users (
    user_id                INT AUTO_INCREMENT PRIMARY KEY,
    password_hash          VARCHAR(255) NOT NULL,
    linked_customer_id     INT UNIQUE,
    linked_employee_id     INT UNIQUE,
    failed_login_attempts  INT NOT NULL DEFAULT 0,
    status                 ENUM('active','locked','disabled') NOT NULL DEFAULT 'active',
    last_login_at          DATETIME,
    created_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_customer FOREIGN KEY (linked_customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_users_employee FOREIGN KEY (linked_employee_id) REFERENCES employees(employee_id),
    CONSTRAINT chk_users_link CHECK ((linked_customer_id IS NULL) <> (linked_employee_id IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 9. user_roles  (weak entity: has_role / role_of)
--    Key is inherited from user + role.
-- ------------------------------------------------------------
CREATE TABLE user_roles (
    user_id      INT NOT NULL,
    role_id      INT NOT NULL,
    assigned_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_userroles_user FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_userroles_role FOREIGN KEY (role_id) REFERENCES roles(role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 10. account_types  (of_type)
-- ------------------------------------------------------------
CREATE TABLE account_types (
    account_type_id      INT AUTO_INCREMENT PRIMARY KEY,
    type_name            VARCHAR(50) NOT NULL UNIQUE,
    minimum_balance      DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (minimum_balance >= 0),
    interest_rate        DECIMAL(5,2) NOT NULL DEFAULT 0 CHECK (interest_rate >= 0),
    single_per_customer  BOOLEAN NOT NULL DEFAULT FALSE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 11. accounts  (of_type, managed_by)
--     Who owns the account is recorded in account_holders.
-- ------------------------------------------------------------
CREATE TABLE accounts (
    account_id       INT AUTO_INCREMENT PRIMARY KEY,
    account_number   VARCHAR(20) NOT NULL UNIQUE,
    account_title    VARCHAR(150) NOT NULL,
    account_type_id  INT NOT NULL,
    branch_id        INT NOT NULL,
    balance          DECIMAL(14,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    currency         VARCHAR(10) NOT NULL DEFAULT 'BDT',
    status           ENUM('active','frozen','closed','pending') NOT NULL DEFAULT 'pending',
    opening_date     DATE NOT NULL,
    closing_date     DATE,
    CONSTRAINT fk_accounts_type FOREIGN KEY (account_type_id) REFERENCES account_types(account_type_id),
    CONSTRAINT fk_accounts_branch FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    CONSTRAINT chk_accounts_dates CHECK (closing_date IS NULL OR closing_date >= opening_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 12. account_holders  (weak entity: held_in / holds)
--     Key is inherited from account + customer. Supports joint accounts.
--     Rule from the ER diagram: every account has at least one holder and
--     exactly one of them is PRIMARY. "At most one primary" is enforced by
--     the unique key below; "at least one primary" cannot be expressed as a
--     plain constraint -- insert the primary holder when the account is
--     created (see the check query at the end of the DML file).
-- ------------------------------------------------------------
CREATE TABLE account_holders (
    account_id      INT NOT NULL,
    customer_id     INT NOT NULL,
    holder_role     ENUM('primary','joint') NOT NULL DEFAULT 'primary',
    operating_mode  ENUM('single','either_or_survivor','jointly') NOT NULL DEFAULT 'single',
    added_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    primary_marker  TINYINT GENERATED ALWAYS AS (IF(holder_role = 'primary', 1, NULL)) STORED,
    PRIMARY KEY (account_id, customer_id),
    CONSTRAINT uq_one_primary_holder UNIQUE (account_id, primary_marker),
    CONSTRAINT fk_holders_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_holders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 13. nominees  (nominee_of)
-- ------------------------------------------------------------
CREATE TABLE nominees (
    nominee_id        INT AUTO_INCREMENT PRIMARY KEY,
    account_id        INT NOT NULL,
    full_name         VARCHAR(100) NOT NULL,
    relationship      VARCHAR(50) NOT NULL,
    date_of_birth     DATE,
    share_percentage  DECIMAL(5,2) NOT NULL DEFAULT 100.00
        CHECK (share_percentage > 0 AND share_percentage <= 100),
    CONSTRAINT fk_nominees_account FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 14. external_accounts  (accounts at other banks)
--     Targets of beneficiaries (refers_to) and interbank transfers (to_external).
-- ------------------------------------------------------------
CREATE TABLE external_accounts (
    external_account_id  INT AUTO_INCREMENT PRIMARY KEY,
    account_number       VARCHAR(30) NOT NULL,
    account_name         VARCHAR(150) NOT NULL,
    bank_name            VARCHAR(100) NOT NULL,
    routing_number       VARCHAR(20) NOT NULL,
    CONSTRAINT uq_external_account UNIQUE (bank_name, routing_number, account_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 15. transactions  (posted_to, counterparty, performed_by)
--     performed_by is optional in the diagram (0..1), e.g. system-generated entries.
-- ------------------------------------------------------------
CREATE TABLE transactions (
    transaction_id        INT AUTO_INCREMENT PRIMARY KEY,
    reference_number      VARCHAR(30) NOT NULL UNIQUE,
    account_id            INT NOT NULL,
    transaction_type      ENUM('deposit','withdrawal','transfer_in','transfer_out','fee','interest') NOT NULL,
    amount                DECIMAL(14,2) NOT NULL CHECK (amount > 0),
    balance_before        DECIMAL(14,2) NOT NULL,
    balance_after         DECIMAL(14,2) NOT NULL,
    related_account_id    INT,
    description           VARCHAR(255),
    status                ENUM('pending','completed','failed','reversed') NOT NULL DEFAULT 'completed',
    performed_by_user_id  INT,
    created_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transactions_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_transactions_related_account FOREIGN KEY (related_account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_transactions_user FOREIGN KEY (performed_by_user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 16. transfers  (debit_side, credit_side, to_external)
--     Every transfer has a debit transaction. Exactly one of
--     credit_transaction_id (internal transfer) / external_account_id
--     (transfer to another bank) is set.
-- ------------------------------------------------------------
CREATE TABLE transfers (
    transfer_id            INT AUTO_INCREMENT PRIMARY KEY,
    debit_transaction_id   INT NOT NULL UNIQUE,
    credit_transaction_id  INT UNIQUE,
    external_account_id    INT,
    transfer_type          ENUM('internal','interbank') NOT NULL DEFAULT 'internal',
    fee                    DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (fee >= 0),
    CONSTRAINT fk_transfers_debit FOREIGN KEY (debit_transaction_id) REFERENCES transactions(transaction_id),
    CONSTRAINT fk_transfers_credit FOREIGN KEY (credit_transaction_id) REFERENCES transactions(transaction_id),
    CONSTRAINT fk_transfers_external FOREIGN KEY (external_account_id) REFERENCES external_accounts(external_account_id),
    CONSTRAINT chk_transfers_destination CHECK (
        (transfer_type = 'internal'  AND credit_transaction_id IS NOT NULL AND external_account_id IS NULL)
        OR
        (transfer_type = 'interbank' AND credit_transaction_id IS NULL AND external_account_id IS NOT NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 17. beneficiaries  (saved_by, points_to, refers_to)
--     Exactly one of target_account_id (a BankEase account) /
--     external_account_id (an account at another bank) is set.
-- ------------------------------------------------------------
CREATE TABLE beneficiaries (
    beneficiary_id       INT AUTO_INCREMENT PRIMARY KEY,
    customer_id          INT NOT NULL,
    nickname             VARCHAR(50),
    target_account_id    INT,
    external_account_id  INT,
    added_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_beneficiaries_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_beneficiaries_account FOREIGN KEY (target_account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_beneficiaries_external FOREIGN KEY (external_account_id) REFERENCES external_accounts(external_account_id),
    CONSTRAINT chk_beneficiaries_target CHECK ((target_account_id IS NULL) <> (external_account_id IS NULL)),
    CONSTRAINT uq_beneficiary_target UNIQUE (customer_id, target_account_id),
    CONSTRAINT uq_beneficiary_external UNIQUE (customer_id, external_account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 18. cards  (held_by, linked_to)
-- ------------------------------------------------------------
CREATE TABLE cards (
    card_id           INT AUTO_INCREMENT PRIMARY KEY,
    customer_id       INT NOT NULL,
    account_id        INT NOT NULL,
    card_type         ENUM('debit','credit') NOT NULL,
    masked_number     VARCHAR(20) NOT NULL,
    card_number_hash  VARCHAR(255) NOT NULL UNIQUE,
    credit_limit      DECIMAL(12,2) CHECK (credit_limit IS NULL OR credit_limit >= 0),
    issue_date        DATE NOT NULL,
    expiry_date       DATE NOT NULL,
    status            ENUM('active','blocked','expired','cancelled') NOT NULL DEFAULT 'active',
    CONSTRAINT fk_cards_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_cards_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT chk_cards_dates CHECK (expiry_date > issue_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 19. loans  (disbursed_to, approved_by)
--     Who borrowed is recorded in loan_parties.
-- ------------------------------------------------------------
CREATE TABLE loans (
    loan_id                  INT AUTO_INCREMENT PRIMARY KEY,
    loan_type                VARCHAR(50) NOT NULL,
    principal_amount         DECIMAL(14,2) NOT NULL CHECK (principal_amount > 0),
    interest_rate            DECIMAL(5,2) NOT NULL CHECK (interest_rate >= 0),
    duration_months          INT NOT NULL CHECK (duration_months > 0),
    application_date         DATE NOT NULL,
    approval_date            DATE,
    disbursement_account_id  INT,
    monthly_installment      DECIMAL(12,2) NOT NULL,
    outstanding_balance      DECIMAL(14,2) NOT NULL,
    status                   ENUM('pending','approved','rejected','active','closed','defaulted') NOT NULL DEFAULT 'pending',
    approved_by_user_id      INT,
    CONSTRAINT fk_loans_disbursement_account FOREIGN KEY (disbursement_account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_loans_approver FOREIGN KEY (approved_by_user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 20. loan_parties  (weak entity: has_party / party_to)
--     Key is inherited from loan + customer. Supports co-borrowers.
--     At most one 'borrower' per loan is enforced by the unique key below.
-- ------------------------------------------------------------
CREATE TABLE loan_parties (
    loan_id          INT NOT NULL,
    customer_id      INT NOT NULL,
    party_role       ENUM('borrower','co_borrower') NOT NULL DEFAULT 'borrower',
    added_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    borrower_marker  TINYINT GENERATED ALWAYS AS (IF(party_role = 'borrower', 1, NULL)) STORED,
    PRIMARY KEY (loan_id, customer_id),
    CONSTRAINT uq_one_main_borrower UNIQUE (loan_id, borrower_marker),
    CONSTRAINT fk_loanparty_loan FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_loanparty_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 21. loan_payments  (installment_of, paid_via)
-- ------------------------------------------------------------
CREATE TABLE loan_payments (
    payment_id              INT AUTO_INCREMENT PRIMARY KEY,
    loan_id                 INT NOT NULL,
    installment_number      INT NOT NULL CHECK (installment_number > 0),
    due_date                DATE NOT NULL,
    scheduled_principal     DECIMAL(12,2) NOT NULL,
    scheduled_interest      DECIMAL(12,2) NOT NULL,
    paid_amount             DECIMAL(12,2) NOT NULL DEFAULT 0,
    paid_date               DATE,
    status                  ENUM('due','paid','overdue','partial') NOT NULL DEFAULT 'due',
    related_transaction_id  INT,
    CONSTRAINT fk_loanpay_loan FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_loanpay_transaction FOREIGN KEY (related_transaction_id) REFERENCES transactions(transaction_id),
    CONSTRAINT uq_loan_installment UNIQUE (loan_id, installment_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 22. notifications  (sent_to)
-- ------------------------------------------------------------
CREATE TABLE notifications (
    notification_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id          INT NOT NULL,
    type             VARCHAR(50) NOT NULL,
    message          VARCHAR(255) NOT NULL,
    is_read          BOOLEAN NOT NULL DEFAULT FALSE,
    created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 23. audit_logs  (logged_by)
-- ------------------------------------------------------------
CREATE TABLE audit_logs (
    audit_id      INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT,
    action        VARCHAR(100) NOT NULL,
    target_table  VARCHAR(50) NOT NULL,
    target_id     INT,
    description   VARCHAR(255),
    ip_address    VARCHAR(45),
    result        ENUM('success','failure') NOT NULL,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- Indexes (foreign-key columns are indexed automatically by InnoDB;
-- these cover the common report / lookup patterns)
-- ============================================================
CREATE INDEX idx_transactions_account_date ON transactions (account_id, created_at);
CREATE INDEX idx_transactions_created      ON transactions (created_at);
CREATE INDEX idx_customers_kyc_status      ON customers (kyc_status);
CREATE INDEX idx_loans_status              ON loans (status);
CREATE INDEX idx_loanpay_due               ON loan_payments (status, due_date);
CREATE INDEX idx_notifications_unread      ON notifications (user_id, is_read);
CREATE INDEX idx_audit_created             ON audit_logs (created_at);

-- ============================================================
-- Reporting views -- the branch-management reports named in the
-- BRAC Bank interview (daily transactions, account activity/status,
-- cash-related activity) plus a KYC overview
-- ============================================================

-- Daily transaction summary per branch (completed transactions only)
CREATE VIEW v_daily_transaction_summary AS
SELECT DATE(t.created_at) AS txn_date,
       b.branch_id,
       b.branch_name,
       COUNT(*) AS txn_count,
       SUM(CASE WHEN t.transaction_type IN ('deposit','transfer_in','interest')
                THEN t.amount ELSE 0 END) AS total_credits,
       SUM(CASE WHEN t.transaction_type IN ('withdrawal','transfer_out','fee')
                THEN t.amount ELSE 0 END) AS total_debits
FROM transactions t
JOIN accounts a ON a.account_id = t.account_id
JOIN branches b ON b.branch_id = a.branch_id
WHERE t.status = 'completed'
GROUP BY DATE(t.created_at), b.branch_id, b.branch_name;

-- Account count and total balance by branch, account type and status
CREATE VIEW v_account_status_summary AS
SELECT b.branch_name,
       at.type_name,
       a.status,
       COUNT(*) AS account_count,
       SUM(a.balance) AS total_balance
FROM accounts a
JOIN branches b ON b.branch_id = a.branch_id
JOIN account_types at ON at.account_type_id = a.account_type_id
GROUP BY b.branch_name, at.type_name, a.status;

-- Cash in (deposits) and cash out (withdrawals) per branch per day
CREATE VIEW v_cash_activity AS
SELECT DATE(t.created_at) AS txn_date,
       b.branch_name,
       SUM(CASE WHEN t.transaction_type = 'deposit' THEN t.amount ELSE 0 END) AS cash_in,
       SUM(CASE WHEN t.transaction_type = 'withdrawal' THEN t.amount ELSE 0 END) AS cash_out
FROM transactions t
JOIN accounts a ON a.account_id = t.account_id
JOIN branches b ON b.branch_id = a.branch_id
WHERE t.status = 'completed'
  AND t.transaction_type IN ('deposit','withdrawal')
GROUP BY DATE(t.created_at), b.branch_name;

-- Customer KYC overview: who verified each customer, and when
CREATE VIEW v_customer_kyc_overview AS
SELECT c.customer_id,
       c.cif_number,
       c.full_name,
       c.id_type,
       c.id_number,
       c.profession,
       c.monthly_income,
       c.source_of_fund,
       c.tin_number,
       c.kyc_status,
       e.full_name AS verified_by,
       c.kyc_verified_at,
       b.branch_name
FROM customers c
JOIN branches b ON b.branch_id = c.branch_id
LEFT JOIN employees e ON e.employee_id = c.kyc_verified_by_employee_id;