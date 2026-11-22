variable "name" { 
    type = string 
    }
variable "vpc_id" { 
    type = string 
    }
variable "subnet_ids" { 
    type = list(string) 
    }
variable "target_port" { 
    type = number
    default = 80 
    }
variable "health_check_path" { 
    type = string
    default = "/" 
    }
variable "allowed_cidrs" { 
    type = list(string)
    default = ["0.0.0.0/0"] 
    }
variable "tags" { 
    type = map(string)
    default = {} 
    }
