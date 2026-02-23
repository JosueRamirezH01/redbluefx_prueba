import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:redbluefx/core/theme/app_theme_backup.dart';
import 'package:redbluefx/presentation/providers/notice_provider.dart';
import 'package:redbluefx/presentation/widgets/notice_card.dart';

class NoticeList extends ConsumerStatefulWidget {
  const NoticeList({super.key});

  @override
  ConsumerState<NoticeList> createState() => _NoticeListState();
}
class _NoticeListState extends ConsumerState<NoticeList> {

  @override
  Widget build(BuildContext context) {
    final noticeState = ref.watch(noticeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (noticeState.isLoading && noticeState.notices.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (noticeState.error != null && noticeState.notices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar las noticias',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(noticeProvider.notifier).loadNotices(refresh: true),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (noticeState.notices.isEmpty) {
      return FadeIn(
        duration: const Duration(milliseconds: 500),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/lupa.svg',
                width: 90,
                height: 90,

              ),
              const SizedBox(height: 16),
              Text(
                  'No se encontraron noticias',
                  style: isDark ?  AppTextStyles.titleLargeDark  : AppTextStyles.titleLarge
              ),
              const SizedBox(height: 12),
              Text(
                  'Intenta con otra categoria',
                  style: isDark ? AppTextStyles.bodyMediumDark : AppTextStyles.bodyMedium
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 12, right: 12, left: 12, top: 16),
      itemCount: noticeState.notices.length,
      itemBuilder: (context, index) {
        final notice = noticeState.notices[index];
        return SlideInDown(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: NoticeCard(
            notice: notice,
            onTap: () => context.push('/notice/${notice.id}'),
          ),
        );
      },
    );
  }
}