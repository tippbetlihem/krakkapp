# KrakkApp – Hönnunarleiðbeiningar

---

## Markhópur

**Foreldrar** — stjórna öllu, sjá yfirlit og samþykkja verkefni
**Börn** — nota appið daglega til að læra og vinna sér inn stig

---

## Tæknileg grunnuppsetning

- **Frontend:** Next.js, TypeScript, Tailwind CSS
- **Backend:** Supabase (PostgreSQL, Auth, Storage)
- **Viðmót:** Virkar vel á síma, spjaldtölvu og skjáborði

---

## Litapaletta og stíll

- Hreint og einfalt — engin emoji í gagnagrunni eða kóða
- Sjónrænt hönnunarlag sér um alla framsetningu
- Barnvænt en ekki barnalegt — virðingarfullt fyrir alla aldurshópa
- Notaðu sterkar litasamsetningar til að aðgreina foreldra- og barnaviðmót

---

## Tveir aðskildir heimar

### Foreldraviðmót
Fagmannlegt og gagnasætt. Foreldri á alltaf að hafa fulla stjórn.

### Barnaviðmót
Einfalt, skýrt og hvetjandi. Barnið þarf að skilja hvað á að gera með einu augabragði.

---

## Virkni — Foreldri

### 1. Reikningur
- Skráning með tölvupósti
- Innskráning með tölvupósti
- Gleymt lykilorð

### 2. Börn
- Bæta við barni (nafn, gælunafn, fæðingarár, fæðingardagur, lykilmynd, PIN)
- Breyta upplýsingum barns
- Gera barn óvirkt (eyða ekki)
- Sjá yfirlit allra barna á dashboard

### 3. Stillingar per barn
- Kveikja/slökkva á stærðfræði, lestri, verkefnum, verðlaunum
- Setja dagmarkmið og vikulegt markmið fyrir stig

### 4. Stærðfræðistillingar
- Velja erfiðleikastig (easy, medium, hard, custom)
- Velja leyfðar aðgerðir (+, -, *, /)
- Setja talnabil (lágmark og hámark)
- Fjöldi spurninga per lotu
- Tímamælir (sýna barni eða ekki)
- Stig per rétt svar
- Stig per rangt svar (getur verið neikvætt)

### 5. Upplestursstillingar
- Velja erfiðleikastig
- Setja nákvæmniþröskuld (default 80%)
- Stig per lotu
- Sýna nákvæmni barni eða ekki

### 6. Heimilisstörf
- Búa til verkefni (titill, lýsing, flokkur, stig, skiladagur)
- Endurtekið verkefni (daglegt eða vikulegt)
- Krefjast ljósmyndapurkunar
- Samþykkja eða hafna verkefni sem barn hefur skilað
- Skrifa skilaboð til barns við samþykki eða höfnun

### 7. Bónusar
- Búa til tímabundna stigsupphækkun (2x, 3x o.s.frv.)
- Velja hvaða activity fær bónus (stærðfræði, lestur, verkefni, allt)
- Velja hvaða barn fær bónus (eitt eða öll)
- Setja tíma — frá og til
- Titill sem barnið sér (t.d. "Helgarbónus!")

### 8. Verðlaun
- Búa til verðlaun (titill, lýsing, mynd, stigakostnaður)
- Eitt-skipti verðlaun eða endurtekið
- Samþykkja, hafna eða uppfylla beiðni barns
- Skrifa skilaboð til barns

### 9. Dashboard
**Per barn:**
- Heildar stig, lausar stig, stig í dag, stig þessa viku
- Verkefni í dag, stærðfræðilotur þessa viku, upplesningslotur þessa viku
- Meðalnákvæmni í stærðfræði og lestri
- Núverandi streak, lengsti streak
- Síðasta virkni
- Virkur bónus
- Verkefni sem bíða samþykkis

**Yfirlit allra barna:**
- Fjöldi barna
- Heildar stig allra barna
- Virkasta barn vikunnar
- Hæsta stærðfræðinákvæmni
- Flest heimilisstörf lokið
- Fjöldi verkefna sem bíða samþykkis

---

## Virkni — Barn

### 1. Innskráning
- PIN kóði (4 tölustafir)
- Foreldri getur opnað appið og valið barn

### 2. Heimaskjár
- Kveðja með nafni
- Stig yfirlit (lausar stig, stig í dag)
- Streak teljari
- Virkur bónus ef til staðar
- Flýtileiðir í stærðfræði, lestur og verkefni

### 3. Stærðfræði
- Byrja nýja lotu
- Sjá spurningu — slá inn svar
- Sjá hvort svar var rétt eða rangt
- Sjá stig sem vinnast á meðan lota er í gangi
- Sleppa spurningu (skráð sérstaklega)
- Sjá niðurstöður þegar lotu er lokið

### 4. Lestur
- Sjá úthlutaðan texta
- Lesa upphátt
- Sjá hvort þröskultur náðist
- Sjá stig sem vunnust

### 5. Heimilisstörf
- Sjá verkefnalista (í bið, skilað, samþykkt, hafnað)
- Merkja verkefni sem lokið
- Hlaða upp ljósmynd ef krafist
- Sjá skilaboð frá foreldri

### 6. Verðlaun
- Sjá verðlauna lista
- Sjá hvað kostar hvað
- Biðja um verðlaun
- Sjá stöðu beiðni

### 7. Stigayfirlit
- Sjá alla stigafærslur (credit og debit)
- Sjá hvernig stig voru unnin
- Sjá hvernig stig voru eytt

---

## Stigakerfi — Reglur

| Atburður | Stig |
|----------|------|
| Rétt svar í stærðfræði | points_per_correct_answer (stillanlegt) |
| Rangt svar | points_per_wrong_answer (default 0, getur verið neikvætt) |
| Sleppt svar | 0 stig (skráð sérstaklega) |
| Upplesningslota lokið yfir þröskuldi | points_per_session (heildar) |
| Upplesningslota undir þröskuldi | 0 stig |
| Heimilisverk samþykkt | points_value verkefnis |
| Bónus virkur | multiplier_value × grunnstigi |

---

## Punktar um UX

- Foreldri þarf aldrei að reikna — appið reiknar allt
- Dashboard hleðst hratt — summary töflur nota á eftir raw data
- Barn á aldrei að fá rugling — ein aðgerð í einu
- Foreldri fær tilkynningu þegar barn skilar verkefni (seinna)
- Allt í íslensku í barnaviðmóti
- Foreldraviðmót getur verið á ensku eða íslensku

---

## Öryggi

- Foreldri sér aldrei gögn annarra foreldra
- Barn sér aldrei gögn annarra barna
- PIN kóði geymdur sem hash — aldrei plain text
- Bónusar og stig eru alltaf staðfestar á server-side — aldrei client-side
- points_ledger er óbreytanleg — engar uppfærslur eða eyðingar leyfðar

---

## MVP v1 — Forgangsröð

1. Email innskráning foreldris
2. Bæta við barni
3. Stærðfræðistillingar og stærðfræðilotur
4. Heimilisstörf með samþykktarflæði
5. Stigakerfi og points_ledger
6. Foreldradashboard með summary gögnum
7. Upplestur
8. Verðlaun og innlausn
9. Bónusar og multipliers
10. Barnadashboard og stigayfirlit