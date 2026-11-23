-- =====================================================================
-- Roomaster - DDL REVISI (Supabase / PostgreSQL)
-- Sumber: DATABASE_ROOMASTER.md (logic terbaru). Mahasiswa ITS, TU, Sarpras.
--
-- Perubahan dari DDL awal (laporan Bab 3.2):
--  users              -> profiles (id uuid = auth.users.id; role -> peran;
--                        + nip, tanggal_lahir, no_telepon, rata_respons_menit, aktif)
--  data_ruangan       + kelompok, kategori_penggunaan, departemen, alamat, deskripsi,
--                        id_pengelola, dibuat_pada
--  fasilitas          + ikon
--  peminjaman         id_user -> id_peminjam; + kode_peminjaman, catatan_tu, id_peninjau,
--                        catatan_checkin/checkout, checklist_checkout, dibuat_pada;
--                        - batas_revisi; + constraint anti-bentrok
--  dokumen_peminjaman jenis 'ktm' -> 'ktm_ktp', + 'lainnya'
--  riwayat_peminjaman + id_pelaku
--  kondisi_ruangan    -> foto_kondisi (boleh banyak foto per tahap); catatan dan
--                        checklist pindah ke kolom peminjaman
--  percakapan         id_user_1/id_user_2 -> id_pengguna (mahasiswa) / id_staf (TU),
--                        + id_ruangan, pasangan unik
--  pesan              isi_pesan boleh kosong, + lampiran
--  notifikasi         id_user -> id_pengguna; + tipe, id_peminjaman, id_laporan
--  laporan_kerusakan  id_user -> id_pelapor; kategori jadi array (proyektor_av -> proyektor,
--                        + pencahayaan); status + ditinjau, menunggu_suku_cadang, ditolak;
--                        + id_peminjaman, tingkat_kerusakan, id_penangan
--  bukti_laporan      -> laporan_media (+ id_update, ukuran, urutan)
--  penanganan_laporan -> laporan_update (status_baru memakai status_laporan)
--  tabel baru         galeri_ruangan
-- =====================================================================
create extension if not exists btree_gist;

-- ---------- ENUM ----------
create type peran_pengguna      as enum ('mahasiswa','tu','sarpras');
create type kategori_ruangan    as enum ('skpb','departemen');
create type status_ruangan      as enum ('available','not_available');
create type status_peminjaman   as enum ('draft','pending','revisi','disetujui','ditolak','berlangsung','selesai','dibatalkan');
create type jenis_dokumen       as enum ('ktm_ktp','surat_kegiatan','lainnya');
create type status_dokumen      as enum ('draft','diterima','revisi','ditolak');
create type tahap_kondisi       as enum ('checkin','checkout');
create type kategori_notifikasi as enum ('peminjaman','pesan','laporan','sistem');
create type tipe_notifikasi     as enum ('action','approved','rejected','timelimit','unfinished','update','system');
create type kategori_kerusakan  as enum ('ac','proyektor','pencahayaan','furnitur','listrik','jaringan','kebersihan','lainnya');
create type tingkat_kerusakan   as enum ('ringan','sedang','berat');
create type status_laporan      as enum ('draft','pending','ditinjau','diproses','menunggu_suku_cadang','selesai','ditolak');
create type tipe_media          as enum ('foto','video');

-- ---------- PENGGUNA ----------
create table profiles (
  id                 uuid primary key references auth.users(id) on delete cascade,
  peran              peran_pengguna not null default 'mahasiswa',
  nama               varchar(100)   not null,
  email              varchar(100)   not null unique,
  nrp                varchar(20)    unique,
  nip                varchar(30)    unique,
  tanggal_lahir      date,
  no_telepon         varchar(20),
  foto_profil        varchar(255),
  rata_respons_menit int check (rata_respons_menit >= 0),
  aktif              boolean        not null default true,
  dibuat_pada        timestamptz    not null default now()
);

-- ---------- RUANGAN ----------
create table data_ruangan (
  id                  bigint generated always as identity primary key,
  kode_ruangan        varchar(20)  not null unique,
  nama_ruangan        varchar(100) not null,
  kategori            kategori_ruangan not null,
  kelompok            varchar(50),
  tipe_ruangan        varchar(50)  not null default 'kelas',
  kategori_penggunaan text[]       not null default '{}'
    check (kategori_penggunaan <@ array['academic','meetings','events','group_study','creativity']),
  departemen          varchar(100),
  kapasitas           int          not null check (kapasitas > 0),
  lokasi              varchar(255) not null,
  alamat              varchar(255),
  deskripsi           text,
  foto_ruangan        varchar(255),
  status              status_ruangan not null default 'available',
  id_pengelola        uuid references profiles(id) on delete set null,
  dibuat_pada         timestamptz  not null default now()
);

create table fasilitas (
  id             bigint generated always as identity primary key,
  nama_fasilitas varchar(50) not null unique,
  ikon           varchar(50) not null default 'check'
);

create table fasilitas_ruangan (
  id_ruangan   bigint not null references data_ruangan(id) on delete cascade,
  id_fasilitas bigint not null references fasilitas(id)    on delete cascade,
  primary key (id_ruangan, id_fasilitas)
);

create table galeri_ruangan (
  id         bigint generated always as identity primary key,
  id_ruangan bigint not null references data_ruangan(id) on delete cascade,
  path       varchar(255) not null,
  urutan     int not null default 0
);

create table ruangan_favorit (
  id_pengguna uuid   not null references profiles(id)     on delete cascade,
  id_ruangan  bigint not null references data_ruangan(id) on delete cascade,
  primary key (id_pengguna, id_ruangan)
);

-- ---------- PEMINJAMAN ----------
create table peminjaman (
  id                       bigint generated always as identity primary key,
  kode_peminjaman          varchar(12)  not null unique,          -- diisi trigger (R + 6 karakter)
  id_peminjam              uuid   not null references profiles(id) on delete cascade,
  id_ruangan               bigint not null references data_ruangan(id),
  nama_kegiatan            varchar(150) not null,
  tujuan                   text         not null,
  departemen_penyelenggara varchar(100) not null,
  tanggal_pakai            date not null,
  waktu_mulai              time not null,
  waktu_selesai            time not null,
  status                   status_peminjaman not null default 'draft',
  tanggal_pengajuan        timestamptz,
  catatan_tu               text,
  id_peninjau              uuid references profiles(id) on delete set null,
  waktu_checkin            timestamptz,
  waktu_checkout           timestamptz,
  catatan_checkin          text,
  catatan_checkout         text,
  checklist_checkout       text[] not null default '{}',
  dibuat_pada              timestamptz not null default now(),
  constraint peminjaman_waktu_valid check (waktu_selesai > waktu_mulai),
  constraint peminjaman_tidak_bentrok exclude using gist (
    id_ruangan with =,
    tsrange(tanggal_pakai + waktu_mulai, tanggal_pakai + waktu_selesai) with &&
  ) where (status in ('pending','revisi','disetujui','berlangsung'))
);
create index idx_peminjaman_peminjam on peminjaman (id_peminjam);
create index idx_peminjaman_ruangan_tgl on peminjaman (id_ruangan, tanggal_pakai);
create index idx_peminjaman_status on peminjaman (status);

create table dokumen_peminjaman (
  id            bigint generated always as identity primary key,
  id_peminjaman bigint not null references peminjaman(id) on delete cascade,
  jenis_dokumen jenis_dokumen not null,
  nama_berkas   varchar(255) not null,
  path_berkas   varchar(255) not null,
  ukuran_berkas bigint check (ukuran_berkas >= 0),
  status        status_dokumen not null default 'draft',
  waktu_unggah  timestamptz not null default now()
);
create index idx_dokumen_peminjaman on dokumen_peminjaman (id_peminjaman);

create table riwayat_peminjaman (
  id            bigint generated always as identity primary key,
  id_peminjaman bigint not null references peminjaman(id) on delete cascade,
  tahapan       status_peminjaman not null,
  waktu         timestamptz not null default now(),
  id_pelaku     uuid references profiles(id) on delete set null,
  keterangan    varchar(255)
);
create index idx_riwayat_peminjaman on riwayat_peminjaman (id_peminjaman, waktu);

create table foto_kondisi (
  id            bigint generated always as identity primary key,
  id_peminjaman bigint not null references peminjaman(id) on delete cascade,
  tahap         tahap_kondisi not null,
  path_berkas   varchar(255) not null,
  waktu_unggah  timestamptz not null default now()
);
create index idx_foto_kondisi on foto_kondisi (id_peminjaman);

create table ulasan_peminjaman (
  id             bigint generated always as identity primary key,
  id_peminjaman  bigint not null unique references peminjaman(id) on delete cascade,
  rating         smallint not null check (rating between 1 and 5),
  komentar       text,
  tanggal_ulasan timestamptz not null default now()
);

-- ---------- CHAT (mahasiswa <-> TU) ----------
create table percakapan (
  id          bigint generated always as identity primary key,
  id_pengguna uuid not null references profiles(id) on delete cascade,   -- mahasiswa
  id_staf     uuid not null references profiles(id) on delete cascade,   -- TU
  id_ruangan  bigint references data_ruangan(id) on delete set null,
  dibuat_pada timestamptz not null default now(),
  constraint percakapan_pasangan_unik unique (id_pengguna, id_staf),
  constraint percakapan_beda_orang check (id_pengguna <> id_staf)
);
create index idx_percakapan_staf on percakapan (id_staf);

create table pesan (
  id            bigint generated always as identity primary key,
  id_percakapan bigint not null references percakapan(id) on delete cascade,
  id_pengirim   uuid   not null references profiles(id) on delete cascade,
  isi_pesan     text,
  lampiran      varchar(255),
  waktu_kirim   timestamptz not null default now(),
  sudah_dibaca  boolean not null default false,
  constraint pesan_tidak_kosong check (isi_pesan is not null or lampiran is not null)
);
create index idx_pesan_percakapan on pesan (id_percakapan, waktu_kirim);

-- ---------- LAPORAN KERUSAKAN ----------
create sequence seq_nomor_laporan;   -- dipakai trigger fn_laporan_nomor (LPR-2026-0001)

create table laporan_kerusakan (
  id                 bigint generated always as identity primary key,
  nomor_laporan      varchar(20) not null unique,              -- diisi trigger (LPR-2026-0001)
  id_ruangan         bigint not null references data_ruangan(id),
  id_pelapor         uuid   not null references profiles(id) on delete cascade,
  id_peminjaman      bigint references peminjaman(id) on delete set null,
  kategori_kerusakan kategori_kerusakan[] not null default '{}',
  deskripsi_masalah  text not null,
  tingkat_kerusakan  tingkat_kerusakan,
  status             status_laporan not null default 'draft',
  tanggal_lapor      timestamptz not null default now(),
  id_penangan        uuid references profiles(id) on delete set null,
  constraint laporan_kategori_wajib
    check (status = 'draft' or cardinality(kategori_kerusakan) >= 1)
);
create index idx_laporan_ruangan on laporan_kerusakan (id_ruangan);
create index idx_laporan_pelapor on laporan_kerusakan (id_pelapor);
create index idx_laporan_status  on laporan_kerusakan (status);

create table laporan_update (
  id              bigint generated always as identity primary key,
  id_laporan      bigint not null references laporan_kerusakan(id) on delete cascade,
  id_staf         uuid references profiles(id) on delete set null,
  status_baru     status_laporan not null,
  catatan_teknisi text,
  waktu           timestamptz not null default now()
);
create index idx_laporan_update on laporan_update (id_laporan, waktu);

create table laporan_media (
  id          bigint generated always as identity primary key,
  id_laporan  bigint not null references laporan_kerusakan(id) on delete cascade,
  id_update   bigint references laporan_update(id) on delete cascade,  -- null = bukti pelapor
  tipe        tipe_media not null,
  path_berkas varchar(255) not null,
  ukuran      bigint check (ukuran >= 0),
  urutan      int not null default 0
);
create index idx_laporan_media on laporan_media (id_laporan);

-- ---------- NOTIFIKASI ----------
create table notifikasi (
  id            bigint generated always as identity primary key,
  id_pengguna   uuid not null references profiles(id) on delete cascade,
  judul         varchar(100) not null,
  isi           varchar(255) not null,
  kategori      kategori_notifikasi not null,
  tipe          tipe_notifikasi     not null default 'update',
  id_peminjaman bigint references peminjaman(id)        on delete cascade,
  id_laporan    bigint references laporan_kerusakan(id) on delete cascade,
  waktu         timestamptz not null default now(),
  sudah_dibaca  boolean not null default false
);
create index idx_notifikasi_pengguna on notifikasi (id_pengguna, waktu desc);
