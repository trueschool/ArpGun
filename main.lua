require 'scaleFunctions'
require 'ToolPreferences'
require 'interface'
require 'keyBindings'
require 'inversionStates'
require 'scaleDegreeHeaders'
require 'OSC'
require 'util'

scaleNotes = {}
scaleChords = {}

scalePattern = nil

chordButtons = {}

function getNotesString(chordNotesArray)

  local notesString = '                '
  for i, note in ipairs(chordNotesArray) do

    local noteName = getNoteName(note+1)

    if i ~= #chordNotesArray then
      notesString = notesString .. noteName .. ', '
    else
      notesString = notesString .. noteName .. ''
    end
  end

  return notesString
end

function applyInversion(chord)

  local chordLength = #chord
  local chordInversionValue = getCurrentInversionValue()
  local chord_ = chord
  local oct = 0

  if chordInversionValue < 0 then
    oct = math.floor(chordInversionValue / chordLength)
    chordInversionValue = chordInversionValue + (math.abs(oct) * chordLength)
  end

  for i = 1, chordInversionValue do
    local r = table.remove(chord_, 1)
    r = r + 12
    table.insert(chord_, #chord_ + 1, r )
  end

  for i = 1, #chord_ do
    chord_[i] = chord_[i] + (oct * 12)
  end

  return chord_
end

function effectsColumnIsSelected()
  return renoise.song().selected_note_column_index == 0
end

function insertNoteAtLine(note, noteColumnIndex, target_line_index)

  if effectsColumnIsSelected() then
    return
  end

  -- Check if target line is within pattern bounds
  local pattern_track = renoise.song().selected_pattern_track
  local num_lines = #pattern_track.lines

  if target_line_index > num_lines or target_line_index < 1 then
    return
  end

  local line = pattern_track:line(target_line_index)

  if noteColumnIndex > renoise.song().selected_track.max_note_columns then
    return
  end

  local noteColumn = line.note_columns[noteColumnIndex]
  if (note > -1 and note < 122) then
    noteColumn.note_value = note
  end

  if renoise.song().transport.keyboard_velocity_enabled then
    noteColumn.volume_value = renoise.song().transport.keyboard_velocity
  else
    noteColumn.volume_value = 255
  end
  noteColumn.instrument_value = renoise.song().selected_instrument_index - 1
end
function insertNote(note, noteColumnIndex)

  if effectsColumnIsSelected() then
    return
  end

  if noteColumnIndex > renoise.song().selected_track.max_note_columns then
    return
  end

  -- Not enough space? Compensate!
  if noteColumnIndex > renoise.song().selected_track.visible_note_columns then
    renoise.song().selected_track.visible_note_columns = noteColumnIndex
  end

  local noteColumn = renoise.song().selected_line.note_columns[noteColumnIndex]

  if (note > -1 and note < 122) then
    noteColumn.note_value = note
  end

  if renoise.song().transport.keyboard_velocity_enabled then
    noteColumn.volume_value = renoise.song().transport.keyboard_velocity
  else
    noteColumn.volume_value = 255
  end
  noteColumn.instrument_value = renoise.song().selected_instrument_index - 1
end

function insertChord(scaleDegree)

  preferences.selectedScaleDegree.value = scaleDegree

  local chordType = preferences.selectedChordTypes[scaleDegree].value
  local chord = scaleChords[scaleDegree][chordType]
  local root = scaleNotes[scaleDegree]

  local chordLength = 0
  local chordNotesArray = {}
  local chordPattern = chord["pattern"]
  for n = 0, #chordPattern-1 do
    if chordPattern:sub(n+1, n+1) == '1' then
      chordLength = chordLength + 1

      local octave = renoise.song().transport.octave
      local noteValue = root + n + (octave * 12) - 1
      table.insert(chordNotesArray, noteValue)
    end
  end

  chordNotesArray = applyInversion(chordNotesArray)
  local chordNotesArray_ = copy(chordNotesArray)

  if renoise.song().transport.edit_mode == true then

    local arpPatternIdx = preferences.arpPattern.value
    local arpPatternName = arpPatterns[arpPatternIdx]
    local stepSize = tonumber(arpSteps[preferences.arpStep.value])

    if arpPatternName ~= "none" then
      local arpNotes = {}

      -- Helper to sort notes for patterns
      local sortedNotes = {}
      for _, n in ipairs(chordNotesArray) do table.insert(sortedNotes, n) end
      table.sort(sortedNotes)

      if arpPatternName == "up" then
        arpNotes = sortedNotes
      elseif arpPatternName == "down" then
        for i = #sortedNotes, 1, -1 do table.insert(arpNotes, sortedNotes[i]) end
      elseif arpPatternName == "up/down" then
        for i = 1, #sortedNotes do table.insert(arpNotes, sortedNotes[i]) end
        for i = #sortedNotes-1, 2, -1 do table.insert(arpNotes, sortedNotes[i]) end
      elseif arpPatternName == "down/up" then
        for i = #sortedNotes, 1, -1 do table.insert(arpNotes, sortedNotes[i]) end
        for i = 2, #sortedNotes-1 do table.insert(arpNotes, sortedNotes[i]) end
      elseif arpPatternName == "up/down/up" then
        for i = 1, #sortedNotes do table.insert(arpNotes, sortedNotes[i]) end
        for i = #sortedNotes-1, 1, -1 do table.insert(arpNotes, sortedNotes[i]) end
        for i = 2, #sortedNotes do table.insert(arpNotes, sortedNotes[i]) end
      elseif arpPatternName == "down/up/down" then
        for i = #sortedNotes, 1, -1 do table.insert(arpNotes, sortedNotes[i]) end
        for i = 2, #sortedNotes do table.insert(arpNotes, sortedNotes[i]) end
        for i = #sortedNotes-1, 1, -1 do table.insert(arpNotes, sortedNotes[i]) end
      elseif arpPatternName == "strum up" then
        -- Strumming typically means very small offsets, but we'll use the stepSize
        arpNotes = sortedNotes
      elseif arpPatternName == "strum down" then
        for i = #sortedNotes, 1, -1 do table.insert(arpNotes, sortedNotes[i]) end
      elseif arpPatternName == "dyads" then
        for i = 1, #sortedNotes - 1 do
          table.insert(arpNotes, {sortedNotes[i], sortedNotes[i+1]})
        end
      end

      local noteColumnIndex = 1 -- Default to the very left hand column for Arp patterns

      -- Set visible columns once to avoid redundant UI updates
      local neededCols = 1
      if arpPatternName == "dyads" then neededCols = 2 end
      if renoise.song().selected_track.visible_note_columns < neededCols then
        renoise.song().selected_track.visible_note_columns = neededCols
      end

      local selection = renoise.song().selection_in_pattern
      local start_line, end_line

      -- Determine range: selection or cursor-to-end
      if selection ~= nil and
         selection.start_line <= #renoise.song().selected_pattern_track.lines and
         selection.start_line ~= selection.end_line then -- Actual range selected
        start_line = selection.start_line
        end_line = selection.end_line
      else
        start_line = renoise.song().selected_line_index
        end_line = #renoise.song().selected_pattern_track.lines
      end

      local arp_index = 1
      local timingMode = arpTimingModes[preferences.arpTimingMode.value]
      local writeMode = arpWriteModes[preferences.arpWriteMode.value]

      -- If overwrite, clear the target columns in the range first
      if writeMode == "overwrite" then
        for l = start_line, end_line do
          local line = renoise.song().selected_pattern_track:line(l)
          -- Only clear the columns we are likely to use (1 and 2 for dyads/chords)
          line.note_columns[1]:clear()
          line.note_columns[2]:clear()
        end
      end

      if timingMode == "standard" then
        for l = start_line, end_line, stepSize do
          local val = arpNotes[arp_index]
          if type(val) == "table" then
            -- Dyad
            insertNoteAtLine(val[1], noteColumnIndex, l)
            insertNoteAtLine(val[2], noteColumnIndex + 1, l)
          else
            insertNoteAtLine(val, noteColumnIndex, l)
          end

          arp_index = arp_index + 1
          if arp_index > #arpNotes then
            arp_index = 1
          end
        end
      elseif timingMode == "euclidean" then
        local hits = preferences.euclideanHits.value
        local len = preferences.euclideanLength.value
        local shift = preferences.euclideanShift.value
        local euclidSeq = generateEuclidean(hits, len, shift)

        local l = start_line
        local e_idx = 1
        while l <= end_line do
          if euclidSeq[e_idx] == 1 then
            local val = arpNotes[arp_index]
            if type(val) == "table" then
              insertNoteAtLine(val[1], noteColumnIndex, l)
              insertNoteAtLine(val[2], noteColumnIndex + 1, l)
            else
              insertNoteAtLine(val, noteColumnIndex, l)
            end

            arp_index = arp_index + 1
            if arp_index > #arpNotes then
              arp_index = 1
            end
          end

          l = l + 1
          e_idx = (e_idx % len) + 1
        end
      end
      -- Still insert trigger note if enabled, but maybe only on the first line or every line?
      -- Brief says "after adding the chord, it's possible to space the notes"
      -- We'll skip ArpGun's complex chord-line logic when arpeggiating for now.

      updateChordText(root, chord, chordNotesArray_)
      highlightSelectedChordTypes()
      return -- End early for arpeggio
    end

    local noteColumnIndex = renoise.song().selected_note_column_index
    for note = 1, #chordNotesArray do
      insertNote(chordNotesArray[note], noteColumnIndex)
      noteColumnIndex = noteColumnIndex + 1
    end

    local visibleNoteColumns = renoise.song().selected_track.visible_note_columns

    if visibleNoteColumns >= noteColumnIndex then
      for i = noteColumnIndex, visibleNoteColumns do
        local noteColumn = renoise.song().selected_line:note_column(i)

        if preferences.insertNoteOffInRemainingNoteColumns.value then
          noteColumn.note_value = 120
        else
          noteColumn.note_value = 121
        end

        noteColumn.instrument_value = 255
      end
    end

  else
    playChordWithOsc(chordNotesArray)
  end

  updateChordText(root, chord, chordNotesArray_)

  highlightSelectedChordTypes()
end
--------------------------------------------------------------------------------

function updateScaleNotes()

  scaleNotes = {}

  local scaleNoteIndex = 1
  for note = preferences.scaleTonicNote.value, preferences.scaleTonicNote.value + 11 do

    if noteIsInScale(note) then
      scaleNotes[scaleNoteIndex] = note
      scaleNoteIndex = scaleNoteIndex + 1
    end
  end
end

function updateScaleChords()

  scaleChords = {}

  local scaleNoteIndex = 1
  for note = preferences.scaleTonicNote.value, preferences.scaleTonicNote.value + 11 do

    if noteIsInScale(note) then
      scaleChords[scaleNoteIndex] = getScaleChordsForRootNote(note)
      scaleNoteIndex = scaleNoteIndex + 1
    end
  end
end

function updateChordButtons()

  local scaleNote = 1
  for note = preferences.scaleTonicNote.value, preferences.scaleTonicNote.value + 11 do

    if noteIsInScale(note) then

      local chordButtonsColumn = viewBuilder.views[string.format("%i", scaleNote)]
      if chordButtonsColumn == nil then
        chordButtonsColumn = viewBuilder:column {
              id = "" .. scaleNote,
              margin = 0,
              spacing = 0,
        }
      end

      chordButtons[scaleNote] = chordButtonsColumn
      chordTypeColumns[scaleNote]:add_child(chordButtonsColumn)

      for chordIndex, chord in ipairs(chords) do

        local existingChordBox = viewBuilder.views[string.format("%i:%i", scaleNote, chordIndex)]

        if existingChordBox then
          existingChordBox.visible = false
        end
      end

      for chordIndex, chord in ipairs(scaleChords[scaleNote]) do

          local scaleNote_ = scaleNote
          local chordIndex_ = chordIndex

          local chordTypeButtonId = string.format("%i:%i", scaleNote, chordIndex)
          local chordTypeButton = viewBuilder.views[chordTypeButtonId]

          local buttonPressedNotifier = function()
                                          preferences.selectedChordTypes[scaleNote_].value = chordIndex_
                                          insertChord(scaleNote_)
                                          highlightSelectedChordTypes()
                                          preferences.chordInversion.value = getCurrentInversionValue()
                                          preferences:saveValues()
                                        end
          local buttonReleasedNotifier = function()

                                         end

          if chordTypeButton then
            chordTypeButton.text = preferences.scaleNoteNames[scaleNote].value .. chord['display']
            chordTypeButton.visible = true
            chordTypeButton.width = BUTTON_WIDTH
          else
            chordTypeButton = viewBuilder:button {
              id = chordTypeButtonId,
              color = {0x2d, 0x2d, 0x2d},
              height = 30,
              width = BUTTON_WIDTH,
              text = preferences.scaleNoteNames[scaleNote].value .. chord['display'],
              pressed = buttonPressedNotifier,
              released = buttonReleasedNotifier
              }

            chordButtonsColumn:add_child(chordTypeButton)
          end
        end



      scaleNote = scaleNote + 1
    end
  end
end


function clearChordBoxes()

  for i, v in ipairs(chordButtons) do
    if v ~= nil then
      chordTypeColumns[i]:remove_child(v)
      chordTypeColumns[i]:resize()
      chordButtons[i] = nil
    end
  end
end

function removeFlatsAndSharps(arg)
  return arg:gsub('b',''):gsub('#','')
end

function aNoteIsRepeated()

 local previousScaleNoteName = preferences.scaleNoteNames[#preferences.scaleNoteNames].value
 local scaleNoteName = nil

  for scaleDegree = 1,  #preferences.scaleNoteNames do

    scaleNoteName = preferences.scaleNoteNames[scaleDegree].value

    if removeFlatsAndSharps(scaleNoteName) == removeFlatsAndSharps(previousScaleNoteName) then
      return true
    end

    previousScaleNoteName = scaleNoteName
  end

  return false
end

function updateScaleNoteNames()

  local previousScaleNoteName = getSharpNoteName(preferences.scaleTonicNote.value + 11)
  local scaleNoteName = nil

  local scaleDegree = 1
  for note = preferences.scaleTonicNote.value, preferences.scaleTonicNote.value + 11 do

    if scalePattern[getNotesIndex(note)] then

      scaleNoteName = getSharpNoteName(note)
      preferences.scaleNoteNames[scaleDegree].value = scaleNoteName
      scaleDegree = scaleDegree + 1
      previousScaleNoteName = scaleNoteName
    end
  end

  if aNoteIsRepeated() then

    local previousScaleNoteName = getFlatNoteName(preferences.scaleTonicNote.value + 11)
    local scaleNoteName = nil

    local scaleDegree = 1
    for note = preferences.scaleTonicNote.value, preferences.scaleTonicNote.value + 11 do

      if scalePattern[getNotesIndex(note)] then

        scaleNoteName = getFlatNoteName(note)
        preferences.scaleNoteNames[scaleDegree].value = scaleNoteName
        scaleDegree = scaleDegree + 1
        previousScaleNoteName = scaleNoteName
      end
    end
  end
end

function updateScaleNotesText()

  local scaleNotesText = ''

  for i = 1, #scaleNotes do
    if scaleNotesText ~= '' then
      scaleNotesText = scaleNotesText .. ', '
    end

    scaleNotesText = scaleNotesText .. preferences.scaleNoteNames[i].value
  end

  if viewBuilder ~= nil then
    viewBuilder.views.scale_notes.text = scaleNotesText
  end

  preferences.scaleNotesText.value = scaleNotesText
end

function getChordInversionText(chordNotesArray)

  local inversionValue = getCurrentInversionValue()

  if inversionValue == 0 then
    return ''
  end

  if math.fmod(inversionValue, #chordNotesArray) == 0 then
    return ''
  end

  return '/' .. getNoteName(chordNotesArray[1]+1)
end

function getChordInversionOctaveIndicator(numberOfChordNotes)

  local inversionValue = getCurrentInversionValue()

  local octaveIndicator = nil

  if inversionValue > 0 then

    local offsetValue = math.floor(inversionValue / numberOfChordNotes)

    if offsetValue > 0 then
      return '+' .. offsetValue
    else
      return '+'
    end

  elseif inversionValue < 0 then

    local offsetValue = math.abs(math.ceil(inversionValue / numberOfChordNotes))

    if offsetValue > 0 then
      return '-' .. offsetValue
    else
      return '-'
    end
  else
    return ''
  end
end

function updateChordText(root, chord, chordNotesArray)

  local rootNoteName = getNoteName(root)
  local chordInversionText = getChordInversionText(chordNotesArray)
  local chordInversionOctaveIndicator = getChordInversionOctaveIndicator(#chordNotesArray)
  local chordString = rootNoteName .. chord["display"]
  local notesString = getNotesString(chordNotesArray)

  local chordTextValue = ''
  if string.match(chordInversionOctaveIndicator, "-") then
    chordTextValue = ("%20s%20s%s%20s"):format(chordInversionOctaveIndicator, chordString, chordInversionText, notesString)
  elseif string.match(chordInversionOctaveIndicator, "+") then
    chordTextValue = ("%20s%20s%s%20s%20s"):format('', chordString, chordInversionText, notesString, chordInversionOctaveIndicator)
  else
    chordTextValue = ("%20s%20s%s%20s"):format('', chordString, chordInversionText, notesString)
  end

  preferences.chordText.value = chordTextValue

  if (viewBuilder ~= nil) then
    viewBuilder.views.chord_text.text = chordTextValue
  end

  renoise.app():show_status(chordTextValue)
end

function updateScaleData()
  scalePattern = getScalePattern(preferences.scaleTonicNote.value, scales[preferences.scaleType.value])
  updateScaleNotes()
  updateScaleNoteNames()
  updateScaleNotesText()
  updateScaleChords()

  if (viewBuilder ~= nil) then
    updateChordButtons()
    highlightSelectedChordTypes()
  end
end

function showScaleStatus()

  local scaleTonicText =  notes[preferences.scaleTonicNote.value]
  local scaleTypeText = scales[preferences.scaleType.value].name
  local scaleNotesText = preferences.scaleNotesText.value
  renoise.app():show_status(("%s %s: %s"):format(scaleTonicText, scaleTypeText, scaleNotesText))
end

local dialog = nil

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:ArpGun",
  invoke = function()

    if dialog ~= nil and dialog.visible then
      dialog:show()
      return
    end

    viewBuilder = renoise.ViewBuilder()
    preferences = ToolPreferences()
    preferences:loadValues()

    local dialogView = getDialogView()
    dialog = renoise.app():show_custom_dialog('ArpGun', dialogView, keyHandler)
    updateScaleData()
    highlightSelectedChordTypes()
  end
}
