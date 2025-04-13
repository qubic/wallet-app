import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CustomPagedListView<int, T> extends StatelessWidget {
  final PagingController<int, T> pagingController;
  final IndexedWidgetBuilder separatorBuilder;
  final ItemWidgetBuilder<T> itemBuilder;
  final WidgetBuilder? firstPageProgressIndicatorBuilder;
  final WidgetBuilder? firstPageErrorIndicatorBuilder;
  final WidgetBuilder? noItemsFoundIndicatorBuilder;
  final EdgeInsetsGeometry? padding;
  final double? cacheExtent;

  const CustomPagedListView({
    super.key,
    required this.pagingController,
    required this.separatorBuilder,
    required this.itemBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.padding,
    this.cacheExtent,
  });

  @override
  Widget build(BuildContext context) {
    return PagingListener<int, T>(
        controller: pagingController,
        builder: (context, state, fetchNextPage) {
          return PagedListView<int, T>.separated(
            padding: padding,
            state: state,
            cacheExtent: cacheExtent,
            separatorBuilder: separatorBuilder,
            builderDelegate: PagedChildBuilderDelegate<T>(
                itemBuilder: itemBuilder,
                firstPageErrorIndicatorBuilder: firstPageErrorIndicatorBuilder,
                noItemsFoundIndicatorBuilder: noItemsFoundIndicatorBuilder,
                firstPageProgressIndicatorBuilder:
                    firstPageProgressIndicatorBuilder),
            fetchNextPage: fetchNextPage,
          );
        });
  }
}

int? customNextPage<I extends int, T>(PagingState<I, T> state, int? pageSize) {
  final keys = state.keys;
  final pages = state.pages;
  if (keys == null) return 1;
  if (pages != null && pages.last.length < (pageSize ?? 10)) {
    return null;
  }
  return keys.last + 1;
}
