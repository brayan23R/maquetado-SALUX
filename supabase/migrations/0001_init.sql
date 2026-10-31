-- SALUX · Esquema base (punto de partida). Valídalo con `supabase db reset` y corrige lo que haga falta.
-- Principios: RLS en todo, respuestas correctas solo por funciones, acceso decidido por el servidor.

create extension if not exists pgcrypto;

-- ============ Perfiles ============
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  role text not null default 'user' check (role in ('user','admin','editor','support','finance')),
  timezone text not null default 'America/Lima',
  daily_goal int not null default 20 check (daily_goal in (10,20,30)),
  trial_ends_at timestamptz not null default (now() + interval '3 days'),
  level int not null default 1,
  xp int not null default 0,
  avatar_url text,
  career text,
  target_exam text,
  exam_date date,
  created_at timestamptz not null default now()
);

create table public.streaks (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  current int not null default 0,
  best int not null default 0,
  freezes_available int not null default 1,
  last_goal_day date
);

create table public.app_settings (key text primary key, value jsonb not null);
insert into public.app_settings values ('free_daily_limit', '5'::jsonb), ('trial_days', '3'::jsonb);

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, name) values (new.id, coalesce(new.raw_user_meta_data->>'name', ''));
  insert into public.streaks (user_id) values (new.id);
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============ Catálogo ============
create table public.exams (
  id uuid primary key default gen_random_uuid(),
  key text unique not null,
  name text not null,
  description text,
  is_premium boolean not null default false,
  sort int not null default 0,
  published boolean not null default true
);
create table public.topics (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams(id) on delete cascade,
  name text not null,
  sort int not null default 0,
  lessons_count int not null default 0,
  unique (exam_id, name)
);
create table public.questions (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams(id) on delete cascade,
  topic_id uuid references public.topics(id) on delete set null,
  text text not null,
  explanation text,
  difficulty smallint not null default 2,
  status text not null default 'published' check (status in ('draft','published','archived')),
  sort int not null default 0,
  created_at timestamptz not null default now()
);
create table public.question_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions(id) on delete cascade,
  label char(1) not null,
  text text not null,
  sort int not null default 0
);
-- Respuesta correcta: tabla SIN políticas de lectura para usuarios.
create table public.question_answers (
  question_id uuid primary key references public.questions(id) on delete cascade,
  option_id uuid not null references public.question_options(id) on delete cascade
);
create table public.documents (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null default 'Guías',
  pages int not null default 1,
  size_mb numeric(6,1) not null default 0,
  storage_path text,
  is_premium boolean not null default true,
  published boolean not null default true
);

-- ============ Intentos y actividad ============
create table public.attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  exam_id uuid references public.exams(id),
  mode text not null check (mode in ('practice','sim','errors')),
  time_limit_sec int,
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  total int not null default 0,
  correct int not null default 0,
  score numeric(5,2)
);
create table public.attempt_answers (
  attempt_id uuid not null references public.attempts(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete cascade,
  option_id uuid references public.question_options(id),
  is_correct boolean,
  answered_at timestamptz,
  primary key (attempt_id, question_id)
);
create table public.daily_activity (
  user_id uuid not null references public.profiles(id) on delete cascade,
  day date not null,
  answered int not null default 0,
  goal_met boolean not null default false,
  primary key (user_id, day)
);
create table public.favorites (
  user_id uuid not null references public.profiles(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, question_id)
);
create table public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null default '',
  tag text,
  created_at timestamptz not null default now()
);
create table public.achievements (key text primary key, name text not null, description text, icon text);
create table public.user_achievements (
  user_id uuid not null references public.profiles(id) on delete cascade,
  achievement_key text not null references public.achievements(key),
  unlocked_at timestamptz not null default now(),
  primary key (user_id, achievement_key)
);

-- ============ Suscripciones y pagos ============
create table public.plans (
  id uuid primary key default gen_random_uuid(),
  key text unique not null,
  name text not null,
  price_cents int not null,
  currency text not null default 'PEN',
  duration_days int not null,
  is_active boolean not null default true
);
insert into public.plans (key, name, price_cents, duration_days) values
  ('mensual','Mensual',2900,30), ('trimestral','Trimestral',6900,90), ('anual','Anual',19900,365);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  plan_id uuid not null references public.plans(id),
  status text not null default 'active' check (status in ('active','expired','canceled')),
  starts_at timestamptz not null default now(),
  ends_at timestamptz not null,
  created_at timestamptz not null default now()
);
create table public.payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  plan_id uuid not null references public.plans(id),
  method text not null check (method in ('yape','plin','card')),
  amount_cents int not null,
  currency text not null default 'PEN',
  status text not null default 'pending' check (status in ('pending','paid','failed','refunded')),
  provider text not null default 'simulated',
  provider_ref text,
  provider_event_id text unique,
  created_at timestamptz not null default now(),
  paid_at timestamptz
);

-- ============ Seguridad, soporte y auditoría ============
create table public.backup_codes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  code_hash text not null,
  used_at timestamptz
);
create table public.devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  last_seen timestamptz not null default now()
);
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text,
  kind text not null default 'info',
  read boolean not null default false,
  created_at timestamptz not null default now()
);
create table public.reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete cascade,
  reason text not null,
  comment text,
  status text not null default 'open' check (status in ('open','reviewed','closed')),
  created_at timestamptz not null default now()
);
create table public.audit_log (
  id bigint generated always as identity primary key,
  actor_id uuid,
  action text not null,
  entity text,
  entity_id text,
  meta jsonb,
  created_at timestamptz not null default now()
);

-- ============ Funciones de ayuda ============
create or replace function public.is_staff() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role in ('admin','editor','support','finance'));
$$;

create or replace function public.has_access(p_uid uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.subscriptions s where s.user_id = p_uid and s.status = 'active' and s.ends_at > now())
      or exists (select 1 from public.profiles p where p.id = p_uid and now() < p.trial_ends_at);
$$;

create or replace function public.my_access() returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'has_access', public.has_access(auth.uid()),
    'trial_ends_at', (select trial_ends_at from public.profiles where id = auth.uid()),
    'subscription_ends_at', (select max(ends_at) from public.subscriptions where user_id = auth.uid() and status = 'active'),
    'is_premium', exists (select 1 from public.subscriptions where user_id = auth.uid() and status = 'active' and ends_at > now())
  );
$$;

-- Suma respuestas del día (zona horaria del usuario) y actualiza la racha.
create or replace function public.register_answers(p_count int) returns void
language plpgsql security definer set search_path = public as $$
declare
  v_uid uuid := auth.uid(); v_tz text; v_goal int; v_today date; v_answered int; v_last date; v_cur int; v_best int;
begin
  if v_uid is null or p_count <= 0 then return; end if;
  p_count := least(p_count, 50);
  select timezone, daily_goal into v_tz, v_goal from public.profiles where id = v_uid;
  v_today := (now() at time zone v_tz)::date;
  insert into public.daily_activity (user_id, day, answered) values (v_uid, v_today, p_count)
    on conflict (user_id, day) do update set answered = public.daily_activity.answered + excluded.answered
    returning answered into v_answered;
  if v_answered >= v_goal then
    update public.daily_activity set goal_met = true where user_id = v_uid and day = v_today and goal_met = false;
    if found then
      select last_goal_day, current, best into v_last, v_cur, v_best from public.streaks where user_id = v_uid;
      if v_last = v_today - 1 then v_cur := v_cur + 1; else v_cur := 1; end if;
      update public.streaks set current = v_cur, best = greatest(v_best, v_cur), last_goal_day = v_today where user_id = v_uid;
      update public.profiles set xp = xp + 50 where id = v_uid;
    end if;
  end if;
end $$;

-- Tarea diaria (pg_cron o Edge Function con service role): aplica congelador o reinicia la racha.
create or replace function public.streak_daily_job() returns void
language plpgsql security definer set search_path = public as $$
declare r record; v_today date;
begin
  for r in select s.user_id, s.last_goal_day, s.freezes_available, p.timezone from public.streaks s join public.profiles p on p.id = s.user_id where s.current > 0 loop
    v_today := (now() at time zone r.timezone)::date;
    if r.last_goal_day is not null and r.last_goal_day < v_today - 1 then
      if r.freezes_available > 0 and r.last_goal_day = v_today - 2 then
        update public.streaks set freezes_available = freezes_available - 1, last_goal_day = v_today - 1 where user_id = r.user_id;
      else
        update public.streaks set current = 0 where user_id = r.user_id;
      end if;
    end if;
  end loop;
end $$;

-- ============ Simulacros ============
create or replace function public.get_questions(p_exam_key text, p_n int, p_mode text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid(); v_exam uuid; v_attempt uuid; v_ids uuid[]; v_limit int;
begin
  if v_uid is null then raise exception 'no_auth'; end if;
  if p_mode not in ('practice','sim','errors') then raise exception 'bad_mode'; end if;
  if not public.has_access(v_uid) then
    select (value #>> '{}')::int into v_limit from public.app_settings where key = 'free_daily_limit';
    if coalesce((select answered from public.daily_activity where user_id = v_uid and day = (now() at time zone (select timezone from public.profiles where id = v_uid))::date), 0) >= v_limit then
      raise exception 'no_access';
    end if;
    p_n := least(p_n, v_limit);
  end if;
  select id into v_exam from public.exams where key = p_exam_key and published;
  if v_exam is null then raise exception 'exam_not_found'; end if;
  if p_mode = 'errors' then
    select array_agg(question_id) into v_ids from (
      select distinct aa.question_id from public.attempt_answers aa join public.attempts a on a.id = aa.attempt_id
      where a.user_id = v_uid and aa.is_correct = false limit p_n) t;
  else
    select array_agg(id) into v_ids from (
      select id from public.questions where exam_id = v_exam and status = 'published' order by random() limit p_n) t;
  end if;
  if v_ids is null then raise exception 'no_questions'; end if;
  insert into public.attempts (user_id, exam_id, mode, total) values (v_uid, v_exam, p_mode, array_length(v_ids,1)) returning id into v_attempt;
  insert into public.attempt_answers (attempt_id, question_id) select v_attempt, unnest(v_ids);
  return jsonb_build_object('attempt_id', v_attempt, 'questions', (
    select jsonb_agg(jsonb_build_object(
      'id', q.id, 'text', q.text, 'topic', coalesce(t.name,''),
      'options', (select jsonb_agg(jsonb_build_object('id', o.id, 'label', o.label, 'text', o.text) order by o.sort) from public.question_options o where o.question_id = q.id)))
    from public.questions q left join public.topics t on t.id = q.topic_id where q.id = any(v_ids)));
end $$;

create or replace function public.check_answer(p_attempt uuid, p_question uuid, p_option uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid(); v_correct uuid; v_ok boolean; v_first boolean;
begin
  if not exists (select 1 from public.attempts where id = p_attempt and user_id = v_uid and mode in ('practice','errors') and finished_at is null) then
    raise exception 'bad_attempt';
  end if;
  select option_id into v_correct from public.question_answers where question_id = p_question;
  v_ok := (v_correct = p_option);
  update public.attempt_answers set option_id = p_option, is_correct = v_ok, answered_at = now()
    where attempt_id = p_attempt and question_id = p_question and option_id is null;
  v_first := found;
  if v_first then perform public.register_answers(1); end if;
  return jsonb_build_object('is_correct', v_ok, 'correct_option_id', v_correct,
    'explanation', (select explanation from public.questions where id = p_question));
end $$;

-- p_answers: [{"question_id": "...", "option_id": "..."}]
create or replace function public.submit_attempt(p_attempt uuid, p_answers jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_uid uuid := auth.uid(); r jsonb; v_ok int; v_total int; v_new int := 0;
begin
  if not exists (select 1 from public.attempts where id = p_attempt and user_id = v_uid and finished_at is null) then
    raise exception 'bad_attempt';
  end if;
  for r in select * from jsonb_array_elements(p_answers) loop
    update public.attempt_answers aa set option_id = (r->>'option_id')::uuid,
      is_correct = ((r->>'option_id')::uuid = (select option_id from public.question_answers where question_id = aa.question_id)),
      answered_at = now()
    where aa.attempt_id = p_attempt and aa.question_id = (r->>'question_id')::uuid and aa.option_id is null;
    if found then v_new := v_new + 1; end if;
  end loop;
  select count(*) filter (where is_correct), count(*) into v_ok, v_total from public.attempt_answers where attempt_id = p_attempt;
  update public.attempts set finished_at = now(), correct = v_ok, total = v_total, score = round(v_ok::numeric * 100 / nullif(v_total,0), 2) where id = p_attempt;
  perform public.register_answers(v_new);
  return jsonb_build_object('correct', v_ok, 'total', v_total, 'score', round(v_ok::numeric * 100 / nullif(v_total,0), 2),
    'by_topic', (select coalesce(jsonb_agg(jsonb_build_object('topic', topic, 'correct', c, 'total', n)), '[]'::jsonb) from (
        select coalesce(t.name,'General') topic, count(*) filter (where aa.is_correct) c, count(*) n
        from public.attempt_answers aa join public.questions q on q.id = aa.question_id left join public.topics t on t.id = q.topic_id
        where aa.attempt_id = p_attempt group by 1) x),
    'review', (select jsonb_agg(jsonb_build_object('question_id', q.id, 'text', q.text, 'chosen_option_id', aa.option_id,
        'correct_option_id', qa.option_id, 'is_correct', aa.is_correct, 'explanation', q.explanation))
        from public.attempt_answers aa join public.questions q on q.id = aa.question_id join public.question_answers qa on qa.question_id = q.id
        where aa.attempt_id = p_attempt));
end $$;

-- ============ Métricas del panel admin ============
create or replace function public.admin_kpis() returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  if not public.is_staff() then raise exception 'forbidden'; end if;
  return jsonb_build_object(
    'total_users', (select count(*) from public.profiles where role = 'user'),
    'active_today', (select count(distinct user_id) from public.daily_activity where day = current_date and answered > 0),
    'active_7d', (select count(distinct user_id) from public.daily_activity where day >= current_date - 6 and answered > 0),
    'active_30d', (select count(distinct user_id) from public.daily_activity where day >= current_date - 29 and answered > 0),
    'new_7d', (select count(*) from public.profiles where created_at >= now() - interval '7 days'),
    'in_trial', (select count(*) from public.profiles where now() < trial_ends_at),
    'premium', (select count(distinct user_id) from public.subscriptions where status = 'active' and ends_at > now()),
    'revenue_30d_cents', (select coalesce(sum(amount_cents),0) from public.payments where status = 'paid' and paid_at >= now() - interval '30 days'),
    'attempts_30d', (select count(*) from public.attempts where started_at >= now() - interval '30 days'),
    'avg_streak', (select coalesce(round(avg(current),1),0) from public.streaks where current > 0));
end $$;

create or replace function public.admin_top_failed_questions(p_limit int default 10) returns table (question_id uuid, text text, fails bigint, total bigint)
language plpgsql stable security definer set search_path = public as $$
begin
  if not public.is_staff() then raise exception 'forbidden'; end if;
  return query select q.id, q.text, count(*) filter (where aa.is_correct = false), count(*)
    from public.attempt_answers aa join public.questions q on q.id = aa.question_id
    where aa.answered_at is not null group by q.id, q.text order by 3 desc limit p_limit;
end $$;

-- ============ RLS ============
do $$ declare t text; begin
  for t in select unnest(array['profiles','streaks','app_settings','exams','topics','questions','question_options','question_answers','documents',
    'attempts','attempt_answers','daily_activity','favorites','notes','achievements','user_achievements','plans','subscriptions','payments',
    'backup_codes','devices','notifications','reports','audit_log']) loop
    execute format('alter table public.%I enable row level security', t);
  end loop;
end $$;

-- Perfil propio (sin poder cambiar rol ni fechas de prueba)
create policy profiles_select_own on public.profiles for select using (id = auth.uid() or public.is_staff());
create policy profiles_update_own on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());
revoke update on public.profiles from authenticated;
grant update (name, timezone, daily_goal, avatar_url, career, target_exam, exam_date) on public.profiles to authenticated;
create policy profiles_staff_update on public.profiles for update using (public.is_staff());

create policy streaks_own on public.streaks for select using (user_id = auth.uid() or public.is_staff());
create policy settings_read on public.app_settings for select to authenticated using (true);
create policy exams_read on public.exams for select to authenticated using (published or public.is_staff());
create policy topics_read on public.topics for select to authenticated using (true);
create policy plans_read on public.plans for select to authenticated using (is_active or public.is_staff());
create policy documents_read on public.documents for select to authenticated using ((published and public.has_access(auth.uid())) or public.is_staff());
create policy achievements_read on public.achievements for select to authenticated using (true);
create policy user_ach_own on public.user_achievements for select using (user_id = auth.uid());

-- Preguntas: solo staff directo; los usuarios las reciben por get_questions()
create policy questions_staff on public.questions for all using (public.is_staff()) with check (public.is_staff());
create policy options_staff on public.question_options for all using (public.is_staff()) with check (public.is_staff());
create policy answers_staff on public.question_answers for all using (public.is_staff()) with check (public.is_staff());

create policy attempts_own on public.attempts for select using (user_id = auth.uid() or public.is_staff());
create policy attempt_answers_staff on public.attempt_answers for select using (public.is_staff());
create policy activity_own on public.daily_activity for select using (user_id = auth.uid() or public.is_staff());
create policy favorites_own on public.favorites for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy notes_own on public.notes for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy subs_own on public.subscriptions for select using (user_id = auth.uid() or public.is_staff());
create policy payments_own on public.payments for select using (user_id = auth.uid() or public.is_staff());
create policy devices_own on public.devices for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy notifs_own on public.notifications for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy reports_own_insert on public.reports for insert with check (user_id = auth.uid());
create policy reports_read on public.reports for select using (user_id = auth.uid() or public.is_staff());
create policy reports_staff_update on public.reports for update using (public.is_staff());
create policy audit_staff on public.audit_log for select using (public.is_staff());
-- backup_codes: sin políticas (solo Edge Function con service role)

-- Realtime para desbloqueo automático tras el pago
alter publication supabase_realtime add table public.subscriptions;

-- Permisos de ejecución de las funciones públicas
revoke all on function public.register_answers(int) from public, anon;
revoke all on function public.streak_daily_job() from public, anon, authenticated;
grant execute on function public.my_access(), public.get_questions(text,int,text), public.check_answer(uuid,uuid,uuid),
  public.submit_attempt(uuid,jsonb), public.admin_kpis(), public.admin_top_failed_questions(int) to authenticated;
