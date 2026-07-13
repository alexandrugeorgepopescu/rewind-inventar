-- 1. Stergerea tabelelor daca exista (pentru a putea rula seed-ul de mai multe ori la nevoie)
DROP TABLE IF EXISTS inventar;
DROP TABLE IF EXISTS produse;

-- 2. Crearea tabelei PRODUSE
CREATE TABLE produse (
  id uuid primary key default gen_random_uuid(),
  nume text not null unique,
  categorie text not null,
  canal text not null default 'Metro',        -- 'Metro' | 'Online' | 'Dropshot' | 'Interuno'
  unitate text default 'buc',                 -- buc / kg / l / rola / pachet
  locatii text[] not null default '{Miroslava,Pacurari,Alexandru}',
  ordine int default 0,
  activ boolean default true
);

-- 3. Crearea tabelei INVENTAR
CREATE TABLE inventar (
  produs_id uuid references produse(id) on delete cascade,
  locatie text not null,
  stoc text,
  necesar text,
  actualizat_la timestamptz default now(),
  actualizat_de text,                          -- nume operator
  primary key (produs_id, locatie)
);

-- 4. Activare RLS
ALTER TABLE produse ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventar ENABLE ROW LEVEL SECURITY;

-- 5. Politici RLS pentru PRODUSE (anon)
CREATE POLICY "Permite SELECT pe produse pentru anon" ON produse FOR SELECT TO anon USING (true);
CREATE POLICY "Permite INSERT pe produse pentru anon" ON produse FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Permite UPDATE pe produse pentru anon" ON produse FOR UPDATE TO anon USING (true) WITH CHECK (true);
-- Delete este interzis (nu cream politica de delete)

-- 6. Politici RLS pentru INVENTAR (anon)
CREATE POLICY "Permite SELECT pe inventar pentru anon" ON inventar FOR SELECT TO anon USING (true);
CREATE POLICY "Permite INSERT pe inventar pentru anon" ON inventar FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Permite UPDATE pe inventar pentru anon" ON inventar FOR UPDATE TO anon USING (true) WITH CHECK (true);
-- Delete este interzis (nu cream politica de delete)

-- 7. Inserare Catalog (Seed)
INSERT INTO produse (nume, categorie, canal, ordine) VALUES
-- Categoria: Cafea de Specialitate (Pungi)
('Aromatic Blend - 3kg', 'Cafea de Specialitate (Pungi)', 'Dropshot', 1),
('Aromatic Blend - 1kg (Beandrops)', 'Cafea de Specialitate (Pungi)', 'Dropshot', 2),
('Aromatic Blend - 250g', 'Cafea de Specialitate (Pungi)', 'Dropshot', 3),
('Lava Cake Blend - 250g', 'Cafea de Specialitate (Pungi)', 'Dropshot', 4),
('Milky Way Blend - 250g', 'Cafea de Specialitate (Pungi)', 'Dropshot', 5),
('Cherry Tart Blend - 250g', 'Cafea de Specialitate (Pungi)', 'Dropshot', 6),
('Colombia El Vergel DECAF Sugar Cane - 1kg', 'Cafea de Specialitate (Pungi)', 'Dropshot', 7),
('Ethiopia Guji - 1kg', 'Cafea de Specialitate (Pungi)', 'Dropshot', 8),
('Bombon - 1kg', 'Cafea de Specialitate (Pungi)', 'Dropshot', 9),
('Bombon - 250g', 'Cafea de Specialitate (Pungi)', 'Dropshot', 10),

-- Categoria: Fructe & Ingrediente Fresh
('Portocale', 'Fructe & Ingrediente Fresh', 'Metro', 11),
('Lamai', 'Fructe & Ingrediente Fresh', 'Metro', 12),
('Grapefruit', 'Fructe & Ingrediente Fresh', 'Metro', 13),
('Menta', 'Fructe & Ingrediente Fresh', 'Metro', 14),
('Zeama de lamaie', 'Fructe & Ingrediente Fresh', 'Metro', 15),
('Portocale Lamai (zeama)', 'Fructe & Ingrediente Fresh', 'Metro', 16),
('Breezer', 'Fructe & Ingrediente Fresh', 'Interuno', 17),

-- Categoria: Ambalaje & Consumabile
('Plicuri pt bani', 'Ambalaje & Consumabile', 'Metro', 18),
('Role casa de marcat', 'Ambalaje & Consumabile', 'Metro', 19),
('Post-it', 'Ambalaje & Consumabile', 'Metro', 20),
('Filtre ceai', 'Ambalaje & Consumabile', 'Metro', 21),
('Paletine', 'Ambalaje & Consumabile', 'Metro', 22),
('Paie ambalate individual', 'Ambalaje & Consumabile', 'Metro', 23),
('Mansoane', 'Ambalaje & Consumabile', 'Metro', 24),
('Suporturi pt pahare', 'Ambalaje & Consumabile', 'Metro', 25),
('Lingurite', 'Ambalaje & Consumabile', 'Metro', 26),
('Rola hartie prosop', 'Ambalaje & Consumabile', 'Metro', 27),
('Servetele patrate', 'Ambalaje & Consumabile', 'Metro', 28),
('Saci menajeri 30l', 'Ambalaje & Consumabile', 'Metro', 29),
('Saci menajeri 60l', 'Ambalaje & Consumabile', 'Metro', 30),
('Saci menajeri 120l', 'Ambalaje & Consumabile', 'Metro', 31),
('Pahare de apa', 'Ambalaje & Consumabile', 'Metro', 32),
('Pungi pt pachet', 'Ambalaje & Consumabile', 'Metro', 33),
('Pahar carton', 'Ambalaje & Consumabile', 'Metro', 34),
('Pahar plastic', 'Ambalaje & Consumabile', 'Metro', 35),

-- Categoria: Curățenie & Chimicale
('Servetele umede', 'Curățenie & Chimicale', 'Metro', 36),
('Bureti vase', 'Curățenie & Chimicale', 'Metro', 37),
('Manusi de unica folosinta', 'Curățenie & Chimicale', 'Metro', 38),
('Detergent pt masina de spalat', 'Curățenie & Chimicale', 'Metro', 39),
('Clatitor pt masina de spalat', 'Curățenie & Chimicale', 'Metro', 40),
('Lavete', 'Curățenie & Chimicale', 'Metro', 41),
('Clor', 'Curățenie & Chimicale', 'Metro', 42),
('Solutie Pardoseli', 'Curățenie & Chimicale', 'Metro', 43),
('Sare pt masina de spalat', 'Curățenie & Chimicale', 'Metro', 44),
('Sapun lichid', 'Curățenie & Chimicale', 'Metro', 45),
('Detergent vase', 'Curățenie & Chimicale', 'Metro', 46),
('Rezerva mop', 'Curățenie & Chimicale', 'Metro', 47),
('Solutie geamuri', 'Curățenie & Chimicale', 'Metro', 48),
('Solutie inox', 'Curățenie & Chimicale', 'Metro', 49),

-- Categoria: Cafea, Siropuri & Bar
('Capsule frisca', 'Cafea, Siropuri & Bar', 'Metro', 50),
('Ness', 'Cafea, Siropuri & Bar', 'Metro', 51),
('Ness deco', 'Cafea, Siropuri & Bar', 'Metro', 52),
('Miere', 'Cafea, Siropuri & Bar', 'Metro', 53),
('Topping Caramel', 'Cafea, Siropuri & Bar', 'Metro', 54),
('Topping Ciocolata', 'Cafea, Siropuri & Bar', 'Metro', 55),
('Frișcă', 'Cafea, Siropuri & Bar', 'Metro', 56),
('Sirop Caramel sarat', 'Cafea, Siropuri & Bar', 'Metro', 57),
('Sirop Vanilie', 'Cafea, Siropuri & Bar', 'Metro', 58),
('Sirop Pumpkin Spice', 'Cafea, Siropuri & Bar', 'Metro', 59),
('Sirop Creme Brulee', 'Cafea, Siropuri & Bar', 'Metro', 60),
('Sirop Menta', 'Cafea, Siropuri & Bar', 'Metro', 61),
('Sirop Macadamia Nut', 'Cafea, Siropuri & Bar', 'Metro', 62),
('Sirop Amareto', 'Cafea, Siropuri & Bar', 'Metro', 63),
('Sirop Cocos', 'Cafea, Siropuri & Bar', 'Metro', 64),
('Sirop Chocolate Cookie', 'Cafea, Siropuri & Bar', 'Metro', 65),
('Sirop Trandafir', 'Cafea, Siropuri & Bar', 'Metro', 66),
('Sirop Lavanda', 'Cafea, Siropuri & Bar', 'Metro', 67),
('Sirop Alune', 'Cafea, Siropuri & Bar', 'Metro', 68),
('Piure Mango', 'Cafea, Siropuri & Bar', 'Metro', 69),
('Piure Capsuni', 'Cafea, Siropuri & Bar', 'Metro', 70),
('Piure Fructul pasiunii', 'Cafea, Siropuri & Bar', 'Metro', 71),
('Zahar alb baghete', 'Cafea, Siropuri & Bar', 'Metro', 72),
('Zahar brun baghete', 'Cafea, Siropuri & Bar', 'Metro', 73),
('Zahar alb kg', 'Cafea, Siropuri & Bar', 'Metro', 74),
('Zahar brun kg', 'Cafea, Siropuri & Bar', 'Metro', 75),
('Scortisoara', 'Cafea, Siropuri & Bar', 'Metro', 76),
('Indulcitor', 'Cafea, Siropuri & Bar', 'Metro', 77),

-- Categoria: Băuturi & Răcoritoare
('Suc pfanner portocale', 'Băuturi & Răcoritoare', 'Metro', 78),
('Apa plata', 'Băuturi & Răcoritoare', 'Metro', 79),
('Apa minerala', 'Băuturi & Răcoritoare', 'Metro', 80),
('Apa Plata 5l', 'Băuturi & Răcoritoare', 'Metro', 81),
('Apa', 'Băuturi & Răcoritoare', 'Metro', 82),
('Tonica', 'Băuturi & Răcoritoare', 'Interuno', 83),
('Pepsi', 'Băuturi & Răcoritoare', 'Interuno', 84),
('Pepsi max', 'Băuturi & Răcoritoare', 'Interuno', 85),
('Mirinda', 'Băuturi & Răcoritoare', 'Interuno', 86),
('7UP', 'Băuturi & Răcoritoare', 'Interuno', 87),
('Pepsi (Locație)', 'Băuturi & Răcoritoare', 'Interuno', 88),
('Mirinda (Locație)', 'Băuturi & Răcoritoare', 'Interuno', 89),
('7UP (Locație)', 'Băuturi & Răcoritoare', 'Interuno', 90),
('Capra Noastra', 'Băuturi & Răcoritoare', 'Interuno', 91),
('Vin', 'Băuturi & Răcoritoare', 'Interuno', 92),
('Prosecco', 'Băuturi & Răcoritoare', 'Interuno', 93),

-- Categoria: Dulciuri & Patiserie
('Cookies', 'Dulciuri & Patiserie', 'Metro', 94),
('Ciocolata de casa', 'Dulciuri & Patiserie', 'Metro', 95),
('Tarta Ciocolata', 'Dulciuri & Patiserie', 'Metro', 96),
('Tarta Caramel Sarat', 'Dulciuri & Patiserie', 'Metro', 97),
('Tarta Lemon Curd', 'Dulciuri & Patiserie', 'Metro', 98),
('Tarta Mere', 'Dulciuri & Patiserie', 'Metro', 99),
('Cescuta Dubai', 'Dulciuri & Patiserie', 'Metro', 100),
('Cescuta Cioc Calda', 'Dulciuri & Patiserie', 'Metro', 101),
('Banana Bread', 'Dulciuri & Patiserie', 'Metro', 102);
