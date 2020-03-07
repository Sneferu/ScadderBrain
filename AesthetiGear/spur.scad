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

translate([0,0,-50]){
  spur_teeth_involute(mod=2, number=30, thickness=5, pressure_angle=20,                  twist_angle=20, inner_radius=20);
  // Note the lack of other rings - this gear is very simple!
  spur_neck_solid(bore=2, outer_radius=21, thickness=5);
}
translate([0,0,-30]) color("red"){
  spur_neck_solid(bore=1.5, outer_radius=2.5, thickness=3);
  spur_interior_solid(inner_radius=2, outer_radius=19, thickness=0.5);
  spur_ring_solid(inner_radius=18, outer_radius=21, thickness=2);
  spur_teeth_involute(mod=1, number=50, thickness=1.5, pressure_angle=18,                  twist_angle=-10, inner_radius=20);
}
translate([0,0,-10]) color("blue"){
  spur_neck_solid(bore=1, outer_radius=1.5, thickness=1.5);
  spur_interior_solid(inner_radius=1.2, outer_radius=12, thickness=1);
  spur_ring_solid(inner_radius=12, outer_radius=14.5, thickness=1.5);
  spur_teeth_involute(mod=0.3, number=110, thickness=1, pressure_angle=25,                  twist_angle=20, inner_radius=14);
}
translate([0,0,10]) color("green"){
  spur_neck_solid(bore=1, outer_radius=1.2, thickness=1.3);
  spur_interior_solid(inner_radius=1.2, outer_radius=5.5, thickness=0.5);
  spur_ring_solid(inner_radius=5.5, outer_radius=6, thickness=1);
  spur_teeth_involute(mod=1, number=16, thickness=1, pressure_angle=20,                  twist_angle=20, inner_radius=6);
}
translate([0,0,30]){
  spur_neck_solid(bore=0.5, outer_radius=0.7, thickness=0.2);
  spur_interior_solid(inner_radius=0.7, outer_radius=2.5, thickness=0.1);
  spur_ring_solid(inner_radius=2.5, outer_radius=3, thickness=0.2);
  spur_teeth_involute(mod=1, number=8, thickness=0.2, pressure_angle=20,                  twist_angle=0, inner_radius=2);
};