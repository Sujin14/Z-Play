import 'collection_kind_model.dart';

class CollectionArgs {
  const CollectionArgs({
    required this.kind,
    required this.id,
    required this.title,
  });

  final CollectionKind kind;
  final String id;
  final String title;
}
