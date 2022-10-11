/**
 * Stepper motor clock mechanism
 * (c) 2022 Alastair Aitchison, Playful Technology
 */

// Gear generator https://github.com/chrisspen/gears
// (English translation of https://www.thingiverse.com/thing:1604369)
include <gears/gears.scad>

// Stepper Motor Properties
MBH = 18.8;   // motor body height
MBD = 28.25;  // motor body OD
SBD = 9.1;    // shaft boss OD
SBH = 1.45;   // shaft boss height above motor body
SBO = 7.875;  // offset of shaft/boss center from motor center
SHD = 4.93;   // motor shaft OD
SHDF = 3.0;   // motor shaft diameter, across flats
SHHF = 6.0;   // motor shaft flats height, or depth in from end
SHH = 9.75;   // height of shaft above motor body 

MBFH = 0.7;   // height of body edge flange protruding above surface
MBFW = 1.0;   // width of edge flange
MBFNW = 8;    // width of notch in edge flange
MBFNW2 = 17.8;  // width of edge flange notch above wiring box

MHCC = 35.0;  // mounting hole center-to-center
MTH  = 0.8;   // mounting tab thickness
MTW  = 7.0;   // mounting tab width
WBH  = 16.7;  // plastic wiring box height
WBW  = 14.6;  // plastic wiring box width
WBD  = 31.3;  // body diameter to outer surface of wiring box

WRD = 1.0;     // diameter of electrical wires
WRL = 30;      // length of electrical wires
WRO = 2.2;		// offset of wires below top motor surface

// Clock Properties
gear_diameter = 20.5;
minute_hand_shaft_diameter = 3.2;
hour_hand_shaft_diameter = 6;

// =========================================================
eps = 0.05;   // small number to avoid coincident faces

// Function to layout all parts
layout_all();

module layout_all() {
  color("Gray")
    facePlate();

  color("Goldenrod") translate([0, SBO, 3]) rotate([0,180,0])
    hour_hand_shaft();
    
  color("SaddleBrown") translate([0, SBO+gear_diameter, 0]) rotate([0,0,0 -360/20/2 *3 ]) 
    20_teeth_spur_gear();

  color("LightGray") translate([0, SBO, 6+3]) rotate([0,180,90])
    minute_hand_shaft();
    
  translate([0, 0, MBH/2 + 14]) rotate([0, 0, 90]) {
    StepMotor28BYJ();  // motor body (without wires)
  translate([0,0,-(MBH/2 - WRO)]) rotate([0,-90,0])  
      wires(); // 5 colored hookup wires
  }
  translate([0, SBO*2 + gear_diameter, MBH/2 + 11]) rotate([0,0,-90]) {
      StepMotor28BYJ();  // motor body (without wires)
  translate([0,0,-(MBH/2 - WRO)]) rotate([0,-90,0])  
        wires();  // 5 colored hookup wires
  }
  
  translate([0, SBO, -SHH+3]) rotate([0,0,90])
    hour_hand();
  translate([0, SBO, -SHH]) rotate([0,0,22.5])
    minute_hand(); 
}


module minute_hand() {
  adjust = 0.1;
  hand_length = 50;
  
  difference(){
    union() {
      cylinder(d=10,h=4);
      translate([0,-5,0])
        cube([hand_length,10,2]);
    }
    translate([0,0,4-3])
    cylinder(d=minute_hand_shaft_diameter + adjust, h=3);
  }
}

module hour_hand() {
  adjust = -0.1;
  hand_length = 45;
  
  difference() {
    union() {
      cylinder(d=10,h=4);
      translate([0,-5,0])
        cube([hand_length,10,2]);
    }
    cylinder(d=hour_hand_shaft_diameter-1, h=4+eps);
    translate([0,0,0.4])
    cylinder(d=hour_hand_shaft_diameter + adjust, h=4-0.4+eps);
  }
}


module minute_hand_shaft() {
  expand = 0.15;
  shaft_depth = 5;

  difference() {
    union() {
      cylinder(d=8.9, h=6);
        translate([0,0,6])
          cylinder(d=3.2, h=12.5);
    }
    translate([0,0,-eps]) {
      intersection() {
        cylinder(d=SHD+expand, h=shaft_depth, $fn=40);
        translate([0,0, shaft_depth/2])
          cube([SHDF+expand,SHHF+expand,shaft_depth],center=true);
      }
    }
  }
}

module hour_hand_shaft() {
  difference() {
    union() {
      spur_gear (modul=1, tooth_number=20, width=3, bore=0, pressure_angle=20, helix_angle=0, optimized=false);
        translate([0,0,3])
          cylinder(d=6, h=6.5);
    }
    translate([0,0,-eps])
      cylinder(d=3.5, h=10);
  }
}

module 20_teeth_spur_gear() {
  expand = 0.1;
  shaft_depth = 5;
  
  difference() {
    union(){
      spur_gear (modul=1, tooth_number=20, width=3, bore=0, pressure_angle=20, helix_angle=0, optimized=false);
      translate([0,0,3]) {
        cylinder(d=8.9, h=3.05);
      }
    }
    translate([0,0,6.05-shaft_depth+eps])
      rotate([0,0,360/20/2*93])
        intersection() {
          cylinder(d=SHD+expand, h=shaft_depth, $fn=40);
            translate([0,0, shaft_depth/2])
            cube([SHDF+expand,SHHF+expand,shaft_depth],center=true);
        }
  }
}

module facePlate() {
  $fn=100;

  width= 50;
  length = 50;
  depth = 2;

  difference() {
    // Base
    translate([-width/2,-6,-depth])  
      cube([width,length,depth]);
    
    // Hole for shaft
    translate([0,SBO,-30]){
      cylinder(h=65, d=6.4);
    } 
  }
  // Standoffs
  translate([-MHCC/2, 0, 0]) {
    difference() {
      cylinder(h=14, d=8.1);
      cylinder(h=14+1, d=3);
    }
  }
  translate([MHCC/2, 0, 0]) {
    difference() {
      cylinder(h=14, d=8.1);
      cylinder(h=14+1, d=3);
    }
  }
  translate([-MHCC/2, SBO*2 + gear_diameter, 0]) {
    difference() {  
      cylinder(h=11, d=8.1);
      cylinder(h=11+1, d=3);
    }
  }
  translate([MHCC/2, SBO*2 + gear_diameter, 0]) {
    difference() {
      cylinder(h=11, d=8.1);
      cylinder(h=11+1, d=3);
    }
  }
}

// 28BYJ-48 model by RGriffoGoes, www.thingiverse.com/thing:204734
module StepMotor28BYJ() {
  difference(){
    union(){
	   color("LightGray") translate([0,0,-(MBH+MBFH)/2])
		  difference() {  // flange at top rim
         cylinder(h = MBFH+eps, r = MBD/2, center = true, $fn = 50);
         cylinder(h = MBFH+2*eps, r = (MBD-MBFW)/2, center = true, $fn = 32);
			cube([MBFNW,MHCC,MBFH*2],center=true); // notches in rim
			cube([MBD+2*MBFW,SBD,MBFH*2],center=true);
		   translate([-MBD/2,0,0]) cube([MBD,MBFNW2,MBFH*2],center=true);
        }
		color("LightGray") // motor body
			cylinder(h = MBH, r = MBD/2, center = true, $fn = 100);
		color("LightGray") translate([SBO,0,-SBH])	// shaft boss
			cylinder(h = MBH, r = SBD/2, center = true, $fn = 32);

		translate([SBO,0,-SHH])	// motor shaft
      difference() {
        color("gold") cylinder(h = MBH, r = SHD/2, center = true, $fn = 32);
				// shaft flats
        translate([(SHD+SHDF)/2,0,-(eps+MBH-SHHF)/2]) 
				cube([SHD,SHD,SHHF], center = true);
        translate([-(SHD+SHDF)/2,0,-(eps+MBH-SHHF)/2]) 
				cube([SHD,SHD,SHHF], center = true);
      }

		color("Silver") translate([0,0,-(MBH-MTH-eps)/2]) // mounting tab 
			cube([MTW,MHCC,MTH], center = true);				
		color("Silver") translate([0,MHCC/2,-(MBH-MTH)/2]) // mt.tab rounded end
			cylinder(h = MTH, r = MTW/2, center = true, $fn = 32);
		color("Silver") translate([0,-MHCC/2,-(MBH-MTH)/2]) // mt.tab rounded end
			cylinder(h = MTH, r = MTW/2, center = true, $fn = 32);

		color("DeepSkyBlue") translate([-(WBD-MBD),0,eps-(MBH-WBH)/2]) // plastic wire box
			cube([MBD,WBW,WBH], center = true);
	   color("DeepSkyBlue") translate([-2,0,0])	
			cube([24.5,16,15], center = true);
		}

    // mounting holes in tabs on side
		translate([0,MHCC/2,-MBH/2])	
				cylinder(h = 2, r = 2, center = true, $fn = 32);
		translate([0,-MHCC/2,-MBH/2])	
				cylinder(h = 2, r = 2, center = true, $fn = 32);
		}
	}
module wires() {
  color("orange") translate([0,WRD*2,0]) cylinder(h=WRL,r=WRD/2, $fn = 7);
  color("yellow") translate([0,WRD*1,0]) cylinder(h=WRL,r=WRD/2, $fn = 7);   
  color("red") translate([0,0,0]) cylinder(h=WRL,r=WRD/2, $fn = 7);
  color("blue") translate([0,-WRD*1,0]) cylinder(h=WRL,r=WRD/2, $fn = 7);
  color("violet") translate([0,-WRD*2,0]) cylinder(h=WRL,r=WRD/2, $fn = 7);
}  