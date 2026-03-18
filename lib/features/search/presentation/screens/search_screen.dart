import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/presentation/widgets/product_card.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

final _searchHistoryProvider =
    StateNotifierProvider<_SearchHistoryNotifier, List<String>>((ref) {
  return _SearchHistoryNotifier(ref.watch(localStorageProvider));
});

class _SearchHistoryNotifier extends StateNotifier<List<String>> {
  final LocalStorage _storage;
  _SearchHistoryNotifier(this._storage) : super([]) {
    _load();
  }
  void _load() {
    final list = _storage.getList(AppConstants.searchHistoryKey);
    if (list != null) state = list.cast<String>();
  }
  void add(String q) {
    if (q.isEmpty) return;
    final updated = [q, ...state.where((x) => x != q)]
        .take(AppConstants.searchHistoryLimit).toList();
    state = updated;
    _storage.setList(AppConstants.searchHistoryKey, updated);
  }
  void remove(String q) {
    state = state.where((x) => x != q).toList();
    _storage.setList(AppConstants.searchHistoryKey, state);
  }
  void clear() {
    state = [];
    _storage.remove(AppConstants.searchHistoryKey);
  }
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() { _controller.dispose(); _focusNode.dispose(); super.dispose(); }

  void _search(String q) {
    if (q.trim().isEmpty) return;
    ref.read(_searchQueryProvider.notifier).state = q.trim();
    ref.read(_searchHistoryProvider.notifier).add(q.trim());
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(_searchQueryProvider);
    final history = ref.watch(_searchHistoryProvider);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: AppStrings.searchProducts,
            border: InputBorder.none, enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none, filled: false,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.close, size: 18),
                    onPressed: () { _controller.clear();
                      ref.read(_searchQueryProvider.notifier).state = ''; })
                : null,
          ),
          onSubmitted: _search,
          textInputAction: TextInputAction.search,
          onChanged: (_) => setState(() {}),
        ),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.grey200)),
      ),
      body: query.isEmpty ? _buildSuggestions(history) : _buildResults(query),
    );
  }

  Widget _buildSuggestions(List<String> history) {
    final popular = ['Phones','Shoes','Clothes','Electronics','Food','Books'];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (history.isNotEmpty) ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(AppStrings.recentSearches, style: Theme.of(context).textTheme.titleSmall),
            TextButton(onPressed: () => ref.read(_searchHistoryProvider.notifier).clear(),
                child: const Text('Clear all', style: TextStyle(fontSize: 12))),
          ]),
          const SizedBox(height: 8),
          ...history.map((q) => ListTile(dense: true,
            leading: const Icon(Icons.history, size: 18, color: AppColors.grey400),
            title: Text(q, style: const TextStyle(fontSize: 14)),
            trailing: IconButton(icon: const Icon(Icons.close, size: 16),
                onPressed: () => ref.read(_searchHistoryProvider.notifier).remove(q)),
            onTap: () { _controller.text = q; _search(q); })),
          const Divider(height: 24),
        ],
        Text(AppStrings.popularSearches, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: popular.map((tag) =>
          GestureDetector(onTap: () { _controller.text = tag; _search(tag); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: AppColors.grey100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.grey200)),
              child: Text(tag, style: const TextStyle(fontSize: 13))))).toList()),
      ],
    );
  }

  Widget _buildResults(String query) {
    final res = ref.watch(filteredProductsProvider(ProductFilterParams(query: query)));
    return res.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (products) => products.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.search_off_rounded, size: 64, color: AppColors.grey300),
              const SizedBox(height: 16),
              Text(AppStrings.noResults, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text(AppStrings.noResultsDesc, style: TextStyle(color: AppColors.grey500)),
            ]))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
              itemCount: products.length,
              itemBuilder: (_, i) => ProductCard(product: products[i], width: double.infinity)),
    );
  }
}
