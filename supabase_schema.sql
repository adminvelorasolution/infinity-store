-- ═══════════════════════════════════════════════
-- INFINITY STORE — Schéma Supabase (SQL)
-- À exécuter dans Supabase → SQL Editor
-- ═══════════════════════════════════════════════

-- ── TABLE: accessoires ──
create table accessoires (
  id bigint generated always as identity primary key,
  nom text not null,
  categorie text not null,
  description text,
  prix integer,
  prix_old integer,           -- prix avant promo (pour calcul du % discount)
  badge text,                 -- 'new' | 'hot' | null
  marque text,
  statut text default 'disponible',  -- disponible | commande | rupture
  image_url text,
  une boolean default false,  -- afficher en page d'accueil "Produits à la une"
  created_at timestamptz default now()
);

-- ── TABLE: produits_reseau ──
create table produits_reseau (
  id bigint generated always as identity primary key,
  nom text not null,
  categorie text not null,    -- routeur | switch | ap | cable | autre
  description text,
  prix integer,
  prix_old integer,
  badge text,
  marque text,
  statut text default 'disponible',
  image_url text,
  une boolean default false,
  created_at timestamptz default now()
);

-- ── TABLE: videos (Astuces & Tutoriels) ──
create table videos (
  id bigint generated always as identity primary key,
  titre text not null,
  description text,
  lien_youtube text not null,
  categorie text not null,    -- tutoriel | astuce | conseil | reseau
  mots_cles text,             -- séparés par virgule
  duree text,                 -- ex: "10:32"
  vues integer default 0,
  created_at timestamptz default now()
);

-- ── TABLE: devis (Demandes de devis réseau) ──
create table devis (
  id bigint generated always as identity primary key,
  nom text not null,
  telephone text not null,
  email text,
  entreprise text,
  produits text,              -- liste séparée par virgules
  message text,
  statut text default 'nouveau',  -- nouveau | traite
  created_at timestamptz default now()
);

-- ── TABLE: messages (Formulaire contact) ──
create table messages (
  id bigint generated always as identity primary key,
  nom text not null,
  telephone text not null,
  email text,
  sujet text,
  message text not null,
  statut text default 'nouveau',  -- nouveau | lu
  created_at timestamptz default now()
);

-- ═══════════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS)
-- Accès public en lecture, écriture via clé anon
-- (à durcir plus tard avec auth admin réelle)
-- ═══════════════════════════════════════════════

alter table accessoires enable row level security;
alter table produits_reseau enable row level security;
alter table videos enable row level security;
alter table devis enable row level security;
alter table messages enable row level security;

-- Lecture publique
create policy "public_read_accessoires" on accessoires for select using (true);
create policy "public_read_reseau" on produits_reseau for select using (true);
create policy "public_read_videos" on videos for select using (true);

-- Écriture publique (admin via mot de passe front-end + clients via formulaires)
create policy "public_write_accessoires" on accessoires for all using (true) with check (true);
create policy "public_write_reseau" on produits_reseau for all using (true) with check (true);
create policy "public_write_videos" on videos for all using (true) with check (true);
create policy "public_insert_devis" on devis for insert with check (true);
create policy "public_read_devis" on devis for select using (true);
create policy "public_update_devis" on devis for update using (true);
create policy "public_delete_devis" on devis for delete using (true);
create policy "public_insert_messages" on messages for insert with check (true);
create policy "public_read_messages" on messages for select using (true);
create policy "public_update_messages" on messages for update using (true);
create policy "public_delete_messages" on messages for delete using (true);

-- ═══════════════════════════════════════════════
-- STORAGE — Bucket pour les images produits
-- ═══════════════════════════════════════════════
-- 1. Aller dans Supabase → Storage → New bucket
-- 2. Nom du bucket: "produits"
-- 3. Cocher "Public bucket" (pour que les images soient accessibles publiquement)
--
-- Puis exécuter cette policy pour autoriser l'upload via la clé anon:

insert into storage.buckets (id, name, public)
values ('produits', 'produits', true)
on conflict (id) do nothing;

create policy "public_upload_produits" on storage.objects
  for insert with check (bucket_id = 'produits');

create policy "public_read_produits" on storage.objects
  for select using (bucket_id = 'produits');

create policy "public_update_produits" on storage.objects
  for update using (bucket_id = 'produits');

create policy "public_delete_produits" on storage.objects
  for delete using (bucket_id = 'produits');

-- ═══════════════════════════════════════════════
-- FIN — N'oubliez pas de copier dans assets/shared.js :
--   SUPABASE_URL     = 'https://VOTRE_ID.supabase.co'
--   SUPABASE_ANON_KEY = 'VOTRE_ANON_KEY'
--   STORAGE_BUCKET   = 'produits'
-- ═══════════════════════════════════════════════
