#pragma header

uniform vec4 frameUV;

uniform bool downscroll;
uniform bool isSustainNote;
uniform float songPosition;
uniform float curBeat;
uniform float scrollSpeed;
uniform float strumID;
uniform float strumLineID;

#pragma modifierUniforms

void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

	#pragma modifierFunctions

	gl_FragColor = color;
}