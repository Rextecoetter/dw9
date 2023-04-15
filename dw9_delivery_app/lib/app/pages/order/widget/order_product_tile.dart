import 'package:dw9_delivery_app/app/core/extensions/formarter_extension.dart';
import 'package:dw9_delivery_app/app/core/ui/styles/colors_app.dart';
import 'package:dw9_delivery_app/app/core/ui/styles/text_styles.dart';
import 'package:dw9_delivery_app/app/core/ui/widgets/delivery_increment_decrement_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dw9_delivery_app/app/dto/order_product_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../order_controller.dart';

class OrderProductTile extends StatelessWidget {
  final int orderIndex;
  final OrderProductDto orderProduct;

  const OrderProductTile({
    super.key,
    required this.orderIndex,
    required this.orderProduct,
  });

  @override
  Widget build(BuildContext context) {
    final product = orderProduct.product;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Image.network(
            product.image,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: context.textStyles.textRegular.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (orderProduct.amount * product.price).currencyPTBR,
                        style: context.textStyles.textMedium.copyWith(
                          fontSize: 14,
                          color: context.colors.secondary,
                        ),
                      ),
                      DeliveryIncrementDecrementButton.compact(
                        amount: orderProduct.amount,
                        incrementTap: () {
                          context.read<OrderController>().incremetProduct(orderIndex);
                        },
                        decrementTap: () {
                          context.read<OrderController>().decremetProduct(orderIndex);
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
