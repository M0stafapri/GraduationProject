import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simpleui/models/plan_model.dart';
import 'package:simpleui/modules/widgets/snackBar_widget.dart';
import '../../../layout/cubit/layout_cubit.dart';
import '../../../layout/cubit/layout_states.dart';
import '../../../shared/style/colors.dart';
import '../../widgets/buttons_widget.dart';
import '../profile/profile_screen.dart';

class EditplanScreen extends StatelessWidget {
  final String
      planID; // as it not saved with Recipe data on fireStore so i will get when i call this state from RecipesID that use in usersrecipesData
  final PlanModel
      model; // to get Recipe data to be able to update it throw its id and the maker of it
  final TextEditingController captionController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  EditplanScreen({super.key, required this.model, required this.planID});
  @override
  Widget build(BuildContext context) {
    captionController.text = model.planName.toString();
    final cubit = LayoutCubit.getInstance(context);
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text("Edit Plan"),
        titleSpacing: 0,
        leading: defaultTextButton(
            title: const Icon(Icons.arrow_back_ios),
            onTap: () {
              Navigator.pop(context);
            }),
        actions: [
          BlocConsumer<LayoutCubit, LayoutStates>(listener: (context, state) {
            if (state is UpdateplanSuccessfullyState) {
              ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                  message: "Recipe Updated successfully!",
                  context: context,
                  color: Colors.green));
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()));
              LayoutCubit.getInstance(context).planImageFile = null;
            }
          }, builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: state is UpdateplanLoadingState
                  ? const CupertinoActivityIndicator(color: mainColor)
                  : InkWell(
                      child: const Icon(
                        Icons.done,
                        color: mainColor,
                        size: 25,
                      ),
                      onTap: () {
                        cubit.updateplan(model: model, planID: planID);
                      },
                    ),
            );
          }),
        ],
      ),
      body: model.authorID == null
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
      {required BuildContext context, required PlanModel model}) {
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
                  child: model.authorImage != null
                      ? Image.network(
                          model.authorImage!,
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
                    model.authorName!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    DateTime.now().toString(),
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
        if (model.planImage !=
            '') // as if there is no image for a Recipe , recipeImage that on Recipe field on fireStore contain '' and this instead of imageUrl
          const SizedBox(
            height: 10,
          ),
        if (model.planImage !=
            '') // لو مش هعمل الاوبشن بتاع حذف صوره البوست ف مش بحاجه لل stack
          Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              Container(
                width: double.infinity,
                height: 350,
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: Colors.grey.withOpacity(0.3), width: 1),
                        bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.3), width: 1))),
                child: Image.network(
                  model.planImage!,
                  fit: BoxFit.cover,
                ),
                // Image.network(cubit.recipeImageUrl!,fit: BoxFit.fitHeight,height: 250),
              ),
            ],
          ),
      ],
    );
  }
}
