return {
	-- Favorite model presets for the pi inline workflow only.
	-- The built-in default is configured in lua/pi_core/config.lua.
	presets = {
		{ name = "OpenAI Codex: GPT-5.3 Codex Spark", provider = "openai-codex", model = "gpt-5.3-codex-spark", thinking = "minimal" },
		{ name = "OpenRouter: Kimi K2.5", provider = "openrouter", model = "moonshotai/kimi-k2.5", thinking = "minimal" },
		{ name = "OpenRouter: Claude Haiku 4.5", provider = "openrouter", model = "anthropic/claude-haiku-4.5", thinking = "minimal" },
		{ name = "Anthropic: Claude Haiku 4.5", provider = "anthropic", model = "claude-haiku-4-5", thinking = "minimal" },
		{ name = "OpenAI: GPT-4.1 Mini", provider = "openai", model = "gpt-4.1-mini", thinking = "minimal" },
	},
}
