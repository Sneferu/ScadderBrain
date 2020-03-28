/* ScrewIt Examples */

include <screw.scad>

/* X/Y translation constants ----------------------------------------------- */
SPUR_X = 0;
SPUR_Y = 0;

/* Basic Countersunk Screw ------------------------------------------------- */

translate([5, 0, 0]) color("grey"){
  translate([0,0,0])
    screw_head_countersunk(radius_top=0.5,
                           radius_bottom=0.25,
                           height=0.5,
                           profile_type="phillips",
                           profile_depth=0.2,
                           profile_bar_width=0.15,
                           profile_width=0.5);

  translate([0,0,-.5])
    screw_shank_standard(length=0.3,
                       radius=0.25);
  translate([0,0,-0.8])
    screw_thread_standard(tpi=10,
                          length=5,
                          pitch_radius=0.21,
                          major_radius=0.25,
                          minor_radius=0.17,
                          flank_angle=20,
                          point_length=0.4);
}
