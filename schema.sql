-- ============================================================
-- Schéma de la base de données pour l'appli de messagerie
-- À exécuter dans Supabase : SQL Editor > New query > coller > Run
-- ============================================================

-- Un profil public par utilisateur (pseudo affiché et cherchable)
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  username_lower text generated always as (lower(username)) stored,
  created_at timestamptz not null default now()
);

create unique index profiles_username_lower_idx on public.profiles(username_lower);

-- Colonnes pour la modération : administrateur et compte banni
alter table public.profiles add column is_admin boolean not null default false;
alter table public.profiles add column banned boolean not null default false;

-- Demandes / relations d'amitié entre deux utilisateurs
create table public.friendships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles(id) on delete cascade,
  addressee_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted')),
  created_at timestamptz not null default now(),
  constraint no_self_friend check (requester_id <> addressee_id),
  constraint unique_pair unique (requester_id, addressee_id)
);

-- Messages privés entre deux amis
create table public.messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles(id) on delete cascade,
  receiver_id uuid not null references public.profiles(id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now()
);

create index messages_pair_idx on public.messages(sender_id, receiver_id, created_at);

-- ============================================================
-- Sécurité : chacun ne voit/modifie que ce qui le concerne
-- ============================================================
alter table public.profiles enable row level security;
alter table public.friendships enable row level security;
alter table public.messages enable row level security;

-- Profils : tout le monde connecté peut chercher un pseudo ; on ne modifie que le sien
create policy "profils visibles par tous les connectés"
  on public.profiles for select
  to authenticated
  using (true);

create policy "on crée son propre profil"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

create policy "on modifie son propre profil"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id);

create policy "un administrateur peut modifier n'importe quel profil"
  on public.profiles for update
  to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true));

-- Amitiés : visibles et gérables seulement par les deux personnes concernées
create policy "voir ses propres relations"
  on public.friendships for select
  to authenticated
  using (auth.uid() = requester_id or auth.uid() = addressee_id);

create policy "envoyer une demande d'ami"
  on public.friendships for insert
  to authenticated
  with check (auth.uid() = requester_id);

create policy "accepter une demande reçue"
  on public.friendships for update
  to authenticated
  using (auth.uid() = addressee_id);

create policy "annuler ou retirer une relation"
  on public.friendships for delete
  to authenticated
  using (auth.uid() = requester_id or auth.uid() = addressee_id);

-- Messages : visibles seulement par l'expéditeur et le destinataire
create policy "voir les messages échangés avec soi"
  on public.messages for select
  to authenticated
  using (auth.uid() = sender_id or auth.uid() = receiver_id);

create policy "envoyer un message en étant soi-même l'expéditeur"
  on public.messages for insert
  to authenticated
  with check (auth.uid() = sender_id);

-- Active le temps réel sur les messages et les amitiés
alter publication supabase_realtime add table public.messages;
alter publication supabase_realtime add table public.friendships;

-- ============================================================
-- Pour vous désigner administrateur : créez d'abord votre compte
-- normalement dans l'appli, PUIS exécutez la ligne suivante en
-- remplaçant 'votre_pseudo' par le pseudo choisi à l'inscription.
-- ============================================================
-- update public.profiles set is_admin = true where username = 'votre_pseudo';
