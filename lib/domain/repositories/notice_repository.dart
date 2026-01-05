
 import '../entities/notice.dart';

abstract class NoticeRepository {
   Future<List<Notice>> getNotice({
     int page = 1,
     int limit = 50,
     NoticeCategory? category,
     String? search,
   });

   Future<List<Notice>> filterNotice({
     int page = 1,
     int limit = 50,
     NoticeCategory? category,
   });
 }