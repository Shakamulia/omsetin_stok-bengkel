import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:omzetin_bengkel/model/pelanggan.dart';
import 'package:omzetin_bengkel/providers/pelangganProvider.dart';
import 'package:omzetin_bengkel/providers/securityProvider.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/pinModalWithAnimation.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/view/page/pelanggan/add_pelanggan.dart';
import 'package:omzetin_bengkel/view/page/pelanggan/update_pelanggan.dart';
import 'package:omzetin_bengkel/view/widget/confirm_delete_dialog.dart';
import 'package:omzetin_bengkel/view/widget/pinModal.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CardPelanggan extends StatefulWidget {
  final Pelanggan pelanggan;
  final VoidCallback onDeleted;

  const CardPelanggan({
    super.key,
    required this.pelanggan,
    required this.onDeleted,
  });

  @override
  State<CardPelanggan> createState() => _CardPelangganState();
}

class _CardPelangganState extends State<CardPelanggan> {
  @override
  Widget build(BuildContext context) {
    final securityProvider =
        Provider.of<SecurityProvider>(context, listen: false);
    final imageDecoration = _buildImageDecoration();

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      child: ZoomTapAnimation(
        onTap: () {
          if (securityProvider.kunciUpdatePelanggan) {
            showPinModalWithAnimation(
              context,
              pinModal: PinModal(onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddPelangganPage(pelanggan: widget.pelanggan),
                  ),
                );
              }),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddPelangganPage(pelanggan: widget.pelanggan),
              ),
            );
          }
        },
        child: Card(
          elevation: 0,
          color: cardColor,
          margin: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 221, 227, 224),
                      image: imageDecoration,
                    ),
                    child: imageDecoration == null
                        ? Icon(Icons.person, size: 40, color: Colors.blueGrey)
                        : null,
                  ),
                ),
                Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.pelanggan.namaPelanggan,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, size: 14, color: primaryColor),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.pelanggan.noHandphone,
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                if (widget.pelanggan.namaPelanggan != "Owner")
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {
                          if (securityProvider.kunciDeletePelanggan) {
                            showPinModalWithAnimation(
                              context,
                              pinModal: PinModal(onTap: () {
                                _showDeleteDialog(context);
                              }),
                            );
                          } else {
                            _showDeleteDialog(context);
                          }
                        },
                        child: securityProvider.kunciDeletePelanggan
                            ? SizedBox.shrink()
                            : Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Hapus",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DecorationImage? _buildImageDecoration() {
    try {
      if (widget.pelanggan.profileImage == null ||
          widget.pelanggan.profileImage!.isEmpty) {
        return null;
      }

      if (widget.pelanggan.profileImage!.startsWith('http') ||
          widget.pelanggan.profileImage!.startsWith('https')) {
        return DecorationImage(
          image: NetworkImage(widget.pelanggan.profileImage!),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => null,
        );
      } else {
        return DecorationImage(
          image: AssetImage(widget.pelanggan.profileImage!),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => null,
        );
      }
    } catch (e) {
      return null;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        message:
            'Yakin ingin menghapus Pelanggan ${widget.pelanggan.namaPelanggan}?',
        onConfirm: () async {
          await Provider.of<Pelangganprovider>(context, listen: false)
              .deletePelanggan(widget.pelanggan.id!);
          widget.onDeleted();
          Navigator.of(context).pop();
          showSuccessAlert(context, 'Pelanggan berhasil dihapus');
        },
      ),
    );
  }
}
