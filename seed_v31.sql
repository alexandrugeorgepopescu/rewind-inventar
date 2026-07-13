-- ==============================================
-- UPDATE v3.1: Canale și Sesiuni Aprovizionare
-- ==============================================

-- 1. Creare Tabel CANALE
CREATE TABLE canale (
  id uuid primary key default gen_random_uuid(),
  nume text not null unique,
  ordine int default 0,
  activ boolean default true
);

ALTER TABLE canale ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Permite SELECT pe canale pentru anon" ON canale FOR SELECT TO anon USING (true);
CREATE POLICY "Permite INSERT pe canale pentru anon" ON canale FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Permite UPDATE pe canale pentru anon" ON canale FOR UPDATE TO anon USING (true) WITH CHECK (true);

INSERT INTO canale (nume, ordine) VALUES 
('Metro', 1), 
('Online', 2), 
('Dropshot', 3), 
('Interuno', 4), 
('IPC', 5);

-- 2. Creare Tabel SESIUNI_APROVIZIONARE
CREATE TABLE sesiuni_aprovizionare (
  id uuid primary key default gen_random_uuid(),
  creata_la timestamptz default now(),
  creata_de text,
  status text default 'deschisa',        -- 'deschisa' | 'finalizata'
  nota text
);

ALTER TABLE sesiuni_aprovizionare ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Permite SELECT pe sesiuni_aprovizionare pentru anon" ON sesiuni_aprovizionare FOR SELECT TO anon USING (true);
CREATE POLICY "Permite INSERT pe sesiuni_aprovizionare pentru anon" ON sesiuni_aprovizionare FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Permite UPDATE pe sesiuni_aprovizionare pentru anon" ON sesiuni_aprovizionare FOR UPDATE TO anon USING (true) WITH CHECK (true);

-- 3. Creare Tabel SESIUNI_LINII
CREATE TABLE sesiuni_linii (
  id uuid primary key default gen_random_uuid(),
  sesiune_id uuid references sesiuni_aprovizionare(id) on delete cascade,
  produs_id uuid references produse(id),
  produs_nume text not null,             
  canal text not null,
  categorie text not null,
  total_necesar text,                    
  distributie jsonb not null,            
  cumparat text,                         
  bifat boolean default false            
);

ALTER TABLE sesiuni_linii ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Permite SELECT pe sesiuni_linii pentru anon" ON sesiuni_linii FOR SELECT TO anon USING (true);
CREATE POLICY "Permite INSERT pe sesiuni_linii pentru anon" ON sesiuni_linii FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Permite UPDATE pe sesiuni_linii pentru anon" ON sesiuni_linii FOR UPDATE TO anon USING (true) WITH CHECK (true);
