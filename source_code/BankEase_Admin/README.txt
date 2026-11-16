BankEase Staff Portal
=====================

This is a separate internal staff/admin website. It shares the `bankease`
database with the independent customer website at /BankEase_Fresh/.

Install with XAMPP
------------------
1. Extract the BankEase_Admin folder directly into C:\New folder\htdocs.
   The final location should be C:\New folder\htdocs\BankEase_Admin\index.php.
2. Start Apache and MySQL in the XAMPP Control Panel.
3. Confirm config.php uses the same DB_HOST, DB_NAME, DB_USER, and DB_PASS as
   the customer website. Defaults are 127.0.0.1, bankease, root, and blank.
4. Open http://localhost/BankEase_Admin/ .
5. Sign in with an administrator employee account already present in `bankease`.

The portal uses the revised schema relationships: employees to users and roles,
employees to branches through branch_assignments, customers to accounts through
account_holders, and borrowers to loans through loan_parties.

Staff features
--------------
Dashboard and branch-scoped stats; customer registration and KYC review; new
accounts and account approvals; deposits, withdrawals, and internal transfers;
transaction history; loan approvals and repayments; masked card issue and card
status management; branch and employee management; account-type setup; reports;
notifications; password change; login lock/unlock; and audit history. Completed
deposits, withdrawals, and internal transfers open a print-ready slip with account,
customer, reference, date/time, before/after balances, amount in words, teller,
signature lines, and linked transfer reference. Use the print button to print or
choose Save as PDF in the browser's print dialog. Transaction history also has
individual slip links.

Employees are restricted to their assigned branch. Administrators can access
all branches. Terminating an employee disables their linked login. All money
movement is recorded in the same database transaction as the balance change.

This is a local academic demonstration, not a production banking system. Card
issuance creates a masked demo record only; it does not create a usable card.
