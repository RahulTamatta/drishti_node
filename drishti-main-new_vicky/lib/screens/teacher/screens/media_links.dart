import 'package:srisridrishti/bloc_latest/bloc/api_bloc.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_event.dart';
import 'package:srisridrishti/bloc_latest/bloc/bloc_state.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:srisridrishti/utils/show_toast.dart';
import 'package:srisridrishti/utils/utill.dart';
import 'package:srisridrishti/widgets/common_container_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../themes/theme.dart';

class MediaLinksScreen extends StatefulWidget {
  const MediaLinksScreen({super.key});

  @override
  State<MediaLinksScreen> createState() => MediaLinksScreenState();
}

class MediaLinksScreenState extends State<MediaLinksScreen> {
  final TextEditingController _instagramUrlController = TextEditingController();
  final TextEditingController _twitterUrlController = TextEditingController();
  final TextEditingController _youtubeUrlController = TextEditingController();

  //flutter bloc for hiting api
  ApiBloc apiBloc = ApiBloc();

  data(context) async {
    String? token = await SharedPreferencesHelper.getAccessToken();
    print("Token: $token");

    dynamic headers = {
      'Authorization': 'Bearer ${token.toString()}'
    }; // Add 'Bearer 'token.toString()};
    // dynamic headers = <String, dynamic>{};
    dynamic body = {
      "youtubeUrl": _youtubeUrlController.text,
      "xUrl": _twitterUrlController.text,
      "instagramUrl": _instagramUrlController.text,
    };
    dynamic path = "/user/socialMedia";
    dynamic type = "PATCH";
    apiBloc.add(GetApi(add: body, header: headers, path: path, type: type));

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return PopScope(
              canPop: true, // prevent back
              onPopInvokedWithResult: (bool didPop, Object? result) {
                Navigator.of(context).pop();
              },
              child: AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                content: Builder(
                  builder: (context) {
                    return SizedBox(
                      height: 200,
                      width: 200,
                      child: bloc(),
                    );
                  },
                ),
                insetPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAliasWithSaveLayer,
              ));
        });
  }

  Widget bloc() {
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
              // showToast(
              //     text: "Address Created Successfully",
              //     color: Colors.red,
              //     context: context);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop();
              });
              return Container();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
        ),
        centerTitle: false,
        title: Text(
          "Social Media Profile Links",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            _textFieldWidget(_instagramUrlController, "Instagram URL"),
            const SizedBox(height: 15),
            _textFieldWidget(_twitterUrlController, "Twitter URL"),
            const SizedBox(height: 15),
            _textFieldWidget(_youtubeUrlController, "Youtube URL"),
            const SizedBox(height: 35),
            InkWell(
                onTap: () {
                  data(context);
                },
                child: const CommonContainerButton(labelText: "Save Changes")),
          ],
        ),
      ),
    );
  }

  Widget _textFieldWidget(TextEditingController controller, String hintText,
      {IconData? prefixIcon,
      String? Function(String?)? validator,
      Color? labelColor,
      IconData? suffixIcon}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.manrope(
        textStyle: TextStyle(
          color: labelColor != null ? AppColors.primaryColor : Colors.black,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(14),
        hintText: hintText,
        labelText: hintText,
        labelStyle: GoogleFonts.manrope(
          textStyle: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        fillColor: Colors.white,
        filled: true,
        hintStyle: GoogleFonts.manrope(
          textStyle: TextStyle(
            color: Colors.black,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 17.sp,
                color: Colors.grey.withOpacity(0.4),
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Icon(
                suffixIcon,
                size: 18.sp,
                color: Colors.grey.withOpacity(0.7),
              )
            : null,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(6),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
