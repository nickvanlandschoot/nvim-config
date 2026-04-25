local model = require("diagram-editor.model")
local renderer = require("diagram-editor.renderer")
local parser = require("diagram-editor.parser")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

local M = {}

-- forward declarations for mutual recursion
local open_picker, handle_action, save_and_close, save_to_buffer, reopen_picker

--- Safely reopen the picker, ensuring we're out of insert mode
--- @param state MenuState
reopen_picker = function(state)
  vim.schedule(function()
    -- Force escape and stop insert
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    vim.cmd('stopinsert')
    -- Clear any pending input in the typeahead buffer
    vim.api.nvim_feedkeys('', 'x', false)
    vim.schedule(function()
      open_picker(state)
    end)
  end)
end

--- Open a Telescope-based input prompt that supports vim motions
--- @param opts table { prompt: string, default: string, on_submit: function }
local function telescope_input(opts)
  vim.schedule(function()
    -- Force escape and stop insert
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    vim.cmd('stopinsert')
    -- Clear any pending input in the typeahead buffer
    vim.api.nvim_feedkeys('', 'x', false)
    vim.schedule(function()
      local input_state = { submitted = false, value = nil }

      pickers.new({}, {
        prompt_title = opts.prompt or "Input",
        finder = finders.new_table({ results = {} }),
        sorter = conf.generic_sorter({}),
        previewer = false,
        default_text = opts.default or "",
        layout_strategy = "center",
        layout_config = {
          width = 60,
          height = 1,
        },
        sorting_strategy = "ascending",
        results_title = false,
        borderchars = {
          prompt = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          results = { " ", " ", " ", " ", " ", " ", " ", " " },
          preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        },
        attach_mappings = function(prompt_bufnr, map)
          -- Prevent default close on Esc - we want to use Esc for normal mode
          actions.close:replace(function()
            -- Ctrl+C or Ctrl+Q to cancel
            input_state.submitted = false
            input_state.value = nil
            vim.api.nvim_buf_delete(prompt_bufnr, { force = true })
            if opts.on_cancel then
              vim.schedule(function()
                -- Clear input before calling callback
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
                vim.cmd('stopinsert')
                vim.api.nvim_feedkeys('', 'x', false)
                vim.schedule(opts.on_cancel)
              end)
            end
          end)

          -- Enter to submit (works in both insert and normal mode)
          local submit = function()
            local picker = action_state.get_current_picker(prompt_bufnr)
            local text = picker:_get_prompt()
            input_state.submitted = true
            input_state.value = text
            actions.close(prompt_bufnr)
            if opts.on_submit then
              vim.schedule(function()
                -- Clear input before calling callback
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
                vim.cmd('stopinsert')
                vim.api.nvim_feedkeys('', 'x', false)
                vim.schedule(function()
                  opts.on_submit(text)
                end)
              end)
            end
          end

          map("i", "<CR>", submit)
          map("n", "<CR>", submit)

          -- Ctrl+C and Ctrl+Q to cancel
          map("i", "<C-c>", function()
            actions.close(prompt_bufnr)
          end)
          map("n", "<C-c>", function()
            actions.close(prompt_bufnr)
          end)
          map("i", "<C-q>", function()
            actions.close(prompt_bufnr)
          end)
          map("n", "<C-q>", function()
            actions.close(prompt_bufnr)
          end)

          return true
        end,
      }):find()
    end)
  end)
end

--- @class MenuState
--- @field root table root node of the tree
--- @field current_id string ID of the currently navigated node
--- @field nav_stack string[] stack of node IDs for back navigation
--- @field bufnr number buffer number containing the diagram
--- @field region table { start_line, end_line, name }

--- Build a path label for a node (e.g. "Root > Phase 1 > SubNode").
--- @param root table
--- @param node_id string
--- @return string
local function path_label(root, node_id)
  local path = model.get_path(root, node_id)
  local parts = {}
  for _, n in ipairs(path) do
    local content = n.content
    if type(content) == "table" then
      content = content[1] or ""
    end
    parts[#parts + 1] = content or ""
  end
  return table.concat(parts, " > ")
end

--- Recursively collect all nodes in the tree with their path labels.
--- @param root table the tree root
--- @param node table current node being visited
--- @param entries table[] accumulator
local function collect_all_nodes(root, node, entries)
  local content = node.content
  if type(content) == "table" then
    content = content[1] or ""
  end
  local full_path = path_label(root, node.id)

  -- Extract node name (last part of path) and parent path
  local node_name = content or ""
  local parent_path = ""
  local last_sep = full_path:match("^.*()>")
  if last_sep then
    parent_path = full_path:sub(1, last_sep - 1):gsub("%s+$", "")
    node_name = full_path:sub(last_sep + 1):gsub("^%s+", "")
  else
    node_name = full_path
  end

  -- Format: "NodeName  →  Parent > Path" or just "NodeName" if root
  local display_text
  if parent_path ~= "" then
    display_text = string.format("[%s] %s  →  %s", node.type, node_name, parent_path)
  else
    display_text = string.format("[%s] %s", node.type, node_name)
  end

  entries[#entries + 1] = {
    display = display_text,
    -- Prioritize node name first, then path for fuzzy matching
    ordinal = node_name .. " " .. node.type .. " " .. full_path,
    action_type = "jump_to",
    data = { node_id = node.id },
  }
  for _, child in ipairs(node.children) do
    collect_all_nodes(root, child, entries)
  end
end

--- Build the list of menu entries for the current node.
--- @param state MenuState
--- @return table[] entries { display, action_type, data }
local function build_entries(state)
  local node = model.find_node(state.root, state.current_id)
  if not node then
    return {}
  end

  local entries = {}

  -- action entries for the current node
  entries[#entries + 1] = {
    display = "[+] Add child to: " .. model.display_label(node),
    ordinal = "+ add child",
    action_type = "add_child",
  }
  -- sibling insertion only available if not root
  if state.current_id ~= state.root.id then
    entries[#entries + 1] = {
      display = "[<] Add sibling before: " .. model.display_label(node),
      ordinal = "< add sibling before",
      action_type = "add_sibling_before",
    }
    entries[#entries + 1] = {
      display = "[>] Add sibling after: " .. model.display_label(node),
      ordinal = "> add sibling after",
      action_type = "add_sibling_after",
    }
  end
  entries[#entries + 1] = {
    display = "[e] Edit content: " .. model.display_label(node),
    ordinal = "e edit content",
    action_type = "edit_content",
  }
  entries[#entries + 1] = {
    display = "[t] Change type: " .. model.display_label(node),
    ordinal = "t change type",
    action_type = "change_type",
  }
  entries[#entries + 1] = {
    display = "[l] Toggle layout (" .. node.layout .. "): " .. model.display_label(node),
    ordinal = "l toggle layout",
    action_type = "toggle_layout",
  }
  if state.current_id ~= state.root.id then
    entries[#entries + 1] = {
      display = "[x] Delete: " .. model.display_label(node),
      ordinal = "x delete",
      action_type = "delete",
    }
  end
  entries[#entries + 1] = {
    display = "[s] Save & Close",
    ordinal = "s save close",
    action_type = "save_and_close",
  }

  -- all nodes in the tree, searchable
  collect_all_nodes(state.root, state.root, entries)

  return entries
end

--- Build breadcrumb string for the current navigation position.
--- @param state MenuState
--- @return string
local function build_breadcrumb(state)
  local path = model.get_path(state.root, state.current_id)
  local parts = {}
  for _, node in ipairs(path) do
    local content = node.content
    if type(content) == "table" then
      content = content[1] or ""
    end
    local label = content or ""
    if #label > 20 then
      label = label:sub(1, 17) .. "..."
    end
    parts[#parts + 1] = label
  end
  return table.concat(parts, " > ") .. " > "
end

--- Create a previewer that shows the rendered ASCII diagram.
--- @param state MenuState
--- @return table previewer
local function create_previewer(state)
  return previewers.new_buffer_previewer({
    title = "Diagram Preview",
    define_preview = function(self, _, _)
      local lines = renderer.render_to_lines(state.root)
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
    end,
  })
end

--- Open the Telescope picker for the current menu state.
--- @param state MenuState
open_picker = function(state)
  local entries = build_entries(state)
  local breadcrumb = build_breadcrumb(state)

  pickers.new({}, {
    prompt_title = breadcrumb .. "Actions",
    finder = finders.new_table({
      results = entries,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.ordinal or entry.display,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = create_previewer(state),
    attach_mappings = function(prompt_bufnr, map)
      -- Override close action to prompt for confirmation
      actions.close:replace(function()
        -- Close the picker first
        if vim.api.nvim_buf_is_valid(prompt_bufnr) then
          vim.api.nvim_buf_delete(prompt_bufnr, { force = true })
        end

        -- Then prompt
        vim.schedule(function()
          vim.ui.select(
            { "Save & Close", "Close without saving", "Cancel" },
            { prompt = "Unsaved changes:" },
            function(choice)
              if choice == "Save & Close" then
                save_and_close(state)
              elseif choice == "Close without saving" then
                vim.notify("Diagram changes discarded", vim.log.levels.WARN)
              else
                -- Cancel - reopen the picker
                reopen_picker(state)
              end
            end
          )
        end)
      end)

      -- CR: execute action or navigate
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if not selection then
          return
        end
        local entry = selection.value
        actions.close(prompt_bufnr)

        if entry.action_type == "separator" then
          -- re-open the menu
          reopen_picker(state)
          return
        end

        vim.schedule(function()
          handle_action(state, entry)
        end)
      end)

      -- C-h: navigate back to parent
      map("i", "<C-h>", function()
        if #state.nav_stack > 0 then
          state.current_id = table.remove(state.nav_stack)
          actions.close(prompt_bufnr)
          reopen_picker(state)
        end
      end)

      -- C-s: save (keep menu open)
      map("i", "<C-s>", function()
        save_to_buffer(state)
        -- refresh the picker to update preview
        actions.close(prompt_bufnr)
        reopen_picker(state)
      end)

      -- M-k (Alt+k): move selected child up
      map("i", "<M-k>", function()
        local selection = action_state.get_selected_entry()
        if selection and selection.value.action_type == "navigate_child" then
          local node = model.find_node(state.root, state.current_id)
          local idx = selection.value.data.index
          if node and idx > 1 then
            model.move_child(node, idx, idx - 1)
            actions.close(prompt_bufnr)
            reopen_picker(state)
          end
        end
      end)

      -- M-j (Alt+j): move selected child down
      map("i", "<M-j>", function()
        local selection = action_state.get_selected_entry()
        if selection and selection.value.action_type == "navigate_child" then
          local node = model.find_node(state.root, state.current_id)
          local idx = selection.value.data.index
          if node and idx < #node.children then
            model.move_child(node, idx, idx + 1)
            actions.close(prompt_bufnr)
            reopen_picker(state)
          end
        end
      end)

      return true
    end,
  }):find()
end

--- Handle an action from the menu.
--- @param state MenuState
--- @param entry table
handle_action = function(state, entry)
  local current_node = model.find_node(state.root, state.current_id)
  if not current_node then
    vim.notify("diagram-editor: node not found", vim.log.levels.ERROR)
    return
  end

  if entry.action_type == "add_child" then
    local type_options = { "box", "phase", "start", "end" }
    vim.ui.select(type_options, { prompt = "Node type:" }, function(chosen_type)
      if not chosen_type then
        reopen_picker(state)
        return
      end
      telescope_input({
        prompt = "Content",
        default = "",
        on_submit = function(content)
          if content and content ~= "" then
            local child = model.create_node(chosen_type, content)
            model.add_child(current_node, child)
          end
          reopen_picker(state)
        end,
        on_cancel = function()
          reopen_picker(state)
        end,
      })
    end)

  elseif entry.action_type == "add_sibling_before" or entry.action_type == "add_sibling_after" then
    local parent, index = model.find_parent(state.root, state.current_id)
    if not parent or not index then
      vim.notify("diagram-editor: cannot add sibling (no parent found)", vim.log.levels.ERROR)
      reopen_picker(state)
      return
    end

    local insert_pos = (entry.action_type == "add_sibling_before") and index or (index + 1)
    local type_options = { "box", "phase", "start", "end" }
    vim.ui.select(type_options, { prompt = "Node type:" }, function(chosen_type)
      if not chosen_type then
        reopen_picker(state)
        return
      end
      telescope_input({
        prompt = "Content",
        default = "",
        on_submit = function(content)
          if content and content ~= "" then
            local sibling = model.create_node(chosen_type, content)
            model.add_child(parent, sibling, insert_pos)
          end
          reopen_picker(state)
        end,
        on_cancel = function()
          reopen_picker(state)
        end,
      })
    end)

  elseif entry.action_type == "edit_content" then
    local current_content = current_node.content
    if type(current_content) == "table" then
      current_content = table.concat(current_content, "\n")
    end
    telescope_input({
      prompt = "Edit Content",
      default = current_content,
      on_submit = function(new_content)
        if new_content and new_content ~= "" then
          current_node.content = new_content
        end
        reopen_picker(state)
      end,
      on_cancel = function()
        reopen_picker(state)
      end,
    })

  elseif entry.action_type == "change_type" then
    local type_options = { "box", "phase", "start", "end" }
    vim.ui.select(type_options, { prompt = "New type:" }, function(chosen_type)
      if chosen_type and model.is_valid_type(chosen_type) then
        current_node.type = chosen_type
      end
      reopen_picker(state)
    end)

  elseif entry.action_type == "toggle_layout" then
    model.toggle_layout(current_node)
    reopen_picker(state)

  elseif entry.action_type == "navigate_back" then
    if #state.nav_stack > 0 then
      state.current_id = table.remove(state.nav_stack)
      reopen_picker(state)
    end

  elseif entry.action_type == "save_and_close" then
    save_to_buffer(state)
    -- Don't reopen - just close

  elseif entry.action_type == "delete" then
    model.remove_child(state.root, state.current_id)
    -- navigate back to parent
    if #state.nav_stack > 0 then
      state.current_id = table.remove(state.nav_stack)
    else
      state.current_id = state.root.id
    end
    reopen_picker(state)

  elseif entry.action_type == "navigate_child" then
    table.insert(state.nav_stack, state.current_id)
    state.current_id = entry.data.child_id
    reopen_picker(state)

  elseif entry.action_type == "jump_to" then
    -- jump directly to any node, rebuilding the nav stack
    state.nav_stack = {}
    local path = model.get_path(state.root, entry.data.node_id)
    for i = 1, #path - 1 do
      state.nav_stack[#state.nav_stack + 1] = path[i].id
    end
    state.current_id = entry.data.node_id
    reopen_picker(state)
  end
end

--- Save the tree to the buffer (does NOT close the menu).
--- @param state MenuState
save_to_buffer = function(state)
  parser.write_region(state.bufnr, state.region, state.root)
  local ok, init = pcall(require, "diagram-editor")
  if ok and init.conceal_metadata then
    init.conceal_metadata(state.bufnr)
  end
  vim.notify("Diagram saved", vim.log.levels.INFO)
end

--- Save and close the menu.
--- @param state MenuState
save_and_close = function(state)
  save_to_buffer(state)
end

--- Open the diagram editor menu for an existing tree.
--- @param tree table root node
--- @param bufnr number
--- @param region table { start_line, end_line, name }
function M.open(tree, bufnr, region)
  local state = {
    root = tree,
    current_id = tree.id,
    nav_stack = {},
    bufnr = bufnr,
    region = region,
  }
  open_picker(state)
end

return M
