DateTime toIst(DateTime dt) {
  // Server timestamps are UTC; we force IST regardless of device timezone.
  return dt.toUtc().add(const Duration(hours: 5, minutes: 30));
}

String formatIst(DateTime? dt) {
  if (dt == null) return '—';
  final t = toIst(dt);
  final y = t.year.toString().padLeft(4, '0');
  final m = t.month.toString().padLeft(2, '0');
  final d = t.day.toString().padLeft(2, '0');
  final hh = t.hour.toString().padLeft(2, '0');
  final mm = t.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm IST';
}

