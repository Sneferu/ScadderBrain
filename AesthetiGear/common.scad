/* Common constants and helpers */

/* Universal constants ----------------------------------------------------- */
PI=3.14159;
DEFAULT_FN = 50;

/* Helper functions -------------------------------------------------------- */

// Repeat something 'count' times around a vector
module replicate_circular(count, vec){
  angle = 360/count;
  for(i = [0 : count - 1]){
    rotate(a=angle*i, v=vec) children(); 
  }
}

// Repeat something 'count' times along a vector
module replicate_linear(count, vec){
  for(i = [0 : count - 1]){
    translate(vec) children();
  }   
}

// Degrees to radians
function dtor(degrees) = PI*degrees/180;

// Radians to degrees
function rtod(radians) = 180*radians/PI;   

// Polar to cartesian
function cartesian2d(vec) = [vec[0]*cos(vec[1]), vec[0]*sin(vec[1])];
function cartesian3d(vec) = [vec[0]*cos(vec[1]), vec[0]*sin(vec[1]), vec[2]];

// Cartesian to polar
function polar2d(vec) = [len(vec), atan(vec[1], vec[0])];
function polar3d(vec) = [len(vec), atan(vec[1], vec[0]), vec[2]];

// Get pitch from mod
function pitch(mod) = PI*mod;

// Get mod from pitch
function mod(pitch) = pitch/PI;

// General solid ring
module solid_ring(inner_radius,
                  outer_radius,
                  thickness,
                  $fn=DEFAULT_FN){
  difference(){
    cylinder(r=outer_radius, h=thickness, center=true, $fn=$fn);
    cylinder(r=inner_radius, h=thickness+1, center=true, $fn=$fn);
  }
}