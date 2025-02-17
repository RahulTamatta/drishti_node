import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NearbyUsersScreen extends StatefulWidget {
  const NearbyUsersScreen({Key? key}) : super(key: key);

  @override
  State<NearbyUsersScreen> createState() => _NearbyUsersScreenState();
}

class _NearbyUsersScreenState extends State<NearbyUsersScreen> {
  final ApiBloc _apiBloc = ApiBloc();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
      _getNearbyUsers();
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _getNearbyUsers() {
    if (_currentPosition != null) {
      _apiBloc.add(NearUser(add: {
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'maxDistance': 5000 // 5km radius
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Users')),
      body: BlocBuilder<ApiBloc, BlocState>(
        bloc: _apiBloc,
        builder: (context, state) {
          if (state is Loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is Loaded) {
            final users = state.data['data'] as List;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user['profileImage'] != null &&
                            user['profileImage'].isNotEmpty
                        ? NetworkImage(user['profileImage'])
                        : null,
                    child: user['profileImage'] == null ||
                            user['profileImage'].isEmpty
                        ? Text(user['name'][0].toUpperCase())
                        : null,
                  ),
                  title: Text(user['name'] ?? ''),
                  subtitle:
                      Text('${user['distance'].toStringAsFixed(2)} km away'),
                );
              },
            );
          } else if (state is Error) {
            return Center(child: Text(state.message ?? 'Error'));
          }
          return const Center(child: Text('No nearby users found'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
