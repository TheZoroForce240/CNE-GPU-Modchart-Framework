//Modchart template for the GPU modchart framework

function postCreate()
{
	//import the script first
	importScript("data/scripts/modchartManager.hx");

	//setup your own modifiers and events
	setupModifiers();
	setupEvents();

	//then initialize the modchart to generate the shaders
	initModchart();
}

function setupModifiers()
{
	createModifier(
		"x", //modifier name 
		0,   //starting value
			//shader code (glsl)
		"
			//add value onto x position
			//value is always NAME_value (please dont put spaces in the name it wont work)
			x += x_value;
		",
		-1, //strumline ID (-1 = all, 0 = dad, 1 = bf, 2 = gf, etc) 									(defaults to -1)
		-1, //strum ID (0 = left, 1 = down, 2 = up, 3 = right) 											(defaults to -1)
		0.0, //default value, if the value equals this then the modifier will auto disable, if enabled 	(defaults to 0.0)
		true, //auto disable																			(defaults to true)
		MOD_TYPE_NOTE //modifier type, either MOD_TYPE_NOTE or MOD_TYPE_CUSTOM							(defaults to MOD_TYPE_NOTE)
			//MOD_TYPE_NOTE is the default type and will use glsl shader code as the function
			//MOD_TYPE_CUSTOM can be used to call a custom function each frame, which can be useful for things like camera modifiers
	);

	//Guide to writing modifier code:
	//
	//these are written in glsl NOT haxe
	//the syntax is similar but closer to c++
	//remember to ALWAYS put .0 on every float that doesnt already have a decimal, otherwise the shader may not work on certain GPUs!
	//
	//modifier variable list:
	//	x				- X position
	//	y				- Y position
	//	z				- Z position (left handed, z+ is forward, i think?)
	//	a				- This is the alpha of the note (cant call it "alpha" so its just "a")
	//	curPos			- Time in milliseconds of how close a note is to the strumLine, strums are always 0, which can be used to check for strums
	//			  		  this value can be manipulated to change where the note will appear, or be used to affect other values based on the position of the note
	//  angleX  		- Rotation of the note in the X Axis
	//  angleY  		- Rotation of the note in the Y Axis
	//  angleZ  		- Rotation of the note in the Z Axis (this is the same as regular angle in flixel)
	//  scaleX  		- Scale of the note in the X Axis
	//  scaleY  		- Scale of the note in the Y Axis
	//  incomingAngleX 	- Rotates the direction at which notes will come from on the X Axis
	//  incomingAngleX 	- Rotates the direction at which notes will come from on the Y Axis
	//  incomingAngleX 	- Rotates the direction at which notes will come from on the Z Axis

	//extra variables you can access but not change
	//
	//strumID			- the arrow direction of the note (0 = left, 1 = down, 2 = up, 3 = right)
	//strumLineID		- the strumline of the note (0 = dad, 1 = bf, 2 = gf, etc)
	//songPosition		- same as Conductor.songPosition
	//curBeat			- same as Conductor.curBeatFloat
	//downscroll		- check for if you're using downscroll, you shouldn't need this but it can be used if you want
	//isSustainNote		- check for if a note is a sustain
	//vertexID			- ID for which corner of the sprite that the shader is currently processing, (0 = Top Left, 1 = Top Right, 2 = Bottom Left, 3 = Bottom Right)

	//strumID, strumLineID and vertexID are stored as floats so dont worry about converting them



	createModifier("y", 0, "
		y -= y_value;
	");

	createModifier("z", 0, "
		z += z_value;
	");

	createModifier("angleX", 0, "
		angleX += angleX_value;
	");

	createModifier("angleY", 0, "
		angleY += angleY_value;
	");

	createModifier("angleZ", 0, "
		angleZ += angleZ_value;
	");

	createModifier("scaleX", 1.0, "
		scaleX *= scaleX_value;
	", -1, -1, 1.0);

	createModifier("scaleY", 1.0, "
		scaleY *= scaleY_value;
	", -1, -1, 1.0);

	//create an xyz modifier for each strum
	for (i in 0...4)
	{
		//strumline 0
		createModifier("x"+i, 0, "
			x += x"+(i)+"_value;
		", 0, i);

		//strumline 1
		createModifier("x"+(i+4), 0, "
			x += x"+(i+4)+"_value;
		", 1, i);

		createModifier("y"+i, 0, "
			y += y"+(i)+"_value;
		", 0, i);
		createModifier("y"+(i+4), 0, "
			y += y"+(i+4)+"_value;
		", 1, i);

		createModifier("z"+i, 0, "
			z += z"+(i)+"_value;
		", 0, i);
		createModifier("z"+(i+4), 0, "
			z += z"+(i+4)+"_value;
		", 1, i);
	}

	createModifier("flip", 0, "
		float newPos = 4.0 + (strumID - 0.0) * ((-4.0 - 4.0) / (4.0 - 0.0));
		x += (112.0 * newPos * flip_value) - (112.0 * flip_value);
	");

	createModifier("invert", 0, "
		if (mod(strumID, 2.0) == 0.0)
		{
			x += (112.0 * invert_value);
		}
		else
		{
			x -= (112.0 * invert_value);
		}
	");


	createModifier("beat", 0.0, "
		float fAccelTime = 0.2;
		float fTotalTime = 0.5;
		float fBeat = curBeat + fAccelTime;

		if (fBeat >= 0.0)
		{
			float evenBeat = mod(floor(fBeat), 2.0);

			fBeat -= floor(fBeat);
			fBeat += 1.0;
			fBeat -= floor(fBeat);

			if (fBeat < fTotalTime)
			{
				float fAmount = 0.0;
				if( fBeat < fAccelTime )
				{
					fAmount = 0.0 + (fBeat - 0.0) * ((1.0 - 0.0) / (fAccelTime - 0.0));
					fAmount *= fAmount;
				}
				else
				{
					fAmount = 1.0 + (fBeat - fAccelTime) * ((0.0 - 1.0) / (fTotalTime - fAccelTime));
					fAmount = 1.0 - (1.0 - fAmount) * (1.0 - fAmount);
				}

				if (evenBeat != 0.0)
					fAmount *= -1.0;

				x += 20.0 * fAmount * sin((curPos * 0.01) + (PI * 0.5)) * beat_value;
			}
		}
	");

	createModifier("speed", 1.0, "
		curPos *= speed_value;
	", -1, -1, 1.0);


	//use drunkSpeed as a subvalue
	createModifier("drunkSpeed", 1.0, "", -1, -1, 0.0, false);
	createModifier("drunk", 0.0, "
		x += cos(((songPosition*0.001) + (strumID*0.2) + 
			(curPos*0.45)*0.013) * (drunkSpeed_value*0.2)) * 112.0*0.5 * drunk_value;
	");


	createModifier("tipsySpeed", 1.0, "", -1, -1, 0.0, false);
	createModifier("tipsy", 0.0, "
		y += cos(songPosition*0.001 * (1.2) + 
			(strumID)*(2.0) + tipsySpeed_value*(0.2) ) * 112.0*0.4 * tipsy_value;
	");

	createModifier("reverse", 0.0, "
		curPos *= (1.0-(reverse_value*2.0));
		y -= 520.0 * reverse_value;
	");

	createModifier("brake", 0.0, "
		float yOffset = 0.0;

		float fYOffset = -curPos;
		float fEffectHeight = 1280.0;
		float fScale = 0.0 + (fYOffset - 0.0) * ((1.0 - 0.0) / (fEffectHeight - 0.0)); //scale
		float fNewYOffset = fYOffset * fScale; 
		float fBrakeYAdjust = brake_value * (fNewYOffset - fYOffset);
		fBrakeYAdjust = clamp( fBrakeYAdjust, -400.0, 400.0 ); //clamp
		
		yOffset -= fBrakeYAdjust;

		curPos += yOffset;
	");

	createModifier("boost", 0.0, "
		float yOffset = 0.0;

		float fYOffset = -curPos;
		float fEffectHeight = 150.0;
		float fNewYOffset = fYOffset * 1.5 / ((fYOffset+fEffectHeight/1.2)/fEffectHeight);
		float fBrakeYAdjust = boost_value * (fNewYOffset - fYOffset);
		fBrakeYAdjust = clamp( fBrakeYAdjust, -400.0, 400.0 ); //clamp
		
		yOffset -= fBrakeYAdjust;

		curPos += yOffset;
	");

	createModifier("incomingAngleX", 0.0, "incomingAngleX += incomingAngleX_value;");
	createModifier("incomingAngleY", 0.0, "incomingAngleY += incomingAngleY_value;");
	createModifier("incomingAngleZ", 0.0, "incomingAngleZ += incomingAngleZ_value;");

	//custom modifier that can call a function instead of using shader code
	//the function will be called every frame before updating the notes
	//these types of modifiers can be useful for the 3D Camera and Camera filters/post processes
	//but you can put literally anything you want in here
	createModifier("camera3DEyeX", 0, function(mod)
	{
		eye[0] = mod[MOD_VALUE]; //use mod[MOD_VALUE] to get the current value
	}, -1, -1, 0.0, false, MOD_TYPE_CUSTOM);

	createModifier("camera3DEyeY", 0, function(mod)
	{
		eye[1] = mod[MOD_VALUE];
	}, -1, -1, 0.0, false, MOD_TYPE_CUSTOM);

	createModifier("camera3DEyeZ", -0.71, function(mod) //need to use -0.71 to look accurate to default camera
	{
		eye[2] = mod[MOD_VALUE];
	}, -1, -1, 0.0, false, MOD_TYPE_CUSTOM);

	createModifier("flash", 0.0, "
		color.rgb = mix(color.rgb, vec3(1.0, 1.0, 1.0), flash_value) * color.a;
	", -1, -1, 0.0, true, MOD_TYPE_FRAG);
}

function setupEvents()
{
	/*
		ease(
			4, //beat that it plays at (check curBeat in charter, or do curStep/4 )
			1, //length of ease in beats
			'cubeOut', //easing function to use (check: https://api.haxeflixel.com/flixel/tweens/FlxEase.html, https://easings.net/)
		//modifiers to tween (you can add as many as you want in the same event)
		//	value, name,
		"
			260, y,
			1.0, speed,
			360, angleZ
		");
	*/
}