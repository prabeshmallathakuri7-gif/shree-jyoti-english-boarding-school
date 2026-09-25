-- JEBS Production Database Schema
-- Run this in Supabase SQL Editor.
-- Security model: Supabase Auth + Row Level Security (RLS).
-- NEVER expose the service_role key in frontend code.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'staff' check (role in ('admin','staff')),
  created_at timestamptz not null default now()
);

create table if not exists public.site_settings (
  id boolean primary key default true,
  school_name text not null default 'Jyoti English Boarding School',
  logo_url text,
  address text default 'Krishnapur-5, Kanchanpur, Nepal',
  phone text,
  landline text,
  email text,
  tagline text,
  facebook text,
  youtube text,
  instagram text,
  tiktok text,
  twitter text,
  messenger text,
  admission_phone text,
  map_embed_url text,
  updated_at timestamptz not null default now()
);

create table if not exists public.hero_slides (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subtitle text,
  description text,
  image_url text,
  sort_order integer not null default 0,
  published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.facilities (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  short_description text,
  details text,
  image_url text,
  sort_order integer not null default 0,
  published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.teachers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  position text,
  subject text,
  phone text,
  email text,
  bio text,
  image_url text,
  sort_order integer not null default 0,
  published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  class_name text,
  address text,
  parent_name text,
  parent_phone text,
  image_path text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.gallery (
  id uuid primary key default gen_random_uuid(),
  title text,
  image_url text not null,
  sort_order integer not null default 0,
  published boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.achievements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  date_text text,
  body text,
  image_url text,
  sort_order integer not null default 0,
  published boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.notices (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  date_text text,
  body text,
  published boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  event_date date,
  description text,
  published boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.admissions (
  id uuid primary key default gen_random_uuid(),
  student_name text not null,
  parent_name text not null,
  current_class text,
  applying_class text not null,
  phone text not null,
  email text,
  address text,
  message text,
  status text not null default 'new' check (status in ('new','contacted','reviewing','accepted','closed')),
  created_at timestamptz not null default now()
);

create table if not exists public.contact_messages (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text,
  phone text,
  message text not null,
  status text not null default 'new' check (status in ('new','read','replied','closed')),
  created_at timestamptz not null default now()
);

-- Prevent public writes to sensitive data. RLS is the primary security boundary.

create or replace function public.is_admin_or_staff()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role in ('admin','staff')
  );
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  );
$$;

-- Enable RLS on all application tables.

alter table public.profiles enable row level security;
alter table public.site_settings enable row level security;
alter table public.hero_slides enable row level security;
alter table public.facilities enable row level security;
alter table public.teachers enable row level security;
alter table public.students enable row level security;
alter table public.gallery enable row level security;
alter table public.achievements enable row level security;
alter table public.notices enable row level security;
alter table public.events enable row level security;
alter table public.admissions enable row level security;
alter table public.contact_messages enable row level security;

-- Public read policies only for content intentionally published.

drop policy if exists "public read settings" on public.site_settings;
create policy "public read settings" on public.site_settings for select using (true);

drop policy if exists "public read hero" on public.hero_slides;
create policy "public read hero" on public.hero_slides for select using (published = true);

drop policy if exists "public read facilities" on public.facilities;
create policy "public read facilities" on public.facilities for select using (published = true);

drop policy if exists "public read teachers" on public.teachers;
create policy "public read teachers" on public.teachers for select using (published = true);

drop policy if exists "public read gallery" on public.gallery;
create policy "public read gallery" on public.gallery for select using (published = true);

drop policy if exists "public read achievements" on public.achievements;
create policy "public read achievements" on public.achievements for select using (published = true);

drop policy if exists "public read notices" on public.notices;
create policy "public read notices" on public.notices for select using (published = true);

drop policy if exists "public read events" on public.events;
create policy "public read events" on public.events for select using (published = true);

-- Staff/admin full management for non-sensitive content.

do $$
declare t text;
begin
  foreach t in array array['site_settings','hero_slides','facilities','teachers','gallery','achievements','notices','events'] loop
    execute format('drop policy if exists "staff manage %s" on public.%I', t, t);
    execute format('create policy "staff manage %s" on public.%I for all to authenticated using (public.is_admin_or_staff()) with check (public.is_admin_or_staff())', t, t);
  end loop;
end $$;

-- Students, admissions and messages are private to staff/admin.

drop policy if exists "staff manage students" on public.students;
create policy "staff manage students" on public.students for all to authenticated using (public.is_admin_or_staff()) with check (public.is_admin_or_staff());

drop policy if exists "staff read admissions" on public.admissions;
create policy "staff read admissions" on public.admissions for select to authenticated using (public.is_admin_or_staff());
drop policy if exists "staff update admissions" on public.admissions;
create policy "staff update admissions" on public.admissions for update to authenticated using (public.is_admin_or_staff()) with check (public.is_admin_or_staff());
drop policy if exists "admin delete admissions" on public.admissions;
create policy "admin delete admissions" on public.admissions for delete to authenticated using (public.is_admin());

-- Visitors can submit an admission enquiry but cannot read it back.
drop policy if exists "public submit admission" on public.admissions;
create policy "public submit admission" on public.admissions for insert to anon, authenticated with check (true);

drop policy if exists "staff read messages" on public.contact_messages;
create policy "staff read messages" on public.contact_messages for select to authenticated using (public.is_admin_or_staff());
drop policy if exists "staff update messages" on public.contact_messages;
create policy "staff update messages" on public.contact_messages for update to authenticated using (public.is_admin_or_staff()) with check (public.is_admin_or_staff());
drop policy if exists "admin delete messages" on public.contact_messages;
create policy "admin delete messages" on public.contact_messages for delete to authenticated using (public.is_admin());

drop policy if exists "public submit message" on public.contact_messages;
create policy "public submit message" on public.contact_messages for insert to anon, authenticated with check (true);

-- Profiles: user can read own profile; admin can manage staff roles.
drop policy if exists "user reads own profile" on public.profiles;
create policy "user reads own profile" on public.profiles for select to authenticated using (id = auth.uid() or public.is_admin());
drop policy if exists "admin manages profiles" on public.profiles;
create policy "admin manages profiles" on public.profiles for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Storage buckets. Public media is only for intentionally public content.
insert into storage.buckets (id, name, public) values ('school-public', 'school-public', true) on conflict (id) do update set public = true;
insert into storage.buckets (id, name, public) values ('student-private', 'student-private', false) on conflict (id) do update set public = false;

-- Public bucket: anyone may read. Only staff/admin may upload/update/delete.
drop policy if exists "public read school media" on storage.objects;
create policy "public read school media" on storage.objects for select using (bucket_id = 'school-public');
drop policy if exists "staff upload school media" on storage.objects;
create policy "staff upload school media" on storage.objects for insert to authenticated with check (bucket_id = 'school-public' and public.is_admin_or_staff());
drop policy if exists "staff update school media" on storage.objects;
create policy "staff update school media" on storage.objects for update to authenticated using (bucket_id = 'school-public' and public.is_admin_or_staff()) with check (bucket_id = 'school-public' and public.is_admin_or_staff());
drop policy if exists "staff delete school media" on storage.objects;
create policy "staff delete school media" on storage.objects for delete to authenticated using (bucket_id = 'school-public' and public.is_admin_or_staff());

-- Private student bucket: only staff/admin may access.
drop policy if exists "staff read student media" on storage.objects;
create policy "staff read student media" on storage.objects for select to authenticated using (bucket_id = 'student-private' and public.is_admin_or_staff());
drop policy if exists "staff upload student media" on storage.objects;
create policy "staff upload student media" on storage.objects for insert to authenticated with check (bucket_id = 'student-private' and public.is_admin_or_staff());
drop policy if exists "staff update student media" on storage.objects;
create policy "staff update student media" on storage.objects for update to authenticated using (bucket_id = 'student-private' and public.is_admin_or_staff()) with check (bucket_id = 'student-private' and public.is_admin_or_staff());
drop policy if exists "staff delete student media" on storage.objects;
create policy "staff delete student media" on storage.objects for delete to authenticated using (bucket_id = 'student-private' and public.is_admin_or_staff());

-- Seed site settings and sample content. Replace text/images from Admin.
insert into public.site_settings (id, school_name, address, phone, landline, email, tagline)
values (true, 'Jyoti English Boarding School', 'Krishnapur-5, Kanchanpur, Nepal', '9848400893', '099-412049', 'jyotiboardingschool@gmail.com', 'Nurturing Minds. Building Character. Creating Leaders.')
on conflict (id) do nothing;

insert into public.hero_slides (title, subtitle, description, image_url, sort_order)
select 'JYOTI ENGLISH', 'BOARDING SCHOOL', 'Nurturing minds. Building character. Creating leaders.', null, 1
where not exists (select 1 from public.hero_slides);

insert into public.facilities (title, short_description, details, sort_order)
select * from (values
('Quality Education','Student-centered learning with experienced teachers.','A structured, caring learning environment with clear academic goals and regular assessment.',1),
('Science Laboratory','Practical science learning.','Hands-on experiments, safe laboratory practice and activity-based science education.',2),
('Computer Laboratory','Digital learning and practical technology.','Computer access, digital literacy, practical exercises and guided technology learning.',3),
('Library','Reading and research space.','A focused reading environment with textbooks, reference materials and age-appropriate books.',4),
('Sports & Playground','Fitness, teamwork and confidence.','Space for physical education, sports practice, team activities and school competitions.',5),
('Transportation','Organized student transport.','Route, schedule, vehicle and driver information can be managed from the Admin dashboard.',6)
) as v(title,short_description,details,sort_order)
where not exists (select 1 from public.facilities);
