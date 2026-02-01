-- DeenHub Trivia Schema
-- Requires: supabase Postgres with pgcrypto for gen_random_uuid()

create extension if not exists pgcrypto;

create table if not exists public.trivia_questions (
  id bigserial primary key,
  question text not null,
  options jsonb not null,
  answer text not null,
  context text,
  fun_fact text,
  hint text,
  difficulty text not null check (difficulty in ('easy','medium','hard')) default 'easy'
);

alter table public.trivia_questions enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where polname = 'trivia_questions_read'
  ) then
    create policy trivia_questions_read on public.trivia_questions
      for select using (true);
  end if;
end $$;

create table if not exists public.trivia_rooms (
  id text primary key default substr(replace(gen_random_uuid()::text,'-',''),1,6),
  host_user_id uuid references auth.users(id),
  difficulty text not null check (difficulty in ('easy','medium','hard')) default 'easy',
  max_players int not null check (max_players between 2 and 4) default 4,
  status text not null default 'lobby',
  created_at timestamptz not null default now()
);

alter table public.trivia_rooms enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where polname = 'trivia_rooms_select_auth'
  ) then
    create policy trivia_rooms_select_auth on public.trivia_rooms
      for select using (true);
  end if;
  if not exists (
    select 1 from pg_policies where polname = 'trivia_rooms_insert_auth'
  ) then
    create policy trivia_rooms_insert_auth on public.trivia_rooms
      for insert with check (auth.role() = 'authenticated');
  end if;
end $$;

create table if not exists public.trivia_room_players (
  room_id text not null references public.trivia_rooms(id) on delete cascade,
  user_id uuid not null references auth.users(id),
  display_name text not null,
  score int not null default 0,
  joined_at timestamptz not null default now(),
  primary key (room_id, user_id)
);

alter table public.trivia_room_players enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where polname = 'trivia_room_players_select_auth'
  ) then
    create policy trivia_room_players_select_auth on public.trivia_room_players
      for select using (true);
  end if;
  if not exists (
    select 1 from pg_policies where polname = 'trivia_room_players_upsert_auth'
  ) then
    create policy trivia_room_players_upsert_auth on public.trivia_room_players
      for insert with check (
        auth.role() = 'authenticated' AND
        auth.uid() = user_id
      );
  end if;
end $$;

create table if not exists public.trivia_answers (
  id bigserial primary key,
  room_id text not null references public.trivia_rooms(id) on delete cascade,
  user_id uuid not null references auth.users(id),
  question_id bigint not null references public.trivia_questions(id),
  is_correct boolean not null,
  points_awarded int not null default 0,
  answered_at timestamptz not null default now()
);

alter table public.trivia_answers enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where polname = 'trivia_answers_select_auth'
  ) then
    create policy trivia_answers_select_auth on public.trivia_answers
      for select using (true);
  end if;
  if not exists (
    select 1 from pg_policies where polname = 'trivia_answers_insert_auth'
  ) then
    create policy trivia_answers_insert_auth on public.trivia_answers
      for insert with check (auth.role() = 'authenticated');
  end if;
end $$;

create or replace function public.trivia_leaderboard(limit_n int default 50)
returns table(display_name text, total_score int) as $$
  select p.display_name,
         coalesce(sum(a.points_awarded), 0) as total_score
  from public.trivia_room_players p
  left join public.trivia_answers a
    on a.user_id = p.user_id
  group by p.display_name
  order by total_score desc
  limit limit_n;
$$ language sql stable;

insert into public.trivia_questions (question, options, answer, context, fun_fact, hint, difficulty)
values (
  'How many Surahs are in the Qur''an?',
  '["100", "114", "120", "130"]'::jsonb,
  '114',
  'The Qur''an contains 114 Surahs revealed to Prophet Muhammad ﷺ over 23 years.',
  'Each Surah has a unique name, like Al-Fatiha or An-Nas.',
  'It’s slightly above 110.',
  'easy'
)
on conflict do nothing;

-- Enable realtime for room player changes (optional - for enhanced realtime experience)
-- This allows clients to listen for player joins/leaves via database changes
do $$ begin
  -- Enable realtime publication for room_players table
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
    and tablename = 'trivia_room_players'
    and schemaname = 'public'
  ) then
    alter publication supabase_realtime add table public.trivia_room_players;
  end if;
end $$;

-- Additional realtime policies for enhanced room synchronization
do $$ begin
  if not exists (
    select 1 from pg_policies where polname = 'trivia_room_players_realtime'
  ) then
    create policy trivia_room_players_realtime on public.trivia_room_players
      for select using (true);
  end if;
end $$;


