import '../../domain/entities/net_worth.dart';

abstract class NetWorthState {
  const NetWorthState();
}

class NetWorthInitial extends NetWorthState {
  const NetWorthInitial();
}

class NetWorthLoading extends NetWorthState {
  const NetWorthLoading();
}

class NetWorthLoaded extends NetWorthState {
  final NetWorthSummary summary;
  final NetWorthProjection? projection;
  final bool projectionLoading;

  const NetWorthLoaded(
    this.summary, {
    this.projection,
    this.projectionLoading = false,
  });

  NetWorthLoaded copyWith({
    NetWorthProjection? projection,
    bool? projectionLoading,
  }) =>
      NetWorthLoaded(
        summary,
        projection: projection ?? this.projection,
        projectionLoading: projectionLoading ?? this.projectionLoading,
      );
}

class NetWorthError extends NetWorthState {
  final String message;
  const NetWorthError(this.message);
}
