local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  error("This extension requires telescope.nvim")
end

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local function show_menu()

  local window_ids = {}

  local windows = vim.api.nvim_list_wins()
  for _, win_id in ipairs(windows) do
    table.insert(window_ids, win_id)
  end


  pickers.new({}, {
    prompt_title = "Select an Option",
    finder = finders.new_table({
      results = window_ids,
      entry_maker = function(entry)
        local buf_id = vim.api.nvim_win_get_buf(entry)
        local buf_name = vim.api.nvim_buf_get_name(buf_id)
        return {
          value = entry,
          display = buf_name,
          ordinal = buf_name,
        }
      end,
    }),
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          vim.notify("setting focus to window " .. selection.value)
          vim.api.nvim_set_current_win(selection.value)
        end
      end)
      return true
    end,
  }):find()
end

return require('telescope').register_extension({
  exports = {
    winsearch = show_menu
  },
})

