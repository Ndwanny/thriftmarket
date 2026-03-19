import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/presentation/screens/checkout_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_room_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/orders/presentation/screens/track_order_screen.dart';
import '../../features/products/presentation/screens/product_details_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/addresses_screen.dart';
import '../../features/profile/presentation/screens/wishlist_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/vendor/presentation/screens/vendor_dashboard_screen.dart';
import '../../features/vendor/presentation/screens/vendor_registration_screen.dart';
import '../../features/vendor/presentation/screens/vendor_store_screen.dart';
import '../../features/vendor/presentation/screens/vendors_screen.dart';
import '../../features/vendor/presentation/screens/add_product_screen.dart';
import '../widgets/main_scaffold.dart';
import 'route_names.dart';

CustomTransitionPage<void> _fadeSlidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isOnboarding = state.matchedLocation == RouteNames.onboarding;
      final isSplash = state.matchedLocation == RouteNames.splash;
      final isAuthRoute = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register ||
          state.matchedLocation == RouteNames.forgotPassword;

      if (isSplash) return null;
      if (isOnboarding) return null;
      if (!isLoggedIn && !isAuthRoute) return RouteNames.login;
      if (isLoggedIn && isAuthRoute) return RouteNames.home;
      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: RouteNames.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth routes
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main app shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            name: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.search,
            name: RouteNames.search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: RouteNames.cart,
            name: RouteNames.cart,
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: RouteNames.orders,
            name: RouteNames.orders,
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Products
      GoRoute(
        path: '${RouteNames.productList}/:categoryId',
        name: RouteNames.productList,
        pageBuilder: (context, state) => _fadeSlidePage(
          ProductListScreen(
            categoryId: state.pathParameters['categoryId'] ?? '',
            categoryName: state.uri.queryParameters['name'] ?? 'Products',
          ),
          state,
        ),
      ),
      GoRoute(
        path: '${RouteNames.productDetails}/:productId',
        name: RouteNames.productDetails,
        pageBuilder: (context, state) => _fadeSlidePage(
          ProductDetailsScreen(
            productId: state.pathParameters['productId'] ?? '',
          ),
          state,
        ),
      ),

      // Checkout
      GoRoute(
        path: RouteNames.checkout,
        name: RouteNames.checkout,
        pageBuilder: (context, state) =>
            _fadeSlidePage(const CheckoutScreen(), state),
      ),

      // Order details & tracking
      GoRoute(
        path: '${RouteNames.orderDetails}/:orderId',
        name: RouteNames.orderDetails,
        pageBuilder: (context, state) => _fadeSlidePage(
          OrderDetailsScreen(
            orderId: state.pathParameters['orderId'] ?? '',
          ),
          state,
        ),
      ),
      GoRoute(
        path: '${RouteNames.trackOrder}/:orderId',
        name: RouteNames.trackOrder,
        pageBuilder: (context, state) => _fadeSlidePage(
          TrackOrderScreen(
            orderId: state.pathParameters['orderId'] ?? '',
          ),
          state,
        ),
      ),

      // Vendors list
      GoRoute(
        path: RouteNames.vendors,
        name: RouteNames.vendors,
        pageBuilder: (context, state) =>
            _fadeSlidePage(const VendorsScreen(), state),
      ),

      // Vendor
      GoRoute(
        path: '${RouteNames.vendorStore}/:vendorId',
        name: RouteNames.vendorStore,
        pageBuilder: (context, state) => _fadeSlidePage(
          VendorStoreScreen(
            vendorId: state.pathParameters['vendorId'] ?? '',
          ),
          state,
        ),
      ),
      GoRoute(
        path: RouteNames.vendorDashboard,
        name: RouteNames.vendorDashboard,
        builder: (context, state) => const VendorDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.vendorRegistration,
        name: RouteNames.vendorRegistration,
        builder: (context, state) => const VendorRegistrationScreen(),
      ),
      GoRoute(
        path: RouteNames.addProduct,
        name: RouteNames.addProduct,
        builder: (context, state) => const AddProductScreen(),
      ),

      // Profile sub-routes
      GoRoute(
        path: RouteNames.editProfile,
        name: RouteNames.editProfile,
        pageBuilder: (context, state) =>
            _fadeSlidePage(const EditProfileScreen(), state),
      ),
      GoRoute(
        path: RouteNames.settings,
        name: RouteNames.settings,
        pageBuilder: (context, state) =>
            _fadeSlidePage(const SettingsScreen(), state),
      ),
      GoRoute(
        path: RouteNames.addresses,
        name: RouteNames.addresses,
        pageBuilder: (context, state) =>
            _fadeSlidePage(const AddressesScreen(), state),
      ),
      GoRoute(
        path: RouteNames.wishlist,
        name: RouteNames.wishlist,
        pageBuilder: (context, state) =>
            _fadeSlidePage(const WishlistScreen(), state),
      ),

      // Notifications
      GoRoute(
        path: RouteNames.notifications,
        name: RouteNames.notifications,
        pageBuilder: (context, state) =>
            _fadeSlidePage(const NotificationsScreen(), state),
      ),

      // Chat
      GoRoute(
        path: RouteNames.chatList,
        name: RouteNames.chatList,
        pageBuilder: (context, state) =>
            _fadeSlidePage(const ChatListScreen(), state),
      ),
      GoRoute(
        path: '${RouteNames.chatRoom}/:chatId',
        name: RouteNames.chatRoom,
        pageBuilder: (context, state) => _fadeSlidePage(
          ChatRoomScreen(
            chatId: state.pathParameters['chatId'] ?? '',
            vendorName: state.uri.queryParameters['vendorName'] ?? '',
          ),
          state,
        ),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
