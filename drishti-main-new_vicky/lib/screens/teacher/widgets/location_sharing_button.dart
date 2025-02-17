import 'package:flutter/material.dart';

class LocationSharingButton extends StatelessWidget {
  final bool isLocationSharingEnabled;
  final VoidCallback onToggle;

  const LocationSharingButton({
    super.key,
    required this.isLocationSharingEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Location Sharing'),
        Expanded(child: Container()), // Spacer to push buttons to the right
        ElevatedButton(
          onPressed: onToggle,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isLocationSharingEnabled ? Colors.green : Colors.red,
          ),
          child: Text(isLocationSharingEnabled ? 'On' : 'Off'),
        ),
      ],
    );
  }
}
