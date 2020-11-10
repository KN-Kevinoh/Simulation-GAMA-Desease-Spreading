/***
* Name: spreading05
* Author: kevin
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model spreading05

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
    
    graph road_network;
    
    init{
    	
    	create road from: roads_shapefile;
    	road_network <- as_edge_graph(road); 
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
	 point target; //make moving building to another
	
	
	/*
	 * Then, we modify the move reflex. This one will be only activated when the agent will have 
	 * to move (target not null). Instead of using the wander action of the moving skill, 
	 * we use the goto one that allows to make an agent moves toward a given target. In addition,
	 *  it is possible to add a facet on to precise on which topology the agent will have to move on. 
	 * In our case, the topology is the road network. When the agent reaches its destination (location = target),
	 *  it sets its target to null.
	 */
	
	reflex move when: target != nil{
		//do wander;
		do goto target: target on: road_network;
		    if (location = target) {
		    target <- nil;
    	} 
	}
	
	reflex infect when:is_infected{
		ask people at_distance 10#m{
			if flip(0.05) {
				is_infected <- true;
			}
		}
	}
	
	/*
	 * First, we add a new reflex called stay that will be activated when the agent
	 *  is in a house (i.e. its target is null) and that will define 
	 * with a probability of 0.05 if the agent has to go or not. 
	 * If the agent has to go, it will randomly choose a new target 
	 * (a random location inside one of the building).
	 * 
	 * 
	 */
	reflex stay when: target = nil {
	    if flip(0.05) {
	    	target <- any_location_in (one_of(building));
	    }
	}
	
	aspect circle{
		draw circle(10) color:is_infected? #red:#green;
	}
	
	/*
	 * At last, we define a new aspect called geom3D for the people species that displays the agent
	 *  only if it is on a road (target != nil). In this aspect, we use an obj file that contains a 3D object.
	 *  The use of the obj_file operator allows to apply an initial rotation to an obj file. In our case,
	 *  we add a rotation of -90° along the x-axis. We specify with the size facet that we want to draw the 3D object
	 *  inside a bounding box of 5m. As the location of the 3D object is its centroid and as we want to draw the 3D
	 *  object on the top of the ground, we use the at facet to put an offset along the z-axis. We use also
	 *  the rotate facet to change the orientation of the 3D object according to the heading of the agent. 
	 * At last, we choose to draw the 3D object in green if the agent is not infected; in red otherwise.
	 */
	  aspect geom3D {
	    if target != nil {
	        draw obj_file("../includes/people.obj", 90::{-1,0,0}) size: 5
	        at: location + {0,0,7} rotate: heading - 90 color: is_infected ? #red : #green;
	    }
    }
}

species road{
	aspect geom{
		draw shape color: #black;
	}
	
	aspect geom3D{
		draw line(shape.points, 2.0) color:#black;
	}
}

species building{
	aspect geom{
		draw shape color: #gray;
	}
	/**
	 *  aspect called geom3D that draws the shape of the building with a depth of 20 meters 
	 * and with using a texture "texture.jpg" for the face and a texture for the roof "roof_top.png".
	 */
	aspect geom3D{
		draw shape depth: 20 #m border: #black texture: ["../includes/roof_top.png","../includes/texture.jpg"];
	}
}


experiment spreading05 type: gui {
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
        
        display view3D type: opengl ambient_light: 80 {
	        image "../includes/luneray.png" refresh: false; 
	        species building aspect: geom3D refresh: false;
	        species road aspect: geom3D refresh: false;
	        species people aspect: geom3D; 
    	}
	    
	     monitor "Infected people rate" value: infected_rate;
	}
}




