import 'dart:ui';

class Recognition {
  late final String name;
  final Rect location;
  final List<double> embeddings;
  final double distance;

  Recognition(this.name, this.location, this.embeddings, this.distance);
}
