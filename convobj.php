<?php
// convert .obj file to a list of lines

$ar = file('teapot.obj');
$scale = 400.0;

$vxes = array();
$lines = array();
$pnum = 0;

function put_line($vx1, $vx2) {
	global $lines;
	$lines[] =  $vx1[0] . ' ' . $vx1[1] . ' ' . $vx1[2] . ' ' .
		$vx2[0] . ' ' . $vx2[1] . ' ' . $vx2[2] . "\n";
}

foreach ($ar as $line) {
	$desc = explode(' ', $line);
	if ($desc[0] == 'v') {
		$vxes[] = array(
			(float)$desc[1] * $scale,
			(float)$desc[2] * $scale,
			(float)$desc[3] * $scale );
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


echo count($lines) . "\n";
foreach ($lines as $l) 
	echo $l;
