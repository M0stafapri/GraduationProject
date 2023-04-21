import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../layout/cubit/layout_cubit.dart';
import '../../models/recipe_model.dart';
import '../../shared/constants.dart';
import '../screens/comments_view/comments_screen.dart';
import '../screens/likes_screen/likesViewScreen.dart';
import '../screens/recipes/edit_recipe.dart';
import 'alert_dialog_widget.dart';

// Todo: Recipe Widget which will be shown on HomeScreen
class RecipeWidget extends StatelessWidget {
  final RecipeModel model;
  final String recipeID;
  final Map<String, bool> likesStatus;
  final LayoutCubit cubit;
  const RecipeWidget(
      {super.key,
      required this.model,
      required this.recipeID,
      required this.likesStatus,
      required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(model.recipeMakerImage.toString()),
          ),
          title: Text(
            model.planName.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp),
          ),
          subtitle: Text(
            "${model.recipeMakerName.toString()}, ${model.recipeDate.toString()}",
            style: TextStyle(color: Colors.grey),
          ),
          trailing: GestureDetector(
            onTap: () {
              if (model.recipeMakerID == userID) {
                showAlertDialog(
                  context: context,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      updateRecipe(context),
                      SizedBox(
                        height: 22.5.h,
                      ),
                      deleteRecipe(),
                    ],
                  ),
                );
              } else if (model.planAuthorID == userID) {
                showAlertDialog(
                  context: context,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      deleteRecipe(),
                    ],
                  ),
                );
              }
            },
            child: const Icon(Icons.more_horiz),
          ),
        ),
        if (model.recipeCaption != null)
          InkWell(
            onTap: () {
              navToCommentsScreen(context);
            },
            child: Text(model.recipeCaption.toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textScaleFactor: 1.2),
          ),
        SizedBox(
          height: 12.h,
        ),
        if (model.recipeImage != null && model.recipeImage != "")
          InkWell(
              onTap: () {
                navToCommentsScreen(context);
              },
              child: Image.network(model.recipeImage.toString(),
                  fit: BoxFit.fill, width: double.infinity)),
        if (model.recipeImage != null && model.recipeImage != "")
          SizedBox(
            height: 12.h,
          ),
        StatefulBuilder(builder: (context, setState) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                child: Icon(Icons.favorite,
                    color: likesStatus[recipeID] == true
                        ? Colors.red
                        : Colors.grey),
                onTap: () {
                  // Todo: will refresh This Row only
                  setState(() {
                    if (likesStatus[recipeID] == true) {
                      likesStatus[recipeID] = false;
                      cubit.removeLike(
                          planID: model.planID!,
                          recipeMakerID: model.recipeMakerID!,
                          recipeID: recipeID,
                          planAuthorID: model.planAuthorID!);
                    } else {
                      likesStatus[recipeID] = true;
                      cubit.addLike(
                          planID: model.planID!,
                          recipeMakerID: model.recipeMakerID!,
                          recipeID: recipeID,
                          planAuthorID: model.planAuthorID!);
                    }
                  });
                },
              ),
              SizedBox(
                width: 7.w,
              ),
              GestureDetector(
                child: const Text("Likes"),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return LikesViewScreen(
                        planID: model.planID!,
                        planAuthorID: model.planAuthorID!,
                        recipeID: recipeID,
                        recipeMakerID: model.recipeMakerID!);
                  }));
                },
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // Todo: call comments method first then open CommentsScreen
                  navToCommentsScreen(context);
                },
                child: const Text("Comments"),
              )
            ],
          );
        }),
        Divider(
          color: Colors.black.withOpacity(0.4),
          thickness: 0.2,
        ),
      ],
    );
  }

  // Todo: This Method can be done either I made this Recipe or I created the plan which this Recipe create in
  Widget deleteRecipe() {
    return GestureDetector(
      child: const Text("Delete Recipe"),
      onTap: () {
        cubit.deleteRecipe(
            planID: model.planID!,
            recipeMakerID: model.recipeMakerID!,
            recipeID: recipeID,
            planAuthorID: model.planAuthorID!);
      },
    );
  }

  // Todo: Update Recipe if I created it
  Widget updateRecipe(BuildContext context) {
    return GestureDetector(
      child: const Text("Update Recipe"),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditRecipeScreen(model: model, recipeID: recipeID)));
      },
    );
  }

  // Todo: Go To Comments Screen
  void navToCommentsScreen(BuildContext context) {
    cubit.getAllComments(
        planID: model.planID!,
        planAuthorID: model.planAuthorID!,
        recipeID: recipeID);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CommentsScreen(
          model: model, recipeID: recipeID, planAuthorID: model.planAuthorID!);
    }));
  }
}
