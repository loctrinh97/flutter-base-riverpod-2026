import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A base widget that wires a Riverpod provider to a builder.
///
/// [S] — the state type produced by the provider.
///
/// The [builder] receives [WidgetRef] so you can read the ViewModel notifier
/// directly (e.g. `ref.read(loginViewModelProvider.notifier)`).
/// This works with both regular and `.autoDispose` providers.
///
/// Usage:
/// ```dart
/// BaseView<LoginState>(
///   provider: loginViewModelProvider,
///   onInit: (ref) => ref.read(loginViewModelProvider.notifier).init(),
///   builder: (context, ref, state) {
///     final vm = ref.read(loginViewModelProvider.notifier);
///     return MyWidget(vm: vm, state: state);
///   },
/// )
/// ```
class BaseView<S> extends ConsumerStatefulWidget {
  const BaseView({
    super.key,
    required this.provider,
    required this.builder,
    this.onInit,
  });

  final ProviderListenable<S> provider;
  final Widget Function(BuildContext context, WidgetRef ref, S state) builder;
  final void Function(WidgetRef ref)? onInit;

  @override
  ConsumerState<BaseView<S>> createState() => _BaseViewState<S>();
}

class _BaseViewState<S> extends ConsumerState<BaseView<S>> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onInit?.call(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);
    return widget.builder(context, ref, state);
  }
}
