#pragma header

uniform bool isSustainNote;
uniform vec4 sustainFrameUV;

void main()
{
	/*if (isSustainNote)
	{
		vec4 col = vec4(0.0, 0.0, 0.0, 0.0);
		vec2 uv = openfl_TextureCoordv;

		float width = abs(sustainFrameUV.z - sustainFrameUV.x);

		//shrink the uv to leave extra space for curve
		uv.x -= sustainFrameUV.x+(width*0.5);
		uv.x *= 4.0;
		uv.x += sustainFrameUV.x+(width*0.5);

		//start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
		float yRemap = 0.0 + (uv.y - sustainFrameUV.y) * ((1.0 - 0.0) / (sustainFrameUV.w - sustainFrameUV.y));

		uv.x += sin(yRemap*3.0)*width;

		//p = (1-t)^2 *P0 + 2*(1-t)*t*P1 + t*t*P2

		//uv.x = ((1.0 - yRemap)*(1.0 - yRemap)) *


		if (uv.x >= sustainFrameUV.x && uv.y >= sustainFrameUV.y &&
			uv.x <= sustainFrameUV.z && uv.y <= sustainFrameUV.w)
		{
			col = flixel_texture2D(bitmap, uv);
		}
		gl_FragColor = col;
		return;
	}*/
	vec4 col = flixel_texture2D(bitmap, openfl_TextureCoordv);
	gl_FragColor = col;
}