create table if not exists public.signatures (
  id bigint generated always as identity primary key,
  display_name text not null check (char_length(display_name) between 1 and 40),
  created_at timestamptz not null default now()
);

alter table public.signatures enable row level security;

drop policy if exists "Anyone can add a signature" on public.signatures;
create policy "Anyone can add a signature"
on public.signatures
for insert
to anon
with check (
  char_length(trim(display_name)) between 1 and 40
);

create or replace function public.get_signature_count()
returns bigint
language sql
security definer
set search_path = ''
as $$
  select count(*) from public.signatures;
$$;

revoke all on function public.get_signature_count() from public;
grant execute on function public.get_signature_count() to anon, authenticated;
grant insert on public.signatures to anon, authenticated;
