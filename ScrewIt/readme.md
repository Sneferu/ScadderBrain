### AesthetiGear

_Bolts. Washers. Screws. It._

# Purpose

ScrewIt provides a simple and modular method for creating screws in OpenSCAD.  It divides each screw into logical subcomponents, providing easy customization of each, and allowing the user to mix and extend various shaps for structure or appearance.  Alongside these screws, it provides nuts, bolts, washers, and other accessories.

# Approach

Each type of screw consists of three components: a head, a shank, and a thread.  Each one can be sized and customized, then all connected to form a finished screw.  A set of functional defaults provide working 
Each type of gear consists of multiple components.  For instance, from outside in, spur gears consist of the Teeth, the Ring, the Interior, and the Neck.  Each one can be sized and customized, then all connected to form a finished gear.

Bolts follow the same division as screws, while washers are simpler, consisting of only a disc.  Nuts consist of a thread (inverted from the equivalent screw), an edge, and a head.

# The Future

Future additions to this library include
* More edge/head types
* Premade, standard screw sizes
* Better support for allowances (right now just look it up or - for an adventure - eyeball it.
