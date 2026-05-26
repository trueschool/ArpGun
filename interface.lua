require 'ToolPreferences'
require 'scaleFunctions'

BUTTON_WIDTH = 73

viewBuilder = nil

chordTypeColumns = {}

scaleNames = {}
for key, scale in ipairs(scales) do
  table.insert(scaleNames, scale['name'])
end

function setInversion(value)

  local selectedScaleDegree = preferences.selectedScaleDegree.value
  local selectedChordTypeIndex = preferences.selectedChordTypes[selectedScaleDegree].value

  setInversionState(selectedScaleDegree, selectedChordTypeIndex, value)
  insertChord(selectedScaleDegree)
end

function highlightSelectedChordTypes()

  if viewBuilder == nil then
    return
  end

  for i = 1, #preferences.selectedChordTypes do

    if scaleChords[i] then

      for j = 1, #scaleChords[i] do

        local chordTypeBox = viewBuilder.views[string.format("%i:%i", i, j)]

        if j == preferences.selectedChordTypes[i].value then

          if i == preferences.selectedScaleDegree.value then
            viewBuilder.views[string.format("%i:%i", i, j)].color = {0xdc, 0xdc, 0xdc}
          else
            viewBuilder.views[string.format("%i:%i", i, j)].color = {0x47, 0x47, 0x47}
          end

        else

          viewBuilder.views[string.format("%i:%i", i, j)].color = {0x2d, 0x2d, 0x2d}
        end

      end
    end
  end
end

function getDialogView ()

  for i = 1, 7 do
    chordTypeColumns[i] = viewBuilder:column {
      style = 'panel',
      viewBuilder:text{
        id = 'scaleDegreeHeader' .. i,
        align = 'center',
        width = BUTTON_WIDTH,
        font = 'bold',
        text = preferences.scaleDegreeHeaders[i].value
      }
    }
  end

  return viewBuilder:column {

          margin = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN,

          viewBuilder:row {

            spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING*3,

            viewBuilder:column {
              spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,

              viewBuilder:horizontal_aligner {

                spacing = 1,
                viewBuilder:row {

                  id = "main_row",
                  spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
                  margin = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN,
                  style = 'group',

                  viewBuilder:text { text = 'Scale:' },

                  viewBuilder:popup {
                    id = "scale_tonic",
                    items = notes,
                    bind = preferences.scaleTonicNote,
                    width = 50,
                    notifier = function (i)

                        clearChordBoxes()

                        preferences.scaleTonicNote.value = i
                        preferences:resetSelectedChordTypes()
                        preferences:resetSelectedInversionStates()
                        updateScaleData()
                        preferences:saveValues()
                        showScaleStatus()
                        updateScaleDegreeHeaders()
                    end
                  },

                  viewBuilder:popup {
                    id = "scale",
                    width = 183,
                    items = scaleNames,
                    bind = preferences.scaleType,
                    notifier = function (i)

                        clearChordBoxes()

                        preferences.scaleType.value = i
                        preferences:resetSelectedChordTypes()
                        preferences:resetSelectedInversionStates()
                        updateScaleData()
                        preferences:saveValues()
                        showScaleStatus()
                        updateScaleDegreeHeaders()
                    end
                  },

                  viewBuilder:space { width = 5 },
                  viewBuilder:text{
                    id = 'scale_notes',
                    align = 'center',
                    width = 183,
                    font = 'bold',
                    text = preferences.scaleNotesText.value
                  },
                },

                viewBuilder:button {
                  id = "options",
                  height = "100%",
                  text = "options",
                  pressed = function()

                    if preferences.optionsPanelIsVisible.value then
                      viewBuilder.views.options_row.visible = false
                      preferences.optionsPanelIsVisible.value = false
                    else
                      viewBuilder.views.options_row.visible = true
                      preferences.optionsPanelIsVisible.value = true
                    end

                    preferences:saveValues()
                  end
                  },
                },
                viewBuilder:column {

                  id = "chord_view",
                  style = 'group',
                  margin = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN,
                  spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
                  height = 200,

                  viewBuilder:horizontal_aligner {

                      mode = "justify",

                      viewBuilder:column {
                          viewBuilder:text{
                            id = 'chord_text',
                            width = 160,
                            text = preferences.chordText.value,
                            font = 'bold',
                          },
                      },

                      viewBuilder:column {
                        viewBuilder:horizontal_aligner {
                          viewBuilder:text { text = "Inversion: " },
                          viewBuilder:valuebox {
                            id = "chord_inversion",
                            bind = preferences.chordInversion,
                            min = preferences.chordInversionMin.value,
                            max = preferences.chordInversionMax.value,
                            notifier = function(value)
                              setInversion(value)
                              preferences:saveValues()
                            end},
                          },
                        },
                      },
                    viewBuilder:row{
                    margin = 0,
                    spacing = 0,
                      chordTypeColumns[1],
                      chordTypeColumns[2],
                      chordTypeColumns[3],
                      chordTypeColumns[4],
                      chordTypeColumns[5],
                      chordTypeColumns[6],
                      chordTypeColumns[7]
                    },
                  },
                },
              viewBuilder:row {
                id = "options_row",
                style = 'group',
                width = 700,
                spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
                margin = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN,
                visible = preferences.optionsPanelIsVisible.value,

                viewBuilder:vertical_aligner {

                  viewBuilder:horizontal_aligner {

                    viewBuilder:text {
                        font = 'bold',
                        text = "options:"
                    }
                  },

                  viewBuilder:horizontal_aligner {

                      mode = "left",
                      viewBuilder:row {
                        viewBuilder:checkbox {
                          id = "insert_note_offs",
                          bind = preferences.insertNoteOffInRemainingNoteColumns,
                          notifier = function()
                            preferences:saveValues()
                          end
                        },
                        viewBuilder:text { text = "insert note offs" }
                    },
                  },

                  viewBuilder:horizontal_aligner {

                      mode = "left",
                      viewBuilder:row {
                        viewBuilder:checkbox {
                          id = "enable_modal_mixture",
                          bind = preferences.enableModalMixtureCheckbox,
                          notifier = function()

                            if preferences.enableModalMixtureCheckbox.value == true then
                              viewBuilder.views.modal_mixture_scale.active = true
                            else
                              viewBuilder.views.modal_mixture_scale.active = false
                            end

                            clearChordBoxes()
                            preferences:resetSelectedChordTypes()
                            preferences:resetSelectedInversionStates()
                            updateScaleData()
                            preferences:saveValues()
                          end
                        },
                        viewBuilder:text { text = "modal mixture" }
                    },
                  },
                  viewBuilder:popup {
                    id = "modal_mixture_scale",
                    items = scaleNames,
                    active = preferences.enableModalMixtureCheckbox.value,
                    width = 120,
                    bind = preferences.modalMixtureScaleType,
                    notifier = function (i)

                      clearChordBoxes()
                      preferences:resetSelectedChordTypes()
                      preferences:resetSelectedInversionStates()
                      updateScaleData()
                      preferences:saveValues()
                    end
                  },

                  viewBuilder:horizontal_aligner {

                      mode = "left",
                      viewBuilder:row {
                        viewBuilder:checkbox {
                          bind = preferences.enableAllChordsCheckbox,
                          notifier = function()

                            clearChordBoxes()
                            preferences:resetSelectedChordTypes()
                            preferences:resetSelectedInversionStates()
                            updateScaleData()
                            preferences:saveValues()
                          end
                        },
                        viewBuilder:text { text = "all chords" }
                    },
                  },

                  viewBuilder:horizontal_aligner {

                      mode = "left",
                      viewBuilder:row {
                        viewBuilder:checkbox {
                          id = "trigger_note_checkbox",
                          bind = preferences.addTriggerNoteCheckbox,
                          notifier = function()

                            preferences:saveValues()

                            if preferences.addTriggerNoteCheckbox.value == true then
                              viewBuilder.views.trigger_note.active = true
                            else
                              viewBuilder.views.trigger_note.active = false
                            end

                          end
                        },
                        viewBuilder:text { text = "add trigger note" }
                    },
                  },

                   viewBuilder:horizontal_aligner {

                    mode = "center",
                    viewBuilder:valuebox {
                                          id = 'trigger_note',
                                          active = preferences.addTriggerNoteCheckbox.value,
                                          width = 80,
                                          min = 0,
                                          max = 119,
                                          bind = preferences.triggerNote,
                                          notifier = function(newValue)

                                          end,
                                          tostring = function(value)
                                            return getSharpNoteName(value+1) .. getOctave(value)
                                          end,
                                          tonumber = function(string)
                                            return tonumber(string)
                                          end
                                         }
                   },

                   viewBuilder:horizontal_aligner {
                      mode = "left",
                      viewBuilder:row {
                        viewBuilder:text { text = "Arp Pattern: ", font = "bold" },
                        viewBuilder:popup {
                          id = "arp_pattern",
                          items = arpPatterns,
                          bind = preferences.arpPattern,
                          width = 100,
                          notifier = function()
                            preferences:saveValues()
                          end
                        },
                      }
                   },

                   viewBuilder:horizontal_aligner {
                      mode = "left",
                      viewBuilder:row {
                        viewBuilder:text { text = "Timing: ", font = "bold" },
                        viewBuilder:popup {
                          id = "arp_timing_mode",
                          items = arpTimingModes,
                          bind = preferences.arpTimingMode,
                          width = 80,
                          notifier = function()
                            local is_euclidean = (preferences.arpTimingMode.value == 2)
                            viewBuilder.views.standard_step_row.visible = not is_euclidean
                            viewBuilder.views.euclidean_row.visible = is_euclidean
                            preferences:saveValues()
                          end
                        },
                      }
                   },

                   viewBuilder:horizontal_aligner {
                      mode = "left",
                      viewBuilder:row {
                        id = "standard_step_row",
                        visible = (preferences.arpTimingMode.value == 1),
                        viewBuilder:text { text = "Arp Step: ", font = "bold" },
                        viewBuilder:popup {
                          id = "arp_step",
                          items = arpSteps,
                          bind = preferences.arpStep,
                          width = 50,
                          notifier = function()
                            preferences:saveValues()
                          end
                        },
                      }
                   },

                   viewBuilder:horizontal_aligner {
                      mode = "left",
                      viewBuilder:row {
                        id = "euclidean_row",
                        visible = (preferences.arpTimingMode.value == 2),
                        viewBuilder:text { text = "Hits: ", font = "bold" },
                        viewBuilder:valuebox {
                          id = "euclid_hits",
                          bind = preferences.euclideanHits,
                          min = 1,
                          max = 64,
                          notifier = function() preferences:saveValues() end
                        },
                        viewBuilder:text { text = "Len: ", font = "bold" },
                        viewBuilder:valuebox {
                          id = "euclid_len",
                          bind = preferences.euclideanLength,
                          min = 1,
                          max = 64,
                          notifier = function() preferences:saveValues() end
                        },
                        viewBuilder:text { text = "Shift: ", font = "bold" },
                        viewBuilder:valuebox {
                          id = "euclid_shift",
                          bind = preferences.euclideanShift,
                          min = 0,
                          max = 64,
                          notifier = function() preferences:saveValues() end
                        },
                      }
                   },

                   viewBuilder:horizontal_aligner {
                      mode = "left",
                      viewBuilder:row {
                        viewBuilder:text { text = "Arp Mode: ", font = "bold" },
                        viewBuilder:popup {
                          id = "arp_write_mode",
                          items = arpWriteModes,
                          bind = preferences.arpWriteMode,
                          width = 80,
                          notifier = function()
                            preferences:saveValues()
                          end
                        },
                      }
                   },

                   --[[]]--

              }
            }
          }
        }
end
