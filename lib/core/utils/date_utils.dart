import 'package:intl/intl.dart';

class AppDateUtils {
  // Zona horaria de Perú (GMT-5)
  //static const String _peruTimeZone = 'America/Lima';
  
  /// Formatea una fecha a zona horaria de Perú (GMT-5)
  /// y retorna en formato "dd/MM/yyyy HH:mm"
  static String formatToPeruTime(DateTime utcDate) {
    try {
      // Crear un DateTime en UTC si no lo es ya
      final DateTime utcDateTime = utcDate.isUtc ? utcDate : utcDate.toUtc();
      
      // Convertir a hora de Perú (GMT-5)
      final DateTime peruTime = utcDateTime.subtract(const Duration(hours: 5));
      
      // Formatear
      final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(peruTime);
    } catch (e) {
      // En caso de error, retornar fecha original formateada
      final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(utcDate);
    }
  }
  
  /// Formatea una fecha a zona horaria de Perú (GMT-5)
  /// y retorna solo la fecha en formato "dd/MM/yyyy"
  static String formatDateToPeruTime(DateTime utcDate) {
    try {
      // Crear un DateTime en UTC si no lo es ya
      final DateTime utcDateTime = utcDate.isUtc ? utcDate : utcDate.toUtc();
      
      // Convertir a hora de Perú (GMT-5)
      final DateTime peruTime = utcDateTime.subtract(const Duration(hours: 5));
      
      // Formatear solo fecha
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(peruTime);
    } catch (e) {
      // En caso de error, retornar fecha original formateada
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(utcDate);
    }
  }
  
  /// Formatea una fecha a zona horaria de Perú (GMT-5)
  /// y retorna solo la hora en formato "HH:mm"
  static String formatTimeToPeruTime(DateTime utcDate) {
    try {
      // Crear un DateTime en UTC si no lo es ya
      final DateTime utcDateTime = utcDate.isUtc ? utcDate : utcDate.toUtc();
      
      // Convertir a hora de Perú (GMT-5)
      final DateTime peruTime = utcDateTime.subtract(const Duration(hours: 5));
      
      // Formatear solo hora
      final DateFormat formatter = DateFormat('HH:mm');
      return formatter.format(peruTime);
    } catch (e) {
      // En caso de error, retornar hora original formateada
      final DateFormat formatter = DateFormat('HH:mm');
      return formatter.format(utcDate);
    }
  }
  
  /// Formatea una fecha con formato más legible para Perú
  /// Ej: "15 de Enero 2024, 3:30 PM"
  static String formatToReadablePeruTime(DateTime utcDate) {
    try {
      // Crear un DateTime en UTC si no lo es ya
      final DateTime utcDateTime = utcDate.isUtc ? utcDate : utcDate.toUtc();
      
      // Convertir a hora de Perú (GMT-5)
      final DateTime peruTime = utcDateTime.subtract(const Duration(hours: 5));
      
      // Formatear de manera legible
      final DateFormat formatter = DateFormat('dd \'de\' MMMM yyyy, h:mm a', 'es_ES');
      return formatter.format(peruTime);
    } catch (e) {
      // Fallback a formato simple
      return formatToPeruTime(utcDate);
    }
  }
  
  /// Convierte un string de fecha ISO a DateTime y lo formatea para Perú
  static String formatIsoStringToPeruTime(String isoString) {
    try {
      final DateTime dateTime = DateTime.parse(isoString);
      return formatToPeruTime(dateTime);
    } catch (e) {
      return isoString; // Retornar el string original si no se puede parsear
    }
  }
  
  /// Obtiene la fecha y hora actual en zona horaria de Perú
  static DateTime getNowInPeruTime() {
    final DateTime utcNow = DateTime.now().toUtc();
    return utcNow.subtract(const Duration(hours: 5));
  }
  
  /// Formatea la fecha actual en zona horaria de Perú
  static String getCurrentPeruTimeFormatted() {
    final DateTime peruNow = getNowInPeruTime();
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(peruNow);
  }
  
  /// Calcula tiempo relativo en zona horaria de Perú
  /// Ej: "hace 5 minutos", "hace 2 horas", "ayer"
  static String getRelativeTimeInPeru(DateTime utcDate) {
    try {
      final DateTime utcDateTime = utcDate.isUtc ? utcDate : utcDate.toUtc();
      final DateTime peruTime = utcDateTime.subtract(const Duration(hours: 5));
      final DateTime nowPeru = getNowInPeruTime();
      
      final Duration difference = nowPeru.difference(peruTime);
      
      if (difference.inMinutes < 1) {
        return 'ahora mismo';
      } else if (difference.inMinutes < 60) {
        return 'hace ${difference.inMinutes} minuto${difference.inMinutes != 1 ? 's' : ''}';
      } else if (difference.inHours < 24) {
        return 'hace ${difference.inHours} hora${difference.inHours != 1 ? 's' : ''}';
      } else if (difference.inDays < 7) {
        return 'hace ${difference.inDays} día${difference.inDays != 1 ? 's' : ''}';
      } else {
        // Para fechas más antiguas, mostrar fecha completa
        return formatToPeruTime(utcDate);
      }
    } catch (e) {
      return formatToPeruTime(utcDate);
    }
  }
}

/// Extensión para DateTime para facilitar el uso
extension DateTimePeruExtension on DateTime {
  /// Convierte el DateTime a formato de Perú
  String toPeruTimeString() => AppDateUtils.formatToPeruTime(this);
  
  /// Convierte el DateTime a solo fecha de Perú
  String toPeruDateString() => AppDateUtils.formatDateToPeruTime(this);
  
  /// Convierte el DateTime a solo hora de Perú
  String toPeruTimeOnly() => AppDateUtils.formatTimeToPeruTime(this);
  
  /// Convierte el DateTime a formato legible de Perú
  String toReadablePeruTime() => AppDateUtils.formatToReadablePeruTime(this);
  
  /// Obtiene tiempo relativo en zona horaria de Perú
  String toRelativePeruTime() => AppDateUtils.getRelativeTimeInPeru(this);
}