
variable prim_ins
variable prim_outs
variable net_list
variable gate_list
variable local_net_list

proc read_verilog { file_name } {
	set fp [open $file_name r]
	set file_data [read $fp]
	close $fp
	set data [split $file_data "\n"]
	
	return $data
}

# helper function for sorting (sort descriptor)
proc sort_descriptor {l1 l2} {

     set a [lindex $l1 4]
     set b [lindex $l2 4]
     
          
          if {$a > $b} {
               return 1
          } elseif { $a < $b} {
               return -1
          } 
          return [string compare [lindex $l1 0]  [lindex $l1 0] ]
          
}

proc get_primary_ports { netlist } {
	global prim_ins
	global prim_outs
	
	foreach line $netlist {
		if {[regexp {^\s?input\s(\w+)(\s?,?.*)\s?;} $line -> var1 var2]} {
			set in_tmp [split $var2 ", "]
			lappend prim_ins $var1
			foreach in $in_tmp {
				if { $in != ""} {
					lappend prim_ins $in
				} ;# end if check empty string
			} ;# end iterating through consequent ins
		} elseif {[regexp {^\s?output\s(\w+)(\s?,?.*)\s?;} $line -> var1 var2]} {
			set out_tmp [split $var2 ", "]
                        lappend prim_outs $var1
                        foreach out $out_tmp {
                                if { $out != ""} {
                                        lappend prim_outs $out
                                } ;# end if check empty string
                        } ;# end iterating through consequent outs
		}
	}
}

proc create_prim_matrix {} {
	global prim_ins
	global net_list

	foreach input $prim_ins {
		lappend net_list [list $input {} 0 "x"]
	}

}

proc get_gates_connected { netlist } {
	global gate_list
	foreach line $netlist {
		if {[regexp {^\s?(not)?(and)?(nand)?(or)?(nor)?(xor)?(xnor)?\s(\w+)\((\w+)\s?,\s?(.*)\);} $line -> v1 v2 v3 v4 v5 v6 v7 v8 v9 v10]} {
			set tmp_ins [split $v10, ", "]
			set inputs {}
			foreach i $tmp_ins {
				if {$i != ""} {
					lappend inputs $i
				}
			}
			if { $v1 != ""} {
				lappend gate_list [list $v1 $v8 $v9 $inputs "x"]
			} elseif { $v2 != ""} {
                                lappend . [list $v2 $v8 $v9 $inputs "x"]
                        } elseif { $v3 != ""} {
                                lappend gate_list [list $v3 $v8 $v9 $inputs "x"]
                        } elseif { $v4 != ""} {
                                lappend gate_list [list $v4 $v8 $v9 $inputs "x"]
                        } elseif { $v5 != ""} {
                                lappend gate_list [list $v5 $v8 $v9 $inputs "x"]
                        } elseif { $v6 != ""} {
                                lappend gate_list [list $v6 $v8 $v9 $inputs "x"]
                        } elseif { $v7 != ""} {
                                lappend gate_list [list $v7 $v8 $v9 $inputs "x"]
                        }

		}
	}
}

proc connect_nets_to_gates {} {
	global net_list
	global gate_list

	set index 0
	foreach n $net_list {
	set temp_l [list]
		foreach g $gate_list {
			if {[lsearch [lindex $g 3] [lindex $n 0]] >= 0} {
				lappend temp_l [lindex $g 1]
				#lset n 1 [lindex $g 1]
			} elseif {$n == [lindex $g 2]} {
				lappend temp_l [lindex $g 1]
				#lset n 1 [lindex $g 1]
			}
		}		
	lset net_list $index 1 $temp_l
	incr index
	}
}

proc levelization {} {
	global net_list
	global gate_list
  	global prim_ins
        
	   	# at first compare_list contains primary inputs
        set cmp_list $prim_ins
        set gate_setted 0
        set level 1
        
        
        while {$gate_setted < [llength $gate_list] } {
               
		 set ind 0
     		
			 # getting one gate from list 
                foreach g $gate_list {

                        set t_ins [lindex $g 3]    
                        set b 1
                       
				    # checking accuracy of inputs  
                        foreach in $t_ins {  
                                
							if {[lsearch $cmp_list  $in ] == -1 } {
                                          
                                             set b 0  
                            }
                         }
                           
					# setting level of gate	  
					if { $b == 1 && [lindex $g 4] == "x"} {
                             
					    	 lset g 4 $level
                             lset gate_list $ind $g   
                             incr gate_setted 
                                   
                    }   

					 incr ind  
            
                }
           
                foreach g $gate_list {
                        
                        if {[lindex $g 4] == $level} {
                             
							if {[lsearch $cmp_list  [lindex $g 2]] == -1 } {
                                 
								# adding outputs into compare_list
								lappend cmp_list [lindex $g 2]       
                                       
                       		 }
               	   		 }      
                
                }

              incr level
                
        
        }
}

proc sorting {} {

     global gate_list
     set gate_list [lsort -command sort_descriptor \ $gate_list ]
    
}
 
proc simulate_gate {gate} {

	global local_net_list
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

			set g_out [lindex $gate 2]

			if {[lsearch $local_net_list $g_out] >= 0 } {

				# add value of local net in local_net_list
				set pos [lsearch $local_net_list $g_out]
				set temp [lindex $local_net_list $pos]
				lappend temp $result
				lset local_net_list $pos $temp
			}
		

			lset gate 2 $result
			puts -nonewline "Output -> "
			puts $result 
			puts \n
			return $gate

 		}	
} 

proc simulate {} {

	global gate_list
	global prim_ins 
	global prim_outs
	global net_list
	global local_net_list

	# -----------------------------------------------------
	# get local nets 
	foreach g $gate_list {
		
		if { [lsearch $prim_outs [lindex $g 2] ] == -1  } {
				
				set temp {}
				lappend temp [lindex $g 2]			
				lappend local_net_list $temp
		}
	
	}

	puts  -nonewline "local nets -> " 
	puts $local_net_list


	# ------------------------------------------
	# set entered values of prim_ins to net_list
	set index 0
	foreach net  $net_list {
		set  temp_list [lindex $net_list $index]  
		puts "Enter [lindex $temp_list 0]  ` "   
		lset temp_list 3 [gets stdin]
		lset net_list $index $temp_list 
		incr index
	}


	# -------------------------------------------
	# set entered values of prim_ins to gate_list
	set index 0
	foreach g $gate_list {
		set ins [lindex $g 3]
		set g_name  [lindex $g 1]
		foreach net  $net_list {
			set gate_in_net_list [lindex $net 1]
			if {[lsearch $gate_in_net_list $g_name ] >= 0} {

					lset ins [lsearch $ins [lindex $net 0]] [lindex $net 3] 
					lset g 3 $ins
					lset gate_list $index $g

			}
		}
		incr index
	}

	# ------------------------------------------------
	# simulation process
	set ind 0
	foreach g $gate_list {
		if {[lindex $g 4] == 1} {

				set g [simulate_gate $g]
		}
		if {[lindex $g 4] > 1} {
				set g_ins [lindex $g 3]
				foreach in $g_ins {
					if { ![string is digit $in] } {
						foreach loc  $local_net_list {
							if {[lsearch $loc $in ] >= 0} {

									lset g_ins [lsearch $g_ins $in ]  [lindex $loc 1]
									lset g  3 $g_ins
									lset gate_list $ind $g 

							}
						}
					}
				}

				set g [simulate_gate $g] 
				
		}
		incr ind
	}




}

# main 
set content [read_verilog input_verilog.v]
get_primary_ports $content
create_prim_matrix
get_gates_connected $content
connect_nets_to_gates
levelization
sorting
puts  -nonewline "netlist -> " 
puts $net_list
puts  -nonewline "gatelist -> "
puts $gate_list
simulate

puts  -nonewline "local nets -> "
puts $local_net_list
puts  -nonewline "netlist -> " 
puts $net_list
puts  -nonewline "gatelist -> "
puts $gate_list
