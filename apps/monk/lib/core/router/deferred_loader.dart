import 'package:flutter/material.dart';
import '../widgets/im_skeleton.dart';

typedef LibraryLoader = Future<dynamic> Function();
typedef WidgetBuilder = Widget Function();

/// Deferred loading wrapper for Flutter Web code-splitting.
/// Dynamically loads route JS chunks on demand while showing a skeleton fallback.
class DeferredLoader extends StatefulWidget {
  const DeferredLoader({
    super.key,
    required this.loader,
    required this.builder,
  });

  final LibraryLoader loader;
  final WidgetBuilder builder;

  @override
  State<DeferredLoader> createState() => _DeferredLoaderState();
}

class _DeferredLoaderState extends State<DeferredLoader> {
  bool _isLoaded = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    try {
      await widget.loader();
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load screen module: $_error'),
            ],
          ),
        ),
      );
    }

    if (!_isLoaded) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: ImSkeleton(height: 300, width: double.infinity),
          ),
        ),
      );
    }

    return widget.builder();
  }
}
