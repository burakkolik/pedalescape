/// Immutable triangle soup ready for the software renderer.
///
/// Storage is non-indexed: triangle i uses positions[i*9 .. i*9+8],
/// normals[i*3 .. i*3+2], colors[i] (ARGB) and flags[i].
library;

import 'dart:typed_data';

abstract final class MeshFlags {
  /// Ignores lighting and most fog (lamps, glowing rims, coins sparkle).
  static const int emissive = 1;

  /// Never back-face culled (thin planes like leaves, flags, signs).
  static const int doubleSided = 2;
}

class Mesh {
  Mesh({
    required this.positions,
    required this.normals,
    required this.colors,
    required this.flags,
    required this.radius,
  });

  final Float32List positions;
  final Float32List normals;
  final Int32List colors;
  final Uint8List flags;

  /// Bounding sphere radius around the local origin (for culling).
  final double radius;

  int get triangleCount => colors.length;

  static final Mesh empty = Mesh(
    positions: Float32List(0),
    normals: Float32List(0),
    colors: Int32List(0),
    flags: Uint8List(0),
    radius: 0,
  );
}
