import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class IsolatedMapWidget extends StatefulWidget {
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Function(GoogleMapController) onMapCreated;
  final Function(CameraPosition)? onCameraMove;
  final bool myLocationEnabled;
  final String? mapStyle;

  const IsolatedMapWidget({
    super.key,
    required this.initialCameraPosition,
    required this.markers,
    required this.onMapCreated,
    this.onCameraMove,
    this.myLocationEnabled = true,
    this.mapStyle,
  });

  @override
  State<IsolatedMapWidget> createState() => _IsolatedMapWidgetState();
}

class _IsolatedMapWidgetState extends State<IsolatedMapWidget> 
    with AutomaticKeepAliveClientMixin {
  
  GoogleMapController? _controller;
  bool _isMapReady = false;
  
  // Use a static counter to ensure unique IDs across app lifecycle
  static int _mapIdCounter = 0;
  late final int _mapId;

  @override
  void initState() {
    super.initState();
    _mapId = _mapIdCounter++;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // Don't dispose the controller here as it's managed by Google Maps
    _controller = null;
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!mounted) return;
    
    setState(() {
      _controller = controller;
      _isMapReady = true;
    });
    
    // Apply map style if provided
    if (widget.mapStyle != null && _controller != null) {
      _controller!.setMapStyle(widget.mapStyle);
    }
    
    widget.onMapCreated(controller);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return GoogleMap(
      // Use a unique key based on the map ID
      key: Key('google_map_$_mapId'),
      onMapCreated: _onMapCreated,
      initialCameraPosition: widget.initialCameraPosition,
      onCameraMove: widget.onCameraMove,
      markers: widget.markers,
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
    );
  }
}