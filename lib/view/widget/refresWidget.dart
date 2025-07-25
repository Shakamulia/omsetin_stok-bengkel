import 'package:flutter/material.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class CustomRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onRefresh; // Callback untuk refresh

  const CustomRefreshWidget({
    super.key,
    required this.child,
    this.onRefresh,
  });

  @override
  _CustomRefreshWidgetState createState() => _CustomRefreshWidgetState();
}

class _CustomRefreshWidgetState extends State<CustomRefreshWidget> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!(); // Panggil fungsi onRefresh dari luar
    }
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // Tambahkan logika memuat data tambahan jika diperlukan
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: WaterDropMaterialHeader(
        backgroundColor: primaryColor,
        color: Colors.white,
      ),
      footer: ClassicFooter(
        loadingText: "Sedang memuat...",
        canLoadingText: "Lepaskan untuk memuat lebih banyak",
        failedText: "Gagal memuat!",
        noDataText: "Tidak ada data lagi",
        textStyle: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: widget.child,
    );
  }
}
