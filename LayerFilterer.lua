-- Aseprite Layer Filter Plugin

local dlg = Dialog { title = "Layer Filterer" }

-- Store the searched layer name
local layerName = ""

-- Recursively hide all layers except the one(s) matching the search, and make parent groups visible if a match is found
local function filterLayers(layer, searchName)
  local found = false
  if layer.isGroup then
    -- Check all children recursively
    local groupHasMatch = false
    for _, child in ipairs(layer.layers) do
      local childHasMatch = filterLayers(child, searchName)
      groupHasMatch = groupHasMatch or childHasMatch
    end
    layer.isVisible = groupHasMatch
    found = groupHasMatch
  else
    if layer.isEditable then
      if layer.name:lower():find(searchName:lower()) then
        layer.isVisible = true
        found = true
      else
        layer.isVisible = false
      end
    end
  end
  return found
end

-- Recursively unhide all unlocked layers and groups
local function unhideLayers(layer)
  if layer.isEditable then
    layer.isVisible = true
  end
  if layer.isGroup then
    for _, child in ipairs(layer.layers) do
      unhideLayers(child)
    end
  end
end

-- UI: Text field to filter layer name
dlg:entry {
  id = "layerName",
  label = "Layer Name:",
  text = "",
  onchange = function()
    layerName = dlg.data.layerName or ""
  end
}

-- Button: Hide all layers except for the provided, searched layer
dlg:button {
  id = "filterBtn",
  text = "Isolate Layer",
  onclick = function()
    local sprite = app.activeSprite
    if not sprite then
      app.alert("No active sprite!")
      return
    end
    if not layerName or layerName == "" then
      app.alert("Please enter a layer name to search for.")
      return
    end
    for _, layer in ipairs(sprite.layers) do
      filterLayers(layer, layerName)
    end
    app.refresh()
  end
}

-- Button: Unhide all layers (only unlocked layers)
dlg:button {
  id = "unhideBtn",
  text = "Unhide All",
  onclick = function()
    local sprite = app.activeSprite
    if not sprite then
      app.alert("No active sprite!")
      return
    end
    for _, layer in ipairs(sprite.layers) do
      unhideLayers(layer)
    end
    app.refresh()
  end
}

dlg:show { wait = false }