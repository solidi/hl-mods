last updated: January 4th, 1999

This ZIP file contains the source code to many of the tools Valve used to build the game Half-Life.  Most are derived from Quake 1 tools released by id Software (c).

BSPINFO: minor changes from the Quake1 original.

QCSG: added ability for textures to stay in WAD's, other minor changes from the Quake1 original.

QBSP2: minor changes from the Quake1 original.

VIS: minor changes from the Quake1 original.

QRAD: added 1/R*R light falloff, colored lighting, sun/sky illumination, automatic smoothing, and fixed minor bugs.  

QLUMPY: added support for paletted sprites.

MAKELS: reads a directory tree and automatically builds a script for qlumpy.

SMDLEXP: exports our intermediate model format (SMD) from 3DStudio Max 2.x and Character Studio 2.x (tm).  You'll need to get 3DStudio Max SDK as well as the Character Studio SDK in order to compile the program.  See http://www.ktx.com for more information.  Their SDK comes included with 3DStudio Max, so if you have MAX than you'll have everything you need.  If you don't have 3DStudio Max, then it doesn't really matter since without it this program is useless other than as a example of how to export to our intermediate format.

STUDIOMDL: highly modified version of the Quake1 modelgen. Added support for skeletons, events, multiple textures, tristrips, and other features.

MDLVIEWER: an OpenGL MDL viewer.  This program really doesn't do much, but it's included as an example of how to process the MDL files and how to do all the math required to have them draw correctly.  You can get the necessary GLUT include files and library files at http://www.opengl.org/Downloads/Downloads.html . From the ZIP file, extract glut.h into your equivalent \msdev6\vc98\Include\Gl directory, and the libs into \msdev6\vc98\Lib directory.

