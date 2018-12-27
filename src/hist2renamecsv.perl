while (/commit (.+)\n(?:.*\n)+?similarity index (\d+)+%\n(rename|copy) from (.+)\n\3 to (.+)\n/g) { printf("$1,$2,$3,$4,$5\n") }
