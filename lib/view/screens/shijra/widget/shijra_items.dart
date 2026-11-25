class ShijraItem {
  final String titleKey;
  final String imagePath;

  const ShijraItem({required this.titleKey, required this.imagePath});
}

class ShijraItems {
  static const List<ShijraItem> all = [
    ShijraItem(
      titleKey: 'khilafati_shijra',
      imagePath: 'assets/icon/khilafati_sijrah.png',
    ),
    ShijraItem(
      titleKey: 'dua_shijra',
      imagePath: 'assets/icon/dua_sajramubarak.png',
    ),
    ShijraItem(
      titleKey: 'nasabi_shijra',
      imagePath: 'assets/icon/nasabi_sijrah.png',
    ),
  ];
}
