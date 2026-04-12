# KrakkApp – UI Brand Guide

---

## Grunnregla

Barnvænt en ekki barnalegt. **Lífrænt, hlýtt og hvetjandi.**
Bogalínur, mjúk form og litaðir bakgrunnar — ekkert er harð-kantuð.
Tveir aðskildir heimar — foreldri og barn — deila Evergreen Mist sem aðallit; barn fær Golden Sun og Citrus Burst sem accent.

---

## 6 Grunnlitir (Fresh and Bright)

| Litur | Hex | Hlutverk |
|-------|-----|----------|
| Evergreen Mist | `#324F44` | Aðallitur — takkar, header, fyrirsagnir |
| Golden Sun | `#FFD746` | Stig, stjörnur, barna accent |
| Citrus Burst | `#FF9B2E` | Hlýr accent — streak, aukahlutar |
| Minted Cream | `#D9E8C1` | Rólegur bakgrunnur, success, blobs |
| Soft Blush | `#F6E1DE` | Mjúkur hlýr bakgrunnur, mildar yfirborðsáherslur |
| Vanilla Cream | `#F3EFE6` | Aðalsíðubakgrunnur, hlýtt off-white |

---

## Hönnunarstíll — Organic / Soft UI

### Lífræn form (Blobs)
- SVG blob shapes á bak við hero sections og stórar tölur
- Blobbar nota `minted-cream`, `soft-blush`, `golden-sun` (dælt) sem fill
- Aldrei harðar línur — allt flæðir

### Bogalínur (Wave Dividers)
- SVG bylgjulínur skipta á milli hluta
- Soft curve, ekki zig-zag
- Nota aðallit section-ins eða `neutral-100`

### Litaðar sections
- Hver kafli á dashboard fær eigin bakgrunnslit:
  - Stig hero: `golden-sun` / ljóst gult (`gold-50`)
  - Stærðfræði: `evergreen-50`
  - Lestur: `soft-blush` eða `minted-cream` (mjúkt)
  - Verkefni: `success-light` / `minted-cream`
- Hvít kort fljóta á ofan á lituðum sections

### Border radius
- Foreldraviðmót: `rounded-2xl` (16px)
- Barnaviðmót: `rounded-3xl` (24px)
- Takkar: `rounded-2xl`
- Avatar/progress: `rounded-full`

### Skuggar
- Foreldri: `shadow-sm` — mjúkt
- Barn: `shadow-lg` — meiri djúp og varmi

---

## Litapaletta — Full scale

### Evergreen Mist (Primary)

| Token | Hex | Notkun |
|-------|-----|--------|
| `evergreen-50` | `#E8EFEC` | Section bakgrunnur, valdir liðir |
| `evergreen-100` | `#D0DDD7` | Tags, border |
| `evergreen-200` | `#B0C7BC` | Rammar, disabled border |
| `evergreen-300` | `#7A9E8C` | Disabled texti |
| `evergreen-400` | `#4D6B5E` | Aukatexti |
| `evergreen-500` | `#324F44` | Takkar, tenglar, header |
| `evergreen-600` | `#2A4239` | Hover |
| `evergreen-700` | `#22352E` | Active |
| `evergreen-900` | `#1A2822` | Dökkar fyrirsagnir |

### Golden Sun (Child accent / Points)

| Token | Hex | Notkun |
|-------|-----|--------|
| `gold-50` | `#FFFBEB` | Stig section bakgrunnur |
| `gold-100` | `#FFF4D4` | Highlight, bónus bakgrunnur |
| `gold-200` | `#FFE99F` | Blob fill, tags |
| `gold-300` | `#FFE066` | Light accent |
| `gold-400` | `#FFD746` | Stig, stjörnur, barna takkar |
| `gold-500` | `#D4B435` | Hover á gulli, tölutexti á ljósu |
| `gold-700` | `#6B5420` | Gull texti á ljósum bakgrunni |

### Citrus Burst (Warm accent)

| Token | Hex | Notkun |
|-------|-----|--------|
| `citrus-50` | `#FFF4E8` | Hlýr section bakgrunnur |
| `citrus-100` | `#FFE4CC` | Border, tags |
| `citrus-300` | `#FFB366` | Blob, icon bakgrunnur |
| `citrus-500` | `#FF9B2E` | Streak, áhersla, aukatakki |
| `citrus-700` | `#B86A18` | Dökkur texti á ljósu |

### Minted Cream

| Token | Hex | Notkun |
|-------|-----|--------|
| `mint-50` | `#F2F7EA` | Mjúkur bg |
| `mint-100` | `#E5EFD5` | Kort, subtle fill |
| `mint-200` | `#D9E8C1` | Grunnlitur — blobs, success yfirborð |
| `mint-300` | `#B8D199` | Hover á mint svæðum |
| `mint-500` | `#6B8F5A` | Texti á mjúku mint (ef þarf) |

### Soft Blush

| Token | Hex | Notkun |
|-------|-----|--------|
| `blush-50` | `#FDF8F7` | Mjúkast |
| `blush-100` | `#F6E1DE` | Grunnlitur — hlýjar yfirborðsáherslur |
| `blush-200` | `#EECBC4` | Border |

### Vanilla Cream (Neutrals base)

| Token | Hex | Notkun |
|-------|-----|--------|
| `cream` | `#F3EFE6` | Aðal bakgrunnur síðu |

### Stöðulitir

| Token | Hex | Notkun |
|-------|-----|--------|
| `success` | `#2D6A4F` | Rétt svar, samþykkt (grænn í takt við evergreen) |
| `success-light` | `#D9E8C1` | Verkefni section — sama og minted cream |
| `error` | `#C64632` | Rangt svar, hafnað (lesanlegur rauður) |
| `error-light` | `#FDEEEB` | Bakgrunnur á neikvæðu |
| `info` | `#3D7A8C` | Streak, upplýsingar (blágrænn, ekki í grunnpöllu) |
| `info-light` | `#E8F4F7` | Bakgrunnur á upplýsingum |

### Hlutlausir litir (warm neutrals)

| Token | Hex | Notkun |
|-------|-----|--------|
| `neutral-50` | `#F3EFE6` | Samsvarar vanilla cream |
| `neutral-100` | `#EBE6DC` | Wave divider, subtle bg |
| `neutral-200` | `#D9D4C9` | Border, skipting |
| `neutral-300` | `#C4BFB3` | Rammar |
| `neutral-500` | `#6E6A62` | Aukatexti, placeholder |
| `neutral-700` | `#3D3C39` | Meginmálstexti |
| `neutral-900` | `#1A1918` | Fyrirsagnir |

---

## Leturval (Typography)

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
| `text-3xl` | 30px | Stórar tölur (foreldri) |
| `text-4xl` | 36px | Hero tölur |
| `text-5xl` | 48px | Hero stig í barnaviðmóti |

---

## Takkar (Buttons)

### Foreldraviðmót

| Tegund | Stíll |
|--------|-------|
| **Primary** | `bg-evergreen-500 text-white hover:bg-evergreen-600 rounded-2xl px-5 py-2.5` |
| **Secondary** | `bg-white text-evergreen-500 border-evergreen-200 hover:bg-evergreen-50 rounded-2xl` |
| **Citrus** | `bg-citrus-500 text-white hover:bg-citrus-600 rounded-2xl` |
| **Danger** | `bg-error text-white rounded-2xl` |
| **Ghost** | `text-neutral-500 hover:bg-neutral-100 rounded-2xl` |

### Barnaviðmót

| Tegund | Stíll |
|--------|-------|
| **Primary** | `bg-evergreen-500 text-white rounded-3xl px-8 py-4 font-bold text-lg shadow-lg` |
| **Gold** | `bg-gold-400 text-neutral-900 hover:brightness-95 rounded-3xl shadow-lg` |
| **Success** | `bg-success text-white rounded-3xl shadow-lg` |

---

## Kort (Cards)

### Foreldraviðmót
```
bg-white rounded-2xl shadow-sm p-6
```

### Barnaviðmót
```
bg-white rounded-3xl shadow-lg p-6
```

Engin sýnileg border á kortum — skuggi einn sér um djúp.

---

## Upplýsingaframsetning

### Circular Progress (hringframvinda)
- Dagmarkmið, nákvæmni, framvinda
- SVG hringur með stroke-dasharray
- Bakgrunnshringur: `neutral-200`
- Framvinda: `gold-400` (stig), `success` (nákvæmni), `evergreen-500` (almennt)
- Stór tala í miðjunni

### Stat Cards (tölfræði kubbar)
- 2-3 í röð, hvort með eigin bakgrunnslit
- Icon í litaðri hring efst
- Stór tala
- Lítill label neðst
- `rounded-2xl` á foreldri, `rounded-3xl` á barni

### Línurit (7-daga trend)
- Smooth bezier curve — aldrei beinar línur
- Fill undir línu með gradient (fade to transparent)
- Á `gold-50` eða `vanilla cream` bakgrunni

---

## Hreyfingar (Animations)

| Tilefni | Hreyfing | Tímalengd |
|---------|----------|-----------|
| Rétt svar | `glow (success)` | 300ms |
| Rangt svar | `shake` | 300ms |
| Stig bætast við | `glow (gold) + count-up` | 500ms |
| Streak | `pulse` | 300ms |
| Kort birtast | `fade-up` | 200ms |
| Circular progress | `draw-in` (stroke animation) | 800ms |
| Síðuskipti | `fade-in` | 150ms |

---

## Iconography

**Lucide React** — aðal icon safn. Forðast emoji og skrautkosti í viðmóti; nota Lucide-ikon (eða stutta textamerki / skammstöfun þegar ikon vantar).

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

Icons birtast í **litaðri hring** (48-64px) — ekki naktar.

---

## Layout skipulag

### Foreldraviðmót
- Evergreen header + sidebar nav
- Main content: `max-w-5xl mx-auto`
- Sidebar foldable á `< lg`
- Sections með litaðir bakgrunnar og wave dividers

### Barnaviðmót
- Centered single-column: `max-w-md`
- Blob shapes á bak við hero
- Gull- og rjómalitaður bakgrunnur (`gold-50` / `vanilla cream`)
- Bottom nav (4 tabs) með golden sun indicator
- Stórir rounded takkar

---

## Samantekt — Munur á heimum

| Eiginleiki | Foreldri | Barn |
|------------|----------|------|
| Aðallitur | Evergreen Mist | Evergreen + Golden Sun |
| Accent | Mint / Citrus | Golden Sun + Citrus Burst |
| Bakgrunnur | Vanilla cream + litaðar sections | Golden-50 + blobs |
| Border radius | `rounded-2xl` (16px) | `rounded-3xl` (24px) |
| Skuggar | `shadow-sm` | `shadow-lg` |
| Leturstærð | 14–16px | 18–20px |
| Takkar | `rounded-2xl`, minni | `rounded-3xl`, stærri |
| Hreyfingar | Lágmarks | Meiri — glow, count-up |
| Nav | Sidebar | Bottom tabs |
| Form | Litaðar sections, wave dividers | Blobs, circular progress |

---

## Dark mode

Ekki í MVP. Aðeins light mode í v1.
