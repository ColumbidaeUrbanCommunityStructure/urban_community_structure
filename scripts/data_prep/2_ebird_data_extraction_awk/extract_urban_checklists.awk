{ 
	if (is_valid_checklist($3, $4)) {
		print $1 "," $2 "," $3
	}
}
