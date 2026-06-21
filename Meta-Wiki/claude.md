# Meta-Wiki — Claude Instructions

This is a personal knowledge wiki built on Andrej Karpathy's LLM wiki pattern.
The idea: drop raw source documents in, and LLM-assisted ingestion distills them into
clean, interlinked wiki pages you can query conversationally.

---

## Directory Layout

```
Meta-Wiki/
├── raw/          # Source documents — PDFs, articles, notes, transcripts, web clips
├── wiki/         # Processed knowledge pages (one .md file per concept/topic)
├── index.md      # Master index: all pages, summaries, relationships, stats
├── log.md        # Ingest log: every operation recorded chronologically
└── claude.md     # This file
```

---

## How to Ingest a New Source

1. Drop the source file into `raw/` (PDF, .txt, .md, URL-as-.txt, etc.).
2. Tell Claude: *"Ingest `raw/<filename>` into the wiki."*
3. Claude will:
   - Read and understand the source.
   - Check `index.md` for existing pages that overlap.
   - Create or update one or more wiki pages in `wiki/`.
   - Add cross-links between related pages.
   - Append an entry to `log.md` (newest first).
   - Update `index.md` with the new/updated pages and bump statistics.

### Ingest prompt template

```
Ingest `raw/<filename>` into the Meta-Wiki.
Follow the instructions in claude.md.
```

---

## Wiki Page Format

Every page in `wiki/` follows this structure:

```markdown
# <Title>

**Summary:** One or two sentences.

**Sources:** `raw/<file>`, `raw/<file>`
**Related:** [[Page Title]], [[Page Title]]
**Last updated:** YYYY-MM-DD

---

## <Section>

...content...

---

## <Section>

...content...
```

Rules:
- One concept per file. If a source spans many topics, split into multiple pages.
- Cross-link aggressively using `[[Page Title]]` syntax.
- Preserve exact quotes from sources when precision matters; paraphrase otherwise.
- Keep pages query-friendly: short sections, direct statements, no filler.

---

## How to Search the Wiki

- **By topic:** Read `index.md` and follow links to relevant pages.
- **Conversationally:** Ask Claude — it can read any subset of pages to answer questions.
- **Keyword search:** `grep -r "term" wiki/` from this directory.

### Query prompt template

```
Search the Meta-Wiki for everything about <topic>.
Read index.md first, then the relevant pages in wiki/.
```

---

## How to Update an Existing Page

If a new source adds to a topic already in the wiki:
1. Claude reads the existing page.
2. Merges new information — adding sections, updating facts, noting conflicts.
3. Updates the **Sources** and **Last updated** fields.
4. Logs the update in `log.md` with action `update`.

---

## Log Format

Each `log.md` entry looks like:

```markdown
### YYYY-MM-DD — <source filename>

- **Action:** create | update | merge
- **Output:** `wiki/<page>.md` [, `wiki/<page2>.md`]
- **Notes:** <anything notable>
```

---

## Index Format

`index.md` has three sections:

| Section | Purpose |
|---------|---------|
| **Pages** | One line per wiki page: title, summary, source, ingest date |
| **Topic Graph** | Typed relationships between pages |
| **Statistics** | Running counts of pages, sources, last ingest date |

Claude updates all three sections on every ingest.

---

## Conventions

- File names in `wiki/` use kebab-case: `reinforcement-learning-basics.md`.
- Never delete a source from `raw/` — it is the ground truth.
- If two sources contradict each other, note the conflict in the wiki page under a **Conflicts** subsection; do not silently overwrite.
- Pages should be self-contained enough to be useful without re-reading the source.
