
proc simulate_gate {gate} {

	variable result 
	set gate_type   [lindex $gate 0]
	set  input_list [lindex $gate 3]
	puts -nonewline "Gate Name -> "
	puts $gate_type
	puts -nonewline "Input -> "
	puts $input_list

	switch  $gate_type {

		not {
				set  in [lindex $gate 3]
				
				if { $in == 1} {
					set result 0
				} else {
					set result 1
				}
			}

		and {

				set result [lindex $input_list 0]
				for {set i 1} {$i < [llength $input_list]} {incr i} {
							set result [expr $result & [lindex $input_list $i]]
						}		
				

		}

		or {
				set result [lindex $input_list 0]
				for {set i 1} {$i < [llength $input_list]} {incr i} {
							set result [expr $result | [lindex $input_list $i]]
						}		
		}
		
		nand {

				set result [lindex $input_list 0]
				for {set i 1} {$i < [llength $input_list]} {incr i} {
							set result [expr $result & [lindex $input_list $i]]
						}	

				if { $result == 1} {
					set result 0
				} else {
					set result 1
				}		
		}

		nor {
				set result [lindex $input_list 0]
				for {set i 1} {$i < [llength $input_list]} {incr i} {
							set result [expr $result | [lindex $input_list $i]]
						}

				if { $result == 1} {
					set result 0
				} else {
					set result 1
				}
				
	
		}

		xor {

			set result [lindex $input_list 0]
				for {set i 1} {$i < [llength $input_list]} {incr i} {
							set result [expr $result ^ [lindex $input_list $i]]
						}		
		}
		default {

				puts "Cannot simulate gate!!! "
		}

		}


		if {[info exists result] == 1 } {
		
		lset gate 2 $result
		puts -nonewline "Output -> "
		puts $result 
		return $gate

 		}
		
		
} 

set gate {nor G4 x2 {0 0 } 1}
set gate  [simulate_gate $gate ]