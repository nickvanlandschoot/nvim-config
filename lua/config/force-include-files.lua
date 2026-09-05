-- Files/patterns that should ALWAYS be searchable in Telescope,
-- even if they're in .gitignore
-- These work across all projects (relative paths)
return {
	".env",
	".env.local",
	".env.development",
	".env.production",
	"backend/.env",
	"frontend/.env",
	"scripts/.env",
	".gitignore",
	".dockerignore",
	"docker-compose.yml",
	"docker-compose.yaml",
	".editorconfig",
	"secrets/*",
	".agentscope/*",
	"intraceadx/*",
	-- Add more patterns here as needed
}
