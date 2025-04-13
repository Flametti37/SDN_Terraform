terraform { 
  cloud { 
    
    organization = "Flametti" 

    workspaces { 
      name = "Bank_SDN_Proj" 
    } 
  } 
}