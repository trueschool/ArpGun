require 'chords'

defaultOptionsPanelIsVisibleValue = true
defaultInsertNoteOffInRemainingNoteColumnsValue = false
defaultScaleTonicNoteValue = 1
defaultScaleTypeValue = 1
defaultScaleNotesTextValue = ''
defaultChordTextValue = ''
defaultChordInversion = 0
defaultChordInversionMin = -8
defaultChordInversionMax = 8
defaultSelectedScaleDegree = 1

defaultSelectedChordTypes = {}
for i = 1, 7 do
  table.insert(defaultSelectedChordTypes, 1)
end

defaultSelectedInversionStates = {}
for i = 1, #chords*2 do
  table.insert(defaultSelectedInversionStates, 0)
end

defaultTriggerNoteValue = 12
defaultAddTriggerNoteCheckboxValue = false
defaultEnableModalMixtureCheckboxValue = false
defaultModalMixtureScaleTypeValue = 2
defaultEnableAllChordsCheckboxValue = false

defaultArpPatternValue = 1
defaultArpStepValue = 1
defaultArpWriteModeValue = 1
defaultArpTimingModeValue = 1
defaultEuclideanHitsValue = 3
defaultEuclideanLengthValue = 8
defaultEuclideanShiftValue = 0

arpTimingModes = {
  "standard",
  "euclidean"
}

arpPatterns = {
  "none",
  "up",
  "down",
  "up/down",
  "down/up",
  "up/down/up",
  "down/up/down",
  "strum up",
  "strum down",
  "dyads"
}

arpSteps = {
  "1",
  "2",
  "3",
  "4",
  "6",
  "8",
  "12",
  "16",
  "32"
}

arpWriteModes = {
  "overwrite",
  "merge"
}
