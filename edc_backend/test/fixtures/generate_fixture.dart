/// Run once to generate test/fixtures/ingredients.png
/// Usage: dart test/fixtures/generate_fixture.dart
///
/// Requires ImageMagick `convert` on PATH, which is available in the same
/// Linux CI environment that has tesseract-ocr installed.
/// On Windows dev machines this script is not needed — tests skip when
/// tesseract is absent.
import 'dart:io';

void main() async {
  final result = await Process.run('convert', [
    '-size', '400x60',
    'xc:white',
    '-font', 'DejaVu-Sans',
    '-pointsize', '20',
    '-fill', 'black',
    '-draw', 'text 10,40 "Water, Methylparaben, BHA, Fragrance"',
    'test/fixtures/ingredients.png',
  ]);
  if (result.exitCode != 0) {
    stderr.writeln('ImageMagick convert failed: ${result.stderr}');
    exit(1);
  }
  stdout.writeln('Generated test/fixtures/ingredients.png');
}
