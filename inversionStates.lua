inversionStates = {}

function updateInversionStates()

  inversionStates = {}

  local scaleNoteIndex = 1
  for note = preferences.scaleTonicNote.value, preferences.scaleTonicNote.value + 11 do
  
    if noteIsInScale(note) then

      if inversionStates[scaleNoteIndex] == nil then
        inversionStates[scaleNoteIndex] = {}
      end
      
      local chordCount = 0

      for k, chord in ipairs(chords) do

        if chordIsInScale(note, k) then
          chordCount = chordCount + 1

          if inversionStates[scaleNoteIndex][chordCount] == nil then
            inversionStates[scaleNoteIndex][chordCount] = 0
          end
        end
      end
    
      scaleNoteIndex = scaleNoteIndex + 1
    end
  end
end

function setInversionState(scaleDegree, chordTypeIndex, inversionValue)
  
  if scaleDegree == 1 then
    preferences.selectedInversionStates1[chordTypeIndex].value = inversionValue
  end
  
  if scaleDegree == 2 then
    preferences.selectedInversionStates2[chordTypeIndex].value = inversionValue
  end
  
  if scaleDegree == 3 then
    preferences.selectedInversionStates3[chordTypeIndex].value = inversionValue
  end
  
  if scaleDegree == 4 then
    preferences.selectedInversionStates4[chordTypeIndex].value = inversionValue
  end
  
  if scaleDegree == 5 then
    preferences.selectedInversionStates5[chordTypeIndex].value = inversionValue
  end
  
  if scaleDegree == 6 then
    preferences.selectedInversionStates6[chordTypeIndex].value = inversionValue
  end
  
  if scaleDegree == 7 then
    preferences.selectedInversionStates7[chordTypeIndex].value = inversionValue
  end
end

function getCurrentInversionValue()

  local selectedScaleDegree = preferences.selectedScaleDegree.value
  local selectedChordTypeIndex = preferences.selectedChordTypes[selectedScaleDegree].value
  
  if selectedScaleDegree == 1 then
    return preferences.selectedInversionStates1[selectedChordTypeIndex].value
  end
  
  if selectedScaleDegree == 2 then
    return preferences.selectedInversionStates2[selectedChordTypeIndex].value
  end
  
  if selectedScaleDegree == 3 then
    return preferences.selectedInversionStates3[selectedChordTypeIndex].value
  end
  
  if selectedScaleDegree == 4 then
    return preferences.selectedInversionStates4[selectedChordTypeIndex].value
  end
  
  if selectedScaleDegree == 5 then
    return preferences.selectedInversionStates5[selectedChordTypeIndex].value
  end
  
  if selectedScaleDegree == 6 then
    return preferences.selectedInversionStates6[selectedChordTypeIndex].value
  end
  
  if selectedScaleDegree == 7 then
    return preferences.selectedInversionStates7[selectedChordTypeIndex].value
  end
end
