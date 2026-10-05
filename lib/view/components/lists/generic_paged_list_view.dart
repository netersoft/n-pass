// generic_paged_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../themes/app_theme.dart';
import '../misc/status.dart';

class GenericPagedListView<T> extends StatelessWidget {
  final PagingController<int, T> pagingController;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget? firstPageProgressIndicatorBuilder;
  final Widget? newPageProgressIndicatorBuilder;

  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  const GenericPagedListView({
    required this.pagingController,
    required this.itemBuilder,
    super.key,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.shrinkWrap = true,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) => PagingListener(
    controller: pagingController,
    builder: (context, state, fetchNextPage) => PagedListView<int, T>(
      shrinkWrap: shrinkWrap,
      padding: padding ?? EdgeInsets.zero,
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate<T>(
        itemBuilder: itemBuilder,
        firstPageProgressIndicatorBuilder: (ctx) => firstPageProgressIndicatorBuilder ?? const SizedBox.shrink(),
        newPageProgressIndicatorBuilder: (ctx) => newPageProgressIndicatorBuilder ?? const SizedBox.shrink(),
        noItemsFoundIndicatorBuilder: (ctx) => noItemsWidget(),
        firstPageErrorIndicatorBuilder: (ctx) => errorWidget(context),
        newPageErrorIndicatorBuilder: (ctx) => const SizedBox.shrink(),
      ),
    ),
  );

  Widget noItemsWidget() => Center(
    child: Status(
      iconWidget: SizedBox(
        height: 300,
        child: SvgPicture.asset('assets/images/no_data_1.svg'),
      ),
      text: t.noItemFound,
    ),
  );

  Widget errorWidget(BuildContext context) => Container(
    margin: EdgeInsets.only(top: context.screenHeight * 0.2),
    child: Status(
      title: context.t.anErrorOccurred,
      icon: Icons.error_outlined,
      text: context.t.unableToRetrieveData,
      footerWidget: Padding(
        padding: const EdgeInsets.only(top: 25),
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${context.t.loading}...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            pagingController.refresh();
          },
          icon: const Icon(Icons.refresh),
          label: Text(context.t.retry),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: const StadiumBorder(),
          ),
        ),
      ),
    ),
  );
}
