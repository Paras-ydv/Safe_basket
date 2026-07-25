/// Which capture flow the Scanning screen is running. Both `/scan/barcode` and
/// `/scan/label` render the same screen, parameterised by this
/// (docs/flutter_app_architecture.md §5.3).
enum ScanMode {
  /// Live barcode scan — synchronous lookup (`POST /scan/barcode`).
  barcode,

  /// Label / ingredients photo — asynchronous OCR job (`POST /scan/image`
  /// then poll).
  label;

  String get title => switch (this) {
    ScanMode.barcode => 'Scan Barcode',
    ScanMode.label => 'Scan Label',
  };

  String get tip => switch (this) {
    ScanMode.barcode => 'Center the barcode inside the frame to scan.',
    ScanMode.label => 'Fit the ingredients label in the frame, then capture.',
  };
}
