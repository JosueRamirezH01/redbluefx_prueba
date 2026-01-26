import '../entities/adverts.dart';

abstract class AdvertRepository {
  Future<Advert> createAdverts({
    required String title,
    required String content,
    String? image,
    required bool isFeatured,
  });


  Future<List<Advert>> getAdverts({
    int page = 1,
    int limit = 20,
    String? search,
  });

  Future<List<Advert>> getAdvertsFeature({
    int page = 1,
    int limit = 20,
    String? search,
  });

  Future<List<Advert>> getAdvertsPublic({
    int page = 1,
    int limit = 20,
    String? search,
  });

  Future<void> deleteAdverts(String id);

}