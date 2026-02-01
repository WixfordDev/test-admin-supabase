-- DeenHub Trivia – Multiplayer Enhancements
-- Safe to run multiple times (IF NOT EXISTS / conditional DDL)

-- 1) Extend rooms with game progress metadata
do $$ begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='trivia_rooms' and column_name='current_question_index'
  ) then
    alter table public.trivia_rooms add column current_question_index int not null default 0;
  end if;
  if not exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='trivia_rooms' and column_name='current_turn_index'
  ) then
    alter table public.trivia_rooms add column current_turn_index int not null default 0;
  end if;
  if not exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='trivia_rooms' and column_name='winner_user_id'
  ) then
    alter table public.trivia_rooms add column winner_user_id uuid references auth.users(id);
  end if;
  if not exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='trivia_rooms' and column_name='ended_at'
  ) then
    alter table public.trivia_rooms add column ended_at timestamptz;
  end if;
end $$;

-- 2) Room questions (ordered set of questions for a room)
create table if not exists public.trivia_room_questions (
  room_id text not null references public.trivia_rooms(id) on delete cascade,
  order_index int not null,
  question_id bigint not null references public.trivia_questions(id),
  primary key (room_id, order_index),
  unique (room_id, question_id)
);

alter table public.trivia_room_questions enable row level security;
do $$ begin
  if not exists (
    select 1 from pg_policies where polname = 'trivia_room_questions_select_all'
  ) then
    create policy trivia_room_questions_select_all on public.trivia_room_questions
      for select using (true);
  end if;
  if not exists (
    select 1 from pg_policies where polname = 'trivia_room_questions_upsert_auth'
  ) then
    create policy trivia_room_questions_upsert_auth on public.trivia_room_questions
      for insert with check (
        auth.role() = 'authenticated' AND
        auth.uid() IN (
          SELECT host_user_id FROM public.trivia_rooms WHERE id = room_id
        )
      );
  end if;
end $$;

-- 3) Hint usage (for penalties)
create table if not exists public.trivia_hint_usage (
  room_id text not null references public.trivia_rooms(id) on delete cascade,
  user_id uuid not null references auth.users(id),
  question_id bigint not null references public.trivia_questions(id),
  penalty_points int not null default 0,
  used_at timestamptz not null default now(),
  primary key (room_id, user_id, question_id)
);

alter table public.trivia_hint_usage enable row level security;
do $$ begin
  if not exists (
    select 1 from pg_policies where polname = 'trivia_hint_usage_select_all'
  ) then
    create policy trivia_hint_usage_select_all on public.trivia_hint_usage
      for select using (true);
  end if;
  if not exists (
    select 1 from pg_policies where polname = 'trivia_hint_usage_upsert_auth'
  ) then
    create policy trivia_hint_usage_upsert_auth on public.trivia_hint_usage
      for insert with check (
        auth.role() = 'authenticated' AND
        auth.uid() = user_id
      );
  end if;
end $$;

-- 4) Protect answers from duplicates per player/question/room
do $$ begin
  if not exists (
    select 1
    from pg_indexes
    where schemaname='public' and tablename='trivia_answers' and indexname='uq_trivia_answers_per_player_question_room'
  ) then
    create unique index uq_trivia_answers_per_player_question_room
      on public.trivia_answers(room_id, user_id, question_id);
  end if;
end $$;

-- 5) Realtime publications for better sync (optional)
do $$ begin
  -- rooms
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'trivia_rooms'
  ) then
    alter publication supabase_realtime add table public.trivia_rooms;
  end if;
  -- room_questions
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'trivia_room_questions'
  ) then
    alter publication supabase_realtime add table public.trivia_room_questions;
  end if;
end $$;





