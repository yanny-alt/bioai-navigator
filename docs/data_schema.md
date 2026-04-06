# Data Schema — BioAI Navigator

## tools table (Google Sheet / tools.csv)

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | integer | Unique tool identifier | `1` |
| `name` | string | Tool name | `"AlphaFold Server"` |
| `short_description` | string | One-line summary | `"Predict protein structures"` |
| `biological_domain` | string | Primary research domain | `"Proteins"` |
| `ai_technique` | string | ML method used | `"Diffusion / Transformer"` |
| `data_type` | string | Input data format | `"FASTA"` |
| `link` | string | Website or GitHub URL | `"https://alphafoldserver.com"` |
| `publication` | string | Associated paper title | `"AlphaFold 3 | Nature"` |
| `year_released` | integer | Year first released | `2018` |
| `license` | string | Open-source or proprietary | `"Open-source"` |
| `tags` | string | Comma-separated tags | `"folding, multi-chain"` |
| `authors` | string | Authors or organization | `"Google DeepMind"` |
| `logo` | string | URL to logo image | `"https://..."` |
| `screenshot_1` | string | URL to screenshot | `"https://..."` |
| `screenshot_2` | string | URL to screenshot | `"https://..."` |
| `rating` | float | Average community rating | `4.5` |
| `review` | string | Short curator review | `"Best-in-class for..."` |
| `researched_by` | string | Who curated this entry | `"Wale"` |

## ratings table (Google Sheet)

| Field | Type | Description |
|-------|------|-------------|
| `tool_id` | integer | References tools.id |
| `rating` | integer | 1–5 star rating |
| `comment` | string | User comment |
| `timestamp` | datetime | When submitted |
| `session_id` | string | Anonymous session ID |

## submissions table (Google Sheet)

| Field | Type | Description |
|-------|------|-------------|
| `tool_name` | string | Submitted tool name |
| `link` | string | URL |
| `description` | string | Submitter's description |
| `category` | string | Biological domain |
| `submitted_at` | datetime | Submission timestamp |
| `status` | string | pending / approved / rejected |
