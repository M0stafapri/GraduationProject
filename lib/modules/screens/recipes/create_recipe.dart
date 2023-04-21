import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simpleui/modules/widgets/snackBar_widget.dart';
import '../../../layout/cubit/layout_cubit.dart';
import '../../../layout/cubit/layout_states.dart';
import '../../../shared/constants.dart';
import '../../../shared/style/colors.dart';
import '../../widgets/buttons_widget.dart';

class CreateRecipeScreen extends StatelessWidget {
  final String planID, planImage, planName, planAuthorID;
  final captionController = TextEditingController();
  CreateRecipeScreen(
      {super.key,
      required this.planID,
      required this.planName,
      required this.planImage,
      required this.planAuthorID});
  @override
  Widget build(BuildContext context) {
    final cubit = LayoutCubit.getInstance(context);
    return BlocConsumer<LayoutCubit, LayoutStates>(listener: (context, state) {
      if (state is UploadRecipeWithoutImageSuccessState) {
        cubit.recipeImageFile = null;
        Navigator.pushReplacementNamed(context, 'home_layout_screen');
        ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
            message: "Recipe Uploaded successfully!",
            context: context,
            color: Colors.green));
      }
    }, builder: (context, state) {
      return Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: const Text("New Recipe"),
          titleSpacing: 0,
          leading: defaultTextButton(
              title: const Icon(Icons.arrow_back),
              onTap: () {
                Navigator.pop(context);
              }),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: state is UploadRecipeWithoutImageLoadingState ||
                      state is UploadRecipeWithImageLoadingState
                  ? const CupertinoActivityIndicator(color: mainColor)
                  : InkWell(
                      child: const Icon(
                        Icons.done,
                        color: mainColor,
                        size: 25,
                      ),
                      onTap: () {
                        if (cubit.recipeImageFile != null) {
                          cubit.createRecipeWithImage(
                              recipeCaption: captionController.text,
                              planName: planName,
                              planImage: planImage,
                              planID: planID,
                              planAuthorID: planAuthorID);
                        } else {
                          cubit.createRecipeWithoutImage(
                              recipeCaption: captionController.text,
                              planID: planID,
                              planImage: planImage,
                              planName: planName,
                              recipeImage: "",
                              planAuthorID: planAuthorID);
                        }
                      },
                    ),
            )
          ],
        ),
        body: cubit.userData == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: mainColor,
                ),
              )
            : buildRecipeItem(context: context, cubit: cubit),
      );
    });
  }

  Widget buildRecipeItem(
      {required BuildContext context,
      dynamic model,
      required LayoutCubit cubit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 5, top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          clipBehavior: Clip.hardEdge,
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.5))),
                          child: cubit.userData?.image != null
                              ? Image.network(
                                  cubit.userData!.image!,
                                  fit: BoxFit.cover,
                                )
                              : const Text("")),
                      const SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cubit.userData!.userName!,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            timeNow,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        child: Icon(
                          Icons.more_vert,
                          color: blackColor.withOpacity(0.5),
                          size: 25,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextFormField(
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    controller: captionController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(0),
                        hintText: "type your caption here...",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(fontSize: 14)),
                  ),
                ),
                if (cubit.recipeImageFile != null)
                  const SizedBox(
                    height: 10,
                  ),
                if (cubit.recipeImageFile != null)
                  Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      SizedBox(
                          width: double.infinity,
                          child: Image(image: FileImage(cubit.recipeImageFile!))
                          // Image.network(cubit.recipeImageUrl!,fit: BoxFit.fitHeight,height: 250),
                          ),
                      GestureDetector(
                        onTap: () {
                          cubit.canceledrecipeImage();
                        },
                        child: Container(
                            margin: const EdgeInsets.all(7.5),
                            child: const CircleAvatar(
                              radius: 15,
                              child: Icon(
                                Icons.close,
                                size: 20,
                              ),
                            )),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (cubit.recipeImageFile == null)
          Padding(
              padding: EdgeInsets.only(bottom: 15.0.h),
              child: Center(
                child: defaultButton(
                    onTap: () {
                      cubit.getrecipeImage();
                    },
                    backgroundColor: whiteColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                    roundedRectangleBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.w)),
                    contentWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image,
                          color: whiteColor,
                          size: 20.w,
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "add a photo",
                              style: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold),
                            ))
                      ],
                    )),
              )),
      ],
    );
  }
}
