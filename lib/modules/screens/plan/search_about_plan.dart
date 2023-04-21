import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simpleui/layout/cubit/layout_states.dart';
import 'package:simpleui/models/plan_model.dart';
import '../../../layout/cubit/layout_cubit.dart';
import '../../../shared/style/colors.dart';
import '../../widgets/alert_dialog_widget.dart';
import '../../widgets/snackBar_widget.dart';

class SearchAboutplanScreen extends StatefulWidget {
  const SearchAboutplanScreen({Key? key}) : super(key: key);

  @override
  State<SearchAboutplanScreen> createState() => _SearchAboutplanScreenState();
}

class _SearchAboutplanScreenState extends State<SearchAboutplanScreen> {
  final searchController = TextEditingController();
  @override
  void dispose() {
    searchController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LayoutCubit cubit = LayoutCubit.getInstance(context);
    return BlocConsumer<LayoutCubit, LayoutStates>(listener: (context, state) {
      if (state is addToJoinedPlanSuccessfullyState) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
            message: "Added to your plans successfully!",
            context: context,
            color: Colors.green));
      }
      if (state is addToJoinedPlanLoadingState) {
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
    }, builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 30.h,
          leading: const SizedBox(),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
              child: TextFormField(
                onChanged: (input) {
                  // Todo : filtered Data depending on input
                  cubit.getOtherplans(input: input);
                },
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: "search for a plan to join...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              height: 7.5.h,
            ),
            Expanded(
              child: cubit.otherPlansData.isNotEmpty
                  ? ListView.separated(
                      itemCount: cubit.otherPlansData.length,
                      itemBuilder: (context, index) {
                        return planItem(
                            model: cubit.otherPlansData[index],
                            planID: cubit.otherPlansID[index],
                            cubit: cubit,
                            context: context);
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                            color: Colors.grey, thickness: 0.5);
                      },
                    )
                  : state is GetOtherplansLoadingState &&
                          searchController.text.isEmpty
                      ? const Center(
                          child: CupertinoActivityIndicator(
                            color: mainColor,
                          ),
                        )
                      : Center(
                          child: Text(
                            "No Data yet!",
                            style: TextStyle(
                                color: mainColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.sp),
                          ),
                        ),
            )
          ],
        ),
      );
    });
  }

  Widget planItem(
      {required PlanModel model,
      required String planID,
      required LayoutCubit cubit,
      required BuildContext context}) {
    return model.planName != null
        ? ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.5.w),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(model.planImage.toString()),
              radius: 30.h,
            ),
            title: Align(
                alignment: AlignmentDirectional.topStart,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      model.planName.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17.sp),
                    ))),
            subtitle: Text(model.planDate.toString()),
            trailing: GestureDetector(
                onTap: () {
                  if (cubit.myPlansID.contains(planID) == false) {
                    cubit.addToJoinedPlan(planModel: model, planID: planID);
                  } else {
                    showAlertDialog(
                        context: context,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0.w),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                    "You are already following this account"),
                              ),
                            )
                          ],
                        ));
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0.w),
                  child: cubit.joinedplansID.contains(planID)
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Followed",
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.green),
                          ))
                      : FittedBox(
                          child: Text(
                          "Follow",
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: mainColor),
                        )),
                )),
          )
        : const Center(
            child: CupertinoActivityIndicator(
              color: Colors.red,
            ),
          );
  }
}
