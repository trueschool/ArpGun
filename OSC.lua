previousChordNotesArray = nil

function connectOSC()
  -- Left empty; OSC networking removed in favor of direct Renoise 6.2 API calls
end

function getVelocityValue()
  if renoise.song().transport.keyboard_velocity_enabled then
    return renoise.song().transport.keyboard_velocity
  else
    return 127
  end
end

function stopPreviousChord(chordNotesArray)
  local song = renoise.song()
  local instrument_index = song.selected_instrument_index
  local track_index = song.selected_track_index

  for i = 1, #chordNotesArray do
    local note = chordNotesArray[i]
    -- Renoise API takes raw note values (0 = C-0, 119 = B-9)
    song:trigger_instrument_note_off(instrument_index, track_index, note)
  end
end

function playChordWithOsc(chordNotesArray)
  -- Stop the previous chord if it is still playing
  if previousChordNotesArray ~= nil then
    stopPreviousChord(previousChordNotesArray)
  end

  local song = renoise.song()
  local instrument_index = song.selected_instrument_index
  local track_index = song.selected_track_index

  -- The Renoise API expects volume normalized between 0.0 and 1.0
  local velocityValue = getVelocityValue()
  local volume = velocityValue / 127.0

  for i = 1, #chordNotesArray do
    local note = chordNotesArray[i]
    song:trigger_instrument_note_on(instrument_index, track_index, note, volume)
  end

  previousChordNotesArray = chordNotesArray
end
