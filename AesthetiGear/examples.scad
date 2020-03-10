/* AesthetiGear Examples */

include <spur.scad>

/* X/Y translation constants ----------------------------------------------- */
SPUR_X = 0;
SPUR_Y = 0;

/* Spur Gear Christmas Tree ------------------------------------------------ */

translate([SPUR_X, SPUR_Y, -40]) color("green"){
  spur_teeth_involute(mod=2, number=30, thickness=5, pressure_angle=20,                  twist_angle=20, inner_radius=20);
  // Note the lack of other rings - this gear is very simple!
  spur_neck_solid(bore=2, outer_radius=21, thickness=5);
}
translate([SPUR_X, SPUR_Y, -20]) color("red"){
  spur_neck_solid(bore=1.5, outer_radius=2.5, thickness=3);
  spur_interior_swiss(inner_radius=2, outer_radius=19, thickness=0.5,
                      symmetry_group=6);
  spur_ring_solid(inner_radius=18, outer_radius=21, thickness=2);
  spur_teeth_involute(mod=1, number=50, thickness=1.5, pressure_angle=18,                  twist_angle=-10, inner_radius=20);
}
translate([SPUR_X, SPUR_Y, 0]) color("blue"){
  spur_neck_solid(bore=1, outer_radius=2, thickness=1.5);
  spur_interior_spoked(inner_radius=1.2, outer_radius=16, thickness=1.5,
                       width=2, number=4, profile="cross", angle=70);
  spur_ring_solid(inner_radius=14.5, outer_radius=16, thickness=1.5);
  spur_teeth_involute(mod=0.3, number=110, thickness=1, pressure_angle=25,                  twist_angle=20, inner_radius=15);
}
translate([SPUR_X, SPUR_Y, 20]) color("green"){
  spur_neck_solid(bore=1, outer_radius=1.5, thickness=1.3);
  spur_interior_spoked(inner_radius=1, outer_radius=5.5, thickness=0.5,
                       width=1, number=6);
  spur_ring_solid(inner_radius=5.5, outer_radius=6, thickness=1);
  spur_teeth_involute(mod=1, number=16, thickness=1, pressure_angle=20,                  twist_angle=20, inner_radius=6);
}
translate([SPUR_X, SPUR_Y, 35]) rotate([0, 90, 0]) color("purple") {
  spur_neck_solid(bore=0.5, outer_radius=0.7, thickness=0.2);
  spur_interior_solid(inner_radius=0.7, outer_radius=2.5, thickness=0.1);
  spur_ring_solid(inner_radius=2.5, outer_radius=3, thickness=0.2);
  spur_teeth_involute(mod=1, number=8, thickness=0.2, pressure_angle=20,                  twist_angle=0, inner_radius=2);
};