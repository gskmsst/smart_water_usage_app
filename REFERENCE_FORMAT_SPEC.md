# Reference Document Format Specification

Source: `C:\Users\gskms\OneDrive\Documents\FLUTTER 25.pdf`
Extracted: 1 Nov 2026 (programmatic PDF inspection — PyMuPDF)
Purpose: exact typographic/layout blueprint to mirror in the Smart Water Usage documentation.

---

## 1. Document identity

| Property | Value |
|---|---|
| Title (metadata) | Skill Sharing Community Platform – Flutter Documentation |
| Author | Kagitapalli Dileep Kumar |
| Subject | Flutter documentation for Skill Sharing Community Platform |
| Keywords | Flutter, Dart, Skill Sharing Community Platform, Java Backend, REST API |
| Created with | Microsoft Word 2016 |
| Post-processed by | ilovepdf.com |
| Pages | 51 |
| Words (approx.) | 5,042 |
| Chapters | 26 numbered chapters |
| Figures/screenshots | 30 raster images on 19 pages |
| Tables | 10 (8 two-column, 2 three-column) |
| Code/diagram blocks | 40 shaded blocks across 29 pages |

---

## 2. Page setup

| Item | Value |
|---|---|
| Paper | US Letter, 612 × 792 pt (8.5 × 11 in) |
| Orientation | Portrait |
| **Page border** | Black rectangle **24 pt (0.333 in) from every edge**, line width ≈ **0.5 pt**, on **every page including the title page** |
| Left text margin | **61.2 pt** (0.85 in / 2.16 cm) |
| Right text margin | text ends at **558.3 pt** → **53.7 pt** (0.75 in) |
| Text column | **≈ 497 pt** (6.9 in) |
| Top of body text | **54.7 pt** from top |
| Bottom text limit | **≈ 720.6 pt** from top |
| Header | **None** (empty header line remains at y ≈ 36.1 pt) |
| Footer | **Centered page number only**, Times New Roman **11 pt**, baseline y ≈ 731–743 pt |
| Page numbers | Present on **all** pages, including title page and CONTENTS |

---

## 3. Typography

Fonts are embedded TTF subsets. Only two families are used:

- **Times New Roman** — all prose, headings, tables, captions, title page
- **Consolas** — all code and all ASCII diagrams

### 3.1 Size / weight map

| Element | Font | Size | Weight | Color | Align |
|---|---|---|---|---|---|
| Chapter title (H1) | Times New Roman | **17 pt** | Bold | **#000000** (exceptions below) | Left |
| "CONTENTS" heading | Times New Roman | **17 pt** | Bold | #000000 | Left |
| Section heading (H2) | Times New Roman | **14 pt** | Bold | #000000 | Left |
| Body text | Times New Roman | **14 pt** | Regular | #000000 | Left (ragged right) |
| Bullet glyph + text | Times New Roman | **14 pt** | Bold (glyph always; text inconsistent) | #000000 | Left, hanging indent |
| Numbered steps ("1.", "2."…) | Times New Roman | **14 pt** | Bold | #000000 | Left, manually typed numbers |
| Table header (early chapters) | Times New Roman | **12 pt** | Bold | #000000 | Left |
| Table header (later chapters) | Times New Roman | **14 pt** | Bold | #000000 | Left |
| Table header (ch. 26 only) | Times New Roman | **14 pt** | **Regular** | #000000 | Left |
| Table cell text | Times New Roman | **14 pt** | Regular | #000000 | Left |
| Code / ASCII diagram | **Consolas** | **9 pt** | Regular | #000000 | Left, on #F2F2F2 |
| Figure caption | Times New Roman | **12 pt** | Bold | #000000 | Left at margin |
| TOC entries | Times New Roman | **14 pt** | Regular | #000000 | Left, 7.2 pt indent |
| Page number | Times New Roman | **11 pt** | Regular | #000000 | Centered |
| Title page university name | Times New Roman | **18 pt** | Bold | #000000 | Centered |
| Title page project title | Times New Roman | **22 pt** | Bold | **#1F497D** | Centered |
| Title page "By" | Times New Roman | **12 pt** | Bold | #000000 | Centered |
| Title page author name | Times New Roman | **14 pt** | Bold | #000000 | Centered |
| Title page registration no. | Times New Roman | **12 pt** | Regular | #000000 | Centered |
| Title page small lines | Times New Roman | **11 pt** | Regular (supervisor name bold) | #000000 | Centered |
| Title page "Academic Year" | Times New Roman | **12 pt** | Bold | #000000 | Centered, slightly right of centre |

### 3.2 Line spacing (measured, top-of-line to top-of-line)

| Context | Leading |
|---|---|
| Body paragraphs | **18.5 pt** |
| Table cells | **16.1 pt** |
| Code / diagrams | **12.1 pt** |
| Table of contents | **24.1 pt** |
| Paragraph gap (body → next body) | ≈ **6 pt** extra after paragraph |
| Section separation | one blank 11–12 pt line between blocks |

### 3.3 Indents

- Body: no first-line indent, x = 61.2 pt.
- Bullets: glyph starts at **68.4 pt** (7.2 pt indent); wrapped lines align at **79.2 pt** (18 pt indent) → hanging indent.
- TOC: starts at **68.4 pt**.
- Code block shading: **77.8 → 548.7 pt**; code text starts **79.2 pt** (16.6 pt indent).
- Table cell padding: ≈ **5 pt** from cell border.

---

## 4. Colors

| Role | Hex | Notes |
|---|---|---|
| All body/heading text | `#000000` | Dominant (≈ 41,000 characters) |
| Project title on cover | `#1F497D` | Dark blue, only colored large text |
| Two chapter titles (21 and 22) | `#2D2D5A` | Accent inconsistency — see §10 |
| Table header shading | `#D9E1F2` | Excel "Blue, Accent 1, Lighter 80%" |
| Code/diagram background | `#F2F2F2` | Light gray paragraph shading, no border |
| Page border / table borders | `#000000` | ≈ 0.5 pt |
| Screenshots | Full color | Native app screenshots |

No gradients, no shadows, no colored highlights, no syntax highlighting.

---

## 5. Structural template (page by page)

1. **Page 1 — Title page**
   - JNTU logo image at top: 396×403 px, displayed **142.7 × 145.1 pt**, horizontally centred, top y = 54 pt.
   - `JAWAHARLAL NEHRU TECHNOLOGICAL UNIVERSITY` — 18 pt bold, centred, y ≈ 228 pt
   - `VIZIANAGARAM` — 18 pt bold, centred, y ≈ 259 pt
   - `VIZIANAGARAM – 535003` — 18 pt bold, centred, y ≈ 296 pt
   - `ANDHRA PRADESH` — 18 pt bold, centred, y ≈ 333 pt
   - Project title — 22 pt bold `#1F497D`, centred, y ≈ 408 pt
   - `By` — 12 pt bold, y ≈ 442 pt
   - Author name — 14 pt bold, y ≈ 464 pt
   - `(Regd. No. …)` — 12 pt regular, y ≈ 489 pt
   - `Under the supervision of` — 11 pt regular, y ≈ 545 pt
   - Supervisor — 11 pt bold, y ≈ 565 pt
   - Department — 11 pt regular, y ≈ 583 pt
   - University — 11 pt regular, y ≈ 602 pt
   - `Academic Year: 2026–2027` — 12 pt bold, y ≈ 673 pt

2. **Page 2 — CONTENTS**
   - "CONTENTS" 17 pt bold at y = 54.7 pt.
   - Exactly **26 entries — chapter level only, no subsections**.
   - Entry format: `N. Title` + literal ellipsis characters (`…`) as dot leaders + page number right-aligned near x = 549 pt.
   - Starts y = 97.3 pt, 24.1 pt leading, 14 pt regular.

3. **Pages 3–51 — Chapters 1–26**
   - Each chapter begins on a **new page**.
   - H1 at y = 54.7 pt, left margin (exceptions: chapters 8, 9, 10, 11 start lower at y ≈ 93–103 pt).
   - Typical chapter anatomy: intro paragraphs → H2 sections → bullet/numbered lists → table(s) → shaded code/diagram → screenshot(s) with bold 12 pt captions.

### Chapter map

| # | Title | Pages |
|---|---|---|
| 1 | Introduction | 3 |
| 2 | Project Overview and Requirements | 4–5 |
| 3 | Project Architecture and Structure | 6–7 |
| 4 | Flutter Development Environment Setup | 8–10 |
| 5 | Dart Programming Fundamentals Used in the Project | 11–12 |
| 6 | Creating and Configuring the Flutter Project | 13 |
| 7 | Skill Sharing Community Platform – Case Study | 14–15 |
| 8 | User Authentication and Profile Management | 16–17 |
| 9 | Skills Management Module | 18–19 |
| 10 | Learning Goals Module | 20–21 |
| 11 | Skill-Based Study Matching Module | 22–23 |
| 12 | Connection Request Module | 24–25 |
| 13 | Exploring Flutter Widgets in the Project | 26–27 |
| 14 | Responsive UI Design | 28–29 |
| 15 | Navigation Between Screens | 30 |
| 16 | Stateful and Stateless Widgets | 31 |
| 17 | State Management | 32 |
| 18 | Custom Widgets and Styling | 33–34 |
| 19 | Forms and Validation | 35–36 |
| 20 | REST API Integration with Java Backend | 37–38 |
| 21 | Database and Data Models | 39–40 |
| 22 | Animations and User Experience | 41 |
| 23 | Testing and Debugging | 42–43 |
| 24 | Application Workflow | 44–48 |
| 25 | Security and Data Validation | 49 |
| 26 | Conclusion | 50–51 |

No abstract, declaration, certificate, acknowledgement, list of figures, references, or appendix.

---

## 6. Headings

- **H1:** `N.Title` — **no space after the period** (`1.Introduction`, `2.Project Overview…`).
- **TOC:** `N. Title` — **with** a space (`1. Introduction`).
- H2 headings are **unnumbered**, 14 pt bold, sentence-style capitalisation (`Problem Statement`, `Main Objectives`, `Skill Management Operations`).
- H1 sits at the very top of the text column (54.7 pt), followed by ≈ 23 pt gap before body.

---

## 7. Tables

- Width: full text column, x = **61.5 → 557.9 pt**.
- Column layouts:
  - **2 equal columns:** 61.5 / 309.4 / 557.9 pt (each ≈ 248 pt).
  - **3 equal columns:** 61.5 / 226.6 / 392.2 / 557.9 pt (each ≈ 165 pt).
- Borders: thin **black ≈ 0.5 pt**, all cells.
- Header row: shaded **#D9E1F2**, text bold (12 pt in ch. 2–3; 14 pt later; 14 pt *regular* in ch. 26).
- Body cells: 14 pt regular, 16.1 pt leading, no zebra striping, top-aligned.
- Header row height ≈ 20–22 pt; body rows expand with wrapped text.
- Tables used on pages: 4, 7, 15, 21, 24, 26, 35, 37, 39, 50.

---

## 8. Code blocks and ASCII diagrams

- Font: **Consolas 9 pt**, black, no syntax highlighting.
- Background: **#F2F2F2** paragraph shading, **no border**.
- Shaded area: x = **77.8 → 548.7 pt** (≈ 471 pt wide), line height **12.1 pt**.
- Text starts x = **79.2 pt**; blank code lines still shaded.
- Long blocks may continue onto the next page (e.g., pp. 44–45).
- Used for Dart snippets (`class SkillService { … }`), shell commands (`flutter create …`), directory trees (`├── lib/`), widget trees, and ASCII flowcharts (`┌──┐ │ ▼`).

---

## 9. Figures / screenshots

- 30 embedded screenshots; 19 pages contain images.
- Widths vary from **109 pt to 497 pt**; phone screenshots ≈ 120–155 pt wide, 265–366 pt tall.
- Placement: centred or left-aligned; multi-image grids of 2, 3, or 4 per page.
- **Captions: Times New Roman 12 pt bold, left-aligned at the 61.2 pt margin, placed below the image.**
- Two side-by-side images share one caption line separated by wide spaces
  (e.g., `Register Screen                                      Home Screen`).
- Image pages: 1 (logo), 8, 9, 10, 15, 17, 19, 21, 23, 25, 27, 29, 30, 34, 36, 45, 46, 47, 48.

---

## 10. Formatting inconsistencies present in the source

Preserved here because they matter if the goal is either exact replication or a cleaner version:

1. **Chapter 20 heading is 14 pt bold**, while all other chapter headings are 17 pt bold.
2. **Chapters 21 and 22 headings are `#2D2D5A`** instead of black; every other H1 is black.
3. Chapters **8, 9, 10, 11** headings start at y ≈ 93–103 pt instead of 54.7 pt (extra blank space above).
4. Table header size varies **12 pt vs 14 pt**; chapter 26's table header is **not bold**.
5. Bullet lists are inconsistent: sometimes the whole item is bold, sometimes only the bullet glyph.
6. H1 uses `1.Introduction`; TOC uses `1. Introduction`.
7. Duplicate/invisible bold space spans exist before some TOC lines and elsewhere (Word artifacts from Calibri bold spaces).
8. Title page uses an 18 pt line for an empty spacer, and the "Academic Year" line is offset right of centre.

---

## 11. Reproduction checklist (if mirroring this format)

- [ ] Letter 612 × 792 pt; 0.5 pt black border inset 24 pt on all pages.
- [ ] Margins: left 61.2 pt, right 53.7 pt, top 54.7 pt, bottom text 720.6 pt.
- [ ] Body: Times New Roman 14 pt, 18.5 pt leading, left aligned, ~6 pt paragraph gap.
- [ ] H1: Times 17 pt bold, `N.Title`, top of page, new page per chapter.
- [ ] H2: Times 14 pt bold, unnumbered.
- [ ] TOC: 17 pt bold title, 14 pt entries, 24.1 pt leading, dot leaders, 26 chapters only.
- [ ] Tables: full width, black 0.5 pt grid, #D9E1F2 header row, 14 pt cells.
- [ ] Code: Consolas 9 pt, #F2F2F2 shading, 12.1 pt leading, 16.6 pt indent.
- [ ] Captions: Times 12 pt bold, left margin, below figure.
- [ ] Footer: centred Times 11 pt page number on every page; no header.
- [ ] Cover: logo top centre; 18 pt university block; 22 pt #1F497D title; 11–14 pt credits.
