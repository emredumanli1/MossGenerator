Moss Generation using Shell Texturing

This Unity project creates a moss-like surface generation technique using Shell Texturing with custom vertex and fragment shaders. The texture simulates the growth, structure, and movement of moss on any given 3D surface, offering parameters to adjust appearance and dynamics of the moss.


To create a  Moss texture, multiple mesh layers are rendered over the object, creating a volumetric moss illusion.

Adjustable Parameters that user can customize include:

Number of shells

Moss color and brightness

Shell length (height)

Alpha discard threshold

Noise density and variation

Wind direction and strength

Texture-based Variation: Moss pattern, color and density are controlled using alpha channels of adjustable noise textures.

References:
The script code for initializing shells is referenced from GarrettGunnell/Shell-Texturing (Github)



