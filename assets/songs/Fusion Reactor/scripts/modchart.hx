
//example of what a full modchart could look like



//for reference
//public function createModifier(name:String, value:Float, func:Dynamic->Void, strumLineID:Int = -1, strumID = -1, defaultValue:Float = 0.0, autoDisable = true, MOD_TYPE:Int = 0)
//public function ease(beat:Float, timeInBeats:Float, easeName:String, data:String)

var beatsScaleX = [18,21.5,23,26,29.5];
var beatsScaleY = [16,19.5,20.5,22.5,24,27.5,28.5];


function postCreate()
{
	importScript("data/scripts/modchartManager.hx");

	setupModifiers();
	setupEvents();

	initModchart();
}




function setupModifiers()
{
	//custom modifier that gets called every frame
	createModifier("eyeRot", 0, function(mod)
	{
		var ang = mod[MOD_VALUE] * Math.sin(Conductor.curBeatFloat*0.5);
		eye[0] = Math.sin(ang) * 0.71;
		eye[1] = mod[MOD_VALUE] * Math.sin(Conductor.curBeatFloat*0.25) * 0.71;
		eye[2] = -Math.cos(ang) * 0.71;
	}, -1, -1, 0.0, false, MOD_TYPE_CUSTOM);

	//gpu note modifiers
	createModifier("z", 0, "
		z -= z_value * 0.75;
	");
	
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

	for (i in 0...4)
	{
		createModifier("z"+i, 0, "
			z -= z"+(i)+"_value * 0.75;
		", 0, i);
		createModifier("z"+(i+4), 0, "
			z -= z"+(i+4)+"_value * 0.75;
		", 1, i);

		createModifier("x"+i, 0, "
			x += x"+(i)+"_value;
		", 0, i);
		createModifier("x"+(i+4), 0, "
			x += x"+(i+4)+"_value;
		", 1, i);
	}

	createModifier("x", 0, "
		x += x_value;
	");

	createModifier("y", 0, "
		y -= y_value;
	");

	createModifier("xP1", 0, "
		x += xP1_value;
	", 1);

	createModifier("xP2", 0, "
		x += xP2_value;
	", 0);

	createModifier("speed", 0.7, "
		curPos *= speed_value;
	", -1, -1, 1.0);


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

	createModifier("beatYP1", 0.0, "
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

				y += 20.0 * fAmount * sin((curPos * 0.01) + (PI * 0.5)) * beatYP1_value;
			}
		}
	", 1);


	createModifier("beatYP2", 0.0, "
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

				y += 20.0 * fAmount * sin((curPos * 0.01) + (PI * 0.5)) * beatYP2_value;
			}
		}
	", 0);


	createModifier("drunk", 0.0, "
		x += cos(((songPosition*0.001) + (strumID*0.2) + 
			(curPos*0.45)*0.013) * (10.0*0.2)) * 112.0*0.5 * drunk_value;
	");

	createModifier("drunkP1", 0.0, "
		x += cos(((songPosition*0.001) + (strumID*0.2) + 
			(curPos*0.45)*0.013) * (2.0*0.2)) * 112.0*0.5 * drunkP1_value;
	", 1);

	createModifier("drunkP2", 0.0, "
		x += cos(((songPosition*0.001) + (strumID*0.2) + 
			(curPos*0.45)*0.013) * (2.0*0.2)) * 112.0*0.5 * drunkP2_value;
	", 0);

	createModifier("tipsy", 0.0, "
		y += cos(songPosition*0.001 * (1.2) + 
			(strumID)*(2.0) + 2.0*(0.2) ) * 112.0*0.4 * tipsy_value;
	");

	createModifier("reverseP1", 0.0, "
		curPos *= (1.0-(reverseP1_value*2.0));
		y -= 520.0 * reverseP1_value;
	", 1);

	createModifier("reverseP2", 0.0, "
		curPos *= (1.0-(reverseP2_value*2.0));
		y -= 520.0 * reverseP2_value;
	", 0);

	createModifier("brake", 0.4, "
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

	//the axes were not correct on the original system but the modifier names are the same
	createModifier("incomingAngleX", 90.0, "incomingAngleY -= incomingAngleX_value;");
	createModifier("incomingAngleY", 0.0, "incomingAngleZ += incomingAngleY_value;");

	createModifier("InvertIncomingAngle", 0.0, "
		if (mod(strumID, 2.0) == 0.0)
		{
			incomingAngleZ -= InvertIncomingAngle_value + (curPos * 0.015);
		}
		else
		{
			incomingAngleZ += InvertIncomingAngle_value + (curPos * 0.015);
		}
	");

	createModifier("IncomingAngleSmooth", 0.0, "
		incomingAngleZ -= IncomingAngleSmooth_value + (curPos * 0.015);
	");

	createModifier("IncomingAngleCurve", 0.0, "
		incomingAngleZ -= IncomingAngleCurve_value * (curPos * 0.015);
	");

	createModifier("MoveYWaveShit", 0.0, "
		y += 260.0*sin(((songPosition+curPos)*0.0008)+(strumID / 4.0)) * MoveYWaveShit_value;
	");

	createModifier("alpha", 0, "
		a *= (0.0 - alpha_value) + 1.0;
	");

	createModifier("opponentAlpha", 0, "
		a *= (0.0 - opponentAlpha_value) + 1.0;
	", 0);


	createModifier("confusion", 0, "
		angleY += confusion_value;
	");

	createModifier("scaleX", 1.0, "
		scaleX *= scaleX_value;
	", -1, -1, 1.0);

	createModifier("scaleY", 1.0, "
		scaleY *= scaleY_value;
	", -1, -1, 1.0);
}

function setupEvents()
{
	ease(31, 1, 'cubeInOut', "
		0, brake,
		0.75, speed,
		1.5, beatYP1,
		-1.5, beatYP2,
		-300, z,
	");

	ease(64, 1, 'cubeInOut', "
		-320, xP1,
		320, xP2,
		1, reverseP2,
		0.7, opponentAlpha
	");

	for (i in 8...24)
	{
		ease(i*4, 2, 'circIn', "
			20, InvertIncomingAngle
		");
		ease((i*4)+2, 2, 'circOut', "
			-20, InvertIncomingAngle
		");
		if (i >= 16)
		{
			if (i % 2 == 1)
			{
				ease(i*4, 4, 'circInOut', "
					30, incomingAngleX,
					100, z0,
					50, z1,
					-50, z2,
					-100, z3,
					100, z4,
					50, z5,
					-50, z6,
					-100, z7,
				");
			}
			else
			{
				ease(i*4, 4, 'circInOut', "
					-30, incomingAngleX,
					-100, z0,
					-50, z1,
					50, z2,
					100, z3,
					-100, z4,
					-50, z5,
					50, z6,
					100, z7,
				");
			}
		}

		if (i % 2 == 1)
		{
			ease((i*4)+3, 1, 'circIn', "
				0, confusion
			");
		}
		else
		{
			ease(i*4, 1, 'circOut', "
				360, confusion
			");
		}
	}

	ease(24*4, 1, 'cubeInOut', "
		0, InvertIncomingAngle,
		30, IncomingAngleSmooth,
	");


	for (i in 24...32)
	{
		if (i % 2 == 1)
		{
			ease(i*4, 4, 'circInOut', "
				15, incomingAngleX,
				50, z0,
				25, z1,
				-25, z2,
				-50, z3,
				50, z4,
				25, z5,
				-25, z6,
				-50, z7,
			");

			ease(i*4, 2, 'cubeInOut', "
				0, reverseP1,
				1, reverseP2
			");
		}
		else
		{
			ease(i*4, 4, 'circInOut', "
				-15, incomingAngleX,
				-50, z0,
				-25, z1,
				25, z2,
				50, z3,
				-50, z4,
				-25, z5,
				25, z6,
				50, z7,
			");

			ease((i*4), 2, 'cubeInOut', "
				1, reverseP1,
				0, reverseP2
			");
		}


		if (i % 4 == 2)
		{
			ease(i*4, 2, 'cubeInOut', "
				30, IncomingAngleSmooth,
			");
		}
		else if (i % 4 == 0)
		{
			ease(i*4, 2, 'cubeInOut', "
				-30, IncomingAngleSmooth,
			");
		}

		if (i % 4 != 3)
		{
			ease((i*4)+1.5, 1, 'circInOut', "
				-360, confusion
			");
		}
		else
		{
			ease(i*4, 1, 'circOut', "
				360, confusion
			");
			ease((i*4)+3, 1, 'circIn', "
				0, confusion
			");
		}
	}


	ease(128, 1, 'cubeInOut', "
		0, z0,
		0, z1,
		0, z2,
		0, z3,
		-600, z4,
		-600, z5,
		-600, z6,
		-600, z7,
		0, reverseP1,
		0, reverseP2,
		0, InvertIncomingAngle,
		90, incomingAngleX,
		0, IncomingAngleSmooth,
		0, beatYP1,
		0, beatYP2,
		-200, z,
		1, boost,
		-100, x0,
		-50, x1,
		50, x2,
		100, x3,
		-100, x4,
		-50, x5,
		50, x6,
		100, x7,
		360, confusion,
		1.2, tipsy,
		2, tipsy:speed,
		1.2, drunkP1,
		-1.2, drunkP2,
		1.5, drunkP1:speed,
		1.5, drunkP2:speed,
	");

	ease(158, 1, 'cubeInOut', "
		-600, z0,
		-600, z1,
		-600, z2,
		-600, z3,
		0, z4,
		0, z5,
		0, z6,
		0, z7,
		-360, confusion
	");

	ease(191, 1, 'cubeInOut', "
		0, z0,
		0, z1,
		0, z2,
		0, z3,
		-600, z4,
		-600, z5,
		-600, z6,
		-600, z7,
		360, confusion,
		0.5, tipsy,
		1, tipsy:speed,
		0.6, drunkP1,
		-0.6, drunkP2,
		0.6, drunkP1:speed,
		0.6, drunkP2:speed,
	");

	ease(218, 1, 'cubeInOut', "
		-600, z0,
		-600, z1,
		-600, z2,
		-600, z3,
		0, z4,
		0, z5,
		0, z6,
		0, z7,
		-360, confusion
	");


	for (i in 0...8)
	{
		var beat = 196+(7*i);
		ease(beat, 0.5, 'backInOut', "
			1.5, invert,
		");
		ease(beat+(1.5), 0.5, 'backInOut', "
			0, invert,
			2, flip,
		");
		if (i != 7)
		{
			ease(beat+(3), 0.5, 'backInOut', "
				0, flip,
			");
		}

	}
		
	set(248.5,"
		1, alpha
	");

	set(250, "
		0, z0,
		0, z1,
		0, z2,
		0, z3,
		0, z4,
		0, z5,
		0, z6,
		0, z7,
		0, tipsy,
		0, drunkP1,
		0, drunkP2,
		0, flip,
		0, boost
	");



	ease(254, 2, 'cubeInOut', "
		0, alpha,
		360, confusion
	");

		
	ease(256, 1, 'cubeInOut', "
		0.6, speed,
		0, PF1Alpha,
		0, PF2Alpha,
		260, y,
		0.5, eyeRot,
		2.5, beatYP1,
		2.5, beatYP2,
	");



	for (i in 0...8)
	{
		var beat = 256+(8*i);
		ease(beat+2, 4, 'backInOut', "
			180, incomingAngleY,
			-360, confusion,
		");
		set(beat+2, "
			0, PF1Alpha,
			0, PF2Alpha,
			-180, incomingAngleY,
		");
		ease(beat+6, 4, 'backInOut', "
			0, incomingAngleY,
			360, confusion,
		");
	}

	for (i in 0...2)
	{
		var beat = 256+(32*i);

		ease(beat+2, 2, 'cubeInOut', "
			-0.5, eyeX,
		");

		ease(beat+6, 1, 'cubeInOut', "
			0.0, eyeX,
			0.5, eyeY,
		");
		ease(beat+7, 1, 'cubeInOut', "
			-0.5, eyeY,
		");

		ease(beat+2+8, 2, 'cubeInOut', "
			0.5, eyeX,
			0.0, eyeY,
		");


		ease(beat+5+8, 1, 'cubeInOut', "
			0.0, eyeX,
			0.5, eyeY,
		");
		ease(beat+6+8, 1, 'cubeInOut', "
			-0.5, eyeX,
			-0.5, eyeY,
		");
		ease(beat+7+8, 1, 'cubeInOut', "
			0.5, eyeX,
			0.0, eyeY,
		");

		ease(beat+2+16, 2, 'cubeInOut', "
		-0.5, eyeX,
		");

		ease(beat+6+16, 1, 'cubeInOut', "
			0.0, eyeX,
			0.5, eyeY,
		");
		ease(beat+7+16, 1, 'cubeInOut', "
			-0.5, eyeY,
		");


		ease(beat+2+24, 2, 'cubeInOut', "
			0.5, eyeX,
			0.0, eyeY,
		");


		ease(beat+6.5+24, 1, 'cubeInOut', "
			0.0, eyeX,
			0.0, eyeY,
		");
	}


	ease(334, 14, 'linear', "
		-720, incomingAngleY,
		-720, confusion,
	");


	ease(352, 1, 'cubeInOut', "
		0.0, eyeRot,
		0.7, speed,
		1, PF1Alpha,
		1, PF2Alpha,
		0, z,
		90, incomingAngleY,
		1, MoveYWaveShit,
		0, beatYP1,
		0, beatYP2,
		0.7, opponentAlpha,
		1.6, speed,
		1.5, beat,
	");

	ease(416, 4, 'cubeInOut', "
		0, MoveYWaveShit,
		0, y,
		0.7, speed,
		0, incomingAngleY,
		0.5, tipsy,
		0.6, drunkP1,
		-0.6, drunkP2,
		1, boost,
		-300, z,
		1, IncomingAngleSmooth,
		0, beat,
	");


	for (i in 0...8)
	{
		var beat = 420+(7*i);
		ease(beat, 0.5, 'backInOut', "
			1.5, invert,
		");
		ease(beat+(1.5), 0.5, 'backInOut', "
			0, invert,
			2, flip,
		");
		if (i != 7)
		{
			ease(beat+(3), 0.5, 'backInOut', "
				0, flip,
			");
		}
	}

	set(472.5,"
		1, alpha
	");

	ease(478, 2, 'cubeInOut', "
		0, alpha,
		360, confusion,
		0, flip,
		260, y,
		0.5, eyeRot,
		2, beat,
	");

	ease(567, 1, 'cubeInOut', "
		0, beat,
		
	");


	for (i in 0...8)
	{
		var beat = 480+(8*i);
		ease(beat+2, 4, 'backInOut', "
			180, incomingAngleY,
			-360, confusion,
		");
		set(beat+2, "
			0, PF1Alpha,
			0, PF2Alpha,
			-180, incomingAngleY,
		");
		ease(beat+6, 4, 'backInOut', "
			0, incomingAngleY,
			360, confusion,
		");
	}





	ease(560, 16, 'linear', "
		0, tipsy,
		0, drunkP1,
		0, drunkP2,
		0.0, eyeRot,
		0, y,
		0, x0,
		0, x1,
		0, x2,
		0, x3,
		0, x4,
		0, x5,
		0, x6,
		0, x7,
	");

	ease(568, 8, 'cubeInOut', "
		0, z,
	");


	ease(576, 4, 'linear', "
		360, incomingAngleY,
		7, IncomingAngleCurve
	");
	ease(585, 3, 'expoOut', "
		1, alpha
	");


	for (shit in beatsScaleX)
	{
		set(shit-0.001, "
			1.5, scaleX
		");
		ease(shit, 1, 'expoOut', "
			1, scaleX
		");
	}
	for (shit in beatsScaleY)
		{
			set(shit-0.001, "
				1.5, scaleX
			");
			ease(shit, 1, 'expoOut', "
				1, scaleX
			");
		}


	for (i in 8...32) 
		setupBeatShit(i);
	for (i in 32...48)  
	{
		var beat = (i*4);
		set(beat-0.001+2, "
			1.5, scaleX,
			2, drunk
		");
		ease(beat+2, 0.5, 'cubeOut', "
			1, scaleX,
			0, drunk
		");
	}

	for (i in 48...62) 
		setupBeatShit(i);
	for (i in 64...80) 
		setupBeatShit(i);
	for (i in 88...118) 
		setupBeatShit(i);
	for (i in 120...136) 
		setupBeatShit(i);
}


function setupBeatShit(i)
{
	var beat = (i*4);
	set(beat-0.001, "
		1.5, scaleY
	");
	ease(beat, 0.5, 'cubeOut', "
		1, scaleY
	");
	set(beat-0.001+0.5, "
		1.5, scaleY
	");
	ease(beat+0.5, 0.5, 'cubeOut', "
		1, scaleY
	");
	set(beat-0.001+1, "
		1.5, scaleX,
		2, drunk
	");
	ease(beat+1, 0.5, 'cubeOut', "
		1, scaleX,
		0, drunk
	");

	set(beat-0.001+2, "
		1.5, scaleY
	");
	ease(beat+2, 0.5, 'cubeOut', "
		1, scaleY
	");
	set(beat-0.001+0.5+2, "
		1.5, scaleY
	");
	ease(beat+0.5+2, 0.5, 'cubeOut', "
		1, scaleY
	");
	set(beat-0.001+1+2, "
		1.5, scaleX,
		2, drunk
	");
	ease(beat+1+2, 0.5, 'cubeOut', "
		1, scaleX,
		0, drunk
	");

	if (i == 27 || i == 27+4)
	{
		set(beat-0.001+1+2-0.5, "
			1.5, scaleX,
			-2, drunk
		");
		ease(beat+1+2-0.5, 0.5, 'cubeOut', "
			1, scaleX,
			0, drunk
		");
		set(beat-0.001+1+2+0.5, "
			1.5, scaleX,
			-2, drunk
		");
		ease(beat+1+2+0.5, 0.5, 'cubeOut', "
			1, scaleX,
			0, drunk
		");
	}

}