/**
 *  blinkingLines
 *  Author: annalisapg
 *  Description: OpenGL blinking lines
 */

model goemonier
global {
	file baseInit <- file('../includes/simpleFinistere.shp');
	geometry shape <- envelope(baseInit);
	init {
		create general from:baseInit;
	}
}

entities {
	species general {	
		aspect default {
			draw shape color: #gray;
		}
	}
}
experiment goemonier type: gui {
	output {
		display my_display type: opengl {	
			species general aspect:default refresh:true;
		}
	}
}
