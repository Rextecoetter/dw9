import 'package:dw9_delivery_app/app/pages/order/order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderController extends Cubit<OrderState> {
  OrderController() : super(const OrderState.initial());
}
