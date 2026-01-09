import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showFeedbackDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _FeedbackDialog(),
  );
}

class _FeedbackDialog extends StatefulWidget {
  const _FeedbackDialog();

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  int selectedIndex = 4;
  bool allowContact = true;
  final TextEditingController controller = TextEditingController();

  final List<Map<String, String>> ratings = [
    {'emoji': '😞', 'label': 'Malo'},
    {'emoji': '😕', 'label': 'Regular'},
    {'emoji': '😐', 'label': 'Normal'},
    {'emoji': '🙂', 'label': 'Bueno'},
    {'emoji': '😁', 'label': 'Excelente'},
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF0F4479) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      contentPadding: const EdgeInsets.all(12),
      content: SizedBox(
        width: width > 400 ? 360 : width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  const Icon(Icons.star_border, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ayúdanos a mejorar',
                      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '¿Cómo calificarías tu experiencia?',
                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 12),

              // EMOJIS
              Row(
                children: List.generate(ratings.length, (index) {
                  final isSelected = index == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF236399) : const Color(0xFF61C6FF))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              ratings[index]['emoji']!,
                              style: const TextStyle(fontSize: 26),
                            ),
                            Text(
                                ratings[index]['label']!,
                                style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w400)

                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              // TEXTAREA
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '¿Qué podemos mejorar?',
                  hintStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w400, fontSize: 14),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // CHECKBOX
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => allowContact = !allowContact),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: const Color(0xFFC3C3C3),
                          width: 1.2,
                        ),
                      ),
                      child: allowContact
                          ? const Center(
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: Color(0xFF1798E0),
                        ),
                      )
                          : null,
                    ),
                  ),

                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pueden contactarme para más información sobre este feedback',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // BOTONES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF0F4479) : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isDark ?  const Color(0xFF6984A0) :  const Color(0xFF414651))
                          ),
                        ),
                        child: Text(
                            "Cancelar",
                            style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)
                        ),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF1B21),
                              Color(0xFFDD0E13),
                              Color(0xFFBB0004),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow:  [
                            if(!isDark)
                           const BoxShadow(
                                color: Color(0xFFED7053),
                                blurRadius: 16,      // intensidad
                                offset: Offset(2, 8) // altura
                            ),
                            if(isDark)
                              const BoxShadow(
                                  color: Color(0xFF673559),
                                  blurRadius: 16,      // intensidad
                                  offset: Offset(2, 8) // altura
                              ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                              "Enviar Opinion",
                              style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

            ],
          ),
        ),
      ),
    );
  }

}
