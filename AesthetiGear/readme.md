### AesthetiGear

_Gears with Aesthetic._

# Purpose

AesthetiGear provides a simple and elegant method for creating gears in OpenSCAD.  It divides each gear into logical subcomponents, providing easy customization of each, and allowing the user to mix and extend various shaps for structure or appearance.

# Approach

Each type of gear consists of multiple components.  For instance, from outside in, spur gears consist of the Teeth, the Ring, the Interior, and the Neck.  Each one can be sized and customized, then all connected to form a finished gear.  A set of functional (if bland) defaults provide a quick and easy experience to the simple user, while nicer modules provide inspiration for the experimentalist.

The following list includes the gear types currently available, their component parts, and the implementations currently available for each:

1. Spur Gear
  * Neck
  * Interior
  * Ring
  * Teeth
2. Worm Gear
  * Neck
  * Spiral

# The Future

Future additions to this library include
* More gear types
* Compounds (such as planetary)
* Custom component divisions
