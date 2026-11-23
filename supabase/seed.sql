-- =====================================================================
-- ROOMASTER - DML data awal (aman dijalankan berulang kali)
--
-- BAGIAN A  Data WAJIB agar aplikasi berjalan:
--           3 akun (mahasiswa, TU, Sarpras), fasilitas, 17 ruangan, relasi fasilitas, galeri.
-- BAGIAN B  Contoh transaksi agar semua layar terisi:
--           peminjaman (semua status), ulasan, laporan kerusakan, chat, favorit, notifikasi.
--           Dilewati otomatis bila sudah pernah dijalankan (penanda: kode RDEMO001).
--
-- Jalankan SETELAH migrasi 01-04. Jangan dipakai di produksi: akun demo berpassword publik.
-- Password semua akun demo: Roomaster123!
-- Tanggal contoh relatif terhadap hari ini, jadi data selalu terlihat segar.
-- =====================================================================

-- =====================================================================
-- BAGIAN A: DATA WAJIB
-- =====================================================================

-- ---------------- Akun demo ----------------
-- Peran staf ditentukan lewat raw_app_meta_data (tidak bisa diubah klien).
do $$
declare
  u record;
begin
  for u in
    select * from (values
      ('11111111-1111-1111-1111-111111111111'::uuid, '5026241065@student.its.ac.id', 'Zenkko Mahasiswa',  'mahasiswa'),
      ('22222222-2222-2222-2222-222222222222'::uuid, 'azura@tu.its.ac.id',           'Fauzan Azura (TU)', 'tu'),
      ('33333333-3333-3333-3333-333333333333'::uuid, 'musaddad@sarpras.its.ac.id',   'Musaddad (Sarpras)', 'sarpras')
    ) as t(id, email, nama, peran)
  loop
    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, recovery_token, email_change, email_change_token_new
    ) values (
      '00000000-0000-0000-0000-000000000000', u.id, 'authenticated', 'authenticated', u.email,
      extensions.crypt('Roomaster123!', extensions.gen_salt('bf')), now(),
      jsonb_build_object('provider', 'email', 'providers', jsonb_build_array('email'), 'peran', u.peran),
      jsonb_build_object('nama', u.nama), now(), now(), '', '', '', ''
    ) on conflict (id) do nothing;

    insert into auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
    values (
      gen_random_uuid(), u.id,
      jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
      'email', u.id::text, now(), now(), now()
    ) on conflict do nothing;
  end loop;
end $$;

update profiles set rata_respons_menit = 120, no_telepon = '081234567890' where id = '22222222-2222-2222-2222-222222222222';
update profiles set nip = '198501012010011001' where id = '22222222-2222-2222-2222-222222222222';

-- ---------------- Fasilitas ----------------
insert into fasilitas (nama_fasilitas, ikon) values
  ('Full AC', 'air-vent'),
  ('Video Projector', 'projector'),
  ('WI-FI 5G', 'wifi'),
  ('Papan Tulis', 'pencil'),
  ('Sound System', 'message-square')
on conflict (nama_fasilitas) do nothing;

-- ---------------- Ruangan contoh ----------------
-- foto_ruangan 'asset:...' = gambar bawaan aplikasi; ganti dengan path bucket "ruangan" bila sudah diunggah.
insert into data_ruangan
  (kode_ruangan, nama_ruangan, kategori, kelompok, tipe_ruangan, kategori_penggunaan, departemen, kapasitas, lokasi, alamat, deskripsi, foto_ruangan, id_pengelola)
values
  ('SI-4202', 'SI-4202', 'departemen', 'FTEIC', 'kelas', '{academic,meetings,group_study}', 'Departemen Sistem Informasi ITS', 20,
   'Gedung 4 Sistem Informasi, 2nd Floor', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Ruang rapat representatif yang dilengkapi dengan fasilitas presentasi modern. Cocok untuk pertemuan tingkat eksekutif, presentasi proyek berskala besar, dan seminar internal. Ruangan memiliki pencahayaan alami yang baik dengan tirai otomatis.',
   'asset:images/rooms/blue-class.jpg', '22222222-2222-2222-2222-222222222222'),
  ('SI-2209', 'SI-2209', 'departemen', 'FTEIC', 'kelas', '{academic,group_study}', 'Departemen Sistem Informasi ITS', 50,
   'Gedung 2 Sistem Informasi, 2nd Floor', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Ruang kelas luas untuk perkuliahan dan diskusi kelompok menengah.', 'asset:images/rooms/class.jpg', '22222222-2222-2222-2222-222222222222'),
  ('SI-3201', 'SI-3201', 'departemen', 'FTEIC', 'laboratorium', '{academic,creativity}', 'Departemen Sistem Informasi ITS', 20,
   'Gedung 3 Sistem Informasi, 2nd Floor', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Laboratorium komputer dengan stasiun kerja lengkap.', 'asset:images/rooms/computer-lab.jpg', '22222222-2222-2222-2222-222222222222'),
  ('SI-DEKANAT', 'Ruang Dekanat', 'departemen', 'FTEIC', 'ruang rapat', '{meetings}', 'Departemen Sistem Informasi', 20,
   'Gedung Dekanat FTEIC, 1st Floor', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Ruang rapat resmi untuk pertemuan pimpinan dan tamu.', 'asset:images/rooms/hall.jpg', '22222222-2222-2222-2222-222222222222'),
  ('IF-103', 'IF-103', 'departemen', 'FTEIC', 'kelas', '{academic,meetings}', 'Departemen Teknik Informatika ITS', 100,
   'Gedung Informatika, 1st Floor', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Ruang kuliah besar dengan sistem audio dan proyektor ganda.', 'asset:images/rooms/hall.jpg', '22222222-2222-2222-2222-222222222222'),
  ('IF-204', 'IF-204', 'departemen', 'FTEIC', 'kelas', '{academic,events}', 'Departemen Teknik Informatika ITS', 100,
   'Gedung Informatika, 2nd Floor', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Ruang kelas lantai dua dengan pencahayaan alami.', 'asset:images/rooms/blue-class.jpg', '22222222-2222-2222-2222-222222222222'),
  ('ELKA-301', 'ELKA-301', 'departemen', 'FTEIC', 'aula', '{events,meetings}', 'Departemen Teknik Elektro ITS', 250,
   'Gedung Teknik Elektro, 3rd Floor', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Aula besar untuk seminar dan acara departemen.', 'asset:images/rooms/computer-lab.jpg', '22222222-2222-2222-2222-222222222222'),
  ('ELKA-210', 'ELKA-210', 'departemen', 'FTEIC', 'kelas', '{academic}', 'Departemen Teknik Elektro ITS', 50,
   'Gedung Teknik Elektro, 2nd Floor', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Ruang kelas menengah untuk kuliah dan kerja kelompok.', 'asset:images/rooms/building.jpg', '22222222-2222-2222-2222-222222222222'),
  ('MS-105', 'MS-105', 'departemen', 'FTIRS', 'kelas', '{academic,group_study}', 'Departemen Teknik Mesin ITS', 50,
   'Gedung Teknik Mesin, 1st Floor', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Ruang kelas dengan meja lebar untuk kerja kelompok.', 'asset:images/rooms/class.jpg', '22222222-2222-2222-2222-222222222222'),
  ('PWK-201', 'PWK-201', 'departemen', 'FTIRS', 'studio', '{creativity,group_study}', 'Departemen Perencanaan Wilayah dan Kota ITS', 20,
   'Gedung PWK, 2nd Floor', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Studio perancangan dengan meja gambar dan pencahayaan terbaik.', 'asset:images/rooms/blue-class.jpg', '22222222-2222-2222-2222-222222222222'),
  ('PWK-305', 'PWK-305', 'departemen', 'FTIRS', 'aula', '{events}', 'Departemen Perencanaan Wilayah dan Kota ITS', 250,
   'Gedung PWK, 3rd Floor', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Aula serbaguna untuk seminar dan pameran.', 'asset:images/rooms/building.jpg', '22222222-2222-2222-2222-222222222222'),
  ('TW2-101', 'TW2-101', 'skpb', 'TW2', 'kelas', '{academic,meetings}', 'Departemen Sistem Informasi ITS', 50,
   'Gedung Teknik Wilayah 2, 1st Floor', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Ruang SKPB TW2 untuk kegiatan akademik dan rapat.', 'asset:images/rooms/hall.jpg', '22222222-2222-2222-2222-222222222222'),
  ('TW2-202', 'TW2-202', 'skpb', 'TW2', 'kelas', '{group_study}', 'Departemen Sistem Informasi ITS', 50,
   'Gedung Teknik Wilayah 2, 2nd Floor', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Ruang SKPB TW2 untuk belajar kelompok.', 'asset:images/rooms/class.jpg', '22222222-2222-2222-2222-222222222222'),
  ('TW2-303', 'TW2-303', 'skpb', 'TW2', 'kelas', '{academic}', 'Departemen Sistem Informasi', 20,
   'Gedung Teknik Wilayah 2, 3rd Floor', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Ruang SKPB TW2 ukuran kecil.', 'asset:images/rooms/blue-class.jpg', '22222222-2222-2222-2222-222222222222'),
  ('UPBG-A1', 'UPBG-A1', 'skpb', 'UPBG', 'kelas', '{academic,events}', 'Departemen Sistem Informasi ITS', 50,
   'Gedung UPBG, Lantai 1', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Ruang UPBG untuk kegiatan kemahasiswaan.', 'asset:images/rooms/class.jpg', '22222222-2222-2222-2222-222222222222'),
  ('UPBG-B2', 'UPBG-B2', 'skpb', 'UPBG', 'kelas', '{meetings,creativity}', 'Departemen Sistem Informasi ITS', 50,
   'Gedung UPBG, Lantai 2', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Ruang UPBG untuk rapat dan kegiatan kreatif.', 'asset:images/rooms/si-4202.jpg', '22222222-2222-2222-2222-222222222222'),
  ('UPBG-SMART', 'SI-Smartclass', 'skpb', 'UPBG', 'kelas', '{academic,group_study}', 'Departemen Sistem Informasi', 20,
   'Gedung UPBG, Lantai 3', 'Kampus ITS, Keputih, Kec. Sukolilo, Surabaya, Jawa Timur 60117',
   'Smart class dengan layar interaktif.', 'asset:images/rooms/blue-class.jpg', '22222222-2222-2222-2222-222222222222')
on conflict (kode_ruangan) do nothing;

-- Fasilitas: semua ruangan Full AC + WiFi; yang besar ditambah proyektor
insert into fasilitas_ruangan (id_ruangan, id_fasilitas)
select r.id, f.id from data_ruangan r, fasilitas f
where f.nama_fasilitas in ('Full AC', 'WI-FI 5G')
on conflict do nothing;

insert into fasilitas_ruangan (id_ruangan, id_fasilitas)
select r.id, f.id from data_ruangan r, fasilitas f
where f.nama_fasilitas = 'Video Projector' and r.kapasitas >= 50
on conflict do nothing;

-- Galeri contoh untuk SI-4202
insert into galeri_ruangan (id_ruangan, path, urutan)
select r.id, g.path, g.urutan
from data_ruangan r,
     (values ('asset:images/rooms/computer-lab.jpg', 1), ('asset:images/rooms/class.jpg', 2),
             ('asset:images/rooms/building.jpg', 3), ('asset:images/rooms/hall.jpg', 4)) as g(path, urutan)
where r.kode_ruangan = 'SI-4202'
  and not exists (select 1 from galeri_ruangan x where x.id_ruangan = r.id);

-- =====================================================================
-- BAGIAN B: CONTOH TRANSAKSI
-- =====================================================================
do $$
declare
  c_mhs constant uuid := '11111111-1111-1111-1111-111111111111';
  c_tu  constant uuid := '22222222-2222-2222-2222-222222222222';
  c_sp  constant uuid := '33333333-3333-3333-3333-333333333333';
  r        record;
  v_id     bigint;
  v_ruang  bigint;
  v_lap    bigint;
  v_perc   bigint;
begin
  if exists (select 1 from peminjaman where kode_peminjaman = 'RDEMO001') then
    raise notice 'Contoh transaksi sudah ada, dilewati.';
    return;
  end if;

  -- ---------------- Favorit mahasiswa ----------------
  insert into ruangan_favorit (id_pengguna, id_ruangan)
  select c_mhs, id from data_ruangan where kode_ruangan in ('SI-4202', 'IF-103', 'TW2-101')
  on conflict do nothing;

  -- ---------------- Peminjaman (seluruh status) ----------------
  -- hari = selisih dari hari ini; akhir = status akhir yang diinginkan
  for r in
    select * from (values
      ('RDEMO001', 'SI-4202',   -14, '09:00', '11:00', 'Rapat Koordinasi Himpunan',  'Evaluasi program kerja semester ganjil',  'Himpunan Mahasiswa Sistem Informasi', 'selesai',    null::text, 5, 'Ruangan nyaman, AC dingin, proyektor berfungsi baik.'),
      ('RDEMO002', 'IF-103',    -10, '13:00', '15:00', 'Seminar Proposal Tugas Akhir', 'Sidang proposal kelompok bimbingan',        'Departemen Teknik Informatika',       'selesai',    null,       4, 'Luas dan audio jelas, hanya sedikit berdebu.'),
      ('RDEMO003', 'SI-3201',    -7, '08:00', '10:00', 'Praktikum Pengganti',          'Praktikum pengganti basis data',           'Laboratorium Sistem Informasi',       'selesai',    null,       3, 'Komputer cukup, tapi koneksi sempat lambat.'),
      ('RDEMO004', 'PWK-201',    -5, '10:00', '12:00', 'Workshop Desain Poster',       'Workshop desain untuk anggota baru',       'Himpunan Mahasiswa Perencanaan Kota', 'selesai',    null,       4, 'Meja gambar luas dan pencahayaan bagus.'),
      ('RDEMO005', 'TW2-101',    -3, '14:00', '16:00', 'Diskusi Panel Kewirausahaan',  'Diskusi panel dengan alumni',              'Himpunan Mahasiswa Sistem Informasi', 'selesai',    null,       5, 'Sangat membantu, proses peminjaman mudah.'),
      ('RDEMO006', 'ELKA-301',   12, '09:00', '12:00', 'Seminar Nasional Elektro',     'Seminar dengan peserta lintas kampus',     'Departemen Teknik Elektro',           'ditolak',    'Kapasitas aula terlalu besar untuk jumlah peserta yang diajukan. Gunakan ruangan lebih kecil.', null, null),
      ('RDEMO007', 'MS-105',      6, '09:00', '11:00', 'Kerja Kelompok Gambar Teknik', 'Penyelesaian tugas besar kelompok',        'Departemen Teknik Mesin',             'revisi',     'Surat peminjaman belum ditandatangani. Mohon unggah ulang surat yang sudah bertanda tangan.', null, null),
      ('RDEMO008', 'SI-2209',     4, '13:00', '15:00', 'Pelatihan Git dan GitHub',     'Pelatihan untuk anggota baru himpunan',    'Himpunan Mahasiswa Sistem Informasi', 'pending',    null,       null, null),
      ('RDEMO009', 'UPBG-A1',     2, '10:00', '12:00', 'Rapat Panitia Dies Natalis',   'Rapat koordinasi panitia',                 'BEM Fakultas',                        'disetujui',  null,       null, null),
      ('RDEMO010', 'SI-4202',     0, '06:00', '23:00', 'Latihan Presentasi Kompetisi', 'Latihan tim lomba tingkat nasional',       'Tim Kompetisi Sistem Informasi',      'berlangsung', null,      null, null),
      ('RDEMO011', 'IF-204',      8, '08:00', '10:00', 'Kuliah Tamu',                  'Kuliah tamu dari praktisi industri',       'Departemen Teknik Informatika',       'draft',      null,       null, null),
      ('RDEMO012', 'TW2-202',     9, '15:00', '17:00', 'Belajar Bersama UAS',          'Belajar bersama menjelang ujian',          'Mahasiswa Angkatan 2024',             'dibatalkan', null,       null, null)
    ) as t(kode, ruang, hari, mulai, selesai, kegiatan, tujuan, dept, akhir, catatan, rating, komentar)
  loop
    select id into v_ruang from data_ruangan where kode_ruangan = r.ruang;

    insert into peminjaman (kode_peminjaman, id_peminjam, id_ruangan, nama_kegiatan, tujuan, departemen_penyelenggara,
                            tanggal_pakai, waktu_mulai, waktu_selesai, status, dibuat_pada)
    values (r.kode, c_mhs, v_ruang, r.kegiatan, r.tujuan, r.dept,
            current_date + r.hari, r.mulai::time, r.selesai::time, 'draft',
            case when r.akhir = 'draft' then now() - interval '1 hour' else now() - interval '10 days' end)
    returning id into v_id;

    if r.akhir <> 'draft' then
      insert into dokumen_peminjaman (id_peminjaman, jenis_dokumen, nama_berkas, path_berkas, ukuran_berkas, status) values
        (v_id, 'ktm_ktp',        'KTM_5026241065.pdf',          c_mhs || '/' || v_id || '/ktm_ktp.pdf',        245760, 'draft'),
        (v_id, 'surat_kegiatan', 'Surat_Peminjaman_Ruangan.pdf', c_mhs || '/' || v_id || '/surat_kegiatan.pdf', 512000, 'draft');

      update peminjaman
         set status = 'pending',
             tanggal_pengajuan = least(now() - interval '1 hour', (current_date + r.hari - 3)::timestamptz)
       where id = v_id;

      if r.akhir in ('revisi', 'ditolak') then
        update peminjaman set status = r.akhir::status_peminjaman, catatan_tu = r.catatan, id_peninjau = c_tu where id = v_id;
        update dokumen_peminjaman
           set status = case when r.akhir = 'ditolak' then 'ditolak'::status_dokumen
                             when jenis_dokumen = 'surat_kegiatan' then 'revisi'::status_dokumen
                             else 'diterima'::status_dokumen end
         where id_peminjaman = v_id;
      elsif r.akhir = 'dibatalkan' then
        update peminjaman set status = 'dibatalkan' where id = v_id;
      elsif r.akhir in ('disetujui', 'berlangsung', 'selesai') then
        update peminjaman set status = 'disetujui', id_peninjau = c_tu where id = v_id;
        update dokumen_peminjaman set status = 'diterima' where id_peminjaman = v_id;

        if r.akhir in ('berlangsung', 'selesai') then
          update peminjaman
             set status = 'berlangsung',
                 waktu_checkin = case when r.akhir = 'berlangsung' then now() else ((current_date + r.hari) + r.mulai::time) at time zone 'Asia/Jakarta' end,
                 catatan_checkin = 'Kondisi ruangan bersih dan semua peralatan lengkap.'
           where id = v_id;
        end if;
        if r.akhir = 'selesai' then
          update peminjaman
             set status = 'selesai',
                 waktu_checkout = ((current_date + r.hari) + r.selesai::time) at time zone 'Asia/Jakarta',
                 catatan_checkout = 'Ruangan sudah dirapikan dan dikembalikan seperti semula.',
                 checklist_checkout = array['Trash bins emptied', 'All surfaces wiped down', 'Floors swept and vacuumed',
                                            'Personal belongings removed', 'Lights and electronics turned off']
           where id = v_id;
          insert into ulasan_peminjaman (id_peminjaman, rating, komentar, tanggal_ulasan)
          values (v_id, r.rating, r.komentar, ((current_date + r.hari) + r.selesai::time) at time zone 'Asia/Jakarta' + interval '1 hour');
        end if;
      end if;
    end if;
  end loop;

  -- Riwayat transaksi lama tidak perlu memenuhi daftar notifikasi
  delete from notifikasi
   where id_peminjaman in (select id from peminjaman where kode_peminjaman in
         ('RDEMO001', 'RDEMO002', 'RDEMO003', 'RDEMO004', 'RDEMO005', 'RDEMO012'));

  -- ---------------- Laporan kerusakan ----------------
  for r in
    select * from (values
      ('LPR-2026-9001', 'SI-4202',  '{ac}'::kategori_kerusakan[],              'AC tidak dingin dan mengeluarkan suara bising saat dinyalakan.', 'pending',              null::tingkat_kerusakan, null::text),
      ('LPR-2026-9002', 'IF-103',   '{proyektor}'::kategori_kerusakan[],       'Proyektor tidak menampilkan gambar, layar hanya menunjukkan pesan no signal.', 'diproses', 'sedang', 'Kabel HDMI diganti, menunggu pengujian ulang.'),
      ('LPR-2026-9003', 'ELKA-210', '{kebersihan,lainnya}'::kategori_kerusakan[], 'Plafon bocor di dekat jendela dan lantai basah saat hujan.', 'menunggu_suku_cadang', 'berat',  'Menunggu material plafon dari vendor.'),
      ('LPR-2026-9004', 'MS-105',   '{furnitur}'::kategori_kerusakan[],        'Dua kursi patah pada bagian sandaran.', 'selesai', 'ringan', 'Kursi sudah diganti dengan unit baru.'),
      ('LPR-2026-9005', 'PWK-201',  '{jaringan}'::kategori_kerusakan[],        'Wi-Fi sering terputus pada sudut belakang ruangan.', 'draft', null, null)
    ) as t(nomor, ruang, kategori, deskripsi, akhir, tingkat, catatan)
  loop
    select id into v_ruang from data_ruangan where kode_ruangan = r.ruang;

    insert into laporan_kerusakan (nomor_laporan, id_ruangan, id_pelapor, kategori_kerusakan, deskripsi_masalah, status, tanggal_lapor)
    values (r.nomor, v_ruang, c_mhs, r.kategori, r.deskripsi,
            case when r.akhir = 'draft' then 'draft' else 'pending' end::status_laporan,
            now() - interval '2 days')
    returning id into v_lap;

    if r.akhir not in ('draft', 'pending') then
      update laporan_kerusakan set status = 'ditinjau', id_penangan = c_sp where id = v_lap;
      insert into laporan_update (id_laporan, id_staf, status_baru, catatan_teknisi, waktu)
      values (v_lap, c_sp, 'ditinjau', 'Laporan diterima, teknisi dijadwalkan melakukan pengecekan.', now() - interval '36 hours');

      update laporan_kerusakan
         set status = r.akhir::status_laporan, tingkat_kerusakan = r.tingkat, id_penangan = c_sp
       where id = v_lap;
      insert into laporan_update (id_laporan, id_staf, status_baru, catatan_teknisi, waktu)
      values (v_lap, c_sp, r.akhir::status_laporan, r.catatan, now() - interval '12 hours');
    end if;
  end loop;

  -- Permintaan yang sudah diputuskan tidak lagi menjadi tugas TU / Sarpras
  delete from notifikasi where id_pengguna = c_tu and tipe = 'action'
     and id_peminjaman in (select id from peminjaman where status <> 'pending');
  delete from notifikasi where id_pengguna = c_sp and tipe = 'action'
     and id_laporan in (select id from laporan_kerusakan where status = 'selesai');

  -- Konsisten dengan aturan perbarui_laporan: kerusakan berat yang belum selesai menutup ruangan
  update data_ruangan set status = 'not_available' where kode_ruangan = 'ELKA-210';

  -- ---------------- Chat mahasiswa <-> TU ----------------
  select id into v_ruang from data_ruangan where kode_ruangan = 'SI-4202';
  insert into percakapan (id_pengguna, id_staf, id_ruangan) values (c_mhs, c_tu, v_ruang)
  on conflict (id_pengguna, id_staf) do nothing;
  select id into v_perc from percakapan where id_pengguna = c_mhs and id_staf = c_tu;

  insert into pesan (id_percakapan, id_pengirim, isi_pesan, waktu_kirim, sudah_dibaca) values
    (v_perc, c_mhs, 'Selamat pagi Bu, saya ingin menanyakan peminjaman SI-4202 untuk latihan presentasi tim lomba.', now() - interval '3 hours', true),
    (v_perc, c_tu,  'Selamat pagi. Silakan lengkapi KTM dan surat peminjaman lalu ajukan lewat aplikasi ya.',        now() - interval '170 minutes', true),
    (v_perc, c_mhs, 'Baik Bu, terima kasih. Apakah proyektor di ruangan itu tersedia?',                            now() - interval '160 minutes', true),
    (v_perc, c_tu,  'Tersedia, Full AC dan proyektor sudah termasuk. Jangan lupa check-in sebelum memakai ruangan.', now() - interval '20 minutes', false);

  -- ---------------- Notifikasi tambahan ----------------
  insert into notifikasi (id_pengguna, judul, isi, kategori, tipe, waktu) values
    (c_mhs, 'Welcome to Roomaster', 'Pinjam ruangan kampus dan laporkan kerusakan fasilitas langsung dari aplikasi.', 'sistem', 'system', now() - interval '10 days'),
    (c_tu,  'Welcome to Roomaster', 'Tinjau pengajuan peminjaman dan pantau rating ruangan dari dashboard Anda.',      'sistem', 'system', now() - interval '10 days'),
    (c_sp,  'Welcome to Roomaster', 'Kelola laporan kerusakan fasilitas dari dashboard Anda.',                         'sistem', 'system', now() - interval '10 days');

  raise notice 'Contoh transaksi berhasil dibuat.';
end $$;
