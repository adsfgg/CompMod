local networkVars =
{
    playing = "boolean",
    positional = "boolean",
    assetIndex = "resource",
    startTime = "time",
    predictorId  = "entityid",
    volume = "float (0 to 30 by 0.01)" -- increase volume for lerk glide. really bad hack but I don't have fmod to change the sound volume properly...
}

Shared.LinkClassToMap("SoundEffect", SoundEffect.kMapName, networkVars, true)