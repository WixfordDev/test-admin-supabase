-- DeenHub Trivia – User Profiles for Unique Usernames
-- Safe to run multiple times (IF NOT EXISTS / conditional DDL)

-- 1) User profiles table for storing unique usernames
create table if not exists public.trivia_user_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  email text,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Create unique index on username (case insensitive)
create unique index if not exists idx_trivia_user_profiles_username_lower
  on public.trivia_user_profiles(lower(username));

-- Create index on user_id for faster lookups
create index if not exists idx_trivia_user_profiles_user_id
  on public.trivia_user_profiles(user_id);

alter table public.trivia_user_profiles enable row level security;

-- 2) RLS Policies for user profiles
do $$ begin
  -- Allow users to read all profiles (for leaderboard and game display)
  if not exists (
    select 1 from pg_policies where polname = 'trivia_user_profiles_select_all'
  ) then
    create policy trivia_user_profiles_select_all on public.trivia_user_profiles
      for select using (true);
  end if;

  -- Allow authenticated users to insert their own profile
  if not exists (
    select 1 from pg_policies where polname = 'trivia_user_profiles_insert_own'
  ) then
    create policy trivia_user_profiles_insert_own on public.trivia_user_profiles
      for insert with check (
        auth.role() = 'authenticated' AND
        auth.uid() = user_id
      );
  end if;

  -- Allow users to update their own profile
  if not exists (
    select 1 from pg_policies where polname = 'trivia_user_profiles_update_own'
  ) then
    create policy trivia_user_profiles_update_own on public.trivia_user_profiles
      for update using (
        auth.role() = 'authenticated' AND
        auth.uid() = user_id
      );
  end if;
end $$;

-- 3) Function to update updated_at timestamp
create or replace function public.update_trivia_user_profiles_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Create trigger for updated_at
drop trigger if exists update_trivia_user_profiles_updated_at on public.trivia_user_profiles;
create trigger update_trivia_user_profiles_updated_at
  before update on public.trivia_user_profiles
  for each row execute function public.update_trivia_user_profiles_updated_at();

-- 4) Function to check username uniqueness (case insensitive)
create or replace function public.is_username_available(check_username text)
returns boolean as $$
begin
  return not exists (
    select 1 from public.trivia_user_profiles
    where lower(username) = lower(check_username)
  );
end;
$$ language plpgsql stable;

-- 5) Function to get user profile with email fallback
create or replace function public.get_user_profile(user_uuid uuid)
returns table(
  user_id uuid,
  username text,
  email text,
  display_name text
) as $$
begin
  return query
  select
    p.user_id,
    p.username,
    p.email,
    coalesce(p.display_name, p.username) as display_name
  from public.trivia_user_profiles p
  where p.user_id = user_uuid;
end;
$$ language plpgsql stable;

-- 6) Updated leaderboard function that includes user profiles
create or replace function public.trivia_leaderboard(limit_n int default 50)
returns table(
  user_id uuid,
  username text,
  email text,
  display_name text,
  total_score bigint,
  games_played bigint
) as $$
  select
    p.user_id,
    coalesce(up.username, 'Anonymous') as username,
    up.email,
    coalesce(up.display_name, up.username, 'Anonymous') as display_name,
    coalesce(sum(a.points_awarded), 0) as total_score,
    count(distinct a.room_id) as games_played
  from public.trivia_room_players p
  left join public.trivia_answers a on a.user_id = p.user_id
  left join public.trivia_user_profiles up on up.user_id = p.user_id
  group by p.user_id, up.username, up.email, up.display_name
  order by total_score desc, games_played desc
  limit limit_n;
$$ language sql stable;

-- 7) Function to migrate existing display names to usernames (one-time migration)
create or replace function public.migrate_display_names_to_usernames()
returns void as $$
begin
  -- Insert profiles for users who don't have one but have played games
  insert into public.trivia_user_profiles (user_id, username, email, display_name)
  select distinct
    p.user_id,
    -- Use display_name as username if available, otherwise use email prefix
    coalesce(
      (select display_name from public.trivia_room_players where user_id = p.user_id limit 1),
      split_part(u.email, '@', 1)
    ) as username,
    u.email,
    coalesce(
      (select display_name from public.trivia_room_players where user_id = p.user_id limit 1),
      split_part(u.email, '@', 1)
    ) as display_name
  from public.trivia_room_players p
  join auth.users u on u.id = p.user_id
  where not exists (
    select 1 from public.trivia_user_profiles where user_id = p.user_id
  )
  on conflict (user_id) do nothing;
end;
$$ language plpgsql;

-- 8) Enable realtime for user profiles
do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
    and schemaname = 'public'
    and tablename = 'trivia_user_profiles'
  ) then
    alter publication supabase_realtime add table public.trivia_user_profiles;
  end if;
end $$;

