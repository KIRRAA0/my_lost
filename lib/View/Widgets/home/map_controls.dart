import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/Utils/app_colors.dart';
import '../../../logic/cubits/home/home_cubit.dart';
import '../../../logic/cubits/home/home_state.dart';

class MapControls extends StatelessWidget {
  final GoogleMapController? mapController;
  final VoidCallback onLocationTap;

  const MapControls({
    super.key,
    this.mapController,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final currentZoom = state is HomeLoaded ? state.currentZoom : 12.0;
        final showControls = state is HomeLoaded ? state.showMapControls : true;
        
        return AnimatedOpacity(
          opacity: showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.darkSurfaceColor.withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zoom Level Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    '${currentZoom.toInt()}x',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightPrimaryColor,
                    ),
                  ),
                ),
                
                Container(
                  height: 1,
                  width: 32,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                
                // Zoom In Button
                _buildMapControlButton(
                  icon: Icons.add_rounded,
                  onTap: () => _zoomIn(context),
                  enabled: currentZoom < 20.0,
                  isDarkMode: isDarkMode,
                ),
                
                // Zoom Out Button
                _buildMapControlButton(
                  icon: Icons.remove_rounded,
                  onTap: () => _zoomOut(context),
                  enabled: currentZoom > 3.0,
                  isDarkMode: isDarkMode,
                ),
                
                Container(
                  height: 1,
                  width: 32,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                
                // Current Location Button
                _buildMapControlButton(
                  icon: Icons.my_location_rounded,
                  onTap: onLocationTap,
                  enabled: true,
                  isPrimary: true,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
    required bool isDarkMode,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isPrimary
                ? AppColors.lightPrimaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isPrimary
                ? Colors.white
                : enabled
                    ? (isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                    : (isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            size: 22,
          ),
        ),
      ),
    );
  }

  void _zoomIn(BuildContext context) {
    final state = context.read<HomeCubit>().state;
    if (state is HomeLoaded && state.currentZoom < 20.0 && mapController != null) {
      final newZoom = state.currentZoom + 1;
      context.read<HomeCubit>().updateZoom(newZoom);
      mapController!.animateCamera(CameraUpdate.zoomTo(newZoom));
    }
  }

  void _zoomOut(BuildContext context) {
    final state = context.read<HomeCubit>().state;
    if (state is HomeLoaded && state.currentZoom > 3.0 && mapController != null) {
      final newZoom = state.currentZoom - 1;
      context.read<HomeCubit>().updateZoom(newZoom);
      mapController!.animateCamera(CameraUpdate.zoomTo(newZoom));
    }
  }
}
