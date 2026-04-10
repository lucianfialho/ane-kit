# README Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite `README.md` so a Swift developer can understand what SwiftAIKit is and have it running in under 5 minutes.

**Architecture:** Single file rewrite (`README.md`). No code changes — this is pure documentation. Approach is A+B hybrid: punchy problem/solution opening immediately followed by the minimal code example, then structured reference sections.

**Tech Stack:** Markdown (GitHub-flavored CommonMark)

---

## Files

- Modify: `README.md` (full rewrite)

---

### Task 1: Hero section — tagline + opening pitch + code hero

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Replace the current header and intro with the new hero**

Replace everything from line 1 through the first `---` (line 7) with:

```markdown
# SwiftAIKit

> Apple Intelligence in your macOS app. No API key. No model download. Just actions.

Adding AI to a macOS app used to mean picking a provider, managing API keys,
handling network errors, and hoping the model is fast enough. SwiftAIKit cuts
all of that — it runs entirely on-device via the Apple Neural Engine,
and your entire integration is one file:

```swift
static let actions: [Action] = [
    Action("Fix Grammar", prompt: "Fix grammar. Return only corrected text:\n\n{input}", icon: "checkmark.seal"),
    Action("Summarize",   prompt: "Summarize in 2 bullets:\n\n{input}",                 icon: "text.quote"),
]
```

That's it. SwiftAIKit handles capture, inference, and result presentation.

---
```

- [ ] **Step 2: Verify the file opens and the hero renders correctly**

Open `README.md` in any Markdown previewer (Xcode, VS Code, or GitHub preview).  
Expected: Title → italic tagline → paragraph → Swift code block → closing line → horizontal rule. No broken fences.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: rewrite hero with problem/solution pitch and code-first opening"
```

---

### Task 2: How it works → Features (replace section)

**Files:**
- Modify: `README.md`

The current README has a `## How it works` section that explains FoundationModels. This gets replaced by a tighter `## Features` list that leads with user-facing value and includes the privacy angle (currently missing).

- [ ] **Step 1: Replace `## How it works` and `## What the reference implementation includes` with `## Features`**

Delete those two sections entirely and insert:

```markdown
## Features

- **Zero configuration** — define actions in one file, framework handles the rest
- **Fully on-device** — runs via Apple Neural Engine, no internet required
- **Privacy first** — text never leaves the device
- **Two trigger modes** — global hotkey or auto-popup on clipboard copy
- **Full action CRUD** — add, edit, remove actions at runtime via Settings
- **UI-agnostic framework** — `MyApp` is just a reference implementation; use SwiftAIKit in any macOS app
```

- [ ] **Step 2: Verify the section looks correct in preview**

Expected: 6 bullet points, bold labels, clean description after dash.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: replace How it works with Features section, add privacy angle"
```

---

### Task 3: Getting Started — merge the two shell commands

**Files:**
- Modify: `README.md`

Currently step 2 is `xcodegen generate` and step 3 is `open MyApp.xcodeproj` as separate commands. Merge them into one shell block to reduce friction.

- [ ] **Step 1: Update the Getting Started shell block**

Find:
```bash
# 2. Generate the Xcode project
xcodegen generate

# 3. Open in Xcode
open MyApp.xcodeproj
```

Replace with:
```bash
# 2. Generate and open the Xcode project
xcodegen generate && open MyApp.xcodeproj
```

Then renumber the prose steps below it: what was step 4 becomes step 3, step 5 becomes step 4, step 6 becomes step 5.

- [ ] **Step 2: Verify numbering is consistent (no gaps, no duplicates)**

Read through the Getting Started section. Steps should be: `bash` block (covers 1–2), then numbered prose 3, 4, 5.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: merge xcodegen and open commands in Getting Started"
```

---

### Task 4: AppConfig.swift section — add subtitle

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add subtitle line under the `## AppConfig.swift` heading**

Find:
```markdown
## AppConfig.swift

```swift
```

Replace with:
```markdown
## AppConfig.swift

The only file you edit. Define your app name, trigger mode, and actions:

```swift
```

- [ ] **Step 2: Verify in preview**

Expected: heading → italic/plain subtitle → Swift code block.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add subtitle to AppConfig section"
```

---

### Task 5: Add "Using SwiftAIKit in an existing app" section

**Files:**
- Modify: `README.md`

This covers the secondary use case. The actual integration requires three real steps (no magic `start()` API exists). Insert this section between `## Project structure` and `## License`.

- [ ] **Step 1: Insert the new section**

After the closing ` ``` ` of the project structure code block and before `## License`, add:

```markdown
## Using SwiftAIKit in an existing app

SwiftAIKit doesn't have an initializer — it's a template, not a library you call into.
To integrate it in an existing app:

1. Copy the `SwiftAIKit/` folder into your Xcode project and add the files to your target
2. Create `AppConfig.swift` conforming to `SwiftAIAppConfig` (see [AppConfig.swift](#appconfigswift) above)
3. Copy `MyApp/MyAppApp.swift` into your project and wire `AppDelegate` to your `@main` entry point

All behaviour is driven by your `AppConfig` — no other changes needed.
```

- [ ] **Step 2: Verify the anchor link works**

In GitHub preview, `[AppConfig.swift](#appconfigswift)` should jump to the `## AppConfig.swift` heading. GitHub lowercases and strips punctuation from heading anchors.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add Using SwiftAIKit in an existing app section"
```

---

### Task 6: Final review pass

**Files:**
- Read: `README.md`

- [ ] **Step 1: Read the full README top to bottom**

Check for:
- Broken code fences (` ``` ` without closing fence)
- Duplicate section headings
- Orphaned references (e.g. mentions of `ANEKit` — old name, should be `SwiftAIKit`)
- Steps numbered incorrectly in Getting Started
- Any remaining references to "Ghost Pepper" or old copy from before the rename

- [ ] **Step 2: Fix any issues found**

Make targeted edits. If none found, no changes needed.

- [ ] **Step 3: Final commit**

```bash
git add README.md
git commit -m "docs: final README review pass"
```

---

## Self-review against spec

| Spec requirement | Task |
|---|---|
| Hero: tagline + problem sentence + code block | Task 1 |
| "That's it" closing line | Task 1 |
| Requirements section (unchanged) | Not touched — already correct |
| Getting Started: merge commands | Task 3 |
| Features section (new, with privacy) | Task 2 |
| AppConfig.swift subtitle | Task 4 |
| Triggers table (unchanged) | Not touched — already correct |
| Project structure (unchanged) | Not touched — already correct |
| Using in existing app (new) | Task 5 |
| License (unchanged) | Not touched — already correct |

All spec requirements covered. No placeholders remaining.
