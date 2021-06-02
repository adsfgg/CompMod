local networkVars = {
    stealthLevel = "integer (0 to 3)"
}

Alien.GetEffectParams = nil

Shared.LinkClassToMap("Alien", Alien.kMapName, networkVars, true)
