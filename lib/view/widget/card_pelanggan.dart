import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:omsetin_bengkel/model/pelanggan.dart';
import 'package:omsetin_bengkel/providers/pelangganProvider.dart';
import 'package:omsetin_bengkel/providers/securityProvider.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/pinModalWithAnimation.dart';
import 'package:omsetin_bengkel/utils/successAlert.dart';
import 'package:omsetin_bengkel/view/page/pelanggan/add_pelanggan.dart';
import 'package:omsetin_bengkel/view/page/pelanggan/update_pelanggan.dart';
import 'package:omsetin_bengkel/view/widget/confirm_delete_dialog.dart';
import 'package:omsetin_bengkel/view/widget/pinModal.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CardPelanggan extends StatelessWidget {
  final Pelanggan pelanggan;
  final VoidCallback onDeleted;

  const CardPelanggan({
    required this.pelanggan,
    required this.onDeleted,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      child: ZoomTapAnimation(
        onTap: () {
          final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
          if (securityProvider.kunciUpdatePelanggan) {
            showPinModalWithAnimation(
              context,
              pinModal: PinModal(onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPelangganPage(pelanggan: pelanggan,),
                  ),
                );
              }),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPelangganPage(pelanggan: pelanggan,),
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
                      color: Colors.green,
                      image: _buildImageDecoration(),
                    ),
                  ),
                ),
                Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          pelanggan.namaPelanggan,
                          style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold),
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
                        pelanggan.noHandphone,
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Builder(
                      builder: (context) {
                        final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
                        return GestureDetector(
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
                          child: 
                          securityProvider.kunciDeletePelanggan
                          ? SizedBox.shrink()
                          : Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        );
                      },
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
      if (pelanggan.profileImage == null || pelanggan.profileImage!.isEmpty)
        return null;

      if (pelanggan.profileImage!.startsWith('http') ||
          pelanggan.profileImage!.startsWith('https')) {
        return DecorationImage(
          image: NetworkImage(pelanggan.profileImage!),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => null,
        );
      } else {
        return DecorationImage(
          image: AssetImage(pelanggan.profileImage!),
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
        message: 'Yakin ingin menghapus pegawai ${pelanggan.namaPelanggan}?',
        onConfirm: () async {
          final navigator = Navigator.of(context);
          await Provider.of<Pelangganprovider>(context, listen: false)
              .deletePelanggan(pelanggan.id!);
          onDeleted();
          navigator.pop();
          showSuccessAlert(context, 'Pelanggan berhasil dihapus');
        },
      ),
    );
  }
}