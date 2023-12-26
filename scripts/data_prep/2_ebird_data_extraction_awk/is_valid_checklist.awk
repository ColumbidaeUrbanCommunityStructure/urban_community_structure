{
	min_duration=4
	max_duration=240
	min_distance=0
	max_distance=10
}

function is_valid_checklist(duration, distance) 
{ 
  # check "is complete" and duration
	if (duration > min_duration && duration <= max_duration) {
	  # check distance
	  if (length(distance) == 0 || (distance > min_distance && distance <= max_distance)) {
			return 1
    }
	}
	
	return 0
}
