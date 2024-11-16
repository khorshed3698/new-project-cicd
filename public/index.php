<?php

require_once '../src/Calculator.php';

$calculator = new Calculator();

echo "<h1>PHP CICD Test Application</h1>";
echo "<p>2 + 5 = " . $calculator->add(2, 5) . "</p>";
?>
