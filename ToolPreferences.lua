require 'defaultValues'
require 'scaleFunctions'
require 'inversionStates'

preferences = nil

class 'ToolPreferences'(renoise.Document.DocumentNode)

function ToolPreferences:__init()

  renoise.Document.DocumentNode.__init(self)

  self:add_property("optionsPanelIsVisible", defaultOptionsPanelIsVisibleValue)
  self:add_property("insertNoteOffInRemainingNoteColumns", defaultInsertNoteOffInRemainingNoteColumnsValue)
  self:add_property("scaleTonicNote", defaultScaleTonicNoteValue)
  self:add_property("chordText", defaultChordTextValue)
  self:add_property("scaleType", defaultScaleTypeValue)
  self:add_property("scaleNoteNames", {'C', 'D', 'E', 'F', 'G', 'A', 'B'})
  self:add_property("scaleNotesText", defaultScaleNotesTextValue)
  self:add_property("scaleDegreeHeaders", {'I', 'ii', 'iii', 'IV', 'V', 'vi', 'vii°'})

  self:add_property("chordInversion", defaultChordInversion)
  self:add_property("chordInversionMin", defaultChordInversionMin)
  self:add_property("chordInversionMax", defaultChordInversionMax)

  self:add_property("selectedScaleDegree", defaultSelectedScaleDegree)

  self:add_property("selectedChordTypes", defaultSelectedChordTypes)

  self:add_property("selectedInversionStates1", defaultSelectedInversionStates)
  self:add_property("selectedInversionStates2", defaultSelectedInversionStates)
  self:add_property("selectedInversionStates3", defaultSelectedInversionStates)
  self:add_property("selectedInversionStates4", defaultSelectedInversionStates)
  self:add_property("selectedInversionStates5", defaultSelectedInversionStates)
  self:add_property("selectedInversionStates6", defaultSelectedInversionStates)
  self:add_property("selectedInversionStates7", defaultSelectedInversionStates)

  self:add_property("addTriggerNoteCheckbox", defaultAddTriggerNoteCheckboxValue)
  self:add_property("triggerNote", defaultTriggerNoteValue)
  self:add_property("enableModalMixtureCheckbox", defaultEnableModalMixtureCheckboxValue)
  self:add_property("modalMixtureScaleType", defaultModalMixtureScaleTypeValue)
  self:add_property("enableAllChordsCheckbox", defaultEnableAllChordsCheckboxValue)

  self:add_property("arpPattern", defaultArpPatternValue)
  self:add_property("arpStep", defaultArpStepValue)
  self:add_property("arpWriteMode", defaultArpWriteModeValue)
  self:add_property("arpTimingMode", defaultArpTimingModeValue)
  self:add_property("euclideanHits", defaultEuclideanHitsValue)
  self:add_property("euclideanLength", defaultEuclideanLengthValue)
  self:add_property("euclideanShift", defaultEuclideanShiftValue)
end

function ToolPreferences:loadValues()
  self:load_from("preferences.xml")
end

function ToolPreferences:saveValues()
  self.chordInversion.value = getCurrentInversionValue()
  self:save_as("preferences.xml")
end

function ToolPreferences:resetSelectedChordTypes()

  for i = 1, #self.selectedChordTypes do
    self.selectedChordTypes[i].value = 1
  end
end

function ToolPreferences:resetSelectedInversionStates()

  for i = 1, #self.selectedInversionStates1 do
    self.selectedInversionStates1[i].value = 0
  end

  for i = 1, #self.selectedInversionStates2 do
    self.selectedInversionStates2[i].value = 0
  end

  for i = 1, #self.selectedInversionStates3 do
    self.selectedInversionStates3[i].value = 0
  end

  for i = 1, #self.selectedInversionStates4 do
    self.selectedInversionStates4[i].value = 0
  end

  for i = 1, #self.selectedInversionStates5 do
    self.selectedInversionStates5[i].value = 0
  end

  for i = 1, #self.selectedInversionStates6 do
    self.selectedInversionStates6[i].value = 0
  end

  for i = 1, #self.selectedInversionStates7 do
    self.selectedInversionStates7[i].value = 0
  end

  self.chordInversion.value = 0
end
