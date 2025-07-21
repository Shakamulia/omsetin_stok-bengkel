import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:omzetin_bengkel/model/mekanik.dart';
import 'package:omzetin_bengkel/providers/mekanikProvider.dart';
import 'package:omzetin_bengkel/providers/securityProvider.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/pinModalWithAnimation.dart';
import 'package:omzetin_bengkel/utils/successAlert.dart';
import 'package:omzetin_bengkel/view/page/mekanik/add_mekanik.dart';
import 'package:omzetin_bengkel/view/widget/confirm_delete_dialog.dart';
import 'package:omzetin_bengkel/view/widget/pinModal.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CardMekanik extends StatefulWidget {
  final Mekanik mekanik;
  final VoidCallback onDeleted;

  const CardMekanik({
    super.key,
    required this.mekanik,
    required this.onDeleted,
  });

  @override
  State<CardMekanik> createState() => _CardMekanikState();
}

class _CardMekanikState extends State<CardMekanik> {
  @override
  Widget build(BuildContext context) {
    final securityProvider =
        Provider.of<SecurityProvider>(context, listen: false);
    final imageDecoration = _buildImageDecoration();

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      child: ZoomTapAnimation(
        onTap: () {
          if (securityProvider.kunciUpdatePegawai) {
            showPinModalWithAnimation(
              context,
              pinModal: PinModal(onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddPegawaiPage(pegawai: widget.mekanik),
                  ),
                );
              }),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPegawaiPage(pegawai: widget.mekanik),
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
                      image: DecorationImage(
                        image: AssetImage(widget.mekanik.profileImage),
                        fit: BoxFit.cover,
                      ),
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
                          widget.mekanik.namaMekanik,
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
                    Icon(Icons.work, size: 14, color: primaryColor),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.mekanik.spesialis,
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                if (widget.mekanik.namaMekanik != "Owner")
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {
                          if (securityProvider.kunciDeletePegawai) {
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
                        child: securityProvider.kunciDeletePegawai
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
      if (widget.mekanik.profileImage == null ||
          widget.mekanik.profileImage!.isEmpty) {
        return null;
      }

      if (widget.mekanik.profileImage!.startsWith('http') ||
          widget.mekanik.profileImage!.startsWith('https')) {
        return DecorationImage(
          image: NetworkImage(widget.mekanik.profileImage!),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => null,
        );
      } else {
        return DecorationImage(
          image: AssetImage(widget.mekanik.profileImage!),
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
        message: 'Yakin ingin menghapus Mekanik ${widget.mekanik.namaMekanik}?',
        onConfirm: () async {
          await Provider.of<MekanikProvider>(context, listen: false)
              .deletePegawai(widget.mekanik.id!);
          widget.onDeleted();
          Navigator.of(context).pop();
          showSuccessAlert(context, 'Mekanik berhasil dihapus');
        },
      ),
    );
  }
}
