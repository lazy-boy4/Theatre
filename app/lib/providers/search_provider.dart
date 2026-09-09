import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/theatre_api.dart';

class SearchState {
  final String query;
  final AsyncValue<SearchPage> page;
  const SearchState({this.query = '', this.page = const AsyncValue.data(SearchPage(results: [], hasMore: false))});
  SearchState copyWith({String? query, AsyncValue<SearchPage>? page}) =>
      SearchState(query: query ?? this.query, page: page ?? this.page);
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() => const SearchState();

  Future<void> search(String query) async {
    if (query.trim().isEmpty) { state = const SearchState(); return; }
    state = state.copyWith(query: query, page: const AsyncValue.loading());
    state = state.copyWith(
      page: await AsyncValue.guard(() => TheatreApi.instance.search(query)),
    );
  }

  void clear() => state = const SearchState();
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
final searchQueryProvider = StateProvider<String>((ref) => '');
