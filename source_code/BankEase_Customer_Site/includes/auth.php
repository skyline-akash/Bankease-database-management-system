<?php
declare(strict_types=1);
function current_user():?array{return $_SESSION['auth']??null;}
function require_auth():array{$u=current_user();if(!$u){flash('Please sign in to continue.','info');go('login.php');}if(($u['role']??'')!=='Customer'){http_response_code(403);exit('Access denied.');}return $u;}
