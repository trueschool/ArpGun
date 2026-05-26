
local cutChords = true

function keyHandler(dialog, key)
  -- Support the user's shortcuts when the dialog is focused
  if key.modifiers == "shift + alt" then
    if key.name == "." then incrementArpPattern(); return end
    if key.name == "," then decrementArpPattern(); return end
    if key.name == "'" then incrementArpStep(); return end
    if key.name == ";" then decrementArpStep(); return end
    if key.name == "0" then incrementScaleTonicNote(); return end
    if key.name == "9" then decrementScaleTonicNote(); return end
    if key.name == "=" then incrementChordType(); return end
    if key.name == "-" then decrementChordType(); return end
    if key.name == "]" then incrementChordInversion(); return end
    if key.name == "[" then decrementChordInversion(); return end
    if key.name == "1" then insertChord(1); return end
    if key.name == "2" then insertChord(2); return end
    if key.name == "3" then insertChord(3); return end
    if key.name == "4" then insertChord(4); return end
    if key.name == "5" then insertChord(5); return end
    if key.name == "6" then insertChord(6); return end
    if key.name == "7" then insertChord(7); return end
  end
  return key
end

function incrementArpPattern()
  if (preferences == nil) then preferences = ToolPreferences(); preferences:loadValues(); updateScaleData() end
  if preferences.arpPattern.value < #arpPatterns then
    preferences.arpPattern.value = preferences.arpPattern.value + 1
  else
    preferences.arpPattern.value = 1
  end
  preferences:saveValues()
  renoise.app():show_status("Arp Pattern: " .. arpPatterns[preferences.arpPattern.value])
end

function decrementArpPattern()
  if (preferences == nil) then preferences = ToolPreferences(); preferences:loadValues(); updateScaleData() end
  if preferences.arpPattern.value > 1 then
    preferences.arpPattern.value = preferences.arpPattern.value - 1
  else
    preferences.arpPattern.value = #arpPatterns
  end
  preferences:saveValues()
  renoise.app():show_status("Arp Pattern: " .. arpPatterns[preferences.arpPattern.value])
end

function incrementArpStep()
  if (preferences == nil) then preferences = ToolPreferences(); preferences:loadValues(); updateScaleData() end
  if preferences.arpStep.value < #arpSteps then
    preferences.arpStep.value = preferences.arpStep.value + 1
  else
    preferences.arpStep.value = 1
  end
  preferences:saveValues()
  renoise.app():show_status("Arp Step: " .. arpSteps[preferences.arpStep.value])
end

function decrementArpStep()
  if (preferences == nil) then preferences = ToolPreferences(); preferences:loadValues(); updateScaleData() end
  if preferences.arpStep.value > 1 then
    preferences.arpStep.value = preferences.arpStep.value - 1
  else
    preferences.arpStep.value = #arpSteps
  end
  preferences:saveValues()
  renoise.app():show_status("Arp Step: " .. arpSteps[preferences.arpStep.value])
end

function incrementScaleTonicNote()

  if preferences.scaleTonicNote.value == #notes then
    return
  end

  preferences.scaleTonicNote.value = preferences.scaleTonicNote.value + 1

  if (viewBuilder == nil) then
    preferences:resetSelectedChordTypes()
    preferences:resetSelectedInversionStates()
    updateScaleData()
    showScaleStatus()
    updateScaleDegreeHeaders()
  end
end

function decrementScaleTonicNote()

  if preferences.scaleTonicNote.value == 1 then
    return
  end

  preferences.scaleTonicNote.value = preferences.scaleTonicNote.value - 1

  if (viewBuilder == nil) then
    preferences:resetSelectedChordTypes()
    preferences:resetSelectedInversionStates()
    updateScaleData()
    showScaleStatus()
    updateScaleDegreeHeaders()
  end
end

function incrementScaleType()

  if preferences.scaleType.value == #scales then
    return
  end

  preferences.scaleType.value = preferences.scaleType.value + 1

  if (viewBuilder == nil) then
    preferences:resetSelectedChordTypes()
    preferences:resetSelectedInversionStates()
    updateScaleData()
    showScaleStatus()
    updateScaleDegreeHeaders()
  end
end

function decrementScaleType()

  if preferences.scaleType.value == 1 then
    return
  end

  preferences.scaleType.value = preferences.scaleType.value - 1

  if (viewBuilder == nil) then
    preferences:resetSelectedChordTypes()
    preferences:resetSelectedInversionStates()
    updateScaleData()
    showScaleStatus()
    updateScaleDegreeHeaders()
  end
end

function incrementChordType()

  local selectedScaleDegree = preferences.selectedScaleDegree.value

  if preferences.selectedChordTypes[selectedScaleDegree].value < #scaleChords[selectedScaleDegree] then
    preferences.selectedChordTypes[selectedScaleDegree].value = preferences.selectedChordTypes[selectedScaleDegree].value + 1
  end

  insertChord(selectedScaleDegree)
end

function decrementChordType()

  local selectedScaleDegree = preferences.selectedScaleDegree.value

  if preferences.selectedChordTypes[selectedScaleDegree].value > 1 then
    preferences.selectedChordTypes[selectedScaleDegree].value = preferences.selectedChordTypes[selectedScaleDegree].value - 1
  end

  insertChord(selectedScaleDegree)
end

function incrementChordInversion()

  if preferences.chordInversion.value ~= preferences.chordInversionMax.value then
    preferences.chordInversion.value = preferences.chordInversion.value + 1
    setInversion(preferences.chordInversion.value)
  end
end

function decrementChordInversion()

  if preferences.chordInversion.value ~= preferences.chordInversionMin.value then
    preferences.chordInversion.value = preferences.chordInversion.value - 1
    setInversion(preferences.chordInversion.value)
  end
end

renoise.tool():add_keybinding {
  name = "Global:ArpGun:toggle arp mode",
  invoke = function()
    if (preferences == nil) then preferences = ToolPreferences(); preferences:loadValues(); updateScaleData() end
    if preferences.arpWriteMode.value < #arpWriteModes then
      preferences.arpWriteMode.value = preferences.arpWriteMode.value + 1
    else
      preferences.arpWriteMode.value = 1
    end
    preferences:saveValues()
    renoise.app():show_status("Arp Mode: " .. arpWriteModes[preferences.arpWriteMode.value])
  end
}

renoise.tool():add_keybinding {
  name = "Global:ArpGun:increment arp pattern",
  invoke = function()
    incrementArpPattern()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:decrement arp pattern",
  invoke = function()
    decrementArpPattern()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:increment arp step",
  invoke = function()
    incrementArpStep()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:decrement arp step",
  invoke = function()
    decrementArpStep()
  end
}

renoise.tool():add_keybinding {
  name = "Global:ArpGun:increment scale tonic note",
  invoke = function()

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    incrementScaleTonicNote()
    preferences:saveValues()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:decrement scale tonic note",
  invoke = function()

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    decrementScaleTonicNote()
    preferences:saveValues()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:increment scale type",
  invoke = function()

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    incrementScaleType()
    preferences:saveValues()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:decrement scale type",
  invoke = function()

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    decrementScaleType()
    preferences:saveValues()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:increment chord type",
  invoke = function()

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    incrementChordType()
    preferences:saveValues()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:decrement chord type",
  invoke = function()

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    decrementChordType()
    preferences:saveValues()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:increment chord inversion",
  invoke = function()

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    incrementChordInversion()
    preferences:saveValues()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:decrement chord inversion",
  invoke = function()

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    decrementChordInversion()
    preferences:saveValues()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:insert scale chord 1",
  invoke = function(repeated)

    if repeated then
      return
    end

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    local scaleDegree = 1
    insertChord(scaleDegree)
    preferences:saveValues()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:insert scale chord 2",
  invoke = function(repeated)

    if repeated then
      return
    end

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    local scaleDegree = 2
    insertChord(scaleDegree)
    preferences:saveValues()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:insert scale chord 3",
  invoke = function(repeated)

    if repeated then
      return
    end

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    local scaleDegree = 3
    insertChord(scaleDegree)
    preferences:saveValues()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:insert scale chord 4",
  invoke = function(repeated)

    if repeated then
      return
    end

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    local scaleDegree = 4
    insertChord(scaleDegree)
    preferences:saveValues()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:insert scale chord 5",
  invoke = function(repeated)

    if repeated then
      return
    end

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    local scaleDegree = 5
    insertChord(scaleDegree)
    preferences:saveValues()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:insert scale chord 6",
  invoke = function(repeated)

    if repeated then
      return
    end

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    local scaleDegree = 6
    insertChord(scaleDegree)
    preferences:saveValues()
  end
}
renoise.tool():add_keybinding {
  name = "Global:ArpGun:insert scale chord 7",
  invoke = function(repeated)

    if repeated then
      return
    end

    if (preferences == nil) then
      preferences = ToolPreferences()
      preferences:loadValues()
      updateScaleData()
    end

    local scaleDegree = 7
    insertChord(scaleDegree)
    preferences:saveValues()
  end
}
