--- Model capability detection helpers.
--- Ported from chatModelCapabilities.ts, using family string matching only.
--- Hash-based hidden model detection is omitted.

local M = {}

--- Returns whether the instructions should be given in a user message
--- instead of a system message when talking to the model.
---@param model string
---@return boolean
function M.modelPrefersInstructionsInUserMessage(model)
    return model:find 'claude%-3%.5%-sonnet' ~= nil
end

--- Model supports apply_patch as an edit tool.
---@param model string
---@return boolean
function M.modelSupportsApplyPatch(model)
    -- only using replace string as edit tool, disable apply_patch for VSC Models
    if M.isVSCModelReplaceStringSet(model) then
        return false
    end
    return (model:find '^gpt' ~= nil and model:find 'gpt%-4o' == nil)
        or model == 'o4-mini'
        or M.isGpt52CodexFamily(model)
        or M.isGpt53Codex(model)
        or M.isGpt52Family(model)
        or M.isVSCModelA(model)
        or M.isVSCModelB(model)
        or M.isGpt54(model)
        or M.isHiddenModelB(model)
end

--- Model supports replace_string_in_file as an edit tool.
---@param model string
---@return boolean
function M.modelSupportsReplaceString(model)
    return model:lower():find 'gemini' ~= nil
        or model:find 'grok%-code' ~= nil
        or M.modelSupportsMultiReplaceString(model)
        or M.isHiddenModelF(model)
        or M.isMinimaxFamily(model)
        or M.isHiddenFamilyH(model)
end

--- Model supports multi_replace_string_in_file as an edit tool.
---@param model string
---@return boolean
function M.modelSupportsMultiReplaceString(model)
    return M.isAnthropicFamily(model)
        or M.isHiddenModelE(model)
        or M.isVSCModelReplaceStringSet(model)
        or M.isMinimaxFamily(model)
        or M.isHiddenFamilyH(model)
end

--- The model is capable of using replace_string_in_file exclusively,
--- without needing insert_edit_into_file.
---@param model string
---@return boolean
function M.modelCanUseReplaceStringExclusively(model)
    return M.isAnthropicFamily(model)
        or model:find 'grok%-code' ~= nil
        or M.isHiddenModelE(model)
        or model:lower():find 'gemini%-3' ~= nil
        or M.isVSCModelReplaceStringSet(model)
        or M.isHiddenModelF(model)
        or M.isMinimaxFamily(model)
        or M.isHiddenFamilyH(model)
end

--- The model is capable of using apply_patch as an edit tool exclusively,
--- without needing insert_edit_into_file.
---@param model string
---@return boolean
function M.modelCanUseApplyPatchExclusively(model)
    -- only using replace string as edit tool, disable apply_patch for VSC Models
    if M.isVSCModelReplaceStringSet(model) then
        return false
    end
    return M.isGpt5PlusFamily(model) or M.isVSCModelA(model) or M.isVSCModelB(model)
end

--- Whether, when replace_string and insert_edit tools are both available,
--- verbiage should be added directing the model to prefer replace_string.
---@param model string
---@return boolean
function M.modelNeedsStrongReplaceStringHint(model)
    return model:lower():find 'gemini' ~= nil
end

--- The model supports native PDF document processing via document content parts.
---@param model string
---@return boolean
function M.modelSupportsPDFDocuments(model)
    return M.isAnthropicFamily(model)
end

---@param model string
---@return boolean
function M.isAnthropicFamily(model)
    return model:find '^claude' ~= nil or model:find '^Anthropic' ~= nil
end

---@param model string
---@return boolean
function M.isGeminiFamily(model)
    return model:lower():find '^gemini' ~= nil
end

---@param model string|nil
---@return boolean
function M.isGpt5PlusFamily(model)
    if not model then
        return false
    end
    return model:find '^gpt%-5' ~= nil
end

---@param model string|nil
---@return boolean
function M.isGpt54(model)
    if not model then
        return false
    end
    return model:find '^gpt%-5%.4' ~= nil
end

--- Matches gpt-5-codex, gpt-5.1-codex, gpt-5.1-codex-mini, etc.
---@param model string|nil
---@return boolean
function M.isGptCodexFamily(model)
    if not model then
        return false
    end
    return model:find '^gpt%-' ~= nil and model:find '%-codex' ~= nil
end

--- GPT-5, -mini, -codex, not 5.1+
---@param model string|nil
---@return boolean
function M.isGpt5Family(model)
    if not model then
        return false
    end
    return model == 'gpt-5' or model == 'gpt-5-mini' or model == 'gpt-5-codex'
end

---@param model string|nil
---@return boolean
function M.isGptFamily(model)
    if not model then
        return false
    end
    return model:find '^gpt%-' ~= nil
end

--- Any GPT-5.1+ model.
---@param model string|nil
---@return boolean
function M.isGpt51Family(model)
    if not model then
        return false
    end
    return model:find '^gpt%-5%.1' ~= nil
end

---@param model string
---@return boolean
function M.isGpt52CodexFamily(model)
    return model == 'gpt-5.2-codex'
end

---@param model string
---@return boolean
function M.isGpt52Family(model)
    return model == 'gpt-5.2'
end

---@param model string
---@return boolean
function M.isGpt53Codex(model)
    return model:find '^gpt%-5%.3%-codex' ~= nil
end

--- Matches grok-code models (xAI).
---@param model string
---@return boolean
function M.isXAIFamily(model)
    return model:find 'grok%-code' ~= nil
end

--- Matches Minimax family models.
---@param model string
---@return boolean
function M.isMinimaxFamily(model)
    return model:lower():find 'minimax' ~= nil
end

--- Matches GLM 4.6/4.7 models (ZAI).
---@param model string
---@return boolean
function M.isZAIFamily(model)
    local lower = model:lower()
    return lower:find 'glm[%-_]?4[._p]?[67]' ~= nil
end

--- Matches gpt-5-codex specifically (not 5.1+).
---@param model string|nil
---@return boolean
function M.isGpt5CodexFamily(model)
    if not model then
        return false
    end
    return model == 'gpt-5-codex'
end

--- Matches gpt-5.1-codex or gpt-5.1-codex-mini.
---@param model string|nil
---@return boolean
function M.isGpt51CodexFamily(model)
    if not model then
        return false
    end
    return model:find '^gpt%-5%.1' ~= nil and model:find '%-codex' ~= nil
end

--- Hash-based hidden models: not detectable by family string, always false in Lua.
---@param model string|nil
---@return boolean
function M.isHiddenModelB(_model)
    return false
end

---@param _model string|nil
---@return boolean
function M.isHiddenModelE(_model)
    return false
end

---@param _model string|nil
---@return boolean
function M.isHiddenModelF(_model)
    return false
end

---@param _model string|nil
---@return boolean
function M.isHiddenFamilyH(_model)
    return false
end

--- VSC-specific models: not applicable in Neovim, always false.
---@param _model string|nil
---@return boolean
function M.isVSCModelA(_model)
    return false
end

---@param _model string|nil
---@return boolean
function M.isVSCModelB(_model)
    return false
end

---@param _model string|nil
---@return boolean
function M.isVSCModelC(_model)
    return false
end

---@param _model string|nil
---@return boolean
function M.isVSCModelD(_model)
    return false
end

---@param _model string|nil
---@return boolean
function M.isVSCModelReplaceStringSet(_model)
    return false
end

return M
