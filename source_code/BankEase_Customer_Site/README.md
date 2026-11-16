# BankEase Customer Site

Customer website for the existing BankEase database. Built for PHP 8 and MySQL 8 / MariaDB 10.4+ with PDO prepared statements, plain CSS, and vanilla JavaScript. No framework, Composer package, or CDN is required.

## Install in XAMPP

1. Extract the `BankEase_Customer_Site` folder into `C:\xampp\htdocs\`.
2. Import the provided `bankease (1).sql` into MySQL using phpMyAdmin or the MySQL command line.
3. Edit `config.php` with your database host, port, name, username, and password. The base URL follows the installed folder name automatically.
4. Open `http://localhost/BankEase_Customer_Site/` (or the matching URL if you use a different folder name).

## Included customer features

- Customer-only sign-in by email or phone, password verification, session renewal, failed-login lockout after five attempts, and LOGIN / LOGOUT audit entries.
- Public home page, rates from `account_types`, and branch directory from `branches`.
- Account application that creates the customer, present address, login, Customer role, pending account, and primary account holder in one database transaction.
- Customer dashboard with account summary, held balance, unread-alert count, pending-account count, and latest transactions.
- Account list, account detail, holder and nominee information, and mini statement.
- Activity search and filters by account, type, date range, or text; pagination; printable transaction slips.
- Transfers between owned accounts, to another BankEase account, to a saved beneficiary, or to an external bank. Transfers use a review step, account row locks in ascending ID order, active-status checks, minimum-balance checks, a configurable daily limit, transaction ledger entries, and `transfers` links for both internal legs.
- Beneficiary add, list, nickname edit, and delete for BankEase and external destinations, without changing schema.
- Additional savings/current account applications from the dashboard, with pending status and individual or joint holders.
- Loan applications, borrower ownership, application listing, installment schedules from `loan_payments`, and full installment repayment from an owned active account.
- Card list with masked numbers, expiry, status, and limits; issue and block requests sent to active staff through `notifications`.
- Dashboard preview and full customer notifications center with unread count in navigation, mark-read/mark-all actions, existing staff approval messages, generated account/loan decision messages, and transfer sent/received notices.

## Demo login data

The project brief names `akarim.mollah@gmail.com`, `salma.khatun92@gmail.com`, and `yusuf.ali78@yahoo.com` with password `BankEase@2026`. Their credentials are determined by the imported SQL data. The website does not reset or replace seeded passwords.

## Manual checklist

- Open home, rates, and branches; confirm the CSS loads when the project folder is named `BankEase_Customer_Site` and that public database errors are handled without stack traces.
- Apply for an account using valid details; confirm customer, address, login, role, pending account, and primary holder rows are created. Try duplicate email/phone/ID, malformed email, missing fields, invalid dropdowns, and a password shorter than 10 characters.
- Sign in by email and phone. Verify staff roles are refused, wrong passwords show a generic error, the fifth failure locks the user, success resets failures, and logout writes an audit entry.
- View all linked accounts. Try another customer’s account ID in `account.php?id=...`; expect a not-found response without any account details.
- Open an account detail and confirm joint holders, nominees, and the mini statement are limited to accounts where the signed-in customer is a holder.
- Filter activity by account, type, dates, and a search phrase; verify date range errors, pagination, and print layout.
- Try another customer’s transaction ID in `transaction.php?id=...`; expect a not-found response. Print a slip for a transaction belonging to the signed-in customer.
- Review an own-account transfer and confirm both ledger legs and the `transfers` row are created; check a transfer to another BankEase account, saved beneficiary, and external account.
- Confirm insufficient funds / minimum-balance violations, frozen or pending source and destination accounts, an amount above the daily limit, and a daily total above the limit are refused without balance or ledger changes.
- In the live recipient lookup, verify only the destination account title is displayed. Test an invalid account number and a destination equal to the source account.
- Add, rename, and remove internal and external beneficiaries. Attempt a duplicate beneficiary and another customer’s beneficiary ID; the duplicate must be rejected and the foreign ID must not be editable/deletable.
- From the dashboard, apply for another savings/current account. Confirm it appears pending and is not usable for transfers until staff approve it.
- Apply for a joint account using the other existing customer's matching email and phone; verify the new account and both `account_holders` rows are created together with exactly one primary holder. Try mismatched details and missing consent.
- Apply for a loan; confirm a pending `loans` row and borrower `loan_parties` row are created. View an existing loan's installment schedule from `loan_payments`.
- Repay an active loan installment from an owned account. Verify minimum balance, inactive account, already-paid installment, and another customer's loan/payment ID are refused; for a successful payment verify one withdrawal transaction, updated `loan_payments`, and reduced `loans.outstanding_balance` in one database transaction.
- View cards and confirm only `masked_number` appears. Submit debit and credit card requests; verify staff users receive a `card_request` notification and the customer gets a request receipt, with no card created/activated prematurely. Request a block on an active card and confirm staff/customer notices are recorded while the card remains active until staff action.
- Review unread navigation count, customer request receipts, and account/loan approval messages. Mark one notification read and mark all read; verify another customer's notification ID cannot be changed.
- Mark one notification read and mark all read; verify another customer's notification ID cannot be changed. Confirm seeded loan approval/rejection and KYC messages render.
- Transfer internally and externally; confirm the sender receives a sent message and every customer holder on the destination account receives a received message for internal transfers.
- Submit account/loan applications and confirm generated decision notifications appear after the staff portal updates account or loan status.
- Submit any POST form without its CSRF token and confirm it is rejected.

## Schema

The implementation uses the schema supplied as `bankease (1).sql`. It does not create or alter database tables or columns. Ownership is resolved through `account_holders`; user roles through `user_roles` and `roles`; login identity from `customers.email` / `customers.phone`; and transaction records from `transactions`.

The supplied schema has no loan product/rate table, but requires a numeric interest rate and monthly installment on every `loans` row. A new pending request therefore stores `interest_rate=0` and `monthly_installment=principal ÷ duration` as provisional values; the page labels these as placeholders for staff review. No payment schedule is generated until staff approval/activation supplies real terms. Joint applicants are matched by both email and phone and the account remains pending so staff can verify both parties and their consent before activation.

The schema has no card-request table and does not permit a pending card status. Card requests are therefore recorded as notifications to active Employee and Administrator users; no active card row is created by the customer site. Approval messages already stored in `notifications` are displayed as provided. For new account and loan requests created by this site, the customer portal detects a later status decision and writes a matching notification when the customer next opens a page.
