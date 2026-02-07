-- Accounts table
CREATE TABLE IF NOT EXISTS accounts (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    avatar TEXT,
    cookies_json TEXT NOT NULL,
    auth_tokens_json TEXT NOT NULL,
    is_logged_in INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    last_used INTEGER NOT NULL DEFAULT 0
);

-- Settings table (key-value with JSON values)
CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value_json TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Watch progress
CREATE TABLE IF NOT EXISTS watch_progress (
    video_id TEXT PRIMARY KEY,
    progress_ms INTEGER NOT NULL,
    total_duration_ms INTEGER NOT NULL,
    updated_at TEXT NOT NULL
);

-- Search history
CREATE TABLE IF NOT EXISTS search_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    keyword TEXT NOT NULL,
    created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_search_history_created
ON search_history(created_at DESC);

-- Download tasks
CREATE TABLE IF NOT EXISTS download_tasks (
    id TEXT PRIMARY KEY,
    video_id TEXT NOT NULL,
    title TEXT NOT NULL,
    quality INTEGER NOT NULL,
    total_bytes INTEGER NOT NULL,
    downloaded_bytes INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL,
    file_path TEXT NOT NULL,
    can_resume INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    completed_at TEXT
);