-- =====================================================================
-- ROOMASTER - Fungsi bantu, trigger, view, dan RPC
-- =====================================================================

-- ---------------------------------------------------------------------
-- Fungsi bantu peran (dipakai RLS). SECURITY DEFINER agar tidak rekursif.
-- ---------------------------------------------------------------------
create or replace function peran_saya() returns peran_pengguna
language sql stable security definer set search_path = public as $$
  select peran from profiles where id = auth.uid();
$$;

create or replace function is_staf() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select peran in ('tu', 'sarpras') from profiles where id = auth.uid()), false);
$$;

create or replace function is_tu() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select peran = 'tu' from profiles where id = auth.uid()), false);
$$;

create or replace function is_sarpras() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select peran = 'sarpras' from profiles where id = auth.uid()), false);
$$;

-- Jam sekarang di zona waktu kampus
create or replace function sekarang_wib() returns timestamp
language sql stable as $$ select (now() at time zone 'Asia/Jakarta'); $$;

-- ---------------------------------------------------------------------
-- Profil otomatis saat akun Auth dibuat.
-- PERAN tidak boleh datang dari klien (raw_user_meta_data bisa diisi siapa saja).
--   * raw_app_meta_data->>'peran' hanya bisa diisi service role / dashboard.
--   * email @student.its.ac.id  -> mahasiswa (aktifkan "Confirm email" di Auth!)
--   * selain itu                -> pendaftaran ditolak
-- ---------------------------------------------------------------------
create or replace function fn_buat_profil() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_peran peran_pengguna;
  v_nama  text;
  v_lokal text;
begin
  v_lokal := split_part(new.email, '@', 1);

  if new.raw_app_meta_data ? 'peran'
     and (new.raw_app_meta_data ->> 'peran') in ('mahasiswa', 'tu', 'sarpras') then
    v_peran := (new.raw_app_meta_data ->> 'peran')::peran_pengguna;
  elsif lower(new.email) like '%@student.its.ac.id' then
    v_peran := 'mahasiswa';
  else
    raise exception 'Pendaftaran hanya untuk mahasiswa ITS (email @student.its.ac.id)';
  end if;

  v_nama := coalesce(nullif(trim(new.raw_user_meta_data ->> 'nama'), ''), initcap(replace(v_lokal, '.', ' ')));

  insert into profiles (id, peran, nama, email, nrp, nip, tanggal_lahir, no_telepon)
  values (
    new.id, v_peran, v_nama, new.email,
    case when v_peran = 'mahasiswa' and v_lokal ~ '^[0-9]+$' then v_lokal end,
    case when v_peran in ('tu', 'sarpras') then nullif(new.raw_app_meta_data ->> 'nip', '') end,
    nullif(new.raw_user_meta_data ->> 'tanggal_lahir', '')::date,
    nullif(new.raw_user_meta_data ->> 'no_telepon', '')
  );
  return new;
end;
$$;

create trigger trg_buat_profil after insert on auth.users
  for each row execute function fn_buat_profil();

-- ---------------------------------------------------------------------
-- Util notifikasi
-- ---------------------------------------------------------------------
create or replace function fn_notif(
  p_pengguna uuid, p_judul text, p_isi text, p_kategori kategori_notifikasi,
  p_tipe tipe_notifikasi, p_peminjaman bigint default null, p_laporan bigint default null
) returns void language sql security definer set search_path = public as $$
  insert into notifikasi (id_pengguna, judul, isi, kategori, tipe, id_peminjaman, id_laporan)
  values (p_pengguna, left(p_judul, 100), left(p_isi, 255), p_kategori, p_tipe, p_peminjaman, p_laporan);
$$;

-- ---------------------------------------------------------------------
-- Peminjaman: kode, riwayat, notifikasi
-- ---------------------------------------------------------------------
create or replace function fn_peminjaman_kode() returns trigger
language plpgsql as $$
begin
  if new.kode_peminjaman is null or new.kode_peminjaman = '' then
    new.kode_peminjaman := 'R' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6));
  end if;
  return new;
end;
$$;

create trigger trg_peminjaman_kode before insert on peminjaman
  for each row execute function fn_peminjaman_kode();

create or replace function fn_peminjaman_riwayat() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_ruang text;
  v_ket   text;
begin
  if tg_op = 'INSERT' then
    insert into riwayat_peminjaman (id_peminjaman, tahapan, id_pelaku)
    values (new.id, new.status, new.id_peminjam);
    return new;
  end if;

  if new.status is distinct from old.status then
    select nama_ruangan into v_ruang from data_ruangan where id = new.id_ruangan;
    v_ket := case when new.status in ('revisi', 'ditolak') then left(new.catatan_tu, 255) end;

    insert into riwayat_peminjaman (id_peminjaman, tahapan, id_pelaku, keterangan)
    values (new.id, new.status, coalesce(auth.uid(), new.id_peminjam), v_ket);

    case new.status
      when 'pending' then
        perform fn_notif(new.id_peminjam, 'Request Submitted',
          'Your booking for ' || v_ruang || ' is pending review by TU.',
          'peminjaman', 'update', new.id);
        -- beri tahu semua TU
        insert into notifikasi (id_pengguna, judul, isi, kategori, tipe, id_peminjaman)
        select p.id, 'New Booking Request',
               'New request #' || new.kode_peminjaman || ' for ' || v_ruang || ' awaits your review.',
               'peminjaman', 'action', new.id
        from profiles p where p.peran = 'tu' and p.aktif;
      when 'revisi' then
        perform fn_notif(new.id_peminjam, 'Action Required',
          'Please upload your document revision for Request #' || new.kode_peminjaman || '. ' || coalesce(new.catatan_tu, ''),
          'peminjaman', 'action', new.id);
      when 'disetujui' then
        perform fn_notif(new.id_peminjam, 'Status Update',
          'Your booking for ' || v_ruang || ' has been Approved. You can check in 30 minutes before the booking time.',
          'peminjaman', 'approved', new.id);
      when 'ditolak' then
        perform fn_notif(new.id_peminjam, 'Status Update',
          'Your booking for ' || v_ruang || ' was Rejected. ' || coalesce(new.catatan_tu, ''),
          'peminjaman', 'rejected', new.id);
      when 'berlangsung' then
        perform fn_notif(new.id_peminjam, 'Status Update',
          'Check-in for ' || v_ruang || ' completed. Enjoy your session!',
          'peminjaman', 'update', new.id);
      when 'selesai' then
        perform fn_notif(new.id_peminjam, 'Status Update',
          'Your booking for ' || v_ruang || ' is completed. Thanks for using Roomaster!',
          'peminjaman', 'update', new.id);
      when 'dibatalkan' then
        perform fn_notif(new.id_peminjam, 'Status Update',
          'Your booking for ' || v_ruang || ' has been cancelled.',
          'peminjaman', 'update', new.id);
      else null;
    end case;
  end if;
  return new;
end;
$$;

create trigger trg_peminjaman_riwayat after insert or update of status on peminjaman
  for each row execute function fn_peminjaman_riwayat();

-- ---------------------------------------------------------------------
-- Laporan: nomor, penautan sesi aktif, notifikasi, sinkron update Sarpras
-- ---------------------------------------------------------------------
create or replace function fn_laporan_nomor() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.nomor_laporan is null or new.nomor_laporan = '' then
    new.nomor_laporan := 'LPR-' || to_char(now() at time zone 'Asia/Jakarta', 'YYYY') || '-' ||
                         lpad(nextval('seq_nomor_laporan')::text, 4, '0');
  end if;
  if new.id_peminjaman is null then
    select p.id into new.id_peminjaman
    from peminjaman p
    where p.id_peminjam = new.id_pelapor and p.id_ruangan = new.id_ruangan and p.status = 'berlangsung'
    order by p.id desc limit 1;
  end if;
  return new;
end;
$$;

create trigger trg_laporan_nomor before insert on laporan_kerusakan
  for each row execute function fn_laporan_nomor();

create or replace function fn_laporan_notifikasi() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_ruang text;
  v_baru  boolean;
begin
  select nama_ruangan into v_ruang from data_ruangan where id = new.id_ruangan;
  v_baru := new.status = 'pending' and (tg_op = 'INSERT' or old.status = 'draft');

  if v_baru then
    perform fn_notif(new.id_pelapor, 'Report Submitted',
      'Your report ' || new.nomor_laporan || ' for ' || v_ruang || ' was received.',
      'laporan', 'update', null, new.id);
    insert into notifikasi (id_pengguna, judul, isi, kategori, tipe, id_laporan)
    select p.id, 'New Damage Report',
           'Report ' || new.nomor_laporan || ' from ' || v_ruang || ' needs review.',
           'laporan', 'action', new.id
    from profiles p where p.peran = 'sarpras' and p.aktif;
  elsif tg_op = 'UPDATE' and new.status is distinct from old.status and new.status <> 'draft' then
    perform fn_notif(new.id_pelapor, 'Report Update',
      'Report ' || new.nomor_laporan || ' is now ' ||
      case new.status
        when 'ditinjau' then 'under review'
        when 'diproses' then 'in progress'
        when 'menunggu_suku_cadang' then 'waiting for parts'
        when 'selesai' then 'resolved'
        when 'ditolak' then 'rejected'
        else new.status::text end || '.',
      'laporan', (case when new.status = 'ditolak' then 'rejected' else 'update' end)::tipe_notifikasi, null, new.id);
  end if;
  return new;
end;
$$;

create trigger trg_laporan_notifikasi after insert or update of status on laporan_kerusakan
  for each row execute function fn_laporan_notifikasi();

-- ---------------------------------------------------------------------
-- VIEW (dibaca klien Flutter)
-- ---------------------------------------------------------------------

-- Ruangan + rating + fasilitas + status "sekarang". Berjalan sebagai pemilik view
-- (agregat dari peminjaman/ulasan tanpa membuka data pribadi).
create or replace view v_ruangan as
select
  r.id, r.kode_ruangan, r.nama_ruangan, r.kategori, r.kelompok, r.tipe_ruangan,
  r.kategori_penggunaan, r.departemen, r.kapasitas, r.lokasi, r.alamat, r.deskripsi,
  r.foto_ruangan, r.status, r.id_pengelola,
  coalesce(rt.rata, 0)::numeric(3, 1)  as rating_rata,
  coalesce(rt.jml, 0)::int             as jumlah_ulasan,
  coalesce(pm.jml, 0)::int             as jumlah_peminjaman,
  coalesce(f.daftar, '[]'::jsonb)      as fasilitas,
  (r.status = 'available' and not exists (
     select 1 from peminjaman p
     where p.id_ruangan = r.id
       and p.status in ('pending', 'revisi', 'disetujui', 'berlangsung')
       and p.tanggal_pakai = sekarang_wib()::date
       and sekarang_wib()::time >= p.waktu_mulai and sekarang_wib()::time < p.waktu_selesai
  ))                                    as tersedia_sekarang,
  pg.nama                               as nama_pengelola,
  pg.foto_profil                        as foto_pengelola,
  pg.rata_respons_menit                 as respons_pengelola_menit
from data_ruangan r
left join lateral (
  select avg(u.rating) as rata, count(*) as jml
  from ulasan_peminjaman u join peminjaman p on p.id = u.id_peminjaman
  where p.id_ruangan = r.id
) rt on true
left join lateral (
  select count(*) as jml from peminjaman p
  where p.id_ruangan = r.id and p.status in ('disetujui', 'berlangsung', 'selesai')
) pm on true
left join lateral (
  select jsonb_agg(jsonb_build_object('nama', fa.nama_fasilitas, 'ikon', fa.ikon) order by fa.id) as daftar
  from fasilitas_ruangan fr join fasilitas fa on fa.id = fr.id_fasilitas
  where fr.id_ruangan = r.id
) f on true
left join profiles pg on pg.id = r.id_pengelola;

-- Ulasan publik per ruangan (hanya nama + foto pengulas, tanpa data lain)
create or replace view v_ulasan_ruangan as
select u.id, p.id_ruangan, pr.nama, pr.foto_profil, u.rating, u.komentar, u.tanggal_ulasan
from ulasan_peminjaman u
join peminjaman p on p.id = u.id_peminjaman
join profiles pr on pr.id = p.id_peminjam;

-- Peminjaman + info ruangan + nama peminjam. SECURITY INVOKER: RLS peminjaman tetap berlaku.
create or replace view v_peminjaman with (security_invoker = true) as
select
  p.id, p.kode_peminjaman, p.id_peminjam, p.id_ruangan, p.nama_kegiatan, p.tujuan,
  p.departemen_penyelenggara, p.tanggal_pakai, p.waktu_mulai, p.waktu_selesai, p.status,
  p.tanggal_pengajuan, p.catatan_tu, p.waktu_checkin, p.waktu_checkout, p.dibuat_pada,
  r.kode_ruangan, r.nama_ruangan, r.foto_ruangan, r.departemen as departemen_ruangan,
  r.lokasi, r.alamat, r.kapasitas,
  u.nama as nama_peminjam, u.peran as peran_peminjam,
  exists (select 1 from ulasan_peminjaman ul where ul.id_peminjaman = p.id) as sudah_diulas
from peminjaman p
join data_ruangan r on r.id = p.id_ruangan
join profiles u on u.id = p.id_peminjam;

create or replace view v_laporan with (security_invoker = true) as
select
  l.id, l.nomor_laporan, l.id_ruangan, l.id_pelapor, l.id_peminjaman, l.kategori_kerusakan,
  l.deskripsi_masalah, l.tingkat_kerusakan, l.status, l.tanggal_lapor, l.id_penangan,
  r.nama_ruangan, r.kode_ruangan, r.lokasi, r.departemen as departemen_ruangan,
  u.nama as nama_pelapor
from laporan_kerusakan l
join data_ruangan r on r.id = l.id_ruangan
join profiles u on u.id = l.id_pelapor;

-- Daftar percakapan milik pengguna yang sedang login. Berjalan sebagai pemilik view,
-- jadi nama lawan bicara terbaca walau RLS profiles membatasi; difilter dengan auth.uid().
create or replace view v_percakapan as
select
  c.id, c.id_pengguna, c.id_staf, c.id_ruangan, c.dibuat_pada,
  case when auth.uid() = c.id_pengguna then s.nama else u.nama end              as nama_lawan,
  case when auth.uid() = c.id_pengguna then s.foto_profil else u.foto_profil end as foto_lawan,
  case when auth.uid() = c.id_pengguna then s.rata_respons_menit end            as respons_menit,
  lp.isi_pesan   as pesan_terakhir,
  lp.lampiran    as lampiran_terakhir,
  lp.waktu_kirim as waktu_pesan_terakhir,
  (select count(*) from pesan x
    where x.id_percakapan = c.id and x.id_pengirim <> auth.uid() and not x.sudah_dibaca)::int as belum_dibaca
from percakapan c
join profiles u on u.id = c.id_pengguna
join profiles s on s.id = c.id_staf
left join lateral (
  select isi_pesan, lampiran, waktu_kirim from pesan
  where id_percakapan = c.id order by waktu_kirim desc, id desc limit 1
) lp on true
where auth.uid() in (c.id_pengguna, c.id_staf);

grant select on v_ruangan, v_ulasan_ruangan, v_peminjaman, v_laporan, v_percakapan to authenticated;

-- ---------------------------------------------------------------------
-- RPC: ketersediaan
-- ---------------------------------------------------------------------

-- Jam (mulai jam) yang sudah terpakai pada suatu tanggal, mis. {9,10,13}
create or replace function jam_terpakai(p_id_ruangan bigint, p_tanggal date) returns int[]
language sql stable security definer set search_path = public as $$
  select coalesce(array_agg(distinct h order by h), '{}'::int[])
  from (
    select generate_series(
             extract(hour from waktu_mulai)::int,
             extract(hour from (waktu_selesai - interval '1 second'))::int
           ) as h
    from peminjaman
    where id_ruangan = p_id_ruangan
      and tanggal_pakai = p_tanggal
      and status in ('pending', 'revisi', 'disetujui', 'berlangsung')
  ) t;
$$;

-- ID ruangan yang masih punya jam kosong (08.00-20.00) pada tanggal tertentu
create or replace function ruangan_tersedia_pada(p_tanggal date) returns setof bigint
language sql stable security definer set search_path = public as $$
  select r.id from data_ruangan r
  where r.status = 'available'
    and coalesce((select count(*) from unnest(jam_terpakai(r.id, p_tanggal)) h where h between 8 and 19), 0) < 12;
$$;

-- ---------------------------------------------------------------------
-- RPC: siklus peminjaman (peminjam)
-- ---------------------------------------------------------------------

-- Kirim pengajuan: draft/revisi -> pending
create or replace function ajukan_peminjaman(p_id bigint) returns status_peminjaman
language plpgsql security definer set search_path = public as $$
declare b peminjaman%rowtype;
begin
  select * into b from peminjaman where id = p_id and id_peminjam = auth.uid() for update;
  if not found then raise exception 'Peminjaman tidak ditemukan' using errcode = 'P0002'; end if;
  if b.status not in ('draft', 'revisi') then
    raise exception 'Pengajuan tidak dapat dikirim pada status %', b.status using errcode = 'P0001';
  end if;
  if b.tanggal_pakai < sekarang_wib()::date then
    raise exception 'Tanggal peminjaman sudah lewat' using errcode = 'P0001';
  end if;
  if (select count(distinct jenis_dokumen) from dokumen_peminjaman
      where id_peminjaman = p_id and jenis_dokumen in ('ktm_ktp', 'surat_kegiatan')) < 2 then
    raise exception 'Dokumen KTM/KTP dan surat peminjaman wajib dilengkapi' using errcode = 'P0001';
  end if;
  begin
    update peminjaman set status = 'pending', tanggal_pengajuan = now(), catatan_tu = null where id = p_id;
  exception when exclusion_violation then
    raise exception 'Ruangan sudah dipesan pada jam tersebut' using errcode = 'P0001';
  end;
  update dokumen_peminjaman set status = 'draft' where id_peminjaman = p_id and status in ('revisi', 'ditolak');
  return 'pending';
end;
$$;

-- Batalkan: draft dihapus, status lain jadi dibatalkan
create or replace function batalkan_peminjaman(p_id bigint) returns void
language plpgsql security definer set search_path = public as $$
declare b peminjaman%rowtype;
begin
  select * into b from peminjaman where id = p_id and id_peminjam = auth.uid() for update;
  if not found then raise exception 'Peminjaman tidak ditemukan' using errcode = 'P0002'; end if;
  if b.status = 'draft' then
    delete from peminjaman where id = p_id;
  elsif b.status in ('pending', 'revisi', 'disetujui') then
    update peminjaman set status = 'dibatalkan' where id = p_id;
  else
    raise exception 'Peminjaman tidak dapat dibatalkan pada status %', b.status using errcode = 'P0001';
  end if;
end;
$$;

-- Check-in: disetujui -> berlangsung. Foto kondisi awal wajib (path di bucket "kondisi").
create or replace function check_in(p_id bigint, p_catatan text, p_foto text[]) returns void
language plpgsql security definer set search_path = public as $$
declare
  b   peminjaman%rowtype;
  v_p text;
  v_sekarang timestamp := sekarang_wib();
begin
  select * into b from peminjaman where id = p_id and id_peminjam = auth.uid() for update;
  if not found then raise exception 'Peminjaman tidak ditemukan' using errcode = 'P0002'; end if;
  if b.status <> 'disetujui' then
    raise exception 'Check-in hanya untuk peminjaman yang sudah disetujui' using errcode = 'P0001';
  end if;
  if b.tanggal_pakai <> v_sekarang::date then
    raise exception 'Check-in hanya dapat dilakukan pada hari peminjaman' using errcode = 'P0001';
  end if;
  if v_sekarang::time < (b.waktu_mulai - interval '30 minutes') or v_sekarang::time >= b.waktu_selesai then
    raise exception 'Check-in dibuka 30 menit sebelum jam peminjaman sampai jam selesai' using errcode = 'P0001';
  end if;
  if coalesce(cardinality(p_foto), 0) < 1 then
    raise exception 'Unggah minimal satu foto kondisi awal ruangan' using errcode = 'P0001';
  end if;

  foreach v_p in array p_foto loop
    insert into foto_kondisi (id_peminjaman, tahap, path_berkas) values (p_id, 'checkin', v_p);
  end loop;
  update peminjaman set status = 'berlangsung', waktu_checkin = now(), catatan_checkin = nullif(trim(p_catatan), '')
   where id = p_id;
end;
$$;

-- Check-out: berlangsung -> selesai
create or replace function check_out(p_id bigint, p_catatan text, p_checklist text[], p_foto text[]) returns void
language plpgsql security definer set search_path = public as $$
declare
  b   peminjaman%rowtype;
  v_p text;
begin
  select * into b from peminjaman where id = p_id and id_peminjam = auth.uid() for update;
  if not found then raise exception 'Peminjaman tidak ditemukan' using errcode = 'P0002'; end if;
  if b.status <> 'berlangsung' then
    raise exception 'Check-out hanya untuk peminjaman yang sedang berlangsung' using errcode = 'P0001';
  end if;
  if coalesce(cardinality(p_foto), 0) < 1 then
    raise exception 'Unggah minimal satu foto kondisi akhir ruangan' using errcode = 'P0001';
  end if;

  foreach v_p in array p_foto loop
    insert into foto_kondisi (id_peminjaman, tahap, path_berkas) values (p_id, 'checkout', v_p);
  end loop;
  update peminjaman
     set status = 'selesai', waktu_checkout = now(),
         catatan_checkout = nullif(trim(p_catatan), ''),
         checklist_checkout = coalesce(p_checklist, '{}')
   where id = p_id;
end;
$$;

-- ---------------------------------------------------------------------
-- RPC: TU meninjau peminjaman (UI TU dibuat pada Fase 2)
--   p_aksi: 'setujui' | 'revisi' | 'tolak'
-- ---------------------------------------------------------------------
create or replace function tinjau_peminjaman(p_id bigint, p_aksi text, p_catatan text default null)
returns status_peminjaman
language plpgsql security definer set search_path = public as $$
declare
  b        peminjaman%rowtype;
  v_target status_peminjaman;
begin
  if not is_tu() then raise exception 'Hanya TU yang dapat meninjau peminjaman' using errcode = '42501'; end if;
  select * into b from peminjaman where id = p_id for update;
  if not found then raise exception 'Peminjaman tidak ditemukan' using errcode = 'P0002'; end if;
  if b.status <> 'pending' then
    raise exception 'Peminjaman tidak berstatus pending' using errcode = 'P0001';
  end if;

  v_target := (case p_aksi when 'setujui' then 'disetujui' when 'revisi' then 'revisi' when 'tolak' then 'ditolak' end)::status_peminjaman;
  if v_target is null then raise exception 'Aksi tidak dikenal: %', p_aksi using errcode = 'P0001'; end if;
  if v_target in ('revisi', 'ditolak') and coalesce(trim(p_catatan), '') = '' then
    raise exception 'Catatan wajib diisi untuk revisi atau penolakan' using errcode = 'P0001';
  end if;

  update peminjaman
     set status = v_target, catatan_tu = nullif(trim(p_catatan), ''), id_peninjau = auth.uid()
   where id = p_id;
  update dokumen_peminjaman
     set status = case v_target when 'disetujui' then 'diterima'::status_dokumen when 'revisi' then 'revisi' else 'ditolak' end
   where id_peminjaman = p_id;
  return v_target;
end;
$$;

-- ---------------------------------------------------------------------
-- RPC: Sarpras memperbarui laporan (UI Sarpras dibuat pada Fase 2)
-- ---------------------------------------------------------------------
create or replace function perbarui_laporan(
  p_id bigint, p_status status_laporan, p_catatan text default null,
  p_tingkat tingkat_kerusakan default null
) returns bigint
language plpgsql security definer set search_path = public as $$
declare v_update bigint;
begin
  if not is_sarpras() then raise exception 'Hanya Sarpras yang dapat memperbarui laporan' using errcode = '42501'; end if;
  if p_status in ('draft', 'pending') then
    raise exception 'Status tidak valid untuk pembaruan' using errcode = 'P0001';
  end if;
  if not exists (select 1 from laporan_kerusakan where id = p_id and status <> 'draft') then
    raise exception 'Laporan tidak ditemukan' using errcode = 'P0002';
  end if;

  update laporan_kerusakan
     set status = p_status,
         tingkat_kerusakan = coalesce(p_tingkat, tingkat_kerusakan),
         id_penangan = auth.uid()
   where id = p_id;
  insert into laporan_update (id_laporan, id_staf, status_baru, catatan_teknisi)
  values (p_id, auth.uid(), p_status, nullif(trim(p_catatan), ''))
  returning id into v_update;

  -- Ruangan rusak berat otomatis ditutup; pulih saat laporan selesai
  if p_tingkat = 'berat' and p_status <> 'selesai' then
    update data_ruangan set status = 'not_available'
     where id = (select id_ruangan from laporan_kerusakan where id = p_id);
  elsif p_status = 'selesai' then
    update data_ruangan set status = 'available'
     where id = (select id_ruangan from laporan_kerusakan where id = p_id)
       and not exists (select 1 from laporan_kerusakan x
                       where x.id_ruangan = data_ruangan.id and x.id <> p_id
                         and x.tingkat_kerusakan = 'berat' and x.status not in ('selesai', 'ditolak', 'draft'));
  end if;
  return v_update;
end;
$$;

-- ---------------------------------------------------------------------
-- RPC: chat
-- ---------------------------------------------------------------------

-- Mahasiswa membuka (atau melanjutkan) percakapan dengan TU.
-- Tanpa p_id_staf: TU pengelola ruangan, lalu TU aktif pertama. Wajib ada minimal satu TU aktif.
create or replace function mulai_percakapan(p_id_staf uuid default null, p_id_ruangan bigint default null)
returns bigint
language plpgsql security definer set search_path = public as $$
declare
  v_tu uuid := p_id_staf;
  v_id bigint;
begin
  if auth.uid() is null then raise exception 'Belum login' using errcode = '42501'; end if;
  if not exists (select 1 from profiles where id = auth.uid() and peran = 'mahasiswa') then
    raise exception 'Hanya mahasiswa yang dapat memulai percakapan ini' using errcode = '42501';
  end if;
  if v_tu is null and p_id_ruangan is not null then
    select pg.id into v_tu from data_ruangan r join profiles pg on pg.id = r.id_pengelola
     where r.id = p_id_ruangan and pg.peran = 'tu' and pg.aktif;
  end if;
  if v_tu is null then
    select id into v_tu from profiles where peran = 'tu' and aktif order by dibuat_pada limit 1;
  end if;
  if v_tu is null then
    raise exception 'Belum ada TU yang tersedia' using errcode = 'P0001';
  end if;

  select id into v_id from percakapan where id_pengguna = auth.uid() and id_staf = v_tu;
  if v_id is null then
    insert into percakapan (id_pengguna, id_staf, id_ruangan) values (auth.uid(), v_tu, p_id_ruangan)
    returning id into v_id;
  end if;
  return v_id;
end;
$$;

-- Percakapan hanya boleh antara mahasiswa (id_pengguna) dan TU (id_staf)
create or replace function fn_percakapan_validasi() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from profiles where id = new.id_pengguna and peran = 'mahasiswa')
     or not exists (select 1 from profiles where id = new.id_staf and peran = 'tu') then
    raise exception 'Percakapan hanya antara mahasiswa dan TU' using errcode = 'P0001';
  end if;
  return new;
end;
$$;
create trigger trg_percakapan_validasi before insert on percakapan
  for each row execute function fn_percakapan_validasi();

create or replace function tandai_pesan_dibaca(p_id_percakapan bigint) returns void
language sql security definer set search_path = public as $$
  update pesan set sudah_dibaca = true
   where id_percakapan = p_id_percakapan and id_pengirim <> auth.uid() and not sudah_dibaca
     and exists (select 1 from percakapan c where c.id = p_id_percakapan and auth.uid() in (c.id_pengguna, c.id_staf));
$$;

create or replace function tandai_notifikasi_dibaca() returns void
language sql security definer set search_path = public as $$
  update notifikasi set sudah_dibaca = true where id_pengguna = auth.uid() and not sudah_dibaca;
$$;

-- ---------------------------------------------------------------------
-- Pengingat terjadwal (jalankan tiap 5 menit lewat pg_cron / Scheduled Edge Function)
--   * Draft peminjaman menggantung > 30 menit  -> "Unfinished booking"
--   * Peminjaman berlangsung berakhir <= 15 menit -> "time limit"
-- ---------------------------------------------------------------------
create or replace function kirim_pengingat() returns void
language plpgsql security definer set search_path = public as $$
declare
  r record;
  v_now timestamp := sekarang_wib();
begin
  for r in
    select p.id, p.id_peminjam, rm.nama_ruangan
    from peminjaman p join data_ruangan rm on rm.id = p.id_ruangan
    where p.status = 'draft' and p.dibuat_pada < now() - interval '30 minutes'
      and not exists (select 1 from notifikasi n where n.id_peminjaman = p.id and n.tipe = 'unfinished')
  loop
    perform fn_notif(r.id_peminjam, 'Unfinished booking',
      'Your booking progress for ' || r.nama_ruangan || ' has not been finished. Continue?',
      'peminjaman', 'unfinished', r.id);
  end loop;

  for r in
    select p.id, p.id_peminjam, rm.nama_ruangan
    from peminjaman p join data_ruangan rm on rm.id = p.id_ruangan
    where p.status = 'berlangsung' and p.tanggal_pakai = v_now::date
      and v_now::time >= (p.waktu_selesai - interval '15 minutes')
      and not exists (select 1 from notifikasi n where n.id_peminjaman = p.id and n.tipe = 'timelimit')
  loop
    perform fn_notif(r.id_peminjam, 'Status Update',
      'Your booking for ' || r.nama_ruangan || ' is about to reach its time limit.',
      'peminjaman', 'timelimit', r.id);
  end loop;
end;
$$;


grant execute on function
  jam_terpakai(bigint, date), ruangan_tersedia_pada(date),
  ajukan_peminjaman(bigint), batalkan_peminjaman(bigint), check_in(bigint, text, text[]),
  check_out(bigint, text, text[], text[]), tinjau_peminjaman(bigint, text, text),
  perbarui_laporan(bigint, status_laporan, text, tingkat_kerusakan),
  mulai_percakapan(uuid, bigint), tandai_pesan_dibaca(bigint), tandai_notifikasi_dibaca()
to authenticated;
revoke execute on function kirim_pengingat() from public, anon, authenticated;
