class ReceiptTemplate {
  final String type;
  final String image;
  final String papperSize;
  final String typeText;

  ReceiptTemplate({
    required this.type,
    required this.typeText,
    required this.papperSize,
    required this.image,
  });
}

List<ReceiptTemplate> itemTemplate = [
  ReceiptTemplate(
      type: "default",
      typeText: "Default",
      papperSize: "58",
      image: "assets/images/struk-default.png"),
  ReceiptTemplate(
      type: "tanpaAntrian",
      typeText: "Tanpa Antrian",
      papperSize: "58",
      image: "assets/images/struk-tanpaAntrian.png"),
  ReceiptTemplate(
      type: "default",
      typeText: "Default",
      papperSize: "80",
      image: "assets/images/struk-default.png"),
  ReceiptTemplate(
      type: "tanpaAntrian",
      typeText: "Tanpa Antrian",
      papperSize: "80",
      image: "assets/images/struk-tanpaAntrian.png")
];
