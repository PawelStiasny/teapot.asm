<?php

$ar = file('teapot.obj');
$scale = 400.0;

$vxes = array();
$pnum = 0;

function put_line($vx1, $vx2) {
	echo $vx1[0] . ', ' . $vx1[1] . ', ' . $vx1[2] . ', ';
	echo $vx2[0] . ', ' . $vx2[1] . ', ' . $vx2[2] . ",\n";
}

echo "float points[] = {\n";

foreach ($ar as $line) {
	$desc = explode(' ', $line);
	if ($desc[0] == 'v') {
		//$vxes[] = array( explode('/', $desc[1]), explode('/', $desc[2]), explode('/', $desc[3]) );
		$vxes[] = array( (float)$desc[1] * $scale, (float)$desc[2] * $scale, (float)$desc[3] * $scale );
	} else if ($desc[0] == 'f') {
		$face = array();
		for ($i = 1; $i <= 3; $i++) {
			list($vnum) = explode('/', $desc[$i]);;
			$face[] = (int)$vnum;
		}
		put_line($vxes[$face[0] - 1], $vxes[$face[1] - 1]);
		put_line($vxes[$face[1] - 1], $vxes[$face[2] - 1]);
		put_line($vxes[$face[0] - 1], $vxes[$face[2] - 1]);
		$pnum += 3;
	}
}

echo "0 };\n";

echo "unsigned long num_points = $pnum;\n";
