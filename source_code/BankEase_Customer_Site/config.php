<?php
declare(strict_types=1);
const DB_HOST='127.0.0.1'; const DB_PORT=3306; const DB_NAME='bankease'; const DB_USER='root'; const DB_PASS='';
// Follow the installed folder name so asset links work after extraction.
define('BASE_URL', '/' . basename(__DIR__));
const DAILY_TRANSFER_LIMIT=100000.00;
date_default_timezone_set('Asia/Dhaka');
if(session_status()!==PHP_SESSION_ACTIVE){session_name('BANKEASE_CUSTOMER');session_start();}
require_once __DIR__.'/includes/helpers.php'; require_once __DIR__.'/includes/auth.php';
