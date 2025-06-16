class CashierProfile {
  final String id;
  final String name;
  final String imageUrl;

  CashierProfile({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

List<CashierProfile> cashierImage = [
  CashierProfile(
    id: '1',
    name: 'Cashier 1',
    imageUrl: 'assets/newProfiles/owner.png',
  ),
  CashierProfile(
    id: '2',
    name: 'Cashier 2',
    imageUrl: 'assets/newProfiles/owner2.png',
  ),
  CashierProfile(
    id: '3',
    name: 'Cashier 3',
    imageUrl: 'assets/newProfiles/kasir-1.png',
  ),
  CashierProfile(
    id: '4',
    name: 'Cashier 4',
    imageUrl: 'assets/newProfiles/kasir-2.png',
  ),
  CashierProfile(
    id: '5',
    name: 'Cashier 5',
    imageUrl: 'assets/newProfiles/kasir-3.png',
  ),
];
