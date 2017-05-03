/*
 ************************************************************************************************
  Polygon class
  An object of this class renders a regular or irregular polygon of n vertices probabilistically 
  email: archit.jain.us@gmail.com  
  Author: Archit Jain                                   
 *************************************************************************************************
 */
package
{
	import flash.display.*;
	
	public class Polygon 
	{
		//---------------------------------------------------------
		//Properties
		//---------------------------------------------------------
		private var g:Graphics;
		private var fill_color:uint;
		private var cmass:Array;
		//Offest from center of mass
		private var offset_x:Number; 
		private var offset_y:Number; 
		//Coordianates of the n points of the polygon 
		private var polygon_points_coord:Array;
		private var edge_angles_from_baseline:Array;
		//Angle between each pairs of edges of the polygon
		private var edge_angles:Array;
		//Number of sides of the polygon
		private var num_sides:int;
		//Edge Length
		private var edge_len:Array;
		private var click_count:int;
		private var mouse_clickX:Number;
		private var mouse_clickY:Number;
		private var array_two:Array;
		//----------------------------------------------------------
		//Constructor
		//----------------------------------------------------------
		public function Polygon(myGraphics:Graphics)
		{
			g = myGraphics;
			
		}
		//----------------------------------------------------------
		//Public Methods
		//----------------------------------------------------------
		/*
		This function draws a point circle at the coordinates centerX,centerY with the given radius
		*/
		public function drawpointCircle(centerX:Number,centerY:Number,radius:int):void
		{
			g.beginFill(0x800000);
			g.drawCircle(centerX,centerY,radius);
			g.endFill();
		}
		
		/*
		This function clears the canvas
		*/
		public function clearStage():void
		{
			g.clear();
		}
		
		/*
		This function draws a polygon with the center at centerX,centerY and number of sides as count + 2
		*/
		public function drawPolygon(centerX:Number,centerY:Number,count:int):void
		{	
			// Initialise the center and the number of sides of the polygon
			initPolygon(centerX,centerY,count);
			// Calculates a permutation of an array with values 0 to (num_sides-1)
			calculatePermutation();
			// Calculate the Length and angle of each side of the polygon
			calculateEdgelengthAngles();
			// Calculate the coordinates of the points from edge lengths and angles 
			calculatePointCoordinates();
			// Calculate the center of mass and translate the center of the polygon to center of mass
			calculateTranslateCm();
			//Generate Random Fill color
			randomFillColor();
			// Draw the polygon with the generated vertices and fill with the random color
			drawPolygonFromPoints();
			
			
			
		}
		//--------------------------------------------------------------------
		//Private Methods
		//--------------------------------------------------------------------
		/*
		This function initialises the number of sides and center of the polygon
		*/
		private function initPolygon(centerX:Number,centerY:Number,count:int)
		{
			click_count = count;
			mouse_clickX = centerX;
			mouse_clickY = centerY;
			num_sides = click_count + 2;
		}
		/*
		This function selects the type of polygon and calculates the edge length and angle accordingly
		*/
		private function calculateEdgelengthAngles():void
		{
			
			edge_angles = new Array();
			edge_len = new Array();
			
			var regular_irregular:Number;
			regular_irregular = Math.random();
			
			if(regular_irregular>0.90) //90% Irregular 10% Regular 
			{
				//For regular polygons
				regularPolygon();
				
			}
			else // Irregular polygon
			{  				
				var polygon_selector:int;
				
				if(num_sides==3) // 3 Sided polygons cases
				{
					polygon_selector = Math.floor(Math.random() * 4);
					
					switch(polygon_selector) // Select from various kinds of 3 sided polygons
					{
						case 0: isoceles(); break;
						case 1: rightTriangle(); break;
						case 2: acute(); break;
						default: obtuse(); 
					}
					
				}
				if(num_sides==4) // 4 Sided polygons cases
				{	
					polygon_selector = Math.floor(Math.random() * 7);
					
					 
					switch(polygon_selector) // Select from various kinds of 4 sided polygons
					{
						case 0: rhombus(); break;
						case 1: rhomboid(); break;
						case 2: rectangle(); break;
						case 3: kite(); break;
						case 4: isoscelesTrapezoid(); break; 
						case 5: parallelogram();break;
						default : trapezium();
					}
					
				}
				if(num_sides>4) // Larger than 4 Sided polygons cases
				{
					polygon_selector = Math.floor(Math.random() * 4.9);
					
					
					switch(polygon_selector) // Select from various kinds of 4 sided polygons
					{
						case 0: convex(); break;
						case 1: randomAngle(); break;
						case 2: semiregularPolygon(); break;
						default : semiregularPolygon();
					}
				}
			}
		}
		
		/*
		This function calculates the intial coordinates of the polygon 
		from previously calculated edge angles and edge lengths.
		Note that this function does not take into account
		the center of mass of the polygon.
		*/
		private function calculatePointCoordinates():void
		{
			//Angle from baseline for each edge 
			edge_angles_from_baseline = new Array();
			edge_angles_from_baseline[0] = edge_angles[0];
			
			for(var i:int=1;i<num_sides-1;i++)
				edge_angles_from_baseline[i] = edge_angles_from_baseline[i-1] +  edge_angles[i];
			
			//The coodinates of the polygon
			polygon_points_coord = new Array();
			
			//First point at the center for now. Later it will be shifted according to center of mass coordinates
			polygon_points_coord[0] = new Array(mouse_clickX,mouse_clickY);
			
			var temp_x:Number; //Temporary variable for x coord
			var temp_y:Number; //Temporary variable for y coord
			
			for(i=1;i<num_sides;i++)
			{
				// Calculating coordinates with taking care of projections 
				temp_x = getX(i);
				temp_y = getY(i);
				polygon_points_coord[i] = new Array(temp_x,temp_y);
			
			}
		}
		/*
		Generates a non interesecting Polygon point 
		This function adds a point to the polygon and checks that 
		the edge generated does not interesect any other existing edge in the polygon.
		If the edge intersects than it keeps on reducing the edge length until the edge 
		does not intersect any other edge. 
		*/
		private function addpoint(polygon_side:int):void
		{	//Initialising the polygon by adding the first point
			if(polygon_side==0)
			{	
				//Angle from baseline for each edge
				edge_angles_from_baseline = new Array();
				edge_angles_from_baseline[polygon_side] = edge_angles[polygon_side];
				
				//The coodinates of the polygon
				polygon_points_coord = new Array();
			
				//First point at the center for now. Later it will be shifted according to center of mass coordinates
				polygon_points_coord[0] = new Array(mouse_clickX,mouse_clickY);
			}
			else
			{
				//Angle from baseline for edge 
				edge_angles_from_baseline[polygon_side] = edge_angles_from_baseline[polygon_side-1] +  edge_angles[polygon_side];
				
				var temp_x:Number; //Temporary variable for x coord
				var temp_y:Number; //Temporary variable for y coord
				var flag:Boolean = false; 
				
				// Calculating coordinates with taking care of projections 
				temp_x = getX(polygon_side);
				temp_y = getY(polygon_side);
				
				while(checkpoint(polygon_side,temp_x,temp_y))//Checks for intersection with other edges of the polygon
				{
					edge_len[polygon_side-1] = edge_len[polygon_side-1] / 3;
					temp_x = getX(polygon_side);
					temp_y = getY(polygon_side);
					flag = true;
				}
				if(flag) // Reduces edge length one more time for better looking polygons
				{
					edge_len[polygon_side-1] = edge_len[polygon_side-1] / 2;
					temp_x = getX(polygon_side);
					temp_y = getY(polygon_side);
				}
				// Adds the final point to the polygon
				polygon_points_coord[polygon_side] = new Array(temp_x,temp_y);
			}
			
		}
		/*
		This function returns the x coordinate of the new point after calculating the projection 
		*/
		private function getX(polygon_side:int):Number
		{
			return  (polygon_points_coord[polygon_side-1][0] + edge_len[polygon_side-1] * (Math.cos(radians(edge_angles_from_baseline[polygon_side-1])))); 
		}
		/*
		This function returns the y coordinate of the new point after calculating the projection 
		*/
		private function getY(polygon_side:int):Number
		{
			return  (polygon_points_coord[polygon_side-1][1] - edge_len[polygon_side-1] * (Math.sin(radians(edge_angles_from_baseline[polygon_side-1]))));
		}
		/*
		Returns true if the polygon generated by the new point (curr_x,curr_y) intersects any previous edge in the polygon 
		*/
		private function checkpoint(polygon_side:int,x1:Number,y1:Number):Boolean		
		{
			if(polygon_side>2) // Polygons with 0,1,2 points never intersect
			{
				// Iterating through all the edges and checking if each one intersects
				for(var i:int=0;i<=polygon_side-3;i++)
				{	//If the new edge intersects ANY previous edge then retrun TRUE
					if(intersectingLines(i,i+1,polygon_side-1,x1,y1))
						return true;
				}
			}
			//Since NO edge intersects new edge return false 
			return false;
		
		}
		/*
		This function gives a random RGB color
		*/
		private function randomFillColor():void
		{
			//Randomise fill color
			var fill_color_r:uint;
			fill_color_r = Math.floor(Math.random()*(1+255));
			var fill_color_g:uint;
			fill_color_g = Math.floor(Math.random()*(1+255));
			var fill_color_b:uint;
			fill_color_b = Math.floor(Math.random()*(1+255));
			//Create fill color
			fill_color = fill_color_r + (1000 * fill_color_g) + (1000000 * fill_color_b);
			
			
		}
		/*
		This function draws the polygon with the given color and polygon coordinate points
		*/
		private function drawPolygonFromPoints():void
		{
			g.beginFill(fill_color);
			g.lineStyle(2,0x000000);
			
			var normal_permuted:int=0;
			normal_permuted = Math.floor(Math.random()*1.99);
			
			switch(normal_permuted)
			{
				case 1: normalPolygon();break;
				case 2: permutedPolygon();break;
				default: normalPolygon();
			}
			
			g.endFill();
			
			
		}
		/*
		This function draws the nomral polygon as given
		*/
		private function normalPolygon():void
		{
			//Draw lines at translated Numbers except the last one
			g.moveTo( polygon_points_coord[0][0], polygon_points_coord[0][1]);
			
			for(var i:int=1;i<num_sides;i++)
				g.lineTo( polygon_points_coord[i][0], polygon_points_coord[i][1]);
			
			//Draw the last edge
			g.lineTo( polygon_points_coord[0][0], polygon_points_coord[0][1]);
		}
		/*
		This function draws the permuted polygon as given by array_two
		*/
		private function permutedPolygon():void
		{
			//Draw lines at translated Numbers except the last one
			g.moveTo( polygon_points_coord[array_two[0]][0], polygon_points_coord[array_two[0]][1]);
			
			for(var i:int=1;i<num_sides;i++)
				g.lineTo( polygon_points_coord[array_two[i]][0], polygon_points_coord[array_two[i]][1]);
			
			//Draw the last edge
			g.lineTo( polygon_points_coord[array_two[0]][0], polygon_points_coord[array_two[0]][1]);
			
		}
		/*
		This function returns the angle in radians after converting from degrees
		*/
		private function radians(n:Number):Number 
		{
			return(Math.PI/180*n);
		}
		/*
		This function calculates the center of mass
		and translates the polygon center to those coordinates.
		*/
		private function calculateTranslateCm():void
		{
			// Calculate the center of mass
			centerofMass();
			
			// Calculate the offset from center of mass 
			offset_x = mouse_clickX - cmass[0];
			offset_y = mouse_clickY - cmass[1];
			
			
			//Translate calculated center of mass to user clicked coordinates
			for(var i:int=0;i<num_sides;i++)
			{
				polygon_points_coord[i][0] = polygon_points_coord[i][0] + offset_x;
				polygon_points_coord[i][1] = polygon_points_coord[i][1] + offset_y;
			}
		}
		/*
		This function calculates the center of mass of the polygon assuming unit mass at the each vertex of the polygon
		*/
		private function centerofMass():void
		{
			
			cmass = new Array(0.0,0.0);
			
			//Assume unit mass at each vertex of the polygon
			for(var i:int=0;i<num_sides;i++)
			{
				// Weighing with unit weights
				cmass[0] = cmass[0] + polygon_points_coord[i][0];
				cmass[1] = cmass[1] + polygon_points_coord[i][1];
			}
			
			// Calculate the average 
			cmass[0] = cmass[0] / num_sides;
			cmass[1] = cmass[1] / num_sides;
			
		}
		/*
		This function calculates edge angles and edge lengths for a regular polygon
		*/
		private function regularPolygon():void
		{
			var edge_angle:Number;
			edge_angle = click_count  * 180 / num_sides;
			for(var i:int=0;i<num_sides;i++)
			{
				edge_angles[i] = 180 - edge_angle;
				edge_len[i]=50; // Uniform length  
			}
		}
		/*
		This function calculates edge angles and edge lengths for a polygon
		with uniform angles but variable edge lengths
		*/
		private function semiregularPolygon():void
		{
			var edge_angle:Number;
			edge_angle = click_count  * 180 / num_sides;
			for(var i:int=0;i<num_sides;i++)
			{
				edge_angles[i] = 180 - edge_angle;
				edge_len[i]=(Math.floor(Math.random() * 100 ) + 50)*(3/num_sides); // Variable length  
			}
		}
		/*
		This function sets points and angles for an isoceles triangle
		*/
		private function isoceles():void
		{
			edge_angles[0] = Math.floor(Math.random() * 90 );
			edge_angles[1] = 180 - 2 * edge_angles[0];
			edge_len[0] = Math.floor(Math.random() * 100 ) + 100;
			edge_len[1] = edge_len[0];
		}
		/*
		This function sets points and angles for a pythogrean triangle
		*/
		private function rightTriangle():void
		{
			edge_angles[0] = 0;
			edge_angles[1] = 90; 
			edge_len[0] = Math.floor(Math.random() * 100) + 100;
			edge_len[1] = Math.floor(Math.random() * 100) + 100;
		}
		/*
		This function sets points and angles for an acute angles triangle
		*/
		private function acute():void
		{
			edge_angles[0] = 0;
			edge_angles[1] = 90 + Math.floor(Math.random() * 90);
			edge_len[0] = Math.floor(Math.random() * 100) + 100;
			edge_len[1] = Math.floor(Math.random() * 100) + edge_len[0]*Math.cos(radians(180 - edge_angles[1]));
		}
		/*
		This function sets points and angles for an obtuse angled triangle
		*/
		private function obtuse():void
		{
			//Code for obtuse triangle
			edge_angles[0] = 0;
			edge_angles[1] = Math.floor(Math.random() * 90);
			edge_len[0] = Math.floor(Math.random() * 100) + 100;
			edge_len[1] = Math.floor(Math.random() * 100) + 100;
		}
		/*
		This function sets points and angles for a rhombus
		*/
		private function rhombus():void
		{
			edge_angles[0] = Math.floor(Math.random()*90);
			edge_angles[1] = 180 - 2 * edge_angles[0];
			edge_angles[2] = 2 * edge_angles[0];
			edge_len[0] = Math.floor(Math.random() * 100) + 100;
			edge_len[1] = edge_len[0];
			edge_len[2] = edge_len[0];
		}
		/*
		This function sets points and angles for a rhomboid
		*/
		private function rhomboid():void
		{
			
			edge_angles[0] = Math.floor(Math.random() * 89.9);
			edge_angles[1] = 90 - edge_angles[0] + Math.floor(Math.random() * 89.9);
			edge_angles[2] = 180 - edge_angles[1];
			edge_len[0] = Math.floor(Math.random() * 100) + 100;
			edge_len[1] = Math.floor(Math.random() * 100) + 75;
			edge_len[2] = edge_len[0];
		}
		/*
		This function sets points and angles for a rectangle
		*/
		private function rectangle():void
		{
			edge_angles[0] = 90;
			edge_angles[1] = 90;
			edge_angles[2] = 90;
			edge_len[0] = Math.floor(Math.random() * 150) + 50 ;
			edge_len[1] = Math.floor(Math.random() * 150) + 50 ;
			edge_len[2] = edge_len[0];
		}
		/*
		This function sets points and angles for a kite
		*/
		private function kite():void
		{
			edge_angles[0] = Math.floor(Math.random()*90);
			edge_angles[1] = Math.floor(Math.random()*(180-edge_angles[0]));
			edge_angles[2] = 360 - 2 * (edge_angles[0] + edge_angles[1]);
			edge_len[0] = Math.floor(Math.random() * 150) + 50;
			edge_len[1] = edge_len[0] * Math.cos(radians(edge_angles[0])) / Math.cos(radians(edge_angles[2]/2));
			edge_len[2] = edge_len[1];
		}
		/*
		This function sets points and angles for an isoceles Trapezoid
		*/
		private function isoscelesTrapezoid():void
		{	
			edge_angles[0] = 0;
			edge_angles[1] = 90 + Math.floor(Math.random()*90);
			edge_angles[2] = 180 - edge_angles[1];
			
			edge_len[1] = Math.floor(Math.random() * 50) + 100;
			edge_len[2] = Math.floor(Math.random() * 150) + 100;
			edge_len[0] = edge_len[2] + 2 * edge_len[1] * Math.cos(radians(edge_angles[2]));
		}
		/*
		This function sets points and angles for an trapezium
		*/
		private function trapezium():void
		{
			edge_angles[0] = Math.floor(Math.random()*90);
			edge_angles[1] = Math.floor(Math.random()*90);
			edge_angles[2] = Math.floor(Math.random()*90);
			edge_len[0] = Math.floor(Math.random() * 50) + 100;
			edge_len[1] = Math.floor(Math.random() * 50) + 100;
			edge_len[2] = Math.floor(Math.random() * 50) + 100;
		}
		/*
		This function sets points and angles for a parallelogram
		*/
		private function parallelogram():void
		{
			edge_angles[0] = 0;
			edge_angles[1] = Math.floor(Math.random()*90);
			edge_angles[2] = 180 - edge_angles[1];
			edge_len[0] = Math.floor(Math.random() * 50) + 100;
			edge_len[1] = Math.floor(Math.random() * 50) + 100;
			edge_len[2] = edge_len[0];
		}
		/*
		This function sets points and angles for a convex polygon
		*/
		private function convex():void
		{
			var sum_of_angles:int=0;
			var residual_angle:int=360;
			
			//Random angle range array 
			var angle_range:Array;
			angle_range = new Array();
			angle_range[0] = 30;
			angle_range[1] = 60;
			angle_range[2] = 90;
			angle_range[3] = 120;
			angle_range[4] = 150;
			angle_range[5] = 160;
			
			//Generate angles randomly with range array and scaling by 3/num_sides so that at high 
			//number of sides we do not see polygons with initial edges having large angles and 
			//large number of small angled edges.
			for(var i:int=0;i<num_sides;i++)
			{	// If Residual angle ( the angle remaining from 360 degree ) is less than 180
				// then use residual angle as range for edge angle generation otherwise use
				// angle range array
				if(residual_angle<180)
					edge_angles[i]=  Math.floor(Math.random()*residual_angle*(3/num_sides));
				else
					edge_angles[i]=  Math.floor(Math.random()*angle_range[Math.floor(Math.random()*5.9)]*(3/num_sides)) + 20;
				
				edge_len[i] = (Math.floor(Math.random() * 100 ) + 50)*(3/num_sides);
				//Add the point to the polygon 
				addpoint(i);
				sum_of_angles = sum_of_angles + edge_angles[i];
				residual_angle = 360 - sum_of_angles;
		
			}
			//Some debug information
			trace("edge length");
			trace(edge_len);
			trace("edge angles")
			trace(edge_angles);
			trace("----------------");
			
		}
		/*
		This function sets points and angles for a random angle polygon with variable edge lengths
		*/
		private function randomAngle():void
		{
			//Generate angles randomly from 20 to 360 degree
			for(var i:int=0;i<num_sides;i++)
			{			
				edge_angles[i]=  Math.floor(Math.random()*340)+ 20;
				edge_len[i] = (Math.floor(Math.random() * 100 ) + 50) ;	
				addpoint(i);
						
			}
			
			//Some debug information
			trace("edge length");
			trace(edge_len);
			trace("edge angles")
			trace(edge_angles);
			trace("----------------");
			
		}
		
		/*
		Returns true if line between first point and second point 
		intersects line between third_pt and (curr_x,curr_y) 
		*/
		private function intersectingLines(first_pt:int,second_pt:int,third_pt:int,curr_x:Number,curr_y:Number):Boolean
		{	
			
			var x1:Number = polygon_points_coord[first_pt][0];
			var y1:Number = polygon_points_coord[first_pt][1];
			var x2:Number = polygon_points_coord[second_pt][0];
			var y2:Number = polygon_points_coord[second_pt][1];
			var x3:Number = polygon_points_coord[third_pt][0];
			var y3:Number = polygon_points_coord[third_pt][1];
			var x4:Number = curr_x;
			var y4:Number = curr_y;
			var pre1:Number = x4-x3;
		    var pre2:Number = y4-y3;
		    var pre3:Number = x2-x1;
		    var pre4:Number = y2-y1;
		    var pre5:Number = y1-y3;
		    var pre6:Number = x1-x3;
		    var nx:Number, ny:Number, dn:Number;
		    
		    nx = pre1 * pre5 - pre2 * pre6;
		    ny = pre3 * pre5 - pre4 * pre6;
		    dn = pre2 * pre3 - pre1 * pre4;
		    
			nx /= dn;
		    ny /= dn;
		    
			// has intersection
		    if(nx>= 0 && nx <= 1 && ny>= 0 && ny <= 1)
				return true;
		    else
		        return false;
		}
		/*
		Generates a permuation of various possible orderings 
		from 1 to n  
		*/
		private function calculatePermutation():void
		{	
			var len:int = num_sides;
			var array_one:Array;
			array_one = new Array;
			
			array_two = new Array;
			var temp_1:int;
			var j:int=0;
			var k:int=0;
			var l:Number=0.01;
			
			for(var i:int=0;i<num_sides;i++) // Loading the first array
				array_one[i]= i;
			
			while(j<(num_sides))
			{
				// Generating ONE index from the first array with array range
				temp_1 = Math.floor(Math.random()*(array_one.length-l));
				
				// Storing the value at that index
				array_two[j]= array_one[temp_1];
				j=j+1;
				
				k=0;
				
				for(i=0;i<(num_sides-l+0.01);i++)
				{
					if(i!=temp_1)
					{	//Copying the first array EXCLUDING the generated index 
						array_one[k]= array_one[i];
						k=k+1;
					}
				
				}
				//Reducing the array range by one 
				l=l+1;
			} 
			
		}
		
	}
}
			
		
