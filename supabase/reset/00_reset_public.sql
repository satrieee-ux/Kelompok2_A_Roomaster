-- =====================================================================
-- RESET: hapus semua objek Roomaster lama agar migrasi 01-04 bisa dijalankan dari nol.
-- HANYA untuk database yang isinya masih data demo. Semua data di schema "public" HILANG.
-- Akun demo di Auth ikut dihapus (seed.sql membuatnya lagi).
-- =====================================================================

-- Akun demo (profil lama ikut hilang bersama schema public)
delete from auth.users where email in (
  '5026241065@student.its.ac.id', 'azura@tu.its.ac.id', 'musaddad@sarpras.its.ac.id', 'tamu@example.com'
);

-- Kebijakan storage buatan Roomaster (nama sama dengan di migrasi 03)
do $$
declare p record;
begin
  for p in select policyname from pg_policies where schemaname = 'storage' and tablename = 'objects'
             and policyname in ('profil baca', 'ruangan baca', 'profil tulis sendiri', 'ruangan tulis sarpras',
                                'privat tulis sendiri', 'privat hapus sendiri', 'privat baca sendiri atau staf',
                                'chat baca peserta', 'chat tulis peserta')
  loop
    execute format('drop policy %I on storage.objects', p.policyname);
  end loop;
end $$;

drop schema if exists public cascade;
create schema public;

grant usage on schema public to postgres, anon, authenticated, service_role;
grant all   on schema public to postgres, service_role;
alter default privileges in schema public grant all on tables    to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to postgres, anon, authenticated, service_role;
