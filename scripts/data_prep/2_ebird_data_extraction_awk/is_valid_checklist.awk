{
	min_duration=4
	max_duration=240
	min_distance=0
	max_distance=10
	min_year=2013
}

function is_valid_checklist(is_complete, duration, distance, protocol, observation_date) 
{ 
  # check "is complete" and duration
	if (is_complete == "1" && duration > min_duration && duration < max_duration) {
	  # check distance
	  if (length(distance) == 0 || (distance > min_distance && distance < max_distance)) {
	    # check protocol
	    if (protocol == "Stationary" || protocol == "Traveling" || protocol == "Area") {
	      command="echo " observation_date " | awk -F\047-\047 \047{print $1}\047"
    		(command | getline year)
    		close(command)
    		if(year > min_year) {
    			return 1
    		}
      }
    }
	}
	
	return 0
}