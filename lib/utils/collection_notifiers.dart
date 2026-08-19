import 'package:flutter/material.dart';

/// A custom notifier that notifies listeners when the contents of a [Set] change.
///
/// Unlike [ValueNotifier], which only triggers updates when the reference changes,
/// this class observes mutations within the [Set] itself (e.g. adding/removing items).
///
/// Currently tailored for [Set] use cases, but can be extended later to support
/// other [Iterable] types if needed.

class SetNotifier<T> extends ChangeNotifier {
  SetNotifier(Iterable<T> iterable) : _values = Set.from(iterable);
  final Set<T> _values;

  Set<T> get value => Set.unmodifiable(_values);

  int get length => _values.length;

  bool get isEmpty => _values.isEmpty;

  bool get isNotEmpty => _values.isNotEmpty;

  bool contains(T item) => _values.contains(item);

  void add(T item) {
    _values.add(item);
    notifyListeners();
  }

  void addAll(Iterable<T> items) {
    _values.addAll(items);
    notifyListeners();
  }

  void delete(T item) {
    _values.remove(item);
    notifyListeners();
  }

  void toggle(T item) {
    if (_values.contains(item)) {
      delete(item);
    } else {
      add(item);
    }
    notifyListeners();
  }

  void clear() {
    _values.clear();
    notifyListeners();
  }
}

class ListNotifier<T> extends ChangeNotifier {
  ListNotifier(Iterable<T> iterable) : _values = List.from(iterable);
  final List<T> _values;

  List<T> get value => List.unmodifiable(_values);

  List<T> get reversed => List.unmodifiable(_values.reversed);

  int get length => _values.length;

  bool get isEmpty => _values.isEmpty;

  bool get isNotEmpty => _values.isNotEmpty;

  T get first => _values.first;

  T get last => _values.last;

  T? get firstOrNull => _values.firstOrNull;

  T? get lastOrNull => _values.lastOrNull;

  bool contains(T item) => _values.contains(item);

  void add(T item) {
    _values.add(item);
    notifyListeners();
  }

  void addAll(Iterable<T> items) {
    _values.addAll(items);
    notifyListeners();
  }

  void removeAt(int index) {
    if (index >= 0 && index < _values.length) {
      _values.removeAt(index);
      notifyListeners();
    } else {
      throw RangeError.index(index, _values.length);
    }
  }

  void removeLast() {
    _values.removeLast();
    notifyListeners();
  }

  void clear() {
    _values.clear();
    notifyListeners();
  }

  void replaceAll(Iterable<T> items) {
    clear();
    addAll(items);
  }

  void replaceAt(int index, T item) {
    if (index >= 0 && index < _values.length) {
      _values[index] = item;
      notifyListeners();
    } else {
      throw RangeError.index(index, _values.length);
    }
  }

  T operator [](int index) {
    return _values[index];
  }
}

class MapNotifier<K, V> extends ChangeNotifier {
  MapNotifier([Map<K, V>? initial]) : _map = Map<K, V>.from(initial ?? {});

  final Map<K, V> _map;

  /// An unmodifiable view of the current map state.
  Map<K, V> get value => Map.unmodifiable(_map);

  int get length => _map.length;

  bool get isEmpty => _map.isEmpty;

  bool get isNotEmpty => _map.isNotEmpty;

  bool containsKey(K key) => _map.containsKey(key);

  V? operator [](K key) => _map[key];

  /// Adds or updates [key] with [value] and notifies listeners.
  void put(K key, V value) {
    _map[key] = value;
    notifyListeners();
  }

  /// Adds or updates all entries from [other] and notifies listeners.
  void putAll(Map<K, V> other) {
    _map.addAll(other);
    notifyListeners();
  }

  /// Removes [key] from the map and notifies listeners.
  /// Returns the removed value, or `null` if the key was not present.
  V? remove(K key) {
    final removed = _map.remove(key);
    if (removed != null) notifyListeners();
    return removed;
  }

  /// Clears all entries and notifies listeners.
  void clear() {
    if (_map.isEmpty) return;
    _map.clear();
    notifyListeners();
  }
}
