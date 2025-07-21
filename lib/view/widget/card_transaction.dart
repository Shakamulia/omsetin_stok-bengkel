import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:omzetin_bengkel/model/product.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/not_enough_stock_alert.dart';

class CardTransaction extends StatefulWidget {
  final Product product;
  final int initialQuantity;
  final Function(int)? onQuantityChanged;
  final VoidCallback? onDelete;
  final Function(Product)? onEdit;
  final VoidCallback? onChange;

  const CardTransaction({
    super.key,
    required this.product,
    this.initialQuantity = 1,
    this.onQuantityChanged,
    this.onDelete,
    this.onEdit,
    this.onChange,
  });

  @override
  _CardTransactionState createState() => _CardTransactionState();
}

class _CardTransactionState extends State<CardTransaction> {
  late int quantity;
  late TextEditingController _quantityController;
  final FocusNode _quantityFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
    _quantityController = TextEditingController(text: quantity.toString());
    _quantityFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.removeListener(_handleFocusChange);
    _quantityFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_quantityFocusNode.hasFocus) {
      _updateQuantityFromText();
    }
  }

  void _updateQuantityFromText() {
    final newQuantity = int.tryParse(_quantityController.text) ?? 1;
    setState(() {
      if (newQuantity < 1) {
        quantity = 1;
      } else if (newQuantity > widget.product.productStock) {
        quantity = widget.product.productStock;
        showNotEnoughStock(context);
      } else {
        quantity = newQuantity;
      }
      _quantityController.text = quantity.toString();
      widget.onQuantityChanged?.call(quantity);
    });
  }

  void decrement() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        _quantityController.text = quantity.toString();
        widget.onQuantityChanged?.call(quantity);
      });
    }
  }

  void increment() {
    setState(() {
      quantity++;
      if (quantity > widget.product.productStock) {
        quantity = widget.product.productStock;
        showNotEnoughStock(context);
      }
      _quantityController.text = quantity.toString();
      widget.onQuantityChanged?.call(quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    double totalHarga = widget.product.productSellPrice.toDouble() * quantity;
    final formattedTotalHarga = formatter.format(totalHarga);
    final formattedHargaProduk =
        formatter.format(widget.product.productSellPrice.toDouble());

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.18,
        children: [
          CustomSlidableAction(
            onPressed: (_) => widget.onDelete?.call(),
            backgroundColor: Colors.transparent,
            autoClose: true,
            padding: EdgeInsets.zero,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.onChange,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(widget.product.productImage ?? ''),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/products/no-image.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '1 ${widget.product.productUnit} × $formattedHargaProduk',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedTotalHarga,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: greenColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: decrement,
                            child: const Icon(
                              Icons.remove,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 30,
                            child: TextField(
                              controller: _quantityController,
                              focusNode: _quantityFocusNode,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              onSubmitted: (value) => _updateQuantityFromText(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: increment,
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
