/**
 *  goemonier
 *  Author: annalisa
 *  Description: simulate the movement and fishing of goemonier boats
 */

model goemonier
global {
//	setting up starting, ending datetime and timestep of the analysis
	string dtOne <- '2011-02-03 07:02';
	string dtTwo <- '2011-02-10 00:02';
	string dt1 <- dtOne + ':%';
	string dt2 <- dtTwo + ':00';
	int nbGoem <- 3;
	int nbCsj <- 2;
	string minut <- '60';
//	string coords <- 'x1,y1;x2,y2';
	string coords <- '42750,18500;50050,22850';
	int res <- 25;
	float areaLevel;
	string stations <- 'brest';
//	int pasVide;
	string minu <- minut + " minutes";
//  WARNING: when you define the step you can choose between seconds, minutes hrs with # symbols but if you want to use that number as a number it will always be reported in seconds!!!	
	float step <- 1#h;
	file bathy_asc <- file('../includes/bathy.asc') ;
	file zdpGoem <- file('../includes/zdpGoem.shp');
	file zdpCSJ <- file('../includes/zdpCSJ.shp');
//	file soilType <- file('../includes/soilType.shp');
	file departGoem <- file('../includes/partenza.shp');
	file deschargeGoem <- file('../includes/arrivo.shp');
	
//modificare in maniera tale che la fase di zoom viene bypassata quindi anche simpleFinistere non e piu necessaria..	
	
	
//	file baseInit <- file('../includes/simpleFinistere.shp');
	geometry shape <- envelope(bathy_asc);
//	geometry polygeom;
//	global variable individuationg the level of the analysis
	int level;
//	variables connected to pgSql and the timestamps
	string j <- dt1;
	string dt3;
	string jtemp;
	float pre;
	float post;
	float diff;	
	map<string,string> POSTGRESTide <- [
	'host'::'localhost',
	'dbtype'::'postgres',
	'database'::'postgres',
	'port'::'5432',
	'user'::'postgres',
	'passwd'::'annalisa81'
//	'host'::'clapot',
//	'dbtype'::'postgres',
//	'database'::'simaris',
//	'port'::'5433',
//	'user'::'geomer',
//	'passwd'::'letg/go!'
	];
	string queryTide <- 'SELECT "'+ stations+'Tide2011".waterlevel FROM public."'+ stations+'Tide2011" WHERE CAST("'+ stations+'Tide2011".datetime as CHAR(50)) LIKE ?;' ;
	string queryTime0 <- 'SELECT "'+ stations+'Tide2011".datetime FROM public."'+ stations+'Tide2011" WHERE CAST("'+ stations+'Tide2011".datetime as CHAR(50)) LIKE ?;' ;
	string queryTime <- "SELECT (?::timestamp + interval '" + minu +"') as ntimestamp ";
//	model initialization	
	init {
//		create general from:baseInit;
		create startPtemp from:departGoem;
		create endPtemp from:deschargeGoem;
		create connector;
//		create zoom;
		write "Select the working zone by reading two pairs ";
		write "of coordinates from the layer cellTide, insert ";
		write "them into the computational zone variable ";
		write "before launching the cycle 1";
	}
//	resizing working area	
//	reflex select when: (cycle=0) {
//		write "resizing working area..";
//		ask zoom {
//			if (cycle=0) {
//				list allCoords <- list(coords split_with ',;');
//				polygeom <- polygon([{float(allCoords[0]),float(allCoords[1])},{float(allCoords[0]),float(allCoords[3])},{float(allCoords[2]),float(allCoords[3])},{float(allCoords[2]),float(allCoords[1])}]);
//				create zoom with: [shape::polygeom];
//				areaLevel <- polygeom.width * polygeom.height;
//				if (areaLevel < 70000000) {
//					level <- 1;
//					write "analysis level = 1";
//				}
//				else if (areaLevel >= 70000000 and areaLevel < 150000000) {
//					level <- 2;
//					write "analysis level = 2";
//				}
//				else if (areaLevel >= 150000000) {
//					level <- 3;
//					write "analysis level = 3";
//				}
//			}
//		}
//	}
//	reflex updatesize when: (cycle=1) {
//       geometry shape <- envelope(zoom); 
        //if the dimensions of the zoom are X then the level is Y
//	}
//	reshaping layers and creation of grids for level 1 and 2 analyses
	reflex createZones when: (cycle=1) {
		write "reshaping layers and instantiating agents..";
		create startP from:departGoem with:[actCode::list(string(read("actCode")) split_with ' ,')];
//		int lenStart <- length(startP inside polygeom);
		int lenStart <- length(startP);
		if lenStart = 0 {
			write "WARNING! no starting point for boats, please review the zoom limits";
		}
		create endP from:deschargeGoem with:[actCode::list(string(read("actCode")) split_with ' ,')];
//		int lenEnd <- length(endP inside polygeom);
		int lenEnd <- length(endP);
		if lenEnd = 0 {
			write "WARNING! no ending point for boats, please review the zoom limits";
		}

//		fix resolution in reason of the level
//		if (level = 1) {
//			if (areaLevel < 10000000) {
//				res <- 10;
//			}
//			else if (areaLevel >= 10000000 and areaLevel < 20000000) {
//				res <- 20;
//			}
			//else if (areaLevel >= 20000000 and areaLevel < 70000000) {
				//res <- 50;
			//}
		//}
		//else if (level = 2) {
			//res <- 100;
		//}
		//else if (level = 3) {
			//res <- 100;
		//}
		
		
//		write "analysis of level "+level;
//		write "resolution fixed at "+res+" meters";
		res <- 25;
				
				// je scale la resolution par rapport à l'étendu du zoom pour les niveau 1 et 2 - pour le moment le rapport est lineaire
			// NON! faire des échellons: 25, 50 et 100 mt de resolution.. par rapport à la res de cellTide - voir overlap - si non cells de forme irregulaire!!!
//		create zonesTide from: polygeom {
		create zonesTide {
//			loop cell over: cellTide overlapping zoom {
			loop cell over: cellTide {
				loop g over: to_squares(cell.shape, 100, true) { //1.8m*14 de cote
						create cell_areaTide with:[shape::g];
				} 
			} 
		}

//		create zonesTraffic from: polygeom {
		create zonesTraffic {
//			loop cell over: cellTraffic overlapping zoom {
			loop cell over: cellTraffic {
				loop g over: to_squares(cell.shape, 100, true) { //1.8m*14 de cote
						create cell_areaTraffic with:[shape::g];
				} 
			} 
		}
		
		create zonesCSJ from: zdpCSJ {
//			loop cell over: cellTide overlapping zoom {
			loop cell over: cellTide {
				loop g over: to_squares(cell.shape, res, true) { //1.8m*14 de cote
					if (g overlaps self) {
//						write "lo creo!";
						create cell_areaCSJ with:[shape::g];
					}
				} 
			} 
		}
		create zones from: zdpGoem {
//			loop cell over: cellTide overlapping zoom {
			loop cell over: cellTide {
				loop g over: to_squares(cell.shape, res, true) { //25m de cote
					if (g overlaps self) {
						create cell_areaGoem with:[shape::g];
					}
				} 
			} 
		}
		
		create boat number: nbGoem with:[activityCode::0] {
			cell_areaTide startCell <- any_location_in(one_of(startP where (each.actCode contains '0')));
			dischargeCell <- any_location_in(one_of(endP where (each.actCode contains '0')));
//			cell_areaTide startCell <- any_location_in(one_of(startP where ((each.actCode contains '0') and (each overlaps polygeom)))); //changed from cellTide to cell_areaTide
//			dischargeCell <- any_location_in(one_of(endP where ((each.actCode contains '0') and (each overlaps polygeom))));
			location <- startCell.location;
			currentCell <- startCell;
			cyclesElapsed <- 14400/step;
		}
		create boat number: nbCsj with:[activityCode::55010] {
			cell_areaTide startCell <- any_location_in(one_of(startP where ((each.actCode contains '55010'))));
			dischargeCell <- any_location_in(one_of(endP where ((each.actCode contains '55010'))));
			//cell_areaTide startCell <- any_location_in(one_of(startP where ((each.actCode contains '55010') and (each overlaps polygeom)))); //changed from cellTide to cell_areaTide
			//dischargeCell <- any_location_in(one_of(endP where ((each.actCode contains '55010') and (each overlaps polygeom))));
			location <- startCell.location;
			currentCell <- startCell;
			cyclesElapsed <- 14400/step; //la session de peche est de 4h - step est defini dans boat!
			scoreDePeche <- 300000; //300kg par jour de peche
		}
		
	}
	reflex all when: (cycle > 0) {
//		ask cell_areaGoem {
//			neighbours <- cell_areaGoem at_distance 0.1; 
//		}   
		ask connector {
			if (cycle = 1) {
				if (self testConnection (params: POSTGRESTide)) {
					write 'connected to the server';
				}else{
					write 'NOT connected to the server';
				}
			}
			if (dt2>j) {
				write "cycle number " +cycle;
				if (j = dt1) {
					list<list> t <- list<list>(self select(params:: POSTGRESTide, select:: queryTide, values:: [j] ));
					pre <- t[2][0][0];
					//da qui dovrei tirare fuori la stringa di timestamp esatta da mettere in queryTime
					ask cell_areaTide {grid_value <- grid_value + pre;}
//					ask cell_areaTide overlapping zoom {grid_value <- grid_value + pre;} //changed from cellTide to cell_areaTide
					list t0 <- list<list>(self select(params:: POSTGRESTide, select:: queryTime0, values:: [j] ));
					dt3 <- t0[2][0][0];
					write "current datetime is "+dt3;
					list cutime <- list<list>(self select(params:: POSTGRESTide, select:: queryTime, values:: [dt3]));
					jtemp <- cutime[2][0][0];
					j <- (jtemp split_with ':')[0]+':'+(jtemp split_with ':')[1]+':%';
				}
				else {
					list<list> t <- list<list>(self select(params:: POSTGRESTide, select:: queryTide, values:: [j] ));
					post <- t[2][0][0];
					diff <- post - pre;
					ask cell_areaTide {grid_value <- grid_value + diff;}
//					ask cell_areaTide overlapping zoom {grid_value <- grid_value + diff;} //changed from cellTide to cell_areaTide
					list t0 <- list<list>(self select(params:: POSTGRESTide, select:: queryTime0, values:: [j] ));
					dt3 <- t0[2][0][0];
					write "current datetime is "+dt3;
					list cutime <- list<list>(self select(params:: POSTGRESTide, select:: queryTime, values:: [dt3]));
					jtemp <- cutime[2][0][0];
					j <- (jtemp split_with ':')[0]+':'+(jtemp split_with ':')[1]+':%';
					pre <- post;
				}
			}
		}
		ask cell_areaTide {  //changed from cellTide to cell_areaTide	
//			color<- grid_value <= -9999 ? #white : rgb(grid_value / 100 * 255, 0,0);
			list<zones> overZones <- agents_overlapping(self.shape) of_species(zones);
			if (length(overZones where (each.code=1))!=0) {
				rocks <- 1;
			} else {
				rocks <- 0;
			}
		}
//	 	ask cellTraffic {
//			color <-rgb( 0,0,grid_value) ;
//		}
		ask cell_areaCSJ {
			today <- (cycle-1)/1;
			if (nbIndiv != 0) {
				if (stage = 1) {
					stageDuration <- 180;
					lifeDays <- lifeDays + 1;
					weight <- (0.040958904109589 * lifeDays)+0.05;
					size <- (-0.000000001713721 * (lifeDays ^ 3))-(0.000034849743988 * (lifeDays ^ 2))+(0.122341813437705 * lifeDays)+1.814285714286140;
					if (lifeDays > 365) {
						stage <- 2;
						lifeDays <- 0;
					}	
				}
				else if (stage = 2) {
					stageDuration <- 365;
					lifeDays <- lifeDays + 1;
					weight <- (-0.000000000000006 * ((365+lifeDays) ^ 5))+(0.000000000065994 * ((365+lifeDays) ^ 4))-(0.000000252399370 * ((365+lifeDays) ^ 3))+(0.000383156594372 * ((365+lifeDays) ^ 2))-(0.075486157599374 * (365+lifeDays))+2.499999977521110;
					size <- (-0.000000001713721 * ((365+lifeDays) ^ 3))-(0.000034849743988 * ((365+lifeDays) ^ 2))+(0.122341813437705 * (365+lifeDays))+1.814285714286140;				
					if (lifeDays > 365) {
						stage <- 3;
						lifeDays <- 0;
					}
				}
				else if (stage = 3) {
					stageDuration <- 365;
					lifeDays <- lifeDays + 1;
					weight <- (-0.000000000000006 * ((730+lifeDays) ^ 5))+(0.000000000065994 * ((730+lifeDays) ^ 4))-(0.000000252399370 * ((730+lifeDays) ^ 3))+(0.000383156594372 * ((730+lifeDays) ^ 2))-(0.075486157599374 * (730+lifeDays))+2.499999977521110;
					size <- (15.961295826275600 * log((730+lifeDays)))-14.502887227797600;	
					if (lifeDays > 365) {
						nbIndiv <- 0;
						stage <- 0;
					}	
				}
			}
		}
	}
	//seulement pour vérifier que l'action de pêche marche - le nbIndiv doit diminuer 
//	reflex count1 when: (cycle = 1) {
//		ask cell_areaCSJ {
//			list<cell_areaCSJ> allCells <- list(cell_areaCSJ);
//			pasVide <- allCells count (each.nbIndiv != 0);
//			write "the number of cells not empty is "+pasVide;
//		}
//	}
//	reflex count2 when: (cycle = 40) {
//		ask cell_areaCSJ {
//			list<cell_areaCSJ> allCells <- list(cell_areaCSJ);
//			pasVide <- allCells count (each.nbIndiv != 0);
//			write "the number of cells not empty is "+pasVide;
//		}
//	}
}

//species definition
entities {
	species connector skills: [SQLSKILL] {
	}

	species boat skills:[moving] {
		int step <- 1#h;
		int activityCode;
		int cyclesElapsed;
		int state;
		int scoreDePeche;
		cell_areaTide currentCell;
		cell_areaTide dischargeCell;
		cell_areaGoem currentCell2;
		cell_areaCSJ currentCellCSJ;
		list<cell_areaCSJ> emptyCells;
		aspect circle {
			draw image:"../includes/goem.png" size:100;
		}
		string currentDate <- (j split_with ' ')[0];
		int currentHour;
		string period;
		reflex definePeriod {
			currentHour <- int((((j split_with ' ')[1]) split_with ':')[0]);
			if (currentHour >= 8 and currentHour <= 12) {
				period <- 'morning';
			}
			if (currentHour > 13 and currentHour <= 17) {
				period <- 'afternoon';
			}
			if ((currentHour > 12 and currentHour <= 13) or currentHour > 17 or currentHour < 8) {
				period <- 'noFish';
			}
		}
		reflex initMove when: (period = 'morning' or period = 'afternoon') and (state = 0 or state = 3) and scoreDePeche != 0 {
			location <- currentCell.location;
			ask boat {
				if (activityCode = 0) {
					do goto (target:: any_location_in(one_of(cell_areaGoem)));
					list candidate <- (cell_areaGoem) closest_to currentCell.location;
					currentCell2 <- one_of(candidate);
				}
				else if (activityCode = 55010) {
					do goto (target:: any_location_in(one_of(cell_areaCSJ)));
					list candidate <- (cell_areaCSJ);
					currentCellCSJ <- one_of(candidate);
				}
			state <- 1;
			}
		}
	
		reflex randMove when: (period = 'morning' or period = 'afternoon') and (state = 1 or state=2) {
			ask boat {
				if (activityCode = 0) {
					list<cell_areaGoem> neighs <- (currentCell2 neighbours_at (res/2));
					currentCell2 <- one_of(neighs);
					location <- currentCell2.location;
					ask cell_areaTraffic { //changed from cellTraffic to cell_areaTraffic
						if ((boat inside self)=[0 as boat]) {
							self.grid_value <- self.grid_value +1;
							}
						}
					}
				else if (activityCode = 55010) and scoreDePeche > 0 {
//					list<cell_areaCSJ> neighs <- (currentCellCSJ neighbours_at (res/2));
					list<cell_areaCSJ> neighs <- (currentCellCSJ neighbours_at 0.1);
					list<cell_areaCSJ> neighsAvail <- neighs - emptyCells;
					currentCellCSJ <- one_of(neighsAvail);
					if currentCellCSJ.stage = 3 {
						if ( scoreDePeche-(currentCellCSJ.nbIndiv * currentCellCSJ.weight)< 0 ) {
							currentCellCSJ.nbIndiv <- (currentCellCSJ.nbIndiv-int(scoreDePeche/currentCellCSJ.weight));
							scoreDePeche <- 0;
						}
						else if (scoreDePeche > (currentCellCSJ.nbIndiv * currentCellCSJ.weight)) {
							scoreDePeche <- scoreDePeche-(currentCellCSJ.nbIndiv * currentCellCSJ.weight);
							currentCellCSJ.nbIndiv <- 0;
							emptyCells <- emptyCells + currentCellCSJ;
						}
					}
					location <- currentCellCSJ.location;
					ask cell_areaTraffic { //changed from cellTraffic to cell_areaTraffic
						if ((boat inside self)=[0 as boat]) {
							self.grid_value <- self.grid_value +1;
							}
						}
					}
				state <- 2;
				}
			}

		reflex backMove when: (period = 'noFish' or scoreDePeche = 0) and state = 2 {
//			if ((cycle-1) = cyclesElapsed) {
//				write "end time - back home";
//			}
			if (scoreDePeche = 0) {
//				write "boat full - back home";
			}
			location <- dischargeCell.location;
			currentCell <- dischargeCell;
			scoreDePeche <- 300000;
			state <- 3;
			}
	}

	species startP {
		list actCode;
		aspect default {
			draw circle(150) color:#red;
			}
		}
	
	species startPtemp {	
		aspect default {
			draw circle(150) color:#red;
		}
		reflex toDie when: cycle = 1 {
			do die;			
		}
	}
	
	species endP {
		list actCode;
		aspect default {
			draw circle(150) color:#yellow;
			}
		}

	species endPtemp {	
		aspect default {
			draw circle(150) color:#yellow;
		}
		reflex toDie when: cycle = 1 {
			do die;			
		}
	}
	
	species zones {
		int code;
		aspect default {
			draw shape color: rgb(150, 222, 209);
		}
	}	
	
	species zonesCSJ {
//		int code;
		aspect default {
			draw shape color: rgb(150, 222, 209);
		}
	}
	
	species zonesTide {
//		int code;
		aspect default {
			draw shape color: rgb(150, 222, 209);
		}
	}
	
	species zonesTraffic {
//		int code;
		aspect default {
			draw shape color: rgb(150, 222, 209);
		}
	}

	species cell_areaGoem {
		list<cell_areaGoem> neighbours;
		aspect default {
			draw shape color: #yellow border: #green; 
		}
	}
	
	species cell_areaTide {
		int rocks;
		float grid_value;
		aspect default {
			draw shape color: (grid_value <= -9999 ? #white : rgb(0,0, 238 - 25*grid_value)) border: rgb(0,0,238 - 25*grid_value);
		}
	}
	
	species cell_areaTraffic {
		float grid_value;
		aspect default {
			draw shape color: #red border: #yellow;
		}
	}
	
	species cell_areaCSJ {
		int nbIndiv <- rnd(3 * ((res/1.8) ^ 2)); //nbIndiv = 3 indiv en chaque cell de 1.8m de cote
		int stage;
		int stageDuration;
		int today;
		int lifeDays;
		float weight;
		float size;
		list<cell_areaGoem> neighbours;
		aspect default {
			if (nbIndiv != 0) {
				draw shape color: #orange border: #orange; 
			}
			else {
				draw shape color: #blue border: #blue;
			}
		}
		init {
			if (nbIndiv != 0) {
				stage <- rnd(3)+1;
				if (stage = 1) {
					lifeDays <- rnd(365)+180; //because the CSJ are placed in the sea only after 180days of "incubation"
				}
				else if (stage=2 or stage=3) {
					lifeDays <- 0;		
				}
			}
			else if (nbIndiv = 0) {
				lifeDays <- 0;
			}
		}
	}

	//species zoom {	
		//aspect default {
			//draw shape color: #gray;
		//}
	//}
	
	//species general {	
		//aspect default {
			//draw shape color: #gray;
		//}
		//reflex toDie when: cycle = 1 {
			//do die;			
		//}
	//}

	grid cellTide file: bathy_asc  use_individual_shapes: false use_regular_agents: false frequency: 0{	
		int rocks;
		reflex toDie when: cycle = 2 {
			write "griglia uccisa";
			do die;	
		}
	}

	grid cellTraffic file: bathy_asc  use_individual_shapes: false use_regular_agents: false frequency: 0{
		init {
			grid_value <- 0;
		}	
	}
}
experiment goemonier type: gui {
	parameter "start datetime in YYYY-MM-DD hh:mm" var: dtOne;
	parameter "end datetime in YYYY-MM-DD hh:mm" var: dtTwo;	
	parameter "time step in minutes" var: minut;
	parameter "nr of goemonier boats" var: nbGoem;
	parameter "nr of CSJ boats" var: nbCsj;
	parameter "computational zone" var: coords;
	parameter "resolution of the square grid covering the fishing zone" var: res;
	parameter "stations to consider in tide calculation" var: stations;
	output {
		display my_display type: opengl {
			species cell_areaTide refresh:true;
			species cell_areaCSJ refresh:true transparency:0.6;		
//			species general aspect:default refresh:true;
			species startPtemp aspect:default refresh:true;
			species endPtemp aspect:default refresh:true;
//			species zoom aspect:default refresh:true transparency:0.7;
			grid cellTide refresh:false;
			species startP aspect:default refresh:true;
			species endP aspect:default refresh:true;
			species cell_areaGoem refresh:true;
			species boat aspect:circle refresh:true;
		}
	}
}
