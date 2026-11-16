-- ============================================================
-- BankEase -- Banking Management System
-- Sample data (DML) for the 23-table schema in schema.sql
-- Group 19: Akash Kumer Dey (240230), Joyee Mitra Roti (240237)
--
-- Run AFTER schema.sql, on the empty bankease database.
-- Every table holds 3-5 rows. Tables are filled parents-first, so no
-- foreign key is violated. All people, phone numbers, card numbers and
-- account numbers are fictional.
--
-- DEMO LOGINS (the same password for every account):  BankEase@2026
--   Customer site   Abdul Karim Mollah     phone 01711098234  / akarim.mollah@gmail.com
--                   Salma Khatun           phone 01812345098  / salma.khatun92@gmail.com
--                   Mohammad Yusuf Ali     phone 01634509821  / yusuf.ali78@yahoo.com
--   Staff portal    Md. Rafiqul Islam      rafiqul.islam@bankease.com.bd   (Administrator)
--                   Farzana Akhter         farzana.akhter@bankease.com.bd  (Employee)
-- ============================================================

USE bankease;
SET NAMES utf8mb4;
START TRANSACTION;

-- 1. roles
INSERT INTO roles (role_name, description) VALUES
('Customer', 'Self-service banking customer'),
('Employee', 'Bank staff handling day-to-day branch operations (teller, customer service, loan officer)'),
('Administrator', 'Branch manager or head-office staff with reporting, approval and access-control rights');

-- 2. branches (manager_employee_id is filled in after employees exist)
INSERT INTO branches (branch_name, address, phone, opening_date, status) VALUES
('Khulna Sonadanga Branch', 'Sonadanga Bus Terminal Road, Khulna 9100', '01711223344', '2010-03-14', 'active'),
('Dhaka Motijheel Branch', '12 Dilkusha C/A, Motijheel, Dhaka 1000', '01912558877', '2005-07-01', 'active'),
('Chattogram Agrabad Branch', 'Agrabad C/A, Chattogram 4100', '01611004477', '2013-11-22', 'active');

-- 3. employees (the branch they work at is stored in branch_assignments)
INSERT INTO employees (full_name, phone, email, position, hire_date, employment_status) VALUES
('Md. Rafiqul Islam', '01715623948', 'rafiqul.islam@bankease.com.bd', 'Branch Manager', '2010-03-01', 'active'),
('Farzana Akhter', '01827749215', 'farzana.akhter@bankease.com.bd', 'Senior Teller', '2017-02-14', 'active'),
('Shahriar Kabir', '01911207765', 'shahriar.kabir@bankease.com.bd', 'Branch Manager', '2008-09-19', 'active'),
('Nusrat Sultana', '01614458820', 'nusrat.sultana@bankease.com.bd', 'Loan Officer', '2018-05-03', 'active'),
('Imran Hossain', '01516730294', 'imran.hossain@bankease.com.bd', 'Branch Manager', '2012-01-27', 'active');

UPDATE branches SET manager_employee_id = 1 WHERE branch_id = 1;
UPDATE branches SET manager_employee_id = 3 WHERE branch_id = 2;
UPDATE branches SET manager_employee_id = 5 WHERE branch_id = 3;

-- 4. branch_assignments (one current posting per employee)
INSERT INTO branch_assignments (branch_id, employee_id, start_date, end_date) VALUES
(1, 1, '2010-03-01', NULL),
(1, 2, '2017-02-14', NULL),
(2, 3, '2008-09-19', NULL),
(2, 4, '2018-05-03', NULL),
(3, 5, '2012-01-27', NULL);

-- 5. customers (fields follow the BRAC Bank "KYC Form for Beneficial Owner")
-- Customer 5 has KYC still pending, so staff can verify it during the demo.
INSERT INTO customers (cif_number, full_name, full_name_bn, father_name, mother_name, spouse_name, date_of_birth, gender, nationality, profession, monthly_income, source_of_fund, tin_number, phone, email, id_type, id_number, branch_id, status, kyc_status, kyc_verified_by_employee_id, kyc_verified_at, registration_date) VALUES
('10047821', 'Abdul Karim Mollah', 'আব্দুল করিম মোল্লা', 'Abdus Salam Mollah', 'Rokeya Begum', 'Shirin Akter', '1985-04-12', 'male', 'Bangladeshi', 'Assistant Teacher', 32000.00, 'Salary', '478215936402', '01711098234', 'akarim.mollah@gmail.com', 'nid', '1985123456789', 1, 'active', 'verified', 1, '2016-05-19 11:05:00', '2016-05-19 10:00:00'),
('10052390', 'Salma Khatun', 'সালমা খাতুন', 'Md. Abul Kalam', 'Nurjahan Begum', 'Md. Jahangir Alam', '1992-11-03', 'female', 'Bangladeshi', 'Boutique owner', 18500.00, 'Boutique sales income', NULL, '01812345098', 'salma.khatun92@gmail.com', 'nid', '9211003456712', 1, 'active', 'verified', 2, '2018-02-27 10:20:00', '2018-02-27 09:30:00'),
('20011642', 'Mohammad Yusuf Ali', NULL, 'Late Md. Nurul Islam', 'Hasina Banu', 'Rahima Yusuf', '1978-01-22', 'male', 'Bangladeshi', 'Garments exporter', 285000.00, 'Business income', '619034872155', '01634509821', 'yusuf.ali78@yahoo.com', 'passport', 'BN0847213', 2, 'active', 'verified', 3, '2012-08-14 13:10:00', '2012-08-14 12:15:00'),
('20011655', 'Rahima Yusuf', NULL, 'Md. Abdul Hakim', 'Sufia Begum', 'Mohammad Yusuf Ali', '1982-10-05', 'female', 'Bangladeshi', 'Homemaker', NULL, 'Spouse income', NULL, '01744286630', NULL, 'nid', '8210054432167', 2, 'active', 'verified', 3, '2012-08-14 13:25:00', '2012-08-14 12:40:00'),
('10091507', 'Nasrin Jahan Mitu', 'নাসরিন জাহান মিতু', 'Md. Mizanur Rahman', 'Fatema Begum', 'Md. Rakibul Hasan', '1995-02-28', 'female', 'Bangladeshi', 'Staff nurse', 29800.00, 'Salary', NULL, '01716789021', 'nasrin.mitu95@gmail.com', 'nid', '9502281145678', 1, 'active', 'pending', NULL, NULL, '2026-11-10 10:15:00');

-- 6. addresses
INSERT INTO addresses (customer_id, address_type, address_line, post_office, thana, district, postal_code, country) VALUES
(1, 'present', 'House 12, Road 4, Sonadanga R/A', 'Sonadanga', 'Sonadanga', 'Khulna', '9100', 'Bangladesh'),
(2, 'present', 'Village Rupsha, Rupsha Ghat Road', 'Rupsha', 'Rupsha', 'Khulna', '9203', 'Bangladesh'),
(3, 'present', 'Flat 3B, 41 Eskaton Garden Road', 'Eskaton', 'Ramna', 'Dhaka', '1000', 'Bangladesh'),
(4, 'present', 'Flat 3B, 41 Eskaton Garden Road', 'Eskaton', 'Ramna', 'Dhaka', '1000', 'Bangladesh'),
(5, 'present', 'Staff Quarter 2, Khulna Medical College Hospital', 'Khulna Sadar', 'Khulna Sadar', 'Khulna', '9000', 'Bangladesh');

-- 7. customer_contacts (extra contact points beyond the main phone / email)
INSERT INTO customer_contacts (customer_id, contact_type, contact_value) VALUES
(1, 'mobile', '01819456201'),
(2, 'emergency', '01712008834'),
(3, 'home_phone', '028312457'),
(4, 'email', 'rahima.yusuf82@gmail.com'),
(5, 'office_phone', '0412731020');

-- 8. users (customers 1-3 and employees 1-2 can log in; password: BankEase@2026)
INSERT INTO users (password_hash, linked_customer_id, linked_employee_id, failed_login_attempts, status, last_login_at, created_at) VALUES
('$2y$10$ObtxVaMSa4663JzTkAiRReHA0n9efGvHMR7Mj41C0YJWgCprvgeYe', 1, NULL, 0, 'active', NULL, '2016-05-19 10:00:00'),
('$2y$10$ObtxVaMSa4663JzTkAiRReHA0n9efGvHMR7Mj41C0YJWgCprvgeYe', 2, NULL, 0, 'active', NULL, '2018-02-27 09:30:00'),
('$2y$10$ObtxVaMSa4663JzTkAiRReHA0n9efGvHMR7Mj41C0YJWgCprvgeYe', 3, NULL, 0, 'active', NULL, '2012-08-14 12:15:00'),
('$2y$10$ObtxVaMSa4663JzTkAiRReHA0n9efGvHMR7Mj41C0YJWgCprvgeYe', NULL, 1, 0, 'active', NULL, '2010-03-01 08:00:00'),
('$2y$10$ObtxVaMSa4663JzTkAiRReHA0n9efGvHMR7Mj41C0YJWgCprvgeYe', NULL, 2, 0, 'active', NULL, '2017-02-14 08:30:00');

-- 9. user_roles
INSERT INTO user_roles (user_id, role_id, assigned_at) VALUES
(1, 1, '2016-05-19 10:00:00'),
(2, 1, '2018-02-27 09:30:00'),
(3, 1, '2012-08-14 12:15:00'),
(4, 3, '2010-03-01 08:00:00'),
(5, 2, '2017-02-14 08:30:00');

-- 10. account_types
INSERT INTO account_types (type_name, minimum_balance, interest_rate, single_per_customer) VALUES
('Savings Account', 500.00, 3.50, FALSE),
('Current Account', 1000.00, 0.00, FALSE),
('Fixed Deposit', 10000.00, 7.00, TRUE);

-- 11. accounts (account 3 is a joint account; account 4 is waiting for staff approval)
INSERT INTO accounts (account_number, account_title, account_type_id, branch_id, balance, currency, status, opening_date, closing_date) VALUES
('KHU0110000472591', 'Abdul Karim Mollah', 1, 1, 30150.00, 'BDT', 'active', '2016-05-20', NULL),
('KHU0210000589214', 'Salma Khatun', 2, 1, 15450.00, 'BDT', 'active', '2018-03-01', NULL),
('DHK0110000116620', 'Mohammad Yusuf Ali and Rahima Yusuf', 1, 2, 50450.00, 'BDT', 'active', '2012-08-20', NULL),
('KHU0110000611905', 'Nasrin Jahan Mitu', 1, 1, 0.00, 'BDT', 'pending', '2026-11-10', NULL);

-- 12. account_holders (ownership; exactly one primary holder per account)
INSERT INTO account_holders (account_id, customer_id, holder_role, operating_mode, added_at) VALUES
(1, 1, 'primary', 'single', '2016-05-20 09:00:00'),
(2, 2, 'primary', 'single', '2018-03-01 09:00:00'),
(3, 3, 'primary', 'either_or_survivor', '2012-08-20 09:00:00'),
(3, 4, 'joint', 'either_or_survivor', '2012-08-20 09:00:00'),
(4, 5, 'primary', 'single', '2026-11-10 10:30:00');

-- 13. nominees
INSERT INTO nominees (account_id, full_name, relationship, date_of_birth, share_percentage) VALUES
(1, 'Shirin Akter', 'Spouse', '1989-07-21', 100.00),
(2, 'Md. Jahangir Alam', 'Spouse', '1988-02-10', 100.00),
(3, 'Imran Yusuf', 'Son', '2008-02-17', 100.00);

-- 14. external_accounts (accounts at other banks)
INSERT INTO external_accounts (account_number, account_name, bank_name, routing_number) VALUES
('1403201004712', 'Dhaka Fabrics Trading', 'Sonali Bank PLC', '200261738'),
('20502130100455217', 'Rokeya Begum', 'Islami Bank Bangladesh PLC', '125261458'),
('0112300009876', 'Khulna Medical Supplies', 'Dutch-Bangla Bank PLC', '090261234');

-- 15. transactions (ledger: each balance_before/balance_after chains to the account balance above)
INSERT INTO transactions (reference_number, account_id, transaction_type, amount, balance_before, balance_after, related_account_id, description, status, performed_by_user_id, created_at) VALUES
('TXN202610221405381204', 1, 'transfer_out', 5250.00, 35400.00, 30150.00, 2, 'Transfer to KHU0210000589214 - fabric advance', 'completed', 1, '2026-10-22 14:05:38'),
('TXN202610221405381311', 2, 'transfer_in', 5250.00, 12000.00, 17250.00, 1, 'Transfer from KHU0110000472591 - fabric advance', 'completed', 1, '2026-10-22 14:05:38'),
('TXN202611021041127740', 2, 'transfer_out', 1800.00, 17250.00, 15450.00, 3, 'Transfer to DHK0110000116620', 'completed', 2, '2026-11-02 10:41:12'),
('TXN202611021041127856', 3, 'transfer_in', 1800.00, 52300.00, 54100.00, 2, 'Transfer from KHU0210000589214', 'completed', 2, '2026-11-02 10:41:12'),
('TXN202611071620456093', 3, 'transfer_out', 3650.00, 54100.00, 50450.00, NULL, 'Interbank transfer to Dhaka Fabrics Trading', 'completed', 3, '2026-11-07 16:20:45');

-- 16. transfers (two internal transfers, one to another bank)
INSERT INTO transfers (debit_transaction_id, credit_transaction_id, external_account_id, transfer_type, fee) VALUES
(1, 2, NULL, 'internal', 0.00),
(3, 4, NULL, 'internal', 0.00),
(5, NULL, 1, 'interbank', 0.00);

-- 17. beneficiaries (saved recipients: two internal, one at another bank)
INSERT INTO beneficiaries (customer_id, nickname, target_account_id, external_account_id, added_at) VALUES
(1, 'Salma - boutique', 2, NULL, '2026-10-22 14:02:10'),
(2, 'Fabric supplier Dhaka', NULL, 1, '2026-10-29 11:30:00'),
(3, 'Karim bhai', 1, NULL, '2026-09-14 17:45:20');

-- 18. cards (full numbers are never stored, only a SHA-256 hash and a masked form)
INSERT INTO cards (customer_id, account_id, card_type, masked_number, card_number_hash, credit_limit, issue_date, expiry_date, status) VALUES
(1, 1, 'debit', '4532 XXXX XXXX 3906', '4396bf85a7a1444702da5e7f91dd11c742f34d89fc1c939dd414ba65b1adb932', NULL, '2024-02-10', '2029-02-10', 'active'),
(2, 2, 'debit', '4532 XXXX XXXX 2281', '01c5e16595333df421624e7a16e2c8722da5c53110f867be7a19e71ebd561318', NULL, '2023-08-21', '2028-08-21', 'blocked'),
(3, 3, 'credit', '5211 XXXX XXXX 8835', '0cdd406a0b208ce6c8f8bdc480144c5b1557e056ed094ce11a82744674c1d239', 100000.00, '2025-04-03', '2030-04-03', 'active');

-- 19. loans (1 active, 1 waiting for approval, 1 rejected)
INSERT INTO loans (loan_type, principal_amount, interest_rate, duration_months, application_date, approval_date, disbursement_account_id, monthly_installment, outstanding_balance, status, approved_by_user_id) VALUES
('Personal Loan', 30000.00, 12.50, 3, '2026-10-30', '2026-11-03', 3, 10209.05, 30000.00, 'active', 4),
('Home Renovation Loan', 150000.00, 10.75, 24, '2026-11-11', NULL, NULL, 6973.78, 0.00, 'pending', NULL),
('Auto Loan', 400000.00, 11.00, 36, '2026-10-15', NULL, NULL, 13095.49, 0.00, 'rejected', 4);

-- 20. loan_parties (loan 1 has a borrower and a co-borrower)
INSERT INTO loan_parties (loan_id, customer_id, party_role, added_at) VALUES
(1, 3, 'borrower', '2026-10-30 12:10:00'),
(1, 4, 'co_borrower', '2026-10-30 12:10:00'),
(2, 1, 'borrower', '2026-11-11 15:20:00'),
(3, 2, 'borrower', '2026-10-15 10:05:00');

-- 21. loan_payments (repayment schedule of loan 1, nothing paid yet)
INSERT INTO loan_payments (loan_id, installment_number, due_date, scheduled_principal, scheduled_interest, paid_amount, paid_date, status, related_transaction_id) VALUES
(1, 1, '2026-12-03', 9896.55, 312.50, 0.00, NULL, 'due', NULL),
(1, 2, '2027-01-03', 9999.64, 209.41, 0.00, NULL, 'due', NULL),
(1, 3, '2027-02-03', 10103.81, 105.25, 0.00, NULL, 'due', NULL);

-- 22. notifications
INSERT INTO notifications (user_id, type, message, is_read, created_at) VALUES
(1, 'transaction_alert', 'Transferred BDT 5,250.00 from KHU0110000472591 to KHU0210000589214.', TRUE, '2026-10-22 14:05:40'),
(2, 'transaction_alert', 'BDT 5,250.00 was credited to your account KHU0210000589214.', TRUE, '2026-10-22 14:05:40'),
(3, 'loan_approved', 'Your Personal Loan application #1 was approved.', FALSE, '2026-11-03 11:15:00'),
(2, 'loan_rejected', 'Your Auto Loan application #3 was not approved.', FALSE, '2026-10-20 13:40:00');

-- 23. audit_logs
INSERT INTO audit_logs (user_id, action, target_table, target_id, description, ip_address, result, created_at) VALUES
(1, 'TRANSFER', 'transfers', 1, 'Transferred 5250.00 KHU0110000472591 -> KHU0210000589214', '103.145.60.21', 'success', '2026-10-22 14:05:38'),
(4, 'APPROVE_LOAN', 'loans', 1, 'Approved loan 1', '10.20.4.11', 'success', '2026-11-03 11:15:00'),
(NULL, 'STAFF_LOGIN', 'users', NULL, 'Failed staff login for imran.hossain@bankease.com.bd', '10.20.4.37', 'failure', '2026-11-05 09:12:44'),
(3, 'LOGIN', 'users', 3, 'Customer logged in', '103.145.62.8', 'success', '2026-11-07 16:18:02');

COMMIT;

-- ------------------------------------------------------------
-- Consistency check named in schema.sql (account_holders):
-- every account must have exactly one PRIMARY holder, and every loan
-- exactly one borrower. Both queries return ZERO rows when the data is correct.
-- ------------------------------------------------------------
SELECT a.account_id, a.account_number
FROM accounts a
WHERE NOT EXISTS (SELECT 1 FROM account_holders h
                  WHERE h.account_id = a.account_id AND h.holder_role = 'primary');

SELECT l.loan_id, l.loan_type
FROM loans l
WHERE NOT EXISTS (SELECT 1 FROM loan_parties p
                  WHERE p.loan_id = l.loan_id AND p.party_role = 'borrower');