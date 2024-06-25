//

import haxe.Timer;


///////////3D Matrix stuff//////////////////////////////
var fov = 90 * (Math.PI/180);
//https://github.com/openfl/openfl/blob/develop/src/openfl/geom/PerspectiveProjection.hx
var focalLength = 1.0 * (1.0 / Math.tan(fov * 0.5));
var perspectiveMatrix:Array<Float> = 
[
    focalLength, 0, 0, 0,
	0, focalLength, 0, 0,
	0, 0, 1.0, 1.0,
	0, 0, 0, 0
];
var viewMatrix:Array<Float> = [];

public var eye:Array<Float> = [0, 0, -0.71, 0];
public var lookAt:Array<Float> = [0, 0, 0, 0];
public var up:Array<Float> = [0, 1, 0, 0];

var right:Array<Float> = [1, 0, 0, 0];
var upv:Array<Float> = [0, 1, 0, 0];
var forward:Array<Float> = [0, 0, 1, 0];

function updateViewMatrix()
{
	forward = [(lookAt[0] - eye[0]), (-lookAt[1] - -eye[1]), (lookAt[2] - eye[2]), 0];
	forward = normalize(forward);

	right = cross(up, forward);
	right = normalize(right);
	upv = cross(forward, right);
	var negEye = [-eye[0], eye[1], -eye[2], -eye[3]];
	viewMatrix = 
	[
		right[0], upv[0], forward[0], 0,
		right[1], upv[1], forward[1], 0,
		right[2], upv[2], forward[2], 0,
		dot(right, negEye), dot(upv, negEye), dot(forward, negEye), 1
	];
}
function normalize(vec:Array<Float>)
{
	var mag:Float = Math.sqrt((vec[0] * vec[0]) + (vec[1] * vec[1]) + (vec[2] * vec[2]) + (vec[3] * vec[3]) );
	vec[0] = vec[0] / mag;
	vec[1] = vec[1] / mag;
	vec[2] = vec[2] / mag;
	vec[3] = vec[3] / mag;
	return vec;
}
function cross(vec1:Array<Float>, vec2:Array<Float>)
{
	var vec:Array<Float> = [0, 0, 0, 1];
	vec[0] = vec1[1] * vec2[2] - vec1[2] * vec2[1];
	vec[1] = vec1[2] * vec2[0] - vec1[0] * vec2[2];
	vec[2] = vec1[0] * vec2[1] - vec1[1] * vec2[0];
	return vec;
}
function dot(vec1:Array<Float>, vec2:Array<Float>)
{
	return vec1[0] * vec2[0] + vec1[1] * vec2[1] + vec1[2] * vec2[2];
}

/////////////////////////////////

//different shader code for each strum (for specific mods)
var modShaderVertTable:Array<Dynamic> = [];
var modShaderFragTable:Array<Dynamic> = [];

function createPerspectiveShader(obj, strumLineID, strumID)
{
	var shader = new FunkinShader(modShaderFragTable[strumLineID][strumID], modShaderVertTable[strumLineID][strumID]);
	//shader.data.vertexXOffset.value = [0.0, 0.0, 0.0, 0.0];
	//shader.data.vertexYOffset.value = [0.0, 0.0, 0.0, 0.0];
	//shader.data.vertexZOffset.value = [0.0, 0.0, 0.0, 0.0];
	shader.data.vertexID.value = [0, 1, 2, 3];
	shader.perspectiveMatrix = perspectiveMatrix;
	shader.viewMatrix = viewMatrix;
	obj.shader = shader;
}
/////////////////////////////////////

public var modifiers:Array<Dynamic> = [];
//modtable that precalculates which mods are used for which strum note
public var modTable:Array<Dynamic> = [];

//indexing variables (used kinda like an enum)
public var MOD_NAME = 0;
public var MOD_VALUE = 1;
public var MOD_FUNC = 2;
public var MOD_DEFAULTVALUE = 3;
public var MOD_AUTODISABLE = 4;
public var MOD_ENABLED = 5;
public var MOD_STRUMLINEID = 6;
public var MOD_STRUMID = 7;
public var MOD_TYPE = 8;

public var MOD_TYPE_NOTE = 0; //updates for each note/strum
public var MOD_TYPE_CUSTOM = 1; //updates once per frame
public var MOD_TYPE_FRAG = 2;

public var modEvents:Array<Dynamic> = [];
public var EVENT_TIME = 0;
public var EVENT_TYPE = 1;
public var EVENT_MODNAME = 2;
public var EVENT_VALUE = 3;
public var EVENT_EASENAME = 4;
public var EVENT_EASETIME = 5;

public var EVENT_TYPE_EASE = 0;
public var EVENT_TYPE_SET = 1;


var initialized = false;

public var modchartManagerKeyCount:Int = 4;

/*
var debugStuff = true;
var updateTS:Float = 0.0;
var drawTS:Float = 0.0;
var drawTime:Float = 0.0;
var debugText:FlxText = null;
*/

function postUpdate(elapsed)
{
	if (!initialized)
		return;

	/*
	if (debugStuff)
	{
		updateTS = Timer.stamp();
	}
	*/

	//check events
	while(modEvents.length > 0 && modEvents[0][EVENT_TIME] <= Conductor.songPosition)
	{
		if (modEvents[0][EVENT_TYPE] == EVENT_TYPE_EASE)
		{
			var easeFunc = CoolUtil.flxeaseFromString(modEvents[0][EVENT_EASENAME], "");
			tweenModifierValue(modEvents[0][EVENT_MODNAME], modEvents[0][EVENT_VALUE], modEvents[0][EVENT_EASETIME] * Conductor.crochet*0.001, easeFunc);
		}
		else if (modEvents[0][EVENT_TYPE] == EVENT_TYPE_SET)
		{
			setModifierValue(modEvents[0][EVENT_MODNAME], modEvents[0][EVENT_VALUE]);
		}

		modEvents.remove(modEvents[0]);
	}




	updateModifers();
	updateViewMatrix();
	//shader updates
	for(p in strumLines)
	{
		p.forEach(function(strum) 
		{
			strum.shader.viewMatrix = viewMatrix;
			strum.shader.songPosition = Conductor.songPosition;
			strum.shader.curBeat = Conductor.curBeatFloat;

			strum.shader.strumID = strum.ID;
			strum.shader.strumLineID = p.ID;
			strum.shader.data.noteCurPos.value = [0.0, 0.0, 0.0, 0.0];
			strum.shader.scrollSpeed = 0.0;

			if (strum.frame != null)
				strum.shader.frameUV = [strum.frame.uv.x,strum.frame.uv.y,strum.frame.uv.width,strum.frame.uv.height];


			//calculate screen position for rotation and scaling inside shader
			var point = FlxPoint.weak();
			strum.getScreenPosition(point, camHUD);
			strum.shader.screenX = strum.origin.x + point.x - strum.offset.x;
			strum.shader.screenY = strum.origin.y + point.y - strum.offset.y;
			point.put();

			strum.shader.downscroll = downscroll;
			strum.shader.isSustainNote = false;

			
			//honestly i have no idea how these are updating the notes as well
			//they should have completely seperate shaders???
			//maybe something with cne runtime shaders idk
			for (mod in modTable[p.ID][strum.ID])
			{
				var shit = Reflect.getProperty(strum.shader.data, mod[MOD_NAME] + "_value");
				Reflect.setProperty(shit, "value", [mod[MOD_VALUE]]);
			}
			

		});

		p.notes.forEach(function(n) 
		{
			n.shader.viewMatrix = viewMatrix;
			n.shader.songPosition = Conductor.songPosition;
			n.shader.curBeat = Conductor.curBeatFloat;
			n.shader.downscroll = downscroll;
			n.shader.isSustainNote = n.isSustainNote;
			//if (n.isSustainNote)

			if (n.frame != null)
				n.shader.frameUV = [n.frame.uv.x,n.frame.uv.y,n.frame.uv.width,n.frame.uv.height];

			var curPos = Conductor.songPosition - n.strumTime;
			var nextCurPos = curPos;

			//curpos for next sustain to match
			if (n.isSustainNote && n.nextNote != null && n.nextNote.isSustainNote) 
				nextCurPos = Conductor.songPosition - n.nextNote.strumTime;

			//sustain ends
			if (n.isSustainNote && n.nextSustain == null) 
				nextCurPos = Conductor.songPosition - (n.strumTime + (Conductor.stepCrochet*0.5));

			//clip to strum
			if (n.isSustainNote && n.wasGoodHit && curPos >= 0) 
				curPos = 0;


			//calculate screen position for rotation and scaling inside shader
			var point = FlxPoint.weak();
			n.getScreenPosition(point, camHUD);
			n.shader.screenX = (n.origin.x + point.x - n.offset.x) + n.__strum.x;
			if (downscroll)
				n.shader.screenY = (n.origin.y + point.y - n.offset.y) - n.__strum.y;
			else
				n.shader.screenY = (n.origin.y + point.y - n.offset.y) + n.__strum.y;
			point.put();

			
			n.shader.strumID = n.strumID;
			n.shader.strumLineID = p.ID;
			n.shader.data.noteCurPos.value = [curPos, curPos, nextCurPos, nextCurPos];
			n.shader.scrollSpeed = strumLines.members[p.ID].members[n.strumID].getScrollSpeed(n);
			/*
			for (mod in modTable[p.ID][n.strumID]) //update modifier values on shader
			{
				var shit = Reflect.getProperty(n.shader.data, mod[MOD_NAME] + "_value");
				Reflect.setProperty(shit, "value", [mod[MOD_VALUE]]);
			}
			*/
		});
	}

	/*
	if (debugStuff)
	{
		var newStamp = Timer.stamp();
		debugText.text = "Update: " + FlxMath.roundDecimal((newStamp-updateTS) * 1000.0, 2) +"ms" + "\n" + "Draw: " + FlxMath.roundDecimal(drawTime * 1000.0, 2) +"ms";
	}
	*/
}
/*
function draw(event)
{
	drawTS = Timer.stamp();
}
function postDraw(event)
{
	var newStamp = Timer.stamp();
	drawTime = newStamp-drawTS;
}
*/



function reconstructModTable()
{
	modTable = [];

	for(p in 0...PlayState.SONG.strumLines.length)
	{
		modTable.push([]);
		for (i in 0...modchartManagerKeyCount)
		{
			modTable[p].push([]);
			for (mod in modifiers)
			{
				if ((mod[MOD_STRUMLINEID] == -1 || mod[MOD_STRUMLINEID] == p) && (mod[MOD_STRUMID] == -1 || mod[MOD_STRUMID] == i))
				{
					modTable[p][i].push(mod); //add modifier to table so it knows which modifiers are gonna be used for each individual strum
				}
			}
		}
	}
}

function updateModifers()
{
	for (mod in modifiers)
	{
		if (mod[MOD_AUTODISABLE])
		{
			mod[MOD_ENABLED] = mod[MOD_VALUE] != mod[MOD_DEFAULTVALUE];				
		}

		if (mod[MOD_ENABLED] && mod[MOD_TYPE] == MOD_TYPE_CUSTOM)
		{
			mod[MOD_FUNC](mod); //call modifier function
		}
	}
}




public function initModchart()
{
	initialized = true;
	
	sortModEvents();
	reconstructModTable();


	generateShaderCode();

	for(p in strumLines)
	{
		p.forEach(function(strum) 
		{
			createPerspectiveShader(strum, p.ID, strum.ID);
		});

		for (i in 0...p.notes.members.length)
		{
			createPerspectiveShader(p.notes.members[i], p.ID, p.notes.members[i].strumID);
		}
	}


	/*createModifier("drunk", 2.0, "
		x += cos(((songPosition*0.001) + (strumID*0.2) + 
			(curPos*0.45)*0.013) * (5.0*0.2)) * 112*0.5 * drunk_value;
	", 0);*/

	/*
	if(debugStuff)
	{
		debugText = new FlxText(0, 0, 0, "Test");
		debugText.size = 48;
		debugText.cameras = [camHUD];
		add(debugText);
	}
	*/


	
}

public function generateShaderCode()
{
	var name = "notePerspective";
	var fragShaderPath = Paths.fragShader(name);
	var vertShaderPath = Paths.vertShader(name);
	var fragCode = Assets.exists(fragShaderPath) ? Assets.getText(fragShaderPath) : null;
	var vertCode = Assets.exists(vertShaderPath) ? Assets.getText(vertShaderPath) : null;

	modShaderVertTable = [];
	modShaderFragTable = [];

	var numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
	var operators = ["+", "-", "*", "/", "(", ")", "="];
	var warnings = "";
	for (mod in modifiers)
	{
		if (mod[MOD_TYPE] == MOD_TYPE_NOTE || mod[MOD_TYPE] == MOD_TYPE_FRAG)
		{
			var foundBadNumber = false;
			var searching = false;

			var data:String = mod[MOD_FUNC];
			for (i in 0...data.length) //loop through every character
			{
				if (operators.contains(data.charAt(i))) //if its an operator then there could be a number afterwards
				{
					searching = true;
				}

				var number = data.charAt(i);
					
				if (numbers.contains(data.charAt(i)) && searching) //there is a number so lets check
				{
					var bad = true;
					while(true)
					{
						i++; //check next number
						if (numbers.contains(data.charAt(i)) || data.charAt(i) == ".") //if its a number or . then continue
						{
							number += data.charAt(i);
							if (data.charAt(i) == ".")
							{
								bad = false; //if the number contains a . then its all good
							}
						}
						else //break if not a number or .
						{
							searching = false;
							break;
						}
					}

					if (bad) //add to warnings since its bad
					{
						warnings += "\nWARNING: found bad number '" + number + "' in Modifier '" + mod[MOD_NAME] + "'\nIf this is intentional then ignore, otherwise add .0!\n";
					}
				}
				else if (!operators.contains(data.charAt(i)) && data.charAt(i) != " ") //not a number or operator so reset, but ignore spaces
					searching = false;
			}
		}
	}

	if (warnings != "")
		trace(warnings);

	for(p in 0...PlayState.SONG.strumLines.length) //generate shader code for each strum lane
	{
		modShaderVertTable.push([]);
		modShaderFragTable.push([]);
		for (i in 0...modchartManagerKeyCount)
		{
			var modifierUniformsVertCode = "";
			var modifierFunctionsVertCode = "";

			var modifierUniformsFragCode = "";
			var modifierFunctionsFragCode = "";

			modShaderVertTable[p].push(vertCode);
			modShaderFragTable[p].push(fragCode);
			for (mod in modTable[p][i]) //loop through each mod
			{
				if (mod[MOD_TYPE] == MOD_TYPE_NOTE)
				{
					//declare uniform
					modifierUniformsVertCode += "uniform float " + mod[MOD_NAME] + "_value;\n";

					//add modifier code
					if (mod[MOD_AUTODISABLE])
					{
						var defaultValue = mod[MOD_DEFAULTVALUE];
						if (!StringTools.contains(defaultValue, "."))
							defaultValue += ".0"; //make sure it has a decimal so the shader knows its a float
			
						modifierFunctionsVertCode += "if (" + mod[MOD_NAME] + "_value != " + (defaultValue) + ")";
						modifierFunctionsVertCode += "{";
						modifierFunctionsVertCode += mod[MOD_FUNC];
						modifierFunctionsVertCode += "}";
					}
					else
					{
						modifierFunctionsVertCode += mod[MOD_FUNC];
					}
				}
				else if (mod[MOD_TYPE] == MOD_TYPE_FRAG)
				{
					//declare uniform
					modifierUniformsFragCode += "uniform float " + mod[MOD_NAME] + "_value;\n";

					//add modifier code
					if (mod[MOD_AUTODISABLE])
					{
						var defaultValue = mod[MOD_DEFAULTVALUE];
						if (!StringTools.contains(defaultValue, "."))
							defaultValue += ".0"; //make sure it has a decimal so the shader knows its a float
			
						modifierFunctionsFragCode += "if (" + mod[MOD_NAME] + "_value != " + (defaultValue) + ")";
						modifierFunctionsFragCode += "{";
						modifierFunctionsFragCode += mod[MOD_FUNC];
						modifierFunctionsFragCode += "}";
					}
					else
					{
						modifierFunctionsFragCode += mod[MOD_FUNC];
					}
				}
			}
			//add modifier code into shader
			modShaderVertTable[p][i] = StringTools.replace(modShaderVertTable[p][i], "#pragma modifierUniforms", modifierUniformsVertCode);
			modShaderVertTable[p][i] = StringTools.replace(modShaderVertTable[p][i], "#pragma modifierFunctions", modifierFunctionsVertCode);

			modShaderFragTable[p][i] = StringTools.replace(modShaderFragTable[p][i], "#pragma modifierUniforms", modifierUniformsFragCode);
			modShaderFragTable[p][i] = StringTools.replace(modShaderFragTable[p][i], "#pragma modifierFunctions", modifierFunctionsFragCode);
		}
	}
}

////Modifier Functions/////
public function createModifier(name:String, value:Float, func:Dynamic, strumLineID:Int = -1, strumID = -1, defaultValue:Float = 0.0, autoDisable = true, modType:Int = 0)
{
	if (defaultValue == null)
		defaultValue = 0.0;
	if (autoDisable == null)
		autoDisable = true;
	if (strumLineID == null)
		strumLineID = -1;
	if (strumID == null)
		strumID = -1;
	if (modType == null)
		modType = MOD_TYPE_NOTE;

	var modData = [name, value, func, defaultValue, autoDisable, true, strumLineID, strumID, modType];
	modifiers.push(modData);

	reconstructModTable();
}

public function tweenModifierValue(name:String, newValue:Float, time:Float, easeFunc:Float->Float)
{
	var mod = null;
	for (m in modifiers)
		if (m[MOD_NAME] == name)
			mod = m;

	if (mod == null)
		return; //cant find

	var startValue = mod[MOD_VALUE];
	FlxTween.num(startValue, newValue, time, {onUpdate: function(tween:FlxTween){
		var ting = FlxMath.lerp(startValue, newValue, easeFunc(tween.percent)); //ease properly with lerp
		mod[MOD_VALUE] = ting;
	}, ease: easeFunc, onComplete: function(tween:FlxTween) {
		mod[MOD_VALUE] = newValue;
	}});
}

public function setModifierValue(name:String, newValue:Float)
{
	var mod = null;
	for (m in modifiers)
		if (m[MOD_NAME] == name)
			mod = m;

	if (mod == null)
		return; //cant find

	mod[MOD_VALUE] = newValue;
}

public function ease(beat:Float, timeInBeats:Float, easeName:String, data:String)
{
	var arguments = StringTools.replace(StringTools.trim(data), ' ', '').split(',');

	var time = Conductor.getTimeForStep(beat*4);

	for (i in 0...Math.floor(arguments.length/2))
	{
		var name:String = Std.string(arguments[1 + (i*2)]);
		var value:Float = Std.parseFloat(arguments[0 + (i*2)]);
		if(Math.isNaN(value))
			value = 0;

		modEvents.push([time, EVENT_TYPE_EASE, name, value, easeName, timeInBeats]);
	}
}

public function set(beat:Float, data:String)
{
	var arguments = StringTools.replace(StringTools.trim(data), ' ', '').split(',');

	var time = Conductor.getTimeForStep(beat*4);

	for (i in 0...Math.floor(arguments.length/2))
	{
		var name:String = Std.string(arguments[1 + (i*2)]);
		var value:Float = Std.parseFloat(arguments[0 + (i*2)]);
		if(Math.isNaN(value))
			value = 0;

		modEvents.push([time, EVENT_TYPE_SET, name, value]);
	}
}

public function sortModEvents()
{
	modEvents.sort(function(a, b) {
		if(a[EVENT_TIME] < b[EVENT_TIME]) return -1;
		else if(a[EVENT_TIME] > b[EVENT_TIME]) return 1;
		else return 0;
	 });
}


//fixes for splashes
function onNoteHit(event)
{
	if (event.showSplash)
	{
		event.showSplash = false;
		
		//show splash func (but we need to keep the splash sprite for after)
		splashHandler.__grp = splashHandler.getSplashGroup(event.note.splash);
		var splash = splashHandler.__grp.showOnStrum(event.note.__strum);
		splash.shader = event.note.__strum.shader;
		splashHandler.add(splash);
		// max 8 rendered splashes
		while(splashHandler.members.length > 8)
			splashHandler.remove(splashHandler.members[0], true);
	}
}