import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tujuan item navbar mahasiswa.
void goStudentNav(BuildContext c, String key) {
  switch (key) {
    case 'home':
      c.go('/menu-utama');
    case 'rooms':
      c.go('/rooms');
    case 'qreport':
      c.go('/qreporting');
    case 'scheduled':
      c.go('/bookings');
    case 'profile':
      c.go('/profile');
  }
}

void goTuNav(BuildContext c, String key) {
  switch (key) {
    case 'dashboard':
      c.go('/menu-utama');
    case 'ratings':
      c.go('/tu/ratings');
    case 'profile':
      c.go('/profile');
  }
}

void goSarprasNav(BuildContext c, String key) {
  switch (key) {
    case 'dashboard':
      c.go('/menu-utama');
    case 'history':
      c.go('/sarpras/history');
    case 'profile':
      c.go('/profile');
  }
}

/// Kembali bila ada halaman sebelumnya, jika tidak ke [fallback].
void goBack(BuildContext c, [String fallback = '/menu-utama']) {
  if (c.canPop()) {
    c.pop();
  } else {
    c.go(fallback);
  }
}
