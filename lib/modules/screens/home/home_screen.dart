import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simpleui/layout/cubit/layout_cubit.dart';
import 'package:simpleui/models/recipe_model.dart';
import 'package:simpleui/modules/widgets/alert_dialog_widget.dart';
import 'package:simpleui/modules/widgets/snackBar_widget.dart';
import 'package:simpleui/shared/style/colors.dart';
import '../../../layout/cubit/layout_states.dart';
import '../../../models/plan_model.dart';
import '../../widgets/plan_component_widget.dart';
import '../../widgets/empty_home_component.dart';
import '../../widgets/recipe_component_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController tabController;
  int currentTabIndex = 0;
  @override
  void initState() {
    tabController =
        TabController(vsync: this, length: 2, initialIndex: currentTabIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final LayoutCubit cubit = LayoutCubit.getInstance(context);
    List<PlanModel> plansData = cubit.myPlansData;
    List<RecipeModel> recipesData = cubit.recipesData;
    Map<String, bool> likesStatus = cubit.likesStatus;
    List<String> plansID = cubit.myPlansID;
    List<String> RecipesID = cubit.RecipesID;
    return Scaffold(
        appBar: AppBar(
          title: const Text("MyFitnessPal"),
          leading: const SizedBox(),
          leadingWidth: 0.w,
          bottom: TabBar(
            labelPadding: const EdgeInsets.only(top: 0),
            onTap: (index) {
              setState(() {
                currentTabIndex = index;
              });
            },
            controller: tabController,
            indicatorColor: const Color.fromARGB(255, 109, 173, 202),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
            labelColor: mainColor,
            labelStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(
                child: Text("Plans"),
              ),
              Tab(
                child: Text("Recipes"),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 12.0.w),
              child: GestureDetector(
                child: const Icon(Icons.search),
                onTap: () {
                  Navigator.pushNamed(context, "search_about_plan_screen");
                },
              ),
            )
          ],
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            // Todo: It was BlocBuilder
            BlocConsumer<LayoutCubit, LayoutStates>(
              listener: (context, state) {
                // Todo: To pop up from AlertDialog
                if (state is DeleteplanSuccessfullyState ||
                    state is LeaveplanSuccessfullyState) {
                  Navigator.pop(context);
                }
                if (state is LeaveplanWithErrorState ||
                    state is FailedToDeleteplanState) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                      message: "Something went wrong, try again later!",
                      context: context,
                      color: Colors.red));
                }
                if (state is LeaveplanLoadingState ||
                    state is DeleteplanLoadingState) {
                  Navigator.pop(context);
                  showAlertDialog(
                      context: context,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(
                            color: mainColor,
                            radius: 15.h,
                          )
                        ],
                      ));
                }
              },
              buildWhen: (oldState, newState) {
                return newState is GetMyplansSuccessState;
              },
              builder: (context, state) {
                return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0.w),
                    child: plansData.isNotEmpty && cubit.userData != null
                        ? SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (plansData.isNotEmpty)
                                  ...List.generate(
                                      plansData.length,
                                      (index) => PlanWidget(
                                            cubit: cubit,
                                            model: plansData[index],
                                            planID: plansID[index],
                                          )),
                              ],
                            ),
                          )
                        : state is GetMyplansLoadingState
                            ? Center(
                                child: CupertinoActivityIndicator(
                                    color: mainColor, radius: 15.h),
                              )
                            : emptyDataItemView(
                                context: context,
                                title: "No plans yet, try to join one!"));
              },
            ),
            BlocConsumer<LayoutCubit, LayoutStates>(
              listener: (context, state) {
                if (state is DeleteRecipeSuccessState) {
                  Navigator.pop(context);
                }
                if (state is DeleteRecipeErrorState) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                      message: "Something went wrong, try again later!",
                      context: context,
                      color: Colors.red));
                }
                if (state is DeleteRecipeLoadingState) {
                  Navigator.pop(context);
                  showAlertDialog(
                      context: context,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(
                            color: mainColor,
                            radius: 15.h,
                          )
                        ],
                      ));
                }
              },
              buildWhen: (oldState, newState) {
                return newState is GetAllRecipesSuccessfullyState;
              },
              builder: (context, state) {
                return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0.w),
                    child: recipesData.isNotEmpty &&
                            RecipesID.isNotEmpty &&
                            cubit.userData != null
                        ? SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (recipesData.isNotEmpty &&
                                    RecipesID.isNotEmpty)
                                  ...List.generate(
                                      recipesData.length,
                                      (index) => RecipeWidget(
                                            model: recipesData[index],
                                            recipeID: RecipesID[index],
                                            cubit: cubit,
                                            likesStatus: likesStatus,
                                          )),
                              ],
                            ),
                          )
                        : state is GetAllRecipesLoadingState
                            ? Center(
                                child: CupertinoActivityIndicator(
                                  color: mainColor,
                                  radius: 25.h,
                                ),
                              )
                            : emptyDataItemView(
                                context: context,
                                title: "No Recipes yet, try to add one!"));
              },
            ),
          ],
        ));
  }
}
