abstract class RepositoryInterface<T> {
  Future<dynamic> add(T item);
  Future<dynamic> getList({int? offset});
  Future<dynamic> get(String id);
  Future<dynamic> update(Map<String, dynamic> body, String id);
  Future<dynamic> delete(String id);
}
