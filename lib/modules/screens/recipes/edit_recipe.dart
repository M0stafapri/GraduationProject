import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simpleui/modules/widgets/snackBar_widget.dart';
import 'package:simpleui/shared/constants.dart';

import '../../../layout/cubit/layout_cubit.dart';
import '../../../layout/cubit/layout_states.dart';
import '../../../models/recipe_model.dart';
import '../../../shared/style/colors.dart';
import '../../widgets/buttons_widget.dart';

class EditRecipeScreen extends StatelessWidget {
  String
      recipeID; // as it not saved with Recipe data on fireStore so i will get when i call this state from RecipesID that use in usersrecipesData
  RecipeModel
      model; // to get Recipe data to be able to update it throw its id and the maker of it
  TextEditingController captionController = TextEditingController();
  EditRecipeScreen({super.key, required this.model, required this.recipeID});
  @override
  Widget build(BuildContext context) {
    captionController.text = model.recipeCaption.toString();
    final cubit = LayoutCubit.getInstance(context);
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text("Update Recipe"),
        titleSpacing: 0,
        leading: defaultTextButton(
            title: const Icon(Icons.arrow_back_ios),
            onTap: () {
              Navigator.pop(context);
            }),
        actions: [
          BlocConsumer<LayoutCubit, LayoutStates>(listener: (context, state) {
            if (state is UpdateRecipeSuccessState) {
              cubit.recipeImageFile = null;
              ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                  message: "Updated successfully!",
                  context: context,
                  color: Colors.green));
              Navigator.pop(context);
            }
          }, builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: state is UpdateRecipeLoadingState
                  ? const CupertinoActivityIndicator(color: mainColor)
                  : InkWell(
                      child: const Icon(
                        Icons.done,
                        color: mainColor,
                        size: 25,
                      ),
                      onTap: () {
                        final newModel = RecipeModel(
                            model.recipeMakerName,
                            model.recipeMakerID,
                            model.recipeMakerImage,
                            captionController.text.isNotEmpty
                                ? captionController.text
                                : model.recipeCaption,
                            model.recipeDate,
                            model.recipeImage,
                            model.planName,
                            model.planID,
                            model.planImage,
                            model.planAuthorID);
                        cubit.updateRecipe(
                            planID: model.planID!,
                            recipeMakerID: model.recipeMakerID!,
                            recipeID: recipeID,
                            planAuthorID: model.planAuthorID!,
                            model: newModel);
                      },
                    ),
            );
          }),
        ],
      ),
      body: userID == null
          ? const Center(
              child: CircularProgressIndicator(
                color: mainColor,
              ),
            )
          : SingleChildScrollView(
              child: buildRecipeItem(context: context, model: model),
            ),
    );
  }

  Widget buildRecipeItem(
      {required BuildContext context, required RecipeModel model}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  clipBehavior: Clip.hardEdge,
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.withOpacity(0.5))),
                  child: model.recipeMakerImage != null
                      ? Image.network(
                          model.recipeMakerImage!,
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
                    model.recipeMakerName!,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextFormField(
            controller: captionController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(0),
            ),
          ),
        ),
        if (model.recipeImage !=
            '') // as if there is no image for a Recipe , recipeImage that on Recipe field on fireStore contain '' and this instead of imageUrl
          const SizedBox(
            height: 10,
          ),
        if (model.recipeImage != '')
          Image.network(
            model.recipeImage!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 300.h,
          ),
      ],
    );
  }
}
