import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

/// A tiny tileable grayscale "grain" texture that is multiplied onto the road
/// and grass mesh. It is built once with a handful of vertex-colored grids
/// (wrapped value noise) plus speckles, so it costs ~256 KB of GPU memory and
/// no image files.
class GroundTexture {
  GroundTexture._(this.image, this.mean);

  static const int size = 256;

  final ui.Image image;

  /// Average brightness of the texture (0..1); vertex colors are divided by it
  /// so the textured scene keeps the palette's overall brightness.
  final double mean;

  void dispose() => image.dispose();

  static GroundTexture build() {
    const n = size;
    final rnd = math.Random(1234);
    final rec = ui.PictureRecorder();
    final c = ui.Canvas(rec);
    c.drawRect(const ui.Rect.fromLTWH(0, 0, n + 0.0, n + 0.0), ui.Paint()..color = const ui.Color(0xffffffff));
    final mul = ui.Paint()..blendMode = ui.BlendMode.multiply;
    var mean = 1.0;

    // Octaves: (cells per side, darkest value). Small features are kept a few
    // texels wide so the texture does not shimmer when seen far away.
    for (final (cells, lo) in const [(4, 0.9), (16, 0.9), (48, 0.86), (96, 0.9)]) {
      final vals = Float64List(cells * cells);
      var sum = 0.0;
      for (var i = 0; i < vals.length; i++) {
        final v = lo + (1 - lo) * rnd.nextDouble();
        vals[i] = v;
        sum += v;
      }
      mean *= sum / vals.length;
      final cell = n / cells;
      final pos = Float32List(cells * cells * 8);
      final col = Int32List(cells * cells * 4);
      final idx = Uint16List(cells * cells * 6);
      var q = 0;
      int gray(int x, int y) {
        final v = (vals[(y % cells) * cells + (x % cells)] * 255).round();
        return 0xff000000 | (v << 16) | (v << 8) | v;
      }

      for (var y = 0; y < cells; y++) {
        for (var x = 0; x < cells; x++) {
          final p = q * 8, v = q * 4, k = q * 6;
          pos[p] = x * cell;
          pos[p + 1] = y * cell;
          pos[p + 2] = (x + 1) * cell;
          pos[p + 3] = y * cell;
          pos[p + 4] = (x + 1) * cell;
          pos[p + 5] = (y + 1) * cell;
          pos[p + 6] = x * cell;
          pos[p + 7] = (y + 1) * cell;
          col[v] = gray(x, y);
          col[v + 1] = gray(x + 1, y);
          col[v + 2] = gray(x + 1, y + 1);
          col[v + 3] = gray(x, y + 1);
          idx[k] = v;
          idx[k + 1] = v + 1;
          idx[k + 2] = v + 2;
          idx[k + 3] = v;
          idx[k + 4] = v + 2;
          idx[k + 5] = v + 3;
          q++;
        }
      }
      final vs = ui.Vertices.raw(ui.VertexMode.triangles, pos, colors: col, indices: idx);
      c.drawVertices(vs, ui.BlendMode.dst, mul);
      vs.dispose();
    }

    // Light and dark speckles (aggregate stones / grass seeds).
    final pts = Float32List(2 * 700);
    for (final (color, count) in const [(0x55ffffff, 700), (0x40000000, 500)]) {
      for (var i = 0; i < count; i++) {
        pts[i * 2] = rnd.nextDouble() * n;
        pts[i * 2 + 1] = rnd.nextDouble() * n;
      }
      c.drawRawPoints(
        ui.PointMode.points,
        Float32List.sublistView(pts, 0, count * 2),
        ui.Paint()
          ..color = ui.Color(color)
          ..strokeWidth = 2.2
          ..strokeCap = ui.StrokeCap.round,
      );
    }
    final pic = rec.endRecording();
    final img = pic.toImageSync(n, n);
    pic.dispose();
    return GroundTexture._(img, mean);
  }
}
