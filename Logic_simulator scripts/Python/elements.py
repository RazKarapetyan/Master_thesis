# Gate and net classes are defined in this file

class Gate:
    def __init__(self, gate_type, name, output, input_list):
        self.gate_type = gate_type
        self.name = name
        self.output = output
        self.input_list = input_list
        self.in_queue = False

    def simulate(self):
        result = None
        print "Gate type -> " , self.gate_type
        print "Gate name -> " , self.name
        print "Inputs ->" , 
        for net in self.input_list:
            print net.value,   
        print " "
        inputs = []

        for inp in self.input_list:
            inputs.append(inp.value)

        
        if self.gate_type == "not" :
            if "x" in inputs:
                self.output.old_value = self.output.value
                self.output.value = "x"
            else:    
                if inputs[0] == 1:
                    self.output.old_value = self.output.value
                    self.output.value = 0
                else:
                    self.output.old_value = self.output.value
                    self.output.value = 1
                     
        if self.gate_type == "or":
            if ("x" in inputs) & (1 in inputs):
                self.output.old_value = self.output.value
                self.output.value = 1
            else:

                if "x" in inputs:
                    self.output.old_value = self.output.value
                    self.output.value = "x"
                else:     
                    result = inputs[0]
                    length = len(inputs)
                    for x in range(1,len(inputs)):
                        result = result | inputs[x]
                    self.output.old_value = self.output.value    
                    self.output.value = result   

        if self.gate_type == "and":
            if ("x" in inputs) & (0 in inputs):
                self.output.old_value = self.output.value
                self.output.value = 0
            else:    
                if "x" in inputs:
                    self.output.old_value = self.output.value
                    self.output.value = "x"
                else:    
                    result = inputs[0]
                    length = len(inputs)
                    for x in range(1,len(inputs)):
                        result = result & inputs[x]
                    self.output.old_value = self.output.value    
                    self.output.value = result

        if self.gate_type == "nand":
            if ("x" in inputs) & (0 in inputs):
                self.output.old_value = self.output.value
                self.output.value = 1
            else:
                if "x" in inputs:
                    self.output.old_value = self.output.value
                    self.output.value = "x"
                else:   
                    result = inputs[0]
                    length = len(inputs)
                    for x in range(1,len(inputs)):
                        result = result & inputs[x]
                    if result == 1 :
                        self.output.old_value = self.output.value
                        self.output.value =0
                    else:
                        self.output.old_value = self.output.value
                        self.output.value =1   

        if self.gate_type == "nor":
            if ("x" in inputs) & (1 in inputs):
                self.output.old_value = self.output.value
                self.output.value = 0
            else:
                if "x" in inputs:
                    self.output.old_value = self.output.value
                    self.output.value = "x"
                else: 
                    result = inputs[0]
                    length = len(inputs)
                    for x in range(1,len(inputs)):
                        result = result | inputs[x]
                    if result == 1 :
                        self.output.old_value = self.output.value
                        self.output.value =0
                    else:
                        self.output.old_value = self.output.value
                        self.output.value =1              
                    
        #print "Gate output name -> ", self.output.name        
        print "Gate output -> ", self.output.value
        print "Gate output old_value -> ", self.output.old_value         

##################################################################    

class Net:  
    def __init__(self, name, gate_list, value):
        self.name = name
        self.gate_list = gate_list
        self.value = value
        self.old_value = "x"

