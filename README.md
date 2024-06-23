# CNE GPU Modchart Framework
 
This is a mod/script for [Codename Engine](https://github.com/FNF-CNE-Devs/CodenameEngine), that implements a custom modcharting system that utilizes vertex shaders to manipulate notes.

Using the GPU instead of the CPU for the modifier math means that this should give better performance (unless you have a bad GPU lol), with a lot of extra customizability that would not have been possible otherwise since it gives direct access to individual vertices.



## Features
- 3D positioning and rotation of notes, with a basic 3D camera
- Custom modifiers that can inject scripted GLSL code into the shaders
- Event system for setting/tweening modifier values

## Getting Started

Start by copying the data and shaders folders into your CNE mod or assets folder

Then, inside of your own script, setup something like this:
```haxe
function postCreate()
{
    importScript("data/scripts/modchartManager.hx");

    //setup your modchart here

    initModchart(); //call this when finished
}
```

Creating a modifier:
```haxe
//Basic
createModifier("modifierName", 0, "
    x += modifierName_value;
");

//Strumline Specific
createModifier("modifierNameStrumLine1", 0, "
    x += modifierNameStrumLine1_value;
", 1);

//Strum Specfific
createModifier("modifierNameStrum0", 0, "
    angleZ += modifierNameStrum0_value;
", -1, 0);

//Advanced
createModifier("drunkSpeed", 3.0, "", -1, -1, 0.0, false); //act as a subValue
createModifier("drunk", 1.0, "
   x += cos(((songPosition*0.001) + (strumID*0.2) +
        (curPos*0.45)*0.013) * (drunkSpeed_value*0.2)) * 112*0.5 * drunk_value;
");


//Custom Haxe Function
createModifier("hudAngle", 0, function(mod)
{
    camHUD.angle = mod[MOD_VALUE];
}, -1, -1, 0.0, false, MOD_TYPE_CUSTOM);

```

Setting up Events
```haxe

//triggers on beat 4
//tween for 1 beat with cubeOut
//tweens modifier "angleX" to -45
ease(4, 1, 'cubeOut', "
   -45, angleX
");

//multiple modifiers can be tweened with the same event
ease(6, 1, 'cubeOut', "
   45, angleX,
   100, x,
   500, z,
");

//instant set on beat 10
set(10,"
   1, hide
");

```



There are a few examples of modcharts inside the songs folder

Check [here](https://github.com/TheZoroForce240/CNE-GPU-Modchart-Framework/blob/main/songs/Bopeebo/scripts/modchart.hx) for a basic guide to setting up a modchart
