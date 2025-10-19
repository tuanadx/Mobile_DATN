import 'package:flutter/material.dart';
import 'package:feedia/core/services/pagination_service.dart';

class PaginationListView<T> extends StatefulWidget {
  final PaginationService<T> paginationService;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PaginationListView({
    Key? key,
    required this.paginationService,
    required this.itemBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.padding,
    this.scrollController,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  State<PaginationListView<T>> createState() => _PaginationListViewState<T>();
}

class _PaginationListViewState<T> extends State<PaginationListView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Load trang đầu tiên
    widget.paginationService.loadFirstPage();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !widget.paginationService.hasMoreData) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    await widget.paginationService.loadNextPage();
    
    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    await widget.paginationService.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: widget.paginationService.itemsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget();
        }

        final items = snapshot.data ?? [];
        
        if (items.isEmpty && !widget.paginationService.isLoading) {
          return _buildEmptyWidget();
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            padding: widget.padding,
            shrinkWrap: widget.shrinkWrap,
            physics: widget.physics,
            itemCount: items.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= items.length) {
                return _buildLoadingWidget();
              }
              
              return widget.itemBuilder(context, items[index], index);
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return widget.loadingWidget ?? 
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ?? 
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Có lỗi xảy ra',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              widget.paginationService.error ?? 'Không thể tải dữ liệu',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.paginationService.loadFirstPage(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
  }

  Widget _buildEmptyWidget() {
    return widget.emptyWidget ?? 
      const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có dữ liệu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy thử lại sau',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
  }
}
