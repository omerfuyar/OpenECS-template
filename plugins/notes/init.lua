-- A board of short notes: a list to choose from, a field to write a new one, and buttons. It shows the parts most plugins use:
-- a panel type, a standard plugin (ui), a setting, a function bound to a key, and state saved in the session.

local ecs = require("ecs") -- the plugin interface; each plugin gets its own
local ui = require("ui")   -- the functions of the ui plugin, which the manifest depends on

-- ui's own styles, which its standard views use too
local STYLES = ui.styles()

-- version of the state a board saves; a board restores only a state of this version
local STATE_VERSION = 1

local boards = {} -- every open board, by its panel handle

-- a setting: the settings window (Alt+W, then ",") lists it, and the user's settings file can change it
-- the name is local: OpenECS declares it as "notes.newestFirst"
ecs.setting.declare({
  name = "newestFirst",
  type = "bool",
  description = "Show the newest note at the top of the board",
  default = true,
  changed = function()
    for panel in pairs(boards) do
      panel:redraw()
    end
  end,
})

-- a board is an object of the class Board: its functions are methods, which get the board as self
local Board = {}
Board.__index = Board

-- runs when a board opens; saved is what saveState gave when the session was saved, or nil for a new board
function Board.create(panel, saved, version)
  local board = setmetatable({ panel = panel, notes = {}, draft = "", selected = 1 }, Board)

  if version == STATE_VERSION and saved then
    board.notes = saved.notes or {}
  end

  panel.title = ("Notes (%d)"):format(#board.notes)
  boards[panel] = board
  return board
end

-- the notes in the order the setting asks for, each with its place in self.notes
function Board:shown()
  local list = {}

  for i, note in ipairs(self.notes) do
    list[#list + 1] = { index = i, text = note }
  end

  if ecs.setting.get("notes.newestFirst") then
    table.sort(list, function(a, b)
      return a.index > b.index
    end)
  end

  return list
end

function Board:add(text)
  if text ~= "" then
    self.notes[#self.notes + 1] = text
    self.draft = ""
    self.panel.title = ("Notes (%d)"):format(#self.notes)
  end
end

function Board:remove()
  local note = self:shown()[self.selected]

  if note then
    table.remove(self.notes, note.index)
    self.selected = math.min(self.selected, #self.notes)
    self.panel.title = ("Notes (%d)"):format(#self.notes)
    self.panel:redraw()
  end
end

-- gives the board's elements each time it draws; ui lays them out and draws them
function Board:view()
  local items = {}

  for _, note in ipairs(self:shown()) do
    items[#items + 1] = ui.row({ padding = 4 }, { ui.text(note.text) })
  end

  if #items == 0 then
    items[1] = ui.text("No notes yet.", { style = STYLES.note, selectable = false })
  end

  return ui.column({ padding = 16, gap = 8 }, {
    ui.row({ gap = 8 }, {
      ui.field(self.draft, {
        id = "draft",
        grow = 1,
        onChange = function(text) self.draft = text end,
        onSubmit = function(text) self:add(text) end,
      }),
      ui.button("Add", { onClick = function() self:add(self.draft) end }),
      ui.button("Remove", { onClick = function() self:remove() end }),
    }),
    ui.list({
      id = "notes",
      selected = self.selected,
      onSelect = function(index) self.selected = index end,
    }, items),
  })
end

-- what the session keeps of the board
function Board:saveState()
  return { notes = self.notes }
end

function Board:destroy()
  boards[self.panel] = nil
end

-- the type names the class's methods; the core calls them with the board, as board:saveState() does. ui.panelType fills in draw, which shows
-- what view gives, event, which gives the board's events to its elements, and destroy's part of ui
ecs.panel.registerType(ui.panelType({
  name = "board", -- the local name; presets name the type "notes.board"
  title = "Notes",
  stateVersion = STATE_VERSION,
  create = Board.create,
  view = Board.view,
  saveState = Board.saveState,
  destroy = Board.destroy,
}))

-- a function that keys and other plugins can run; its full name is "notes.remove"
ecs.service.register({
  remove = {
    sig = "void(handle<ecs.panel> panel)",
    doc = "Remove the chosen note",
    fn = function(panel)
      local board = boards[panel]

      -- a key in the board's field types text, so Delete removes a note only while no field has the keys
      if board and not ui.focus(panel) then
        board:remove()
      end
    end,
  },
})

-- Delete runs it while a board has the focus; presets and the user's settings can change the key
ecs.key.bind("notes.board", "Delete", "notes.remove")
ecs.panel.addMenuEntry("notes.board", "notes.remove")
