--- Code block formatting rules.
--- Ported from src/extension/prompts/node/panel/codeBlockFormattingRules.tsx.

local M = {}

--- CodeBlockFormattingRules — instructions for formatting code blocks in responses.
---@return string
function M.render()
    return table.concat({
        'When suggesting code changes or new content, use Markdown code blocks.',
        'To start a code block, use 4 backticks.',
        'After the backticks, add the programming language name as the language ID',
        'and the file path within curly braces if available.',
        'To close a code block, use 4 backticks on a new line.',
        'If you want the user to decide where to place the code, do not add the file path.',
        "In the code block, use a line comment with '...existing code...'",
        'to indicate code that is already present in the file.',
        'Ensure this comment is specific to the programming language.',
        'Code block example:',
        '',
        '````languageId {path/to/file}',
        '// ...existing code...',
        '{ changed code }',
        '// ...existing code...',
        '{ changed code }',
        '// ...existing code...',
        '````',
        '',
        'Ensure line comments use the correct syntax for the programming language',
        '(e.g. "#" for Python, "--" for Lua).',
    }, '\n')
end

return M
