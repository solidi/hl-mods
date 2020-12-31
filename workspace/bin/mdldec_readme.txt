=====================================================================

	Half-Life MDL Decompiler v1.2
	2003, Kratisto. Based on code from Valve's HL SDK.

	Comments/Suggestions/Bug reports: kratisto@yahoo.com

=====================================================================


Change log
==========

	1.2	-Added support for the new $texrendermode keyword.
		-Now $cliptotextures is always in QC scripts.
		-Now unnamed bones are given a name in the form
		 MDLDEC_Bone + n 
		-More warnings.
		-Fixed a memory leak.
		-Small changes and bug fixes.
		-Plugin code rewroted from scratch.

	1.01	-Changed name to "Half-Life MDL Decompiler" from
		 "UnMDL".
		-Small bug fixes.

	1.0	-First public release.


Description
===========

Decompilation tool for the MDL model files used by the Half-Life
game engine.

Creates *.smd files (meshes and animation sequences),
extracts textures in BMP format, and generates a QC script
that can be parsed by studiomdl.exe, Valve's MDL compiler,
to recompile the model.

You can use it as a standalone command line executable (mdldec.exe),
or as a tool plugin (msMDLDecompiler.dll) for the shareware 
low-polygon modeler MilkShape 3D (see http://www.milkshape3d.com).


Limitations
===========

When studiomdl.exe compiles a model, the original data is transformed
and optimized through the process, therefore, the files created by
the decompiler can't be 100% the same as the originals authored
by the modeller and animator.

Be aware of small misplacements in texture coordinates, and
other subtle numeric rounding errors due to the 3D math
involved during the compilation and decompilation of models. 

=====================================================================

