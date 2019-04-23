# This file defines necessary functions for levelization of logic circuit

import re
from elements import *
import sys
import Queue

prim_input_match = r'^\s?input\s(\w+)(\s?,.+)*\s?;'
prim_output_match = r'^\s?output\s(\w+)(\s?,.+)*\s?;'
gates_connected_match = r'^\s?(not)?(and)?(nand)?(or)?(nor)?(xor)?(xnor)?\s(\w+)\((\w+)\s?,\s?(.*)\);'


prim_ins = []
prim_outs = []
net_list = []
gate_list = []


def read_verilog(file_name):
    fo = open(file_name, 'r')
    verilog_netlist = fo.readlines()
    fo.close()

    return verilog_netlist

def get_primary_ports(netlist):
    global prim_ins
    global prim_outs

    for line in netlist:
        line_mod = re.sub(r'\s+', ' ', line)
        ins_found = re.search(prim_input_match, line_mod)
        outs_found = re.search(prim_output_match, line_mod)

        if ins_found:
            if ins_found.group(2):
                in_tmp = re.sub(r'\s', '', ins_found.group(2)) #string
                in_tmp = in_tmp.split(',') #list
                in_tmp.remove('') #removed empty strings

                prim_ins += [ins_found.group(1)] + in_tmp
            else:
                prim_ins += [ins_found.group(1)]
        elif outs_found:
            if outs_found.group(2):
                out_tmp = re.sub(r'\s', '', outs_found.group(2)) #string
                out_tmp = out_tmp.split(',') #list
                out_tmp.remove('') #removed empty strings

                prim_outs += [outs_found.group(1)] + out_tmp
            else:
                prim_outs += [outs_found.group(1)]

def create_net_obj(net_name, gate_list=[], value='x'):
    global net_list
    names = []

    for n in net_list:
        names += [n.name]

    if (net_name not in names):
        net = Net(net_name, gate_list, value)
        net_list += [net]


def create_gate_obj(mo, gate_type, inputs):
    global gate_list
    names = []
    for g in gate_list:
        names += [g.name]
    if (mo.group(8) not in names):
        gate = Gate(gate_type, mo.group(8), mo.group(9), inputs)
        gate_list += [gate]


def create_prim_obj():
    global prim_outs
    global prim_ins
    for net_name in prim_ins:
        create_net_obj(net_name)

def gates_connected(net_object, verilog):
    gate_lines = filter(lambda x: re.search(r'^(?!module)\w+\s\w+\(.*%s.*\)\s*;' % net_object.name, x), verilog)
    for gate_line in gate_lines:
        gate_line = re.sub(r'\s', ' ', gate_line)
        gate_line.rstrip()
        mo = re.search(gates_connected_match, gate_line)

        if mo:
            inputs = re.sub(r'\s', '', mo.group(10)) #string
            inputs = inputs.split(',')
            for inp in inputs:
                create_net_obj(inp)
            create_net_obj(mo.group(9))
            gate_type = ''
            for x in mo.groups()[0:7]:
                if (x != None):
                    gate_type = x
            create_gate_obj(mo, gate_type, inputs)

def connect_nets_to_gates():
    global net_list
    global gate_list

    for n in net_list:
        n.gate_list = []
        for gate in gate_list:
            if (n.name in gate.input_list):
                gate.input_list[gate.input_list.index(n.name)] = n
                n.gate_list.append(gate)
            elif (n.name == gate.output):
                gate.output = n
                n.gate_list.append(gate)

def report():
    global net_list
    global gate_list

    #outputting gate table
    print "----------------------------------------------"
    print "Gate Table -> "
    print "----------------------------------------------" 
    for g in gate_list:
        print g.gate_type,"",g.name,
        print "Inputs-> " ,
        for inp in g.input_list:
        	print inp.value ,
        print "Output ->" , g.output.value
    print "----------------------------------------------"   
      
    #outputting net table
    print "----------------------------------------------"
    print "Net Table -> "
    print "----------------------------------------------" 
    for net in net_list:
    	print net.name , 
    	print "gates on net -> ",
    	for gate in net.gate_list:
    		print gate.name,
    	print "  value -> ",net.value
    	#print " old_value-> " ,net.old_value
    print "----------------------------------------------" 

def event_driven_simualtion(input_vector):
	global net_list
	global gate_list
  	global prim_ins
  	global prim_outs

  	net_queue  = Queue.Queue()
  	gate_queue = Queue.Queue()

  	# setting primery_inputs values from input_vector
  	index = 0
  	for net in net_list:
  		if net.name in  prim_ins:
  			net.old_value = net.value
  			net.value = input_vector[index]
  	  	index+=1
  
  	# putting changed nets to net_queue 	
  	for net in net_list:
  		if net.value != net.old_value:
  			net_queue.put(net)
	

	# main process  of simulation  
  	while not net_queue.empty():
		#finding gates,whose inputs are the changed nets
		while not net_queue.empty():
			temp_net = net_queue.get()
			for gate in gate_list:
				if temp_net in gate.input_list:
					if gate.in_queue == False:	
						gate.in_queue = True
						gate_queue.put(gate)		


		# simulation process 				
		while not gate_queue.empty():
			temp_gate = gate_queue.get()
			temp_gate.in_queue = False
			temp_gate.simulate()
			if temp_gate.output.old_value != temp_gate.output.value:
				net_queue.put(temp_gate.output)
			print "\n"
	
		
 

		 	
if __name__ == "__main__":
    verilog = read_verilog('input_verilog.v')
    get_primary_ports(verilog)
    create_prim_obj()    
    for net in net_list:
        gates_connected(net, verilog)
    connect_nets_to_gates()
    report()
    input_vector = [0,0,1,0,1]
    #event_driven_simualtion(input_vector)