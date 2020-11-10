/***
* Name: spreading03
* Author: kevin
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model spreading03

/* Insert your model definition here */


global {
	/** Insert the global definitions, variables and actions here */
	int nb_people <- 2147;
    int nb_infected_init <- 5;
    float step <- 5 #mn;
    //geometry shape<-square(1500 #m);
    
    //---others attributs
    file roads_shapefile <- file("../includes/roads.shp");
    file buildings_shapefile <- file("../includes/buildings.shp");
    geometry shape <- envelope(roads_shapefile); 
    
    //... other attributes
    int nb_people_infected <- nb_infected_init update: people count (each.is_infected);
    int nb_people_not_infected <- nb_people - nb_infected_init update: nb_people - nb_people_infected;
    float infected_rate update: nb_people_infected/nb_people;
    
    
    
    init{
    	
    	create road from: roads_shapefile;
    	create building from: buildings_shapefile;
    	
    	create people number:nb_people{
    		 location <- any_location_in(one_of(building));
    	}
    	
    	ask nb_infected_init among people {
    		is_infected <- true;
    	}
    }
    
    reflex end_simulation when: infected_rate = 1.0 {
   	 do pause;
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
		draw circle(10) color:is_infected? #red:#green;
	}
}

species road{
	aspect geom{
		draw shape color: #black;
	}
}

species building{
	aspect geom{
		draw shape color: #gray;
	}
}


experiment spreading03 type: gui {
	/** Insert here the definition of the input and output of the model */
	 parameter "Nb people infected at init" var: nb_infected_init min: 1 max: 2147;
	output {
		display map {
	    	species people aspect: circle;  
	    	species road aspect: geom;
	    	species building aspect:geom;
	    }
	    
	    display chart_display refresh:every(10 #cycles) {
	        chart "Disease spreading" type: series {
	        data "susceptible" value: nb_people_not_infected color: #green;
	        data "infected" value: nb_people_infected color: #red;
        }
    }
	    
	     monitor "Infected people rate" value: infected_rate;
	}
}




