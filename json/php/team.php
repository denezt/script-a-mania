<?php

$filename = "texas_alternative_energy.json";
$results = file_get_contents($filename);
echo "\$results type: " . gettype($results) . "\n";
$json = json_decode($results, false);
echo "\$json type: " . gettype($json) . "\n";
$json2 = json_decode(json_encode($json->team), true);
for ($i = 0; $i < 110; $i++) {
        if (isset($json2[$i]['id'])) {
                echo "ID: " . $json2[$i]['id'] . "\n";
                echo "Firstname: " . $json2[$i]['first_name'] . "\n";
                echo "Lastname: " . $json2[$i]['last_name'] . "\n";
        } else {
                break;
        }
        echo "==============================\n";
}

?>
