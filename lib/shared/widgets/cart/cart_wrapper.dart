import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/cart/presentation/bloc/cart_bloc.dart';
import 'cart_bottom_bar.dart';

class CartWrapper extends StatefulWidget {
  final Widget child;
  final bool showCartButton;

  const CartWrapper({
    super.key,
    required this.child,
    this.showCartButton = true,
  });

  @override
  State<CartWrapper> createState() => _CartWrapperState();
}

class _CartWrapperState extends State<CartWrapper> {
  @override
  void initState() {
    super.initState();
    // Load cart when wrapper is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartBloc>().add(CartLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          widget.child,
          // Cart bottom bar
          if (widget.showCartButton)
            const CartBottomBar(),
        ],
      ),
    );
  }
}