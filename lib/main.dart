import 'package:pks_13/api/api_service.dart';
import 'package:pks_13/api/cart_api.dart';
import 'package:pks_13/api/favorite_api.dart';
import 'package:pks_13/api/product_api.dart';
import 'package:pks_13/api/order_api.dart';
import 'package:pks_13/auth/auth_gate.dart';
import 'package:pks_13/cart_bloc/cart_event.dart';
import 'package:pks_13/favorite_bloc/favorite_event.dart';
import 'package:pks_13/product_bloc/product_event.dart';
import 'package:pks_13/order_bloc/order_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_bloc/cart_bloc.dart';
import 'product_bloc/product_bloc.dart';
import 'product_bloc/product_deletion_bloc.dart';
import 'favorite_bloc/favorite_bloc.dart';
import 'pages/cart_page.dart';
import 'pages/favorite_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_related/test_profile_page.dart';
import 'cubit/navigation_cubit.dart';

void main() async {

  await Supabase.initialize(
      url: 'https://szanrqyypefmzdfjoxpk.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6YW5ycXl5cGVmbXpkZmpveHBrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ0MDEyMTAsImV4cCI6MjA0OTk3NzIxMH0.8CIww5uHtmNQijOYHW8s0smdBGfq2oPj9IMtywwYtn4'
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavigationCubit()),
        BlocProvider(create: (context) => FavoriteBloc(
            favoriteApi: FavoriteApi(ApiService()))..add(LoadFavoritesEvent(0)),
        ),
        BlocProvider(create: (context) => CartBloc(cartApi: CartApi(ApiService()))..add(LoadCartEvent(0))
        ),
        BlocProvider(create: (context) => ProductBloc(
            productApi: ProductApi(ApiService()))..add(LoadProductsEvent()),
        ),
        BlocProvider(create: (context) => ProductDeletionBloc(
          productBloc: context.read<ProductBloc>(),
          favoriteBloc: context.read<FavoriteBloc>(),
          cartBloc: context.read<CartBloc>(),
        )),
        BlocProvider(create: (context) => OrderBloc(
          OrderApi(ApiService()),
          ProductApi(ApiService()),
        )),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(),
      FavoritePage(
        productApi: ProductApi(ApiService()),
      ),
      CartPage(
        productApi: ProductApi(ApiService()),
      ),
      AuthGate(),
     //TestProfilePage()
    ];

    return BlocBuilder<NavigationCubit, int>(
      builder: (context, selectedIndex) {
        return Scaffold(
          body: _pages[selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Главная',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Избранное',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Корзина',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Профиль',
              ),
            ],
            currentIndex: selectedIndex,
            selectedItemColor: const Color(0xFF504BFF),
            unselectedItemColor: Colors.grey,
            onTap: (index) => context.read<NavigationCubit>().setPage(index),
          ),
        );
      },
    );
  }
}
