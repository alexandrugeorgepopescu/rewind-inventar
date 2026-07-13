# Rewind Inventar v3.0

Acesta este repository-ul pentru aplicația de inventar Rewind Café, o aplicație Single Page Application (SPA) bazată pe HTML, CSS, JavaScript și Supabase.

## Structură

- `index.html`: Aplicația principală (Inventar, Centralizator, Admin).
- `seed.sql`: Scriptul SQL pentru crearea tabelelor, politicilor de securitate și popularea inițială a catalogului de produse.
- `migration.html`: Script de migrare a datelor din tabelul vechi (`inventar_rewind`) către cel nou (`inventar`).

## Deployment / Actualizări
Aplicația este hostată pe GitHub Pages. Orice commit pe branch-ul `main` se va reflecta automat (în câteva minute) la adresa live a aplicației. 
Deoarece întregul cod frontend se află în `index.html`, este suficient să adaugi și să faci commit acestui fișier.

## Configurare Bază de Date (Supabase)

Aplicația folosește un proiect Supabase cu un model de date normalizat în 2 tabele principale: `produse` și `inventar`.

### Pași inițializare (dacă instanțiezi de la zero sau migrezi)
1. Accesează panoul SQL din Supabase (SQL Editor).
2. Rulează conținutul fișierului `seed.sql`. Aceasta va:
   - Crea structura de tabele.
   - Activa RLS (Row Level Security).
   - Insera cele 102 produse de bază cu canalele aferente.
3. Deschide fișierul `migration.html` în browserul tău.
   - Apasă pe "Pornește Migrarea".
   - Așteaptă finalizarea procesului. Vor fi transferate valorile vechi de stoc și necesar.
   - Verifică raportul pentru a vedea dacă au existat produse lipsă (produse vechi ce nu s-au potrivit perfect ca nume cu noul catalog - acestea trebuie adăugate manual din Admin dacă mai sunt relevante).

## Securitate și RLS (Row Level Security)

Aplicația folosește cheia de API publică (`anon publishable`), destinată utilizării client-side, direct în `index.html`. 
Protecția reală a bazei de date NU stă în ascunderea acestei chei (care este oricum expusă în browser), ci în **politicile RLS (Row Level Security)** implementate:
- Sunt permise operațiuni de `SELECT`, `INSERT` și `UPDATE` pe ambele tabele.
- Sunt strict **interzise** operațiunile de `DELETE` (pe produse se folosește funcția soft-delete setând `activ = false`).

### Rotirea cheilor (Key Rotation)
Dacă link-ul ajunge public și există incidente:
1. Din panoul Supabase, mergi la `Settings` -> `API`.
2. Găsește cheia `anon public` și alege opțiunea de regenerare/rolare (roll key).
3. Va fi generată o cheie nouă. Baza de date devine instant inaccesibilă pentru cheia veche.
4. Actualizează variabila `supabaseKey` în fișierul `index.html`.
5. Fă commit pe GitHub cu noul `index.html`.

## Ghid pentru Operatori
1. **Salvare Automată**: În ecranul de inventar, odată ce introduci o cantitate de stoc sau necesar, aceasta este salvată automat după 800 milisecunde. Nu există buton de salvare pe fiecare rând.
2. **Căutare**: Folosește bara de sus pentru a găsi un produs instantaneu, evitând scroll-ul.
3. **Locație**: Odată selectată locația din antet, aceasta este memorată pentru vizitele viitoare.
4. **Finalizare**: Butonul "Finalizează Inventarul" este pentru validarea vizuală a sesiunii.
5. **Centralizator și Comenzi**: Din Centralizator poți genera rapoarte separate pe canal și trimite mesajele direct pe WhatsApp.
6. **Admin**: Produsele noi, schimbarea categoriei sau a canalului de aprovizionare se fac exclusiv din ecranul Admin (PIN implicit: `2024`). Modificările din Admin se aplică live, fără a fi nevoie de actualizarea codului.
