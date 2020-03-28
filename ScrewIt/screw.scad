/* Screws */

include <../common/common.scad>

/* Screw Specific Helpers --------------------------------------------------- */

module profile_flat_head(width,
                       depth,
                       bar_width){
  cube([width, bar_width, depth], center=true);
}

module profile_phillips_head(width,
                            depth,
                            bar_width){
  profile_flat_head(width=width, depth=depth, bar_width=bar_width);
  rotate([0, 0, 90])
    profile_flat_head(width=width, depth=depth, bar_width=bar_width);
}

/* Standard Thread --------------------------------------------------------- */

// Generate the 2D profile of a thread
module thread_profile(pitch, pitch_radius,
                     major_radius, minor_radius,
                     flank_angle){
                         
  // Thread parameters
  pitch_offset = (pitch/4)/tan(flank_angle);
  thread_top = min(pitch_radius + pitch_offset, major_radius);
  thread_bottom = max(pitch_radius - pitch_offset, minor_radius);
  top_offset = thread_top - pitch_radius;
  bottom_offset = pitch_radius - thread_bottom;
  top_width = 2*max((pitch_offset - top_offset)*tan(flank_angle), 0);
  bottom_width = 2*max((pitch_offset - bottom_offset)*tan(flank_angle), 0);
  
  // Rotational parameters
  slope_width = (pitch - (top_width + bottom_width))/2;
  bottom_start = 0;
  bottom_steps = round(DEFAULT_FN * bottom_width/pitch) + 1;
  ascent_start = bottom_steps;
  ascent_steps = round(DEFAULT_FN * slope_width/pitch) + 1;
  ascent_taper = (top_offset + bottom_offset)/ascent_steps;
  top_start = ascent_start + ascent_steps;
  top_steps = round(DEFAULT_FN * bottom_width/pitch) + 1;
  descent_start = top_start + top_steps;
  descent_steps = ascent_steps; // Dictated by symmetry
  descent_taper = ascent_taper;
  step_angle = 360 / (bottom_steps + top_steps + 2*ascent_steps);
  
  // Generate portion shapes
  bottom_shape =
    [for (a = [0:bottom_steps - 1])
      cartesian2d([thread_bottom, a * step_angle])
    ];
  ascent_shape =
    [for (a = [0:ascent_steps - 1])
      cartesian2d([thread_bottom + a*ascent_taper,
                   (ascent_start + a) * step_angle])
    ];
  top_shape =
    [for (a = [0:top_steps - 1])
      cartesian2d([thread_top, (top_start + a) * step_angle])
    ];
  descent_shape =
    [for (a = [0:descent_steps - 1])
      cartesian2d([thread_top - a*descent_taper,
                   (descent_start + a) * step_angle])
    ];

  // Draw overall thread shape
  thread_shape = concat(bottom_shape,
                        ascent_shape,
                        top_shape,
                        descent_shape);
  polygon(thread_shape);
}

// Standard Thread (Metric Convention)
module screw_thread_metric(pitch,
                           length,
                           pitch_radius,
                           major_radius,
                           minor_radius,
                           flank_angle,
                           point_length=0){

  length_eff = length - point_length;
  twist = -360 * length_eff/pitch;
  translate([0, 0, -length_eff/2])
    linear_extrude(height=length_eff,
                   center=true,
                   twist=twist,
                   slices=DEFAULT_FN*length_eff/pitch,
                   convexity=10)
      thread_profile(pitch=pitch,
                    pitch_radius=pitch_radius,
                    major_radius=major_radius,
                    minor_radius=minor_radius,
                    flank_angle=flank_angle);
  translate([0, 0, -(length_eff + point_length/2)]){
    cylinder(h=point_length,
             r1=0,
             r2=minor_radius,
             center=true,
             $fn=DEFAULT_FN);
  }
}

// Standard Thread (American Convention)
module screw_thread_standard(tpi, /* Threads Per Inch */
                             length,
                             pitch_radius,
                             major_radius,
                             minor_radius,
                             flank_angle,
                             point_length=0){
  screw_thread_metric(pitch=1/tpi,
                      length=length,
                      pitch_radius=pitch_radius,
                      major_radius=major_radius,
                      minor_radius=minor_radius,
                      flank_angle=flank_angle,
                      point_length=point_length);
}

/* Standard Shank ---------------------------------------------------------- */

module screw_shank_standard(length,
                            radius){
  translate([0, 0, -length/2])
    cylinder(h=length,
             r=radius,
             center=true,
             $fn=DEFAULT_FN);
}

/* Countersunk Head -------------------------------------------------------- */

module screw_head_countersunk(radius_top,
                              radius_bottom,
                              height,
                              profile_type="none",
                              profile_width=0,
                              profile_depth=0,
                              profile_bar_width=0){
  difference(){
    translate([0, 0, -height/2])
      cylinder(r1=radius_bottom,
               r2=radius_top,
               h=height,
               center=true,
               $fn=DEFAULT_FN);
    {
      if(profile_type == "phillips"){
        profile_phillips_head(width=profile_width,
                             bar_width=profile_bar_width,
                             depth=profile_depth*2);
      } else if(profile_type == "flat"){
        profile_flat_head(width=profile_width,
                        bar_width=profile_bar_width,
                        depth=profile_depth*2);
      }
    }
  }
}