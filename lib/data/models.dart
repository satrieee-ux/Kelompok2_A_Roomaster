/// Model data ringan: dipetakan langsung dari baris view/tabel Supabase.
DateTime? _dt(dynamic v) => v == null ? null : DateTime.parse(v as String);
int _int(dynamic v) => v == null ? 0 : (v as num).toInt();
double _dbl(dynamic v) => v == null ? 0 : (v as num).toDouble();

class Profile {
  Profile({
    required this.id,
    required this.peran,
    required this.nama,
    required this.email,
    this.nrp,
    this.nip,
    this.noTelepon,
    this.fotoProfil,
    this.tanggalLahir,
  });
  final String id, peran, nama, email;
  final String? nrp, nip, noTelepon, fotoProfil;
  final DateTime? tanggalLahir;

  bool get isStaf => peran == 'tu' || peran == 'sarpras';
  String get peranLabel => const {
        'mahasiswa': 'Student',
        'tu': 'Education Personnel (TU)',
        'sarpras': 'Facilities (Sarpras)',
      }[peran]!;
  String get firstName => nama.split(' ').first;

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
        id: m['id'] as String,
        peran: m['peran'] as String,
        nama: m['nama'] as String,
        email: m['email'] as String,
        nrp: m['nrp'] as String?,
        nip: m['nip'] as String?,
        noTelepon: m['no_telepon'] as String?,
        fotoProfil: m['foto_profil'] as String?,
        tanggalLahir: m['tanggal_lahir'] == null ? null : DateTime.parse(m['tanggal_lahir'] as String),
      );
}

class Facility {
  const Facility(this.nama, this.ikon);
  final String nama, ikon;
}

class Room {
  Room({
    required this.id,
    required this.kode,
    required this.nama,
    required this.kategori,
    this.kelompok,
    required this.tipe,
    required this.kategoriPenggunaan,
    this.departemen,
    required this.kapasitas,
    this.lokasi,
    this.alamat,
    this.deskripsi,
    this.foto,
    required this.status,
    required this.ratingRata,
    required this.jumlahUlasan,
    required this.jumlahPeminjaman,
    required this.fasilitas,
    required this.tersediaSekarang,
    this.idPengelola,
    this.namaPengelola,
    this.fotoPengelola,
    this.responsMenit,
    this.favorite = false,
  });
  final int id, kapasitas, jumlahUlasan, jumlahPeminjaman;
  final String kode, nama, kategori, tipe, status;
  final String? kelompok, departemen, lokasi, alamat, deskripsi, foto, idPengelola, namaPengelola, fotoPengelola;
  final List<String> kategoriPenggunaan;
  final double ratingRata;
  final List<Facility> fasilitas;
  final bool tersediaSekarang;
  final int? responsMenit;
  final bool favorite;

  Room withFavorite(bool f) => Room(
        id: id, kode: kode, nama: nama, kategori: kategori, kelompok: kelompok, tipe: tipe,
        kategoriPenggunaan: kategoriPenggunaan, departemen: departemen, kapasitas: kapasitas,
        lokasi: lokasi, alamat: alamat, deskripsi: deskripsi, foto: foto, status: status,
        ratingRata: ratingRata, jumlahUlasan: jumlahUlasan, jumlahPeminjaman: jumlahPeminjaman,
        fasilitas: fasilitas, tersediaSekarang: tersediaSekarang, idPengelola: idPengelola,
        namaPengelola: namaPengelola, fotoPengelola: fotoPengelola, responsMenit: responsMenit, favorite: f,
      );

  factory Room.fromMap(Map<String, dynamic> m) => Room(
        id: _int(m['id']),
        kode: m['kode_ruangan'] as String,
        nama: m['nama_ruangan'] as String,
        kategori: m['kategori'] as String,
        kelompok: m['kelompok'] as String?,
        tipe: (m['tipe_ruangan'] as String?) ?? 'kelas',
        kategoriPenggunaan: ((m['kategori_penggunaan'] as List?) ?? const []).cast<String>(),
        departemen: m['departemen'] as String?,
        kapasitas: _int(m['kapasitas']),
        lokasi: m['lokasi'] as String?,
        alamat: m['alamat'] as String?,
        deskripsi: m['deskripsi'] as String?,
        foto: m['foto_ruangan'] as String?,
        status: m['status'] as String,
        ratingRata: _dbl(m['rating_rata']),
        jumlahUlasan: _int(m['jumlah_ulasan']),
        jumlahPeminjaman: _int(m['jumlah_peminjaman']),
        fasilitas: ((m['fasilitas'] as List?) ?? const [])
            .map((e) => Facility((e as Map)['nama'] as String, (e['ikon'] as String?) ?? 'check'))
            .toList(),
        tersediaSekarang: (m['tersedia_sekarang'] as bool?) ?? false,
        idPengelola: m['id_pengelola'] as String?,
        namaPengelola: m['nama_pengelola'] as String?,
        fotoPengelola: m['foto_pengelola'] as String?,
        responsMenit: m['respons_pengelola_menit'] as int?,
      );
}

class Review {
  Review({required this.id, this.idRuangan, this.namaRuangan, required this.nama, this.foto, required this.rating, this.komentar, required this.tanggal});
  final int id, rating;
  final int? idRuangan;
  final String nama;
  final String? foto, komentar, namaRuangan;
  final DateTime tanggal;
  factory Review.fromMap(Map<String, dynamic> m) => Review(
        id: _int(m['id']),
        idRuangan: m['id_ruangan'] == null ? null : _int(m['id_ruangan']),
        namaRuangan: m['nama_ruangan'] as String?,
        nama: m['nama'] as String,
        foto: m['foto_profil'] as String?,
        rating: _int(m['rating']),
        komentar: m['komentar'] as String?,
        tanggal: _dt(m['tanggal_ulasan'])!,
      );
}

class Booking {
  Booking({
    required this.id,
    required this.kode,
    required this.idPeminjam,
    required this.idRuangan,
    required this.namaKegiatan,
    required this.tujuan,
    required this.departemenPenyelenggara,
    required this.tanggal,
    required this.mulai,
    required this.selesai,
    required this.status,
    this.tanggalPengajuan,
    this.catatanTu,
    this.checkin,
    this.checkout,
    this.kodeRuangan = '',
    this.namaRuangan = '',
    this.fotoRuangan,
    this.departemenRuangan,
    this.lokasi,
    this.alamat,
    this.kapasitas = 0,
    this.namaPeminjam = '',
    this.peranPeminjam = 'mahasiswa',
    this.sudahDiulas = false,
  });
  final int id, idRuangan, kapasitas;
  final String kode, idPeminjam, namaKegiatan, tujuan, departemenPenyelenggara, mulai, selesai, status;
  final String kodeRuangan, namaRuangan, namaPeminjam, peranPeminjam;
  final DateTime tanggal;
  final DateTime? tanggalPengajuan, checkin, checkout;
  final String? catatanTu, fotoRuangan, departemenRuangan, lokasi, alamat;
  final bool sudahDiulas;

  DateTime get startAt => DateTime(tanggal.year, tanggal.month, tanggal.day, int.parse(mulai.substring(0, 2)), int.parse(mulai.substring(3, 5)));
  DateTime get endAt => DateTime(tanggal.year, tanggal.month, tanggal.day, int.parse(selesai.substring(0, 2)), int.parse(selesai.substring(3, 5)));

  /// Status UI (lihat pemetaan di README): kunci StatusPill.
  String get uiStatus {
    switch (status) {
      case 'draft':
        return 'draft';
      case 'pending':
        return 'pending';
      case 'revisi':
        return 'action_required';
      case 'disetujui':
      case 'berlangsung':
        return 'approved';
      case 'selesai':
        return 'completed';
      default:
        return 'rejected';
    }
  }

  String get uiLabel => const {
        'draft': 'Draft',
        'pending': 'Pending',
        'revisi': 'Revision Needed',
        'disetujui': 'Approved',
        'berlangsung': 'In Use',
        'selesai': 'Completed',
        'ditolak': 'Rejected',
        'dibatalkan': 'Cancelled',
      }[status]!;

  bool get isActive => const {'draft', 'pending', 'revisi', 'disetujui', 'berlangsung'}.contains(status);

  factory Booking.fromMap(Map<String, dynamic> m) => Booking(
        id: _int(m['id']),
        kode: m['kode_peminjaman'] as String,
        idPeminjam: m['id_peminjam'] as String,
        idRuangan: _int(m['id_ruangan']),
        namaKegiatan: (m['nama_kegiatan'] as String?) ?? '',
        tujuan: (m['tujuan'] as String?) ?? '',
        departemenPenyelenggara: (m['departemen_penyelenggara'] as String?) ?? '',
        tanggal: DateTime.parse(m['tanggal_pakai'] as String),
        mulai: m['waktu_mulai'] as String,
        selesai: m['waktu_selesai'] as String,
        status: m['status'] as String,
        tanggalPengajuan: _dt(m['tanggal_pengajuan']),
        catatanTu: m['catatan_tu'] as String?,
        checkin: _dt(m['waktu_checkin']),
        checkout: _dt(m['waktu_checkout']),
        kodeRuangan: (m['kode_ruangan'] as String?) ?? '',
        namaRuangan: (m['nama_ruangan'] as String?) ?? '',
        fotoRuangan: m['foto_ruangan'] as String?,
        departemenRuangan: m['departemen_ruangan'] as String?,
        lokasi: m['lokasi'] as String?,
        alamat: m['alamat'] as String?,
        kapasitas: _int(m['kapasitas']),
        namaPeminjam: (m['nama_peminjam'] as String?) ?? '',
        peranPeminjam: (m['peran_peminjam'] as String?) ?? 'mahasiswa',
        sudahDiulas: (m['sudah_diulas'] as bool?) ?? false,
      );
}

class BookingDoc {
  BookingDoc({required this.id, required this.jenis, required this.nama, required this.path, required this.ukuran});
  final int id, ukuran;
  final String jenis, nama, path;
  factory BookingDoc.fromMap(Map<String, dynamic> m) => BookingDoc(
        id: _int(m['id']),
        jenis: m['jenis_dokumen'] as String,
        nama: m['nama_berkas'] as String,
        path: m['path_berkas'] as String,
        ukuran: _int(m['ukuran_berkas']),
      );
}

class Report {
  Report({
    required this.id,
    required this.nomor,
    required this.idRuangan,
    required this.idPelapor,
    required this.kategori,
    required this.deskripsi,
    this.tingkat,
    required this.status,
    required this.tanggal,
    this.namaRuangan = '',
    this.kodeRuangan = '',
    this.lokasi,
    this.departemen,
    this.namaPelapor = '',
  });
  final int id, idRuangan;
  final String nomor, idPelapor, deskripsi, status, namaRuangan, kodeRuangan, namaPelapor;
  final List<String> kategori;
  final String? tingkat, lokasi, departemen;
  final DateTime tanggal;

  String get uiStatus => const {
        'draft': 'draft',
        'pending': 'pending',
        'ditinjau': 'pending',
        'diproses': 'draft',
        'menunggu_suku_cadang': 'action_required',
        'selesai': 'completed',
        'ditolak': 'rejected',
      }[status]!;
  String get uiLabel => const {
        'draft': 'Draft',
        'pending': 'Pending',
        'ditinjau': 'Under Review',
        'diproses': 'In Progress',
        'menunggu_suku_cadang': 'Waiting for Parts',
        'selesai': 'Resolved',
        'ditolak': 'Rejected',
      }[status]!;
  bool get isFinal => status == 'selesai' || status == 'ditolak';
  String get tingkatLabel => const {'ringan': 'Low', 'sedang': 'Medium', 'berat': 'High'}[tingkat] ?? '-';
  String get judul {
    if (kategori.isEmpty) return 'Damage Report';
    final k = kategori.first;
    return kReportCategoryLabel[k] ?? k;
  }

  factory Report.fromMap(Map<String, dynamic> m) => Report(
        id: _int(m['id']),
        nomor: m['nomor_laporan'] as String,
        idRuangan: _int(m['id_ruangan']),
        idPelapor: m['id_pelapor'] as String,
        kategori: ((m['kategori_kerusakan'] as List?) ?? const []).cast<String>(),
        deskripsi: (m['deskripsi_masalah'] as String?) ?? '',
        tingkat: m['tingkat_kerusakan'] as String?,
        status: m['status'] as String,
        tanggal: _dt(m['tanggal_lapor'])!,
        namaRuangan: (m['nama_ruangan'] as String?) ?? '',
        kodeRuangan: (m['kode_ruangan'] as String?) ?? '',
        lokasi: m['lokasi'] as String?,
        departemen: m['departemen_ruangan'] as String?,
        namaPelapor: (m['nama_pelapor'] as String?) ?? '',
      );
}

const kReportCategoryLabel = {
  'ac': 'Air Conditioning',
  'proyektor': 'Projector',
  'pencahayaan': 'Lighting',
  'furnitur': 'Furniture',
  'listrik': 'Electricity',
  'jaringan': 'Network',
  'kebersihan': 'Cleanliness',
  'lainnya': 'Other',
};
const kReportCategoryIcon = {
  'ac': 'air-vent',
  'proyektor': 'projector',
  'pencahayaan': 'lightbulb',
  'furnitur': 'armchair',
  'listrik': 'zap',
  'jaringan': 'wifi',
  'kebersihan': 'sparkles',
  'lainnya': 'ellipsis',
};

class ReportMedia {
  ReportMedia({required this.id, this.idUpdate, required this.tipe, required this.path});
  final int id;
  final int? idUpdate;
  final String tipe, path;
  factory ReportMedia.fromMap(Map<String, dynamic> m) => ReportMedia(
        id: _int(m['id']),
        idUpdate: m['id_update'] == null ? null : _int(m['id_update']),
        tipe: m['tipe'] as String,
        path: m['path_berkas'] as String,
      );
}

class ReportUpdate {
  ReportUpdate({required this.id, required this.status, this.catatan, required this.waktu});
  final int id;
  final String status;
  final String? catatan;
  final DateTime waktu;
  factory ReportUpdate.fromMap(Map<String, dynamic> m) => ReportUpdate(
        id: _int(m['id']),
        status: m['status_baru'] as String,
        catatan: m['catatan_teknisi'] as String?,
        waktu: _dt(m['waktu'])!,
      );
}

class AppNotif {
  AppNotif({required this.id, required this.judul, required this.isi, required this.kategori, required this.tipe, this.idPeminjaman, this.idLaporan, required this.waktu, required this.sudahDibaca});
  final int id;
  final String judul, isi, kategori, tipe;
  final int? idPeminjaman, idLaporan;
  final DateTime waktu;
  final bool sudahDibaca;
  factory AppNotif.fromMap(Map<String, dynamic> m) => AppNotif(
        id: _int(m['id']),
        judul: m['judul'] as String,
        isi: m['isi'] as String,
        kategori: m['kategori'] as String,
        tipe: m['tipe'] as String,
        idPeminjaman: m['id_peminjaman'] == null ? null : _int(m['id_peminjaman']),
        idLaporan: m['id_laporan'] == null ? null : _int(m['id_laporan']),
        waktu: _dt(m['waktu'])!,
        sudahDibaca: m['sudah_dibaca'] as bool,
      );
}

class Conversation {
  Conversation({required this.id, required this.namaLawan, this.fotoLawan, this.responsMenit, this.pesanTerakhir, this.lampiranTerakhir, this.waktuTerakhir, required this.belumDibaca, this.idRuangan});
  final int id, belumDibaca;
  final String namaLawan;
  final String? fotoLawan, pesanTerakhir, lampiranTerakhir;
  final int? responsMenit, idRuangan;
  final DateTime? waktuTerakhir;
  String get preview => (pesanTerakhir != null && pesanTerakhir!.isNotEmpty) ? pesanTerakhir! : (lampiranTerakhir != null ? 'Sent an attachment' : 'No messages yet');
  factory Conversation.fromMap(Map<String, dynamic> m) => Conversation(
        id: _int(m['id']),
        namaLawan: (m['nama_lawan'] as String?) ?? '-',
        fotoLawan: m['foto_lawan'] as String?,
        responsMenit: m['respons_menit'] as int?,
        pesanTerakhir: m['pesan_terakhir'] as String?,
        lampiranTerakhir: m['lampiran_terakhir'] as String?,
        waktuTerakhir: _dt(m['waktu_pesan_terakhir']),
        belumDibaca: _int(m['belum_dibaca']),
        idRuangan: m['id_ruangan'] == null ? null : _int(m['id_ruangan']),
      );
}

class Message {
  Message({required this.id, required this.idPengirim, this.isi, this.lampiran, required this.waktu, required this.dibaca});
  final int id;
  final String idPengirim;
  final String? isi, lampiran;
  final DateTime waktu;
  final bool dibaca;
  factory Message.fromMap(Map<String, dynamic> m) => Message(
        id: _int(m['id']),
        idPengirim: m['id_pengirim'] as String,
        isi: m['isi_pesan'] as String?,
        lampiran: m['lampiran'] as String?,
        waktu: _dt(m['waktu_kirim'])!,
        dibaca: m['sudah_dibaca'] as bool,
      );
}
