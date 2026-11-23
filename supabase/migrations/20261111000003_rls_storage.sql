-- =====================================================================
-- ROOMASTER - Row Level Security, Storage, Realtime
-- Prinsip: klien hanya boleh membaca/menulis data miliknya. Perubahan status penting
-- (ajukan, check-in/out, tinjau, perbarui laporan) lewat RPC SECURITY DEFINER.
-- =====================================================================

alter table profiles             enable row level security;
alter table data_ruangan         enable row level security;
alter table fasilitas            enable row level security;
alter table fasilitas_ruangan    enable row level security;
alter table galeri_ruangan       enable row level security;
alter table ruangan_favorit      enable row level security;
alter table peminjaman           enable row level security;
alter table dokumen_peminjaman   enable row level security;
alter table riwayat_peminjaman   enable row level security;
alter table ulasan_peminjaman    enable row level security;
alter table foto_kondisi         enable row level security;
alter table percakapan           enable row level security;
alter table pesan                enable row level security;
alter table notifikasi           enable row level security;
alter table laporan_kerusakan    enable row level security;
alter table laporan_update       enable row level security;
alter table laporan_media        enable row level security;

-- ---------------- profiles ----------------
create policy profiles_baca_sendiri on profiles for select to authenticated
  using (id = auth.uid() or is_staf());
create policy profiles_ubah_sendiri on profiles for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid() and peran = peran_saya());   -- peran tidak boleh diubah sendiri

-- ---------------- katalog ruangan (baca semua; tulis Sarpras) ----------------
create policy ruangan_baca on data_ruangan for select to authenticated using (true);
create policy ruangan_tulis on data_ruangan for all to authenticated
  using (is_sarpras()) with check (is_sarpras());

create policy fasilitas_baca on fasilitas for select to authenticated using (true);
create policy fasilitas_tulis on fasilitas for all to authenticated
  using (is_sarpras()) with check (is_sarpras());

create policy fasilitas_ruangan_baca on fasilitas_ruangan for select to authenticated using (true);
create policy fasilitas_ruangan_tulis on fasilitas_ruangan for all to authenticated
  using (is_sarpras()) with check (is_sarpras());

create policy galeri_baca on galeri_ruangan for select to authenticated using (true);
create policy galeri_tulis on galeri_ruangan for all to authenticated
  using (is_sarpras()) with check (is_sarpras());

-- ---------------- favorit ----------------
create policy favorit_sendiri on ruangan_favorit for all to authenticated
  using (id_pengguna = auth.uid()) with check (id_pengguna = auth.uid());

-- ---------------- peminjaman ----------------
create policy peminjaman_baca on peminjaman for select to authenticated
  using (id_peminjam = auth.uid() or is_staf());
create policy peminjaman_buat on peminjaman for insert to authenticated
  with check (id_peminjam = auth.uid() and status = 'draft');
create policy peminjaman_ubah_draft on peminjaman for update to authenticated
  using (id_peminjam = auth.uid() and status = 'draft')
  with check (id_peminjam = auth.uid() and status = 'draft');
create policy peminjaman_hapus_draft on peminjaman for delete to authenticated
  using (id_peminjam = auth.uid() and status = 'draft');

-- ---------------- dokumen ----------------
create policy dokumen_baca on dokumen_peminjaman for select to authenticated
  using (exists (select 1 from peminjaman p where p.id = id_peminjaman and (p.id_peminjam = auth.uid() or is_staf())));
create policy dokumen_tulis on dokumen_peminjaman for insert to authenticated
  with check (exists (select 1 from peminjaman p
                      where p.id = id_peminjaman and p.id_peminjam = auth.uid() and p.status in ('draft', 'revisi')));
create policy dokumen_hapus on dokumen_peminjaman for delete to authenticated
  using (exists (select 1 from peminjaman p
                 where p.id = id_peminjaman and p.id_peminjam = auth.uid() and p.status in ('draft', 'revisi')));

-- ---------------- riwayat ----------------
create policy riwayat_baca on riwayat_peminjaman for select to authenticated
  using (exists (select 1 from peminjaman p where p.id = id_peminjaman and (p.id_peminjam = auth.uid() or is_staf())));

-- ---------------- ulasan ----------------
create policy ulasan_baca_sendiri on ulasan_peminjaman for select to authenticated
  using (exists (select 1 from peminjaman p where p.id = id_peminjaman and (p.id_peminjam = auth.uid() or is_staf())));
create policy ulasan_tulis on ulasan_peminjaman for insert to authenticated
  with check (exists (select 1 from peminjaman p
                      where p.id = id_peminjaman and p.id_peminjam = auth.uid() and p.status = 'selesai'));

-- ---------------- foto kondisi ruangan (ditulis lewat RPC check_in/check_out) ----------------
create policy foto_kondisi_baca on foto_kondisi for select to authenticated
  using (exists (select 1 from peminjaman p where p.id = id_peminjaman and (p.id_peminjam = auth.uid() or is_staf())));

-- ---------------- chat ----------------
create policy percakapan_baca on percakapan for select to authenticated
  using (auth.uid() in (id_pengguna, id_staf));

create policy pesan_baca on pesan for select to authenticated
  using (exists (select 1 from percakapan c where c.id = id_percakapan and auth.uid() in (c.id_pengguna, c.id_staf)));
create policy pesan_kirim on pesan for insert to authenticated
  with check (id_pengirim = auth.uid()
              and exists (select 1 from percakapan c where c.id = id_percakapan and auth.uid() in (c.id_pengguna, c.id_staf)));

-- ---------------- notifikasi ----------------
create policy notifikasi_baca on notifikasi for select to authenticated using (id_pengguna = auth.uid());
create policy notifikasi_ubah on notifikasi for update to authenticated
  using (id_pengguna = auth.uid()) with check (id_pengguna = auth.uid());

-- ---------------- laporan ----------------
create policy laporan_baca on laporan_kerusakan for select to authenticated
  using (id_pelapor = auth.uid() or is_staf());
create policy laporan_buat on laporan_kerusakan for insert to authenticated
  with check (id_pelapor = auth.uid() and status in ('draft', 'pending'));
create policy laporan_ubah_draft on laporan_kerusakan for update to authenticated
  using (id_pelapor = auth.uid() and status = 'draft')
  with check (id_pelapor = auth.uid() and status in ('draft', 'pending'));
create policy laporan_hapus_draft on laporan_kerusakan for delete to authenticated
  using (id_pelapor = auth.uid() and status = 'draft');

create policy laporan_update_baca on laporan_update for select to authenticated
  using (exists (select 1 from laporan_kerusakan l where l.id = id_laporan and (l.id_pelapor = auth.uid() or is_staf())));

create policy laporan_media_baca on laporan_media for select to authenticated
  using (exists (select 1 from laporan_kerusakan l where l.id = id_laporan and (l.id_pelapor = auth.uid() or is_staf())));
create policy laporan_media_tulis on laporan_media for insert to authenticated
  with check (id_update is null
              and exists (select 1 from laporan_kerusakan l
                          where l.id = id_laporan and l.id_pelapor = auth.uid() and l.status in ('draft', 'pending')));
create policy laporan_media_hapus on laporan_media for delete to authenticated
  using (id_update is null
         and exists (select 1 from laporan_kerusakan l where l.id = id_laporan and l.id_pelapor = auth.uid() and l.status = 'draft'));

-- ---------------------------------------------------------------------
-- Hak kolom: klien hanya boleh menyentuh kolom yang memang miliknya.
-- Kolom status/biaya/catatan/check-in dll. hanya berubah lewat RPC & trigger.
-- ---------------------------------------------------------------------
revoke insert, update on peminjaman        from authenticated;
revoke insert, update on laporan_kerusakan from authenticated;
revoke update         on profiles          from authenticated;
revoke update         on notifikasi        from authenticated;

grant insert (id_peminjam, id_ruangan, nama_kegiatan, tujuan, departemen_penyelenggara,
              tanggal_pakai, waktu_mulai, waktu_selesai, status) on peminjaman to authenticated;
grant update (nama_kegiatan, tujuan, departemen_penyelenggara, tanggal_pakai, waktu_mulai, waktu_selesai)
  on peminjaman to authenticated;

grant insert (id_ruangan, id_pelapor, kategori_kerusakan, deskripsi_masalah, status) on laporan_kerusakan to authenticated;
grant update (kategori_kerusakan, deskripsi_masalah, status) on laporan_kerusakan to authenticated;

grant update (nama, no_telepon, tanggal_lahir, foto_profil) on profiles to authenticated;
grant update (sudah_dibaca) on notifikasi to authenticated;

-- ---------------------------------------------------------------------
-- STORAGE
-- Konvensi path: {id_pengguna}/... untuk unggahan milik pengguna.
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public) values
  ('profil',   'profil',   true),
  ('ruangan',  'ruangan',  true),
  ('dokumen',  'dokumen',  false),
  ('kondisi',  'kondisi',  false),
  ('laporan',  'laporan',  false),
  ('chat',     'chat',     false)
on conflict (id) do nothing;

-- bucket publik: semua boleh baca
create policy "profil baca"  on storage.objects for select using (bucket_id = 'profil');
create policy "ruangan baca" on storage.objects for select using (bucket_id = 'ruangan');

create policy "profil tulis sendiri" on storage.objects for all to authenticated
  using (bucket_id = 'profil' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'profil' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "ruangan tulis sarpras" on storage.objects for all to authenticated
  using (bucket_id = 'ruangan' and is_sarpras()) with check (bucket_id = 'ruangan' and is_sarpras());

-- bucket privat milik pengguna: dokumen, kondisi, laporan
create policy "privat tulis sendiri" on storage.objects for insert to authenticated
  with check (bucket_id in ('dokumen', 'kondisi', 'laporan') and (storage.foldername(name))[1] = auth.uid()::text);
create policy "privat hapus sendiri" on storage.objects for delete to authenticated
  using (bucket_id in ('dokumen', 'kondisi', 'laporan') and (storage.foldername(name))[1] = auth.uid()::text);
create policy "privat baca sendiri atau staf" on storage.objects for select to authenticated
  using (bucket_id in ('dokumen', 'kondisi', 'laporan')
         and ((storage.foldername(name))[1] = auth.uid()::text or is_staf()));

-- chat: folder pertama = id percakapan; hanya peserta
create policy "chat baca peserta" on storage.objects for select to authenticated
  using (bucket_id = 'chat' and exists (
    select 1 from percakapan c
    where c.id::text = (storage.foldername(name))[1] and auth.uid() in (c.id_pengguna, c.id_staf)));
create policy "chat tulis peserta" on storage.objects for insert to authenticated
  with check (bucket_id = 'chat' and exists (
    select 1 from percakapan c
    where c.id::text = (storage.foldername(name))[1] and auth.uid() in (c.id_pengguna, c.id_staf)));

-- ---------------------------------------------------------------------
-- REALTIME
-- ---------------------------------------------------------------------
alter publication supabase_realtime add table pesan, notifikasi, peminjaman, laporan_kerusakan;
