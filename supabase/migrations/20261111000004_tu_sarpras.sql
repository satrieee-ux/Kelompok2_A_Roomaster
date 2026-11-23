-- =====================================================================
-- ROOMASTER - Tambahan alur TU & Sarpras (Fase 2 awal)
--   * TU memulai percakapan dengan peminjam
--   * Notifikasi Sarpras saat status laporan berubah (Urgent / Maintenance / Resolved)
--   * Notifikasi TU saat peminjam mengirim ulang revisi
--   * Pengingat TU: pengajuan pending yang tanggal pakainya <= 24 jam lagi
-- =====================================================================

-- TU membuka percakapan dengan peminjam (TU = id_staf, peminjam = id_pengguna)
create or replace function mulai_percakapan_peminjam(p_id_peminjam uuid, p_id_ruangan bigint default null)
returns bigint
language plpgsql security definer set search_path = public as $$
declare v_id bigint;
begin
  if not is_tu() then raise exception 'Hanya TU yang dapat memulai percakapan ini' using errcode = '42501'; end if;
  if not exists (select 1 from profiles where id = p_id_peminjam and peran = 'mahasiswa') then
    raise exception 'Peminjam tidak ditemukan' using errcode = 'P0002';
  end if;
  select id into v_id from percakapan where id_pengguna = p_id_peminjam and id_staf = auth.uid();
  if v_id is null then
    insert into percakapan (id_pengguna, id_staf, id_ruangan) values (p_id_peminjam, auth.uid(), p_id_ruangan)
    returning id into v_id;
  end if;
  return v_id;
end;
$$;
grant execute on function mulai_percakapan_peminjam(uuid, bigint) to authenticated;

-- Notifikasi laporan: pelapor + seluruh Sarpras
create or replace function fn_laporan_notifikasi() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_ruang text;
  v_baru  boolean;
  v_teks  text;
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
    v_teks := case new.status
        when 'ditinjau' then 'under review'
        when 'diproses' then 'in progress'
        when 'menunggu_suku_cadang' then 'waiting for parts'
        when 'selesai' then 'resolved'
        when 'ditolak' then 'rejected'
        else new.status::text end;
    perform fn_notif(new.id_pelapor, 'Report Update',
      'Report ' || new.nomor_laporan || ' is now ' || v_teks || '.',
      'laporan', (case when new.status = 'ditolak' then 'rejected' else 'update' end)::tipe_notifikasi, null, new.id);
    -- jejak untuk seluruh Sarpras
    insert into notifikasi (id_pengguna, judul, isi, kategori, tipe, id_laporan)
    select p.id,
           case when new.status = 'selesai' then 'Resolved: ' || v_ruang else v_ruang || ' repair update' end,
           'Report ' || new.nomor_laporan || ' is now ' || v_teks || '.',
           'laporan',
           (case when new.status = 'selesai' then 'approved' else 'update' end)::tipe_notifikasi,
           new.id
    from profiles p where p.peran = 'sarpras' and p.aktif;
  end if;
  return new;
end;
$$;

-- TU: pengajuan ulang setelah revisi -> ubah notifikasi "request baru" menjadi "revisi dikirim"
create or replace function fn_tu_revisi_dikirim() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if old.status = 'revisi' and new.status = 'pending' then
    update notifikasi n
       set judul = 'Revision Submitted',
           isi   = 'The applicant uploaded the revision for #' || new.kode_peminjaman || '.',
           tipe  = 'update'
     where n.id_peminjaman = new.id and n.tipe = 'action'
       and n.waktu >= now() - interval '10 seconds'
       and n.id_pengguna in (select id from profiles where peran = 'tu');
  end if;
  return new;
end;
$$;
create trigger trg_z_tu_revisi_dikirim after update of status on peminjaman
  for each row execute function fn_tu_revisi_dikirim();

-- Pengingat TU (dipanggil juga oleh kirim_pengingat via jadwal yang sama)
create or replace function kirim_pengingat_tu() returns void
language plpgsql security definer set search_path = public as $$
declare r record;
begin
  for r in
    select p.id, p.kode_peminjaman, rm.nama_ruangan
    from peminjaman p join data_ruangan rm on rm.id = p.id_ruangan
    where p.status = 'pending'
      and (p.tanggal_pakai + p.waktu_mulai) <= sekarang_wib() + interval '24 hours'
      and (p.tanggal_pakai + p.waktu_mulai) >  sekarang_wib()
      and not exists (select 1 from notifikasi n where n.id_peminjaman = p.id and n.tipe = 'timelimit'
                      and n.id_pengguna in (select id from profiles where peran = 'tu'))
  loop
    insert into notifikasi (id_pengguna, judul, isi, kategori, tipe, id_peminjaman)
    select t.id, 'Review deadline approaching',
           '#' || r.kode_peminjaman || ' for ' || r.nama_ruangan || ' starts within 24 hours. Action required.',
           'peminjaman', 'timelimit', r.id
    from profiles t where t.peran = 'tu' and t.aktif;
  end loop;
end;
$$;
revoke execute on function kirim_pengingat_tu() from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Penjadwalan otomatis (pg_cron). Jika ekstensi tidak tersedia, migrasi tetap berhasil
-- dan hanya memberi NOTICE; aktifkan pg_cron di Dashboard > Database > Extensions lalu jalankan ulang blok ini.
-- ---------------------------------------------------------------------
do $$
begin
  create extension if not exists pg_cron;
  perform cron.schedule('roomaster-pengingat',    '*/5 * * * *', 'select public.kirim_pengingat()');
  perform cron.schedule('roomaster-pengingat-tu', '*/15 * * * *', 'select public.kirim_pengingat_tu()');
exception when others then
  raise notice 'pg_cron tidak aktif, pengingat belum terjadwal: %', sqlerrm;
end $$;
