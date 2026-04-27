# copilot-prompt.nvim

[![License MIT](https://img.shields.io/badge/license-MIT-royalblue.svg)](LICENSE)
[![Neovim 0.10+](https://img.shields.io/badge/Neovim-0.10%2B-royalblue?logo=neovim&logoColor=white)](https://neovim.io/)
[![Lua 5.1](https://img.shields.io/badge/Lua-5.1-blue)](https://www.lua.org/)
[![Test](https://img.shields.io/github/actions/workflow/status/powerman/copilot-prompt.nvim/test.yml?label=test)](https://github.com/powerman/copilot-prompt.nvim/actions/workflows/test.yml)
[![Release](https://img.shields.io/github/v/release/powerman/copilot-prompt.nvim?color=blue)](https://github.com/powerman/copilot-prompt.nvim/releases/latest)

## About

Neovim plugin that generates a system prompt (adapted for Neovim)
close to the official VS Code Copilot prompt,
for use with [CodeCompanion](https://github.com/olimorris/codecompanion.nvim)
or any other Neovim AI chat plugin.

The prompt generation logic was ported from
[microsoft/vscode-copilot-chat](https://github.com/microsoft/vscode-copilot-chat)
version **v0.43.2026040705**.<br/>
See [LICENSE.copilot](LICENSE.copilot) (MIT) for the original copyright notice.

## Features

- Full-featured VS Code Copilot prompt.
- Adapted for Neovim.
- Configurable LLM identity.
- Your tool names included in the prompt with generic instructions per tool type.
- Optional structured-workflow prompt for `gpt-*` models.
- Optional code search ("Ask") mode:
  omits Agent-mode instructions (file editing, command execution).
- Optional Anthropic context compaction.
- Option to omit base identity, safety, and main prompt sections.
- Option to add LaTeX math formatting instructions.
- Option to always output Markdown code block formatting instructions.

### Model-specific prompts

The plugin automatically selects the best prompt variant for the given model:

| Model pattern                              | Prompt variant        |
| ------------------------------------------ | --------------------- |
| `claude-sonnet-4`, `claude-sonnet-4-*`     | Anthropic (legacy)    |
| `claude-*4.5*`, `claude-*4-5*`             | Anthropic Claude 4.5  |
| `claude-opus-*`                            | Anthropic Claude 4.6+ Opus |
| other `claude-*`                           | Anthropic Claude 4.6+ Sonnet |
| `gemini-*`                                 | Gemini                |
| `minimax-*`                                | Minimax               |
| `gpt-5.4*`                                 | GPT-5.4               |
| `gpt-5.3-codex*`                           | GPT-5.3 Codex         |
| `gpt-5.2-codex*`                           | GPT-5.2 Codex         |
| `gpt-5.1-codex*`                           | GPT-5.1 Codex         |
| `gpt-5-codex*`                             | GPT-5 Codex           |
| `gpt-5.2*`                                 | GPT-5.2               |
| `gpt-5.1*`                                 | GPT-5.1               |
| `gpt-5*`                                   | GPT-5                 |
| `gpt-4*`, `o3-mini*`, `o4-mini`, `OpenAI*` | Default OpenAI        |
| `grok-*`                                   | xAI                   |
| `glm-*`                                    | ZAI                   |
| anything else                              | Generic fallback      |

## Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return { 'powerman/copilot-prompt.nvim' }
```

## Usage

`system_prompt(opts)` returns a plain string with the Copilot system prompt,
adapted for Neovim and optimized for the specified model, tools, and options.
Depending on your AI plugin, you may need to add extra instructions or use it as is.

Example using [CodeCompanion](https://github.com/olimorris/codecompanion.nvim) tools:

```lua
local copilot_prompt = require('copilot_prompt').system_prompt {
    identity = 'CodeCompanion',
    model = 'claude-sonnet-4.6',
    tools = {
        EditFile = 'insert_edit_into_file',
        ReadFile = 'read_file',
        CreateFile = 'create_file',
        CoreRunInTerminal = 'run_command',
        FindTextInFiles = 'grep_search',
        FindFiles = 'file_search',
        FetchWebPage = 'fetch_webpage',
        GetErrors = 'get_diagnostics',
        GetScmChanges = 'get_changed_files',
    },
}
```

If you use [MCPHub](https://github.com/ravitemer/mcphub.nvim) with CodeCompanion
and have it "Neovim" MCP server configured then you can pass it tool names instead:

```lua
local copilot_prompt = require('copilot_prompt').system_prompt {
    identity = 'CodeCompanion',
    model = 'gpt-4.1',
    modelDisplayName = 'GPT 4.1'
    enableAlternateGptPrompt = true,
    tools = {
        EditFile = 'neovim__edit_file',
        ReadFile = 'neovim__read_file',
        CreateFile = 'neovim__write_file',
        CoreRunInTerminal = 'neovim__execute_command',
        FindTextInFiles = 'grep_search',
        FindFiles = 'neovim__find_files',
        FetchWebPage = 'fetch_webpage',
        GetErrors = 'get_diagnostics',
        GetScmChanges = 'get_changed_files',
    },
}
```

### Options

```lua
require('copilot_prompt').system_prompt {
    -- Name the AI identifies itself as.
    identity = 'GitHub Copilot',

    -- Model family string as used by Copilot
    -- (e.g. "gpt-4o", "claude-sonnet-4", "gemini-2.5-pro").
    model = 'unknown',

    -- Human-readable model name used in identity rules.
    -- Default: value of model field
    modelDisplayName = nil,

    -- BCP 47 locale code. When set to anything other than "en",
    -- adds a response-translation instruction.
    -- See list of supported codes: https://github.com/powerman/copilot-prompt.nvim/blob/main/lua/copilot_prompt/base/response_translation_rules.lua
    locale = nil,

    -- When true, omits the base identity, safety, and main prompt sections.
    omitBaseAgentInstructions = false,

    -- Uses the structured-workflow alternate prompt for gpt-* models.
    enableAlternateGptPrompt = false,

    -- When true, removes Agent-mode editing/execution instructions
    -- and adds code-search specific instructions.
    codesearchMode = false,

    -- Adds LaTeX math formatting instructions.
    mathEnabled = false,

    -- When true, Anthropic context compaction is enabled for supported models.
    anthropicContextEditingEnabled = false,

    -- When true, adds code block formatting instructions to the prompt.
    -- VS Code Copilot renders code blocks itself and omits these instructions in agent mode.
    -- Enable this when your AI plugin renders Markdown responses and needs explicit guidance.
    -- Has no effect when codesearchMode=true (instructions are already included there).
    codeBlockFormatting = false,

    -- Maps Copilot tool capability names to the actual tool names in your AI plugin.
    -- Omit a key (or set it to nil) if the tool is not available.
    tools = {
        EditFile = nil, -- File editing via insert-edit.
        ReplaceString = nil, -- String replacement in files.
        MultiReplaceString = nil, -- Multi-file string replacement.
        ApplyPatch = nil, -- Patch-based file editing.
        ReadFile = nil, -- Read file contents.
        CreateFile = nil, -- Create a new file.
        CoreRunInTerminal = nil, -- Run a command in a terminal.
        CoreRunTest = nil, -- Run tests.
        CoreRunTask = nil, -- Run a project task.
        CoreManageTodoList = nil, -- Manage a todo/task list.
        Codebase = nil, -- Semantic code search across the workspace.
        FindTextInFiles = nil, -- Grep/text search in files.
        FindFiles = nil, -- Find files by name/glob.
        SearchSubagent = nil, -- Delegated search via a sub-agent.
        ExecutionSubagent = nil, -- Delegated execution via a sub-agent.
        FetchWebPage = nil, -- Fetch a web page.
        GetErrors = nil, -- Get diagnostics/errors from the editor.
        ToolSearch = nil, -- Tool search (Anthropic deferred tools).
        SearchWorkspaceSymbols = nil, -- Search workspace symbols.
        GetScmChanges = nil, -- Get SCM (git) changes.
    },
}
```

## Examples

### Integration with CodeCompanion

Below is a full example that wires `copilot-prompt.nvim` into CodeCompanion + MCPHub.

```lua
---@module 'codecompanion'
---@module 'copilot_prompt'

---@param ctx CodeCompanion.SystemPrompt.Context
---@return string model CodeCompanion adapter's model name.
local function get_model(ctx)
    local adapter = ctx.adapter
    local model = ''
    if adapter and adapter.type == 'http' then
        model = adapter.model and adapter.model.name or ''
    elseif adapter and adapter.type == 'acp' then
        model = adapter.model
    end
    return model
end

---@param available string[] List of active tool names.
---@return Copilot.Tools
local function make_tools(available)
    local set = {}
    for _, v in ipairs(available) do
        set[v] = true
    end
    local function first(...)
        for _, name in ipairs { ... } do
            if set[name] then
                return name
            end
        end
    end
    -- NOTE: Some tools are provided by extra MCP servers which needs to be installed with MCPHub:
    -- - https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem
    -- - https://github.com/modelcontextprotocol/servers/tree/main/src/git
    -- - https://github.com/tavily-ai/tavily-mcp
    -- - https://github.com/sonirico/mcp-shell
    return {
        EditFile = first('filesystem__edit_file', 'insert_edit_into_file', 'neovim__edit_file'),
        ReplaceString = nil, -- No such tool in CodeCompanion.
        MultiReplaceString = nil, -- No such tool in CodeCompanion.
        ApplyPatch = nil, -- No such tool in CodeCompanion.
        ReadFile = first(
            'filesystem__read_file',
            'read_file',
            'neovim__read_file',
            'filesystem__read_text_file',
            'filesystem__read_media_file',
            'filesystem__read_multiple_files',
            'neovim__read_multiple_files'
        ),
        CreateFile = first('filesystem__write_file', 'create_file', 'neovim__write_file'),
        CoreRunInTerminal = first(
            'shell__shell_exec',
            'run_command',
            'neovim__execute_command'
        ),
        CoreRunTest = nil, -- No such tool in CodeCompanion.
        CoreRunTask = nil, -- No such tool in CodeCompanion.
        CoreManageTodoList = nil, -- No such tool in CodeCompanion.
        Codebase = nil, -- No such tool in CodeCompanion.
        FindTextInFiles = first 'grep_search',
        FindFiles = first('filesystem__search_files', 'file_search', 'neovim__find_files'),
        SearchSubagent = nil, -- No such tool in CodeCompanion.
        FetchWebPage = first('fetch_webpage', 'tavily_mcp__tavily_extract'),
        GetErrors = first 'get_diagnostics',
        ToolSearch = nil, -- No such tool in CodeCompanion.
        SearchWorkspaceSymbols = nil, -- No such tool in CodeCompanion.
        GetScmChanges = first('get_changed_files', 'git__git_diff_unstaged'),
    }
end

-- Additional CodeCompanion formatting instructions not covered by copilot-prompt.nvim.
local codecompanion_instructions = [[
<outputFormattingInstructions>
Use Markdown formatting in your answers.

DO NOT use H1 or H2 headers in your response.

Avoid wrapping the whole response in triple backticks.

Do not include diff formatting unless explicitly asked.

Do not include line numbers in code blocks unless explicitly asked.
</outputFormattingInstructions>
]]

-- Same as in CodeCompanion's default system prompt, wrapped in <additionalContext> tags.
---@param ctx CodeCompanion.SystemPrompt.Context
---@return string
local function dynamic_context(ctx)
    return string.format(
        [[
<additionalContext>
All non-code text responses must be written in the %s language.
The user's current working directory is %s.
The current date is %s.
The user's Neovim version is %s.
The user is working on a %s machine. Please respond with system specific commands if applicable.
</additionalContext>
]],
        ctx.language,
        ctx.cwd,
        ctx.date,
        ctx.nvim_version,
        ctx.os
    )
end

---@param ctx CodeCompanion.SystemPrompt.Context
---@param tools Copilot.Tools
---@return string Copilot-based system prompt for CodeCompanion.
local function make_prompt(ctx, tools)
    local copilot_prompt = require('copilot_prompt').system_prompt {
        identity = 'CodeCompanion',
        model = get_model(ctx),
        codeBlockFormatting = true,
        tools = tools,
    }
    return copilot_prompt
        .. '\n\n'
        .. codecompanion_instructions
        .. '\n\n'
        .. dynamic_context(ctx)
end

---@module 'lazy'
---@type LazySpec
return {
    { 'powerman/copilot-prompt.nvim' },
    --- ... ---
    {
        'olimorris/codecompanion.nvim',
        --- ... ---
        dependencies = {
            'ravitemer/mcphub.nvim',
            --- ... ---
        },
        opts = {
            -- NOTE: When using non-copilot adapter you may need to convert model names
            -- used by that adapter into Copilot model names.
            interactions = {
                background = {
                    adapter = {
                        name = 'copilot',
                        model = 'gpt-4.1',
                    },
                },
                cmd = {
                    adapter = {
                        name = 'copilot',
                        model = 'gpt-4.1',
                    },
                },
                inline = {
                    adapter = {
                        name = 'copilot',
                        model = 'gpt-4.1',
                    },
                },
                chat = {
                    adapter = {
                        name = 'copilot',
                        model = 'gpt-4.1',
                    },
                    opts = {
                        -- Evaluated once when the chat is created (or when the adapter changes).
                        system_prompt = function(ctx)
                            return make_prompt(ctx, {})
                        end,
                    },
                    tools = {
                        opts = {
                            system_prompt = {
                                enabled = true,
                                replace_main_system_prompt = true,
                                -- Re-evaluated whenever the set of active tools changes.
                                prompt = function(args)
                                    return make_prompt(args.ctx, make_tools(args.tools))
                                end,
                            },
                        },
                    },
                },
            },
            extensions = {
                mcphub = {
                    callback = 'mcphub.extensions.codecompanion',
                    opts = {
                        make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers.
                        add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`).
                        --- ... ---
                    },
                    --- ... ---
                },
            },
        },
    },
}
```
