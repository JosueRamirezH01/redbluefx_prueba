import '../entities/adverts.dart';

abstract class AdvertRepository {
  Future<Advert> createAdverts({
    required String title,
    required String content,
    String? image,
    required bool isPublic,
  });

  Future<List<Advert>> getAdverts({
    int page = 1,
    int limit = 20,
    String? search,
  });

}