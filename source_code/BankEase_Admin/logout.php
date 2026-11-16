<?php require __DIR__.'/config.php';if(user())audit('ADMIN_LOGOUT','users',(int)user()['id'],'Administrator logged out');$_SESSION=[];session_destroy();header('Location: '.url('login.php'));exit;
