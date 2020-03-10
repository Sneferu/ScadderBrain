/* Spur Gears */

include <common.scad>

/* Spur-Specific Helpers ---------------------------------------------------- */

TOOTH_GRANULARITY = 20;
DEFAULT_FN = 50;

// Generate involution of angle in rads
function involution(angle) = tan(rtod(angle)) - angle;

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

/* Involute Teeth ---------------------------------------------------------- */

// Generate the 2D profile of an involute tooth
module involute_tooth_profile(mod, number, pressure_angle, inner_radius){
    
   // ANSI B6.1 Spur Gear Standards
  pitch = pitch(mod);
  addendum = 1.000*mod;
  dedendum = 1.250*mod;
    
  // Tooth parameters
  r_pitch = number*mod/2;
  r_base = r_pitch*cos(pressure_angle);
  r_min = r_pitch - dedendum;
  r_max = r_pitch + addendum;
  a_pressure = dtor(pressure_angle);
  a_contact = pitch/(4 * r_pitch);
  a_base = a_contact + involution(a_pressure);
  a_top = dtor(acos(r_base/r_max));
  a_cutoff = a_top < 0 ? 0 : a_top;
  a_step_tooth = a_cutoff/TOOTH_GRANULARITY;
  a_undercut = pitch/(2 * r_pitch) - a_base;

  // Valley parameters
  a_bottom = pitch/(2 * r_pitch);
  a_valley = a_bottom - a_base;
  d_valley = 2 * sin(rtod(a_valley)) * r_base;
  r_valley_center = cos(rtod(a_valley)) * r_base;
  c_valley_center = cartesian2d([r_valley_center, rtod(a_bottom)]);
  r_bottom = r_valley_center - d_valley/2;
  a_step_valley = PI / (2 * TOOTH_GRANULARITY);
  
  // Generate valley shape
  valley_shape =
    [for (a = [0:TOOTH_GRANULARITY])
      c_valley_center + cartesian2d([d_valley/2,
                                     rtod(PI + a_bottom + a*a_step_valley)])
    ];
  
  // Generate tooth shape
  tooth_shape =
    [for (a = [0:TOOTH_GRANULARITY])
            cartesian2d([r_base/cos(rtod(a*a_step_tooth)),
                         rtod(a_base - involution(a*a_step_tooth))])
    ];

  // Draw
  total_shape = concat(
    [cartesian2d([inner_radius, 0]),
     cartesian2d([inner_radius, rtod(a_bottom)])
    ],
    valley_shape,
    tooth_shape,
    [[r_max, 0]]
  );
  polygon(total_shape);
  mirror([0, 1, 0]){
    polygon(total_shape);
  }
}

// Generate the teeth of an involute gear
module spur_teeth_involute(mod,
                           number,
                           thickness,
                           pressure_angle,
                           twist_angle,
                           inner_radius){
  twist = tan(twist_angle)*thickness/(number*mod/2);
  linear_extrude(height=thickness,
                 center=true,
                 twist=rtod(twist),
                 slices=thickness*10,
                 convexity=5){
    replicate_circular(count=number,
                       vec=[0, 0, 1]){
      involute_tooth_profile(mod=mod,
                            number=number,
                            pressure_angle=pressure_angle,
                            inner_radius=inner_radius);
    }
  }
}
                           
/* Solid Ring -------------------------------------------------------------- */

module spur_ring_solid(inner_radius,
                       outer_radius,
                       thickness,
                       $fn=DEFAULT_FN){
  solid_ring(inner_radius=inner_radius,
             outer_radius=outer_radius,
             thickness=thickness,
             $fn=$fn);
}

/* Solid Interior ---------------------------------------------------------- */

module spur_interior_solid(inner_radius,
                           outer_radius,
                           thickness,
                           $fn=DEFAULT_FN){
  solid_ring(inner_radius=inner_radius,
             outer_radius=outer_radius,
             thickness=thickness,
             $fn=$fn);
}

/* Spoked Interior --------------------------------------------------------- */

module spur_interior_spoked(inner_radius,
                            outer_radius,
                            thickness,
                            width,
                            number,
                            profile="rectangle",
                            angle=0){
  replicate_circular(count=number,
                     vec=[0, 0, 1]){
    translate([inner_radius, 0, 0])
      spoke(length=outer_radius - inner_radius,
            angle=angle){
        if (profile == "rectangle"){
          spoke_profile_rectangle([width, thickness]);
        } else if (profile == "cross") {
          spoke_profile_cross([width, thickness]);
        }
      }
  }
}

// Generates a spoke using its first child as the profile
module spoke(length, angle){
    
  if (angle == 0){
    translate([length/2, 0, 0]) rotate(a=90, v=[0, 1, 0]){
      linear_extrude(height=length, convexity=10, center=true){
        rotate(a=-90) children();
      }    
    }
  }else{
    radius = length/(2 * sin(angle/2));
    rotate(a=-angle) translate([-radius, 0, 0])
      rotate_extrude(angle=angle, convexity=10, $fn=DEFAULT_FN){
        translate([radius, 0, 0]) children();
      }
  }
}

module spoke_profile_rectangle(vec){
  square(vec, center=true);   
}

module spoke_profile_cross(vec){
  // TODO
  bar_thickness = (vec[0] + vec[1]) / 8;
  square([vec[0], bar_thickness], center=true);
  square([bar_thickness, vec[1]], center=true);
}

/* Swiss Interior ---------------------------------------------------------- */

// Note that this module is named after the cheese, not the watch gears
module spur_interior_swiss(inner_radius,
                           outer_radius,
                           thickness,
                           symmetry_group){
  angle = 360/symmetry_group;
  nthickness = thickness + 1; //Ensure no overlap
  difference(){
    solid_ring(inner_radius=inner_radius,
             outer_radius=outer_radius,
             thickness=thickness,
             $fn=$fn);
    replicate_circular(count=symmetry_group, vec=[0,0,1]){
      r_center_1 = inner_radius/2 + outer_radius/2;
      r_cutout_1 = r_center_1 * sin(angle/2) * 2/3;
      r_center_2 = inner_radius/4 + 3*outer_radius/4;
      r_cutout_2 = r_center_2 * sin(angle/6) * 2/3;
      union(){
        translate([r_center_1, 0, 0])
          cylinder(r=r_cutout_1, h=nthickness, center=true, $fn=DEFAULT_FN);
        rotate(a=angle/2, v=[0, 0, 1]) translate([r_center_2, 0, 0])
          cylinder(r=r_cutout_2, h=nthickness, center=true, $fn=DEFAULT_FN);
      }
    }
  }
}

/* Solid Neck -------------------------------------------------------------- */

module spur_neck_solid(bore,
                       outer_radius,
                       thickness,
                       $fn=DEFAULT_FN){
  solid_ring(inner_radius=bore,
             outer_radius=outer_radius,
             thickness=thickness,
             $fn=$fn);
}