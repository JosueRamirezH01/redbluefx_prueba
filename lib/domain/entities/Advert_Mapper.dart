import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';
import 'adverts.dart';

class AdvertMapper {
  static Advert fromRemoteMessage(RemoteMessage msg) {
    return Advert(
      id: msg.data['id'] ?? const Uuid().v4(), // fallback
      title: msg.notification?.title ?? 'Nuevo anuncio',
      content: msg.notification?.body ?? '',
      imageUrl: msg.data['imageUrl'],
      image: msg.data['image'] ?? msg.data['imageUrl'],
      isFeatured: true, // porque viene por push
      createdAt: DateTime.now(),
      createdBy: msg.data['createdBy'] ?? 'system',
    );
  }
}