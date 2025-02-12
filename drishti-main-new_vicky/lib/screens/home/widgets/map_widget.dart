import 'package:srisridrishti/bloc/all_event_bloc/all_event_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:srisridrishti/models/near_events.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/utils/utill.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../providers/course_list_provder.dart';

class EventMap extends StatefulWidget {
  final dynamic bottomType;
  final String userID;
  const EventMap({super.key, required this.bottomType, required this.userID});

  @override
  State<EventMap> createState() => _EventMapState();
}

class _EventMapState extends State<EventMap> {
  LatLng? middlePointOfScreenOnMap;

  String? map_theme;

  LatLng? currentPosition;

  late GoogleMapController mapController;

  DateTime selectedMonth = DateTime.now();

  bool isSelected = false;

  var scaffoldkey = GlobalKey<ScaffoldState>();

  Set<Marker> markers = {};
  //flutter bloc for hiting api
  ApiBloc apiBloc = ApiBloc();
  late Position position;

  data({radius}) async {
    position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
    apiBloc.add(widget.bottomType == 1
        ? NearUser(add: {
            "longitude": position.longitude,
            "latitude": position.latitude,
            "radius": 1000
          })
        : NearEvent(add: {
            "longitude": position.longitude,
            "latitude": position.latitude,
            "maxDistance": radius ?? 1000
          }));
    // );
  }

  double radius = 400000;
  int zoomLevel = 3;
  void _onCameraMove(CameraPosition position) {
    try {
      double zoomvalue = position.zoom;
      int intZoomLevel = zoomvalue.toInt();
      if (intZoomLevel < 4 && zoomLevel != intZoomLevel) {
        zoomLevel = intZoomLevel;
        radius = 400000;
        setState(() {});
      } else if (intZoomLevel > zoomLevel) {
        int fach = intZoomLevel - zoomLevel;
        zoomLevel = intZoomLevel;
        radius = radius / (2 * fach);
        setState(() {});
      } else if (intZoomLevel < zoomLevel) {
        int fach = zoomLevel - intZoomLevel;
        zoomLevel = intZoomLevel;
        radius = radius * (2 * fach);
        setState(() {});
      }
    } catch (_) {}
  }

  @override
  void initState() {
    data();
    DefaultAssetBundle.of(context)
        .loadString("assets/map_theme.json")
        .then((value) {
      map_theme = value;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("radius");
    print(radius);
    // final CourseListProvider courseListProvider =
    //     Provider.of<CourseListProvider>(context, listen: false);

    // final LocationProvider locationProvider =
    // Provider.of<LocationProvider>(context, listen: false);
    return BlocProvider(
      create: (_) => apiBloc,
      child: BlocListener<ApiBloc, BlocState>(
        listener: (context, state) {
          if (state is Error) {
            showToast(
                text: state.message!, color: Colors.red, context: context);
          }
        },
        child: BlocBuilder<ApiBloc, BlocState>(
          builder: (context, state) {
            if (state is Initial) {
              return buildLoading();
            } else if (state is Loading) {
              return Container(child: buildLoading());
            } else if (state is Loaded) {
              NearEvents nearEvents = nearEventsFromJson(state.data);

              return Stack(
                alignment: Alignment.center,
                children: [
                  Consumer<CourseListProvider>(
                    builder: (context, courseListProvider, child) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: GoogleMap(
                          zoomControlsEnabled: true,
                          zoomGesturesEnabled: true,
                          scrollGesturesEnabled: true,
                          compassEnabled: true,
                          rotateGesturesEnabled: true,
                          mapToolbarEnabled: true,
                          myLocationEnabled: true,
                          tiltGesturesEnabled: true,

                          gestureRecognizers: <Factory<
                              OneSequenceGestureRecognizer>>{
                            Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer(),
                            ),
                          },
                          onCameraMove: (CameraPosition cameraPosition) {
                            _onCameraMove(cameraPosition);
                            middlePointOfScreenOnMap = cameraPosition.target;
                            // print(middlePointOfScreenOnMap);
                            courseListProvider
                                .setNewCoordinates(middlePointOfScreenOnMap!);
                          },
                          onCameraIdle: () {},

                          mapType: MapType.normal,

                          markers: markers,
                          // markers: Set<Marker>.of(courseListProvider.markers),
                          initialCameraPosition: CameraPosition(
                            target:
                                LatLng(position.latitude, position.longitude),
                            zoom: 12.00,
                          ),

                          // style: map_theme,
                          onMapCreated: (GoogleMapController controller) async {
                            mapController = controller;

                            final ByteData bytes =
                                await rootBundle.load('assets/images/user.png');
                            final Uint8List list = bytes.buffer.asUint8List();

                            for (int index = 0;
                                index < nearEvents.nearByEvents!.length;
                                index++) {
                              NearByEvent event =
                                  nearEvents.nearByEvents![index];

                              // var request = await http.get( event.profileImage);
                              // var bytes = await request.bodyBytes;
                              // BitmapDescriptor.fromBytes(bytes.buffer.asUint8List())

                              markers.add(Marker(
                                  markerId: const MarkerId("marker_1"),
                                  position: LatLng(
                                      event.location!.coordinates![1],
                                      event.location!.coordinates![0]),
                                  icon: BytesMapBitmap(list,
                                      height: 50, width: 50)));
                              // }
                            }
                            // setState(() {});
                          },
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 10.0,
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 1,
                            backgroundColor: Colors.grey.withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            )),
                        onPressed: () async {
                          data(radius: radius);
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) async {
                            context.read<AllEventBloc>().add(FetchAllEvents(
                                  "",
                                  position.latitude,
                                  position.longitude,
                                  radius,
                                  // 0.0,
                                  // 0.0,
                                  // 0,

                                  "2024-01-26T15:00:00.000Z",
                                ));
                          });
                          // showModalBottomSheet(
                          //     showDragHandle: true,
                          //     context: context,
                          //     builder: (builder) {
                          //       return Container(
                          //         height: 500,
                          //         child: HomeScreenBottomSheet(
                          //             position: position,
                          //             userID: widget.userID,
                          //             radius: radius),
                          //       );
                          //     });
                        },
                        child: const Text('Search this area',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black,
                            )),
                      ),
                    ),
                  ),
                  // Positioned(
                  //   bottom: 10.0,
                  //   child: Center(
                  //     child: IconButton(
                  //       onPressed: () {
                  //         // myBottomSheet(context);
                  //         showBottomSheetHomeScreen(context,
                  //             currentPosition: currentPosition,
                  //             scaffoldkey: scaffoldkey);
                  //       },
                  //       icon: const Icon(
                  //         Icons.arrow_circle_up_rounded,
                  //         size: 40,
                  //         color: Colors.black,
                  //       ),
                  //       style: IconButton.styleFrom(
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(30),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              );
            } else if (state is Error) {
              return Container();
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
