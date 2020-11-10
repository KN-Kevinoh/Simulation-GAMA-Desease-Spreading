/***
* Name: spreading01
* Author: kevin
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model spreading01

global {
	/** Insert the global definitions, variables and actions here */
	int nb_people <- 2147;
    int nb_infected_init <- 5;
    float step <- 5 #mn;
    geometry shape<-square(1500 #m);
    
    init{
    	create people number:nb_people;
    	
    	ask nb_infected_init among people {
    		is_infected <- true;
    	}
    }
    
}

species people skills: [moving]{
	
	float speed <- (2 + rnd(3))#km/#h;
	bool is_infected <- false;
	
	reflex move{
		do wander;
	}
	
	reflex infect when:is_infected{
		ask people at_distance 10#m{
			if flip(0.05) {
				is_infected <- true;
			}
		}
	}
	
	aspect circle{
		draw circle(5) color:is_infected? #red:#green;
	}
}


experiment spreading01 type: gui {
	/** Insert here the definition of the input and output of the model */
	 parameter "Nb people infected at init" var: nb_infected_init min: 1 max: 2147;
	output {
		display map {
	    	species people aspect: circle;  
	    }
	}
}
