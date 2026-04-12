# KrakkApp – UI Brand Guide

---

## Grunnregla

Barnvænt en ekki barnalegt. Hreint, skýrt og hvetjandi.
Tveir aðskildir heimar — foreldri og barn — deila navy sem aðallit, barn fær gull accent.

---

## 5 Grunnlitir

| Litur | Hex | Hlutverk |
|-------|-----|----------|
| Navy | `#1F2E6C` | Aðallitur — takkar, header, fyrirsagnir |
| Brown | `#734A27` | Hlýr accent — flokkur, aukatakkar |
| Dark Gold | `#D0A51D` | Hover á gulli, gull texti |
| Yellow | `#FAD707` | Stig, stjörnur, barna accent |
| Off-white | `#FAFAF9` | Bakgrunnur |

---

## Litapaletta — Full scale

### Navy (Primary)

| Token | Hex | Notkun |
|-------|-----|--------|
| `navy-50` | `#EAECF3` | Bakgrunnsblær, valdir liðir |
| `navy-100` | `#C8CCE0` | Tags, border |
| `navy-200` | `#A3AACA` | Rammar, border |
| `navy-300` | `#7D87B4` | Disabled |
| `navy-400` | `#4E5B8E` | Aukatexti |
| `navy-500` | `#1F2E6C` | Takkar, tenglar, header |
| `navy-600` | `#1B2860` | Hover |
| `navy-700` | `#162152` | Active |
| `navy-900` | `#0C1230` | Fyrirsagnir |

### Gold (Child accent / Points)

| Token | Hex | Notkun |
|-------|-----|--------|
| `gold-50` | `#FFFDE7` | Barna bakgrunnur |
| `gold-100` | `#FFF8C4` | Highlight, bónus bakgrunnur |
| `gold-200` | `#FFF09D` | Hringir, tags |
| `gold-300` | `#FFE876` | Light accent |
| `gold-400` | `#FAD707` | Stig, stjörnur, barna takkar |
| `gold-500` | `#D0A51D` | Hover á gulli |
| `gold-700` | `#8A6B10` | Gull texti á ljósum bakgrunni |

### Brown (Warm accent)

| Token | Hex | Notkun |
|-------|-----|--------|
| `brown-50` | `#F5EDE7` | Hlýr bakgrunnur |
| `brown-100` | `#E6D5C7` | Border |
| `brown-300` | `#BB9677` | Aukaaktar |
| `brown-500` | `#734A27` | Verkefna flokkur, aukatakki |
| `brown-700` | `#51341A` | Dökkur texti |

### Stöðulitir

| Token | Hex | Notkun |
|-------|-----|--------|
| `success` | `#10B981` | Rétt svar, samþykkt |
| `success-light` | `#ECFDF5` | Bakgrunnur á jákvæðu |
| `error` | `#EF4444` | Rangt svar, hafnað |
| `error-light` | `#FEF2F2` | Bakgrunnur á neikvæðu |
| `warning` | `#D0A51D` | Bíður samþykkis (dark gold) |
| `warning-light` | `#FFFDE7` | Bakgrunnur á viðvörun |
| `info` | `#0EA5E9` | Streak, upplýsingar |
| `info-light` | `#F0F9FF` | Bakgrunnur á upplýsingum |

### Hlutlausir litir (warm neutrals)

| Token | Hex | Notkun |
|-------|-----|--------|
| `neutral-50` | `#FAFAF9` | Síðu bakgrunnur |
| `neutral-100` | `#F3F2F0` | Korta bakgrunnur |
| `neutral-200` | `#E5E4E1` | Border, skipting |
| `neutral-300` | `#D1D0CC` | Rammar |
| `neutral-500` | `#73726D` | Aukatexti, placeholder |
| `neutral-700` | `#3D3C39` | Meginmálstexti |
| `neutral-900` | `#1A1918` | Fyrirsagnir |

---

## Leturval (Typography)

### Leturgerð

| Notkun | Leturgerð | Fallback |
|--------|-----------|----------|
| Allt | **Inter** | `system-ui, sans-serif` |
| Tölur/stig | **Inter Tabular** | `font-variant-numeric: tabular-nums` |

### Leturstærðir

| Token | Stærð | Notkun |
|-------|-------|--------|
| `text-xs` | 12px | Tímastimplar |
| `text-sm` | 14px | Labels, aukatexti |
| `text-base` | 16px | Meginmál |
| `text-lg` | 18px | Korta titlar |
| `text-xl` | 20px | Kafla fyrirsagnir |
| `text-2xl` | 24px | Síðu fyrirsagnir |
| `text-3xl` | 30px | Stórar tölur |
| `text-4xl` | 36px | Hero tölur í barnaviðmóti |

---

## Takkar (Buttons)

### Foreldraviðmót

| Tegund | Stíll |
|--------|-------|
| **Primary** | `bg-navy-500 text-white hover:bg-navy-600 rounded-md` |
| **Secondary** | `bg-white text-navy-500 border-navy-200 hover:bg-navy-50 rounded-md` |
| **Brown** | `bg-brown-500 text-white hover:bg-brown-600 rounded-md` |
| **Danger** | `bg-error text-white rounded-md` |
| **Ghost** | `text-neutral-500 hover:bg-neutral-100 rounded-md` |

### Barnaviðmót

| Tegund | Stíll |
|--------|-------|
| **Primary** | `bg-navy-500 text-white rounded-xl px-6 py-3 font-bold text-lg shadow-md` |
| **Gold** | `bg-gold-400 text-neutral-900 hover:bg-gold-500 rounded-xl shadow-md` |
| **Success** | `bg-success text-white rounded-xl shadow-md` |

---

## Kort (Cards)

### Foreldraviðmót
```
bg-white rounded-lg shadow border border-neutral-200 p-6
```

### Barnaviðmót
```
bg-white rounded-2xl shadow-md p-6
```

---

## Badge / Tag

| Tegund | Litir |
|--------|-------|
| Samþykkt | `bg-success-light text-emerald-700` |
| Hafnað | `bg-error-light text-red-700` |
| Bíður | `bg-warning-light text-brown-600` |
| Upplýsingar | `bg-info-light text-sky-700` |
| Flokkur | `bg-navy-50 text-navy-600` |

---

## Stig og tölur

| Element | Litur |
|---------|-------|
| Stig teljari (barn) | `text-4xl font-bold text-gold-400` |
| Stig teljari (foreldri) | `text-2xl font-bold text-navy-500` |
| Streak | `text-info` |
| Bónus | `text-brown-500` á `bg-gold-100` |
| Credit (+) | `text-success font-semibold` |
| Debit (−) | `text-error font-semibold` |

---

## Hreyfingar (Animations)

| Tilefni | Hreyfing | Tímalengd |
|---------|----------|-----------|
| Rétt svar | `glow (success)` | 300ms |
| Rangt svar | `shake` | 300ms |
| Stig bætast við | `glow (gold)` | 300ms |
| Streak | `pulse` | 300ms |
| Modal/kort | `bounce-in` | 300ms |
| Síðuskipti | `fade-in` | 150ms |

---

## Iconography

**Lucide React** — aðal icon safn

| Aðgerð | Icon |
|--------|------|
| Stærðfræði | `Calculator` |
| Lestur | `BookOpen` |
| Verkefni | `ClipboardCheck` |
| Verðlaun | `Gift` |
| Stig | `Star` |
| Streak | `Flame` |
| Bónus | `Zap` |
| Stillingar | `Settings` |

---

## Layout skipulag

### Foreldraviðmót
- Navy header + sidebar nav
- Main content: `max-w-5xl mx-auto`
- Sidebar foldable á `< lg`

### Barnaviðmót
- Centered single-column: `max-w-md`
- Gold-tinted bakgrunnur (`gold-50`)
- Bottom nav (4 tabs) með gold indicator á active tab
- Stórir takkar, skýrt layout

---

## Samantekt — Munur á heimum

| Eiginleiki | Foreldri | Barn |
|------------|----------|------|
| Aðallitur | Navy | Navy + Gold |
| Accent | Brown | Gold (stig, verðlaun) |
| Bakgrunnur | Off-white | Gold-50 |
| Border radius | 6–8px | 12–16px |
| Skuggar | shadow | shadow-md |
| Leturstærð | 14–16px | 18–20px |
| Takkar | Flatter, minni | Stærri, boldari |
| Hreyfingar | Lágmarks | Meiri — gull glow, shake |
| Nav | Sidebar | Bottom tabs + gold indicator |

---

## Dark mode

Ekki í MVP. Aðeins light mode í v1.
