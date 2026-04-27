--- Prompt registry — resolves per-model prompt customizations.
--- Ported from promptRegistry.ts (resolveAllCustomizations logic).

local M = {}

local capabilities = require 'copilot_prompt.common.chat_model_capabilities'
local copilot_identity = require 'copilot_prompt.base.copilot_identity'
local dai = require 'copilot_prompt.agent.default_agent_instructions'
local safety_rules = require 'copilot_prompt.base.safety_rules'

--- Resolve which prompt renderer and reminder instructions to use,
--- based on model family.
--- Mirrors PromptRegistry.resolveAllCustomizations().
---@param opts Copilot.Options
---@return fun(opts: Copilot.Options): string systemPromptRenderer
---@return fun(opts: Copilot.Options): string reminderRenderer
---@return fun(opts: Copilot.Options): string identityRenderer
---@return fun(): string safetyRenderer
function M.resolveCustomizations(opts)
    local systemPromptRenderer
    local reminderRenderer
    local identityRenderer = copilot_identity.CopilotIdentityRules_render
    local safetyRenderer = safety_rules.SafetyRules_render

    -- Check model family in priority order matching PromptRegistry resolution.
    -- Codex models are checked first because they overlap with gpt-5* families.
    -- GPT-5.4 is checked before other gpt-5* families because it has its own prompt.
    if capabilities.isGpt54(opts.model) then
        local gpt54 = require 'copilot_prompt.agent.openai.gpt54_prompt'
        systemPromptRenderer, reminderRenderer = gpt54.resolve(opts)
        identityRenderer = copilot_identity.GPT5CopilotIdentityRule_render
        safetyRenderer = safety_rules.Gpt5SafetyRule_render
    elseif capabilities.isGpt53Codex(opts.model) then
        local gpt53_codex = require 'copilot_prompt.agent.openai.gpt53_codex_prompt'
        systemPromptRenderer, reminderRenderer = gpt53_codex.resolve(opts)
        identityRenderer = copilot_identity.GPT5CopilotIdentityRule_render
        safetyRenderer = safety_rules.Gpt5SafetyRule_render
    elseif
        capabilities.isGpt52CodexFamily(opts.model)
        or capabilities.isGpt51CodexFamily(opts.model)
    then
        local gpt51_codex = require 'copilot_prompt.agent.openai.gpt51_codex_prompt'
        systemPromptRenderer, reminderRenderer = gpt51_codex.resolve(opts)
        identityRenderer = copilot_identity.GPT5CopilotIdentityRule_render
        safetyRenderer = safety_rules.Gpt5SafetyRule_render
    elseif capabilities.isGpt5CodexFamily(opts.model) then
        local gpt5_codex = require 'copilot_prompt.agent.openai.gpt5_codex_prompt'
        systemPromptRenderer, reminderRenderer = gpt5_codex.resolve(opts)
        -- gpt-5-codex does not override identity/safety in the original.
    elseif capabilities.isXAIFamily(opts.model) then
        local xai = require 'copilot_prompt.agent.xai_prompts'
        systemPromptRenderer, reminderRenderer = xai.resolve(opts)
    elseif capabilities.isZAIFamily(opts.model) then
        local zai = require 'copilot_prompt.agent.zai_prompts'
        systemPromptRenderer, reminderRenderer = zai.resolve(opts)
    elseif capabilities.isAnthropicFamily(opts.model) then
        local anthropic = require 'copilot_prompt.agent.anthropic_prompts'
        systemPromptRenderer, reminderRenderer = anthropic.resolve(opts)
    elseif capabilities.isGeminiFamily(opts.model) then
        local gemini = require 'copilot_prompt.agent.gemini_prompts'
        systemPromptRenderer, reminderRenderer = gemini.resolve(opts)
    elseif capabilities.isMinimaxFamily(opts.model) then
        local minimax = require 'copilot_prompt.agent.minimax_prompts'
        systemPromptRenderer, reminderRenderer = minimax.resolve(opts)
    elseif capabilities.isGpt52Family(opts.model) then
        local gpt52 = require 'copilot_prompt.agent.openai.gpt52_prompt'
        systemPromptRenderer, reminderRenderer = gpt52.resolve(opts)
        identityRenderer = copilot_identity.GPT5CopilotIdentityRule_render
        safetyRenderer = safety_rules.Gpt5SafetyRule_render
    elseif
        capabilities.isGpt51Family(opts.model) and not capabilities.isGptCodexFamily(opts.model)
    then
        local gpt51 = require 'copilot_prompt.agent.openai.gpt51_prompt'
        systemPromptRenderer, reminderRenderer = gpt51.resolve(opts)
        identityRenderer = copilot_identity.GPT5CopilotIdentityRule_render
        safetyRenderer = safety_rules.Gpt5SafetyRule_render
    elseif
        capabilities.isGpt5Family(opts.model) and not capabilities.isGptCodexFamily(opts.model)
    then
        local gpt5 = require 'copilot_prompt.agent.openai.gpt5_prompt'
        systemPromptRenderer, reminderRenderer = gpt5.resolve(opts)
        identityRenderer = copilot_identity.GPT5CopilotIdentityRule_render
        safetyRenderer = safety_rules.Gpt5SafetyRule_render
    elseif
        capabilities.isGptFamily(opts.model)
        or opts.model == 'o4-mini'
        or opts.model:find '^o3%-mini' ~= nil
        or opts.model:find '^OpenAI' ~= nil
    then
        local openai = require 'copilot_prompt.agent.openai.default_openai_prompt'
        systemPromptRenderer, reminderRenderer = openai.resolve(opts)
    else
        -- Fallback: default prompt.
        systemPromptRenderer = dai.DefaultAgentPrompt_render
        reminderRenderer = dai.DefaultReminderInstructions_render
    end

    return systemPromptRenderer, reminderRenderer, identityRenderer, safetyRenderer
end

return M
