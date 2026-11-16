<?php
require __DIR__.'/config.php';require_auth();
header('Content-Type: application/json; charset=utf-8');header('Cache-Control: no-store, private');
$now=time();$window=$_SESSION['_account_lookup_window']??['start'=>$now,'count'=>0];if($now-(int)$window['start']>=60)$window=['start'=>$now,'count'=>0];$window['count']++;$_SESSION['_account_lookup_window']=$window;if($window['count']>30){http_response_code(429);echo json_encode(['found'=>false,'message'=>'Please wait before trying again.']);exit;}
$number=trim((string)($_GET['number']??''));if(!preg_match('/^[A-Za-z0-9]{6,20}$/',$number)){echo json_encode(['found'=>false]);exit;}
try{$s=db()->prepare("SELECT account_title FROM accounts WHERE account_number=? AND status='active' LIMIT 1");$s->execute([$number]);$title=$s->fetchColumn();echo json_encode($title===false?['found'=>false]:['found'=>true,'title'=>$title],JSON_UNESCAPED_UNICODE|JSON_INVALID_UTF8_SUBSTITUTE);}catch(Throwable $x){http_response_code(503);echo json_encode(['found'=>false,'message'=>'Lookup is temporarily unavailable.']);}
