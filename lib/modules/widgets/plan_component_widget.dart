import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simpleui/layout/cubit/layout_cubit.dart';
import 'package:simpleui/models/plan_model.dart';
import 'package:simpleui/modules/screens/plan/plan_details_screen.dart';
import 'package:simpleui/modules/widgets/alert_dialog_widget.dart';
import 'package:simpleui/shared/constants.dart';

class PlanWidget extends StatelessWidget {
  final PlanModel model;
  final String planID;
  final LayoutCubit cubit;
  const PlanWidget(
      {super.key,
      required this.model,
      required this.planID,
      required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PlanDetails(planModel: model, planID: planID)));
            },
            contentPadding: const EdgeInsets.all(0),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(model.authorImage!),
            ),
            title: Text(
              model.planName!,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp),
            ),
            subtitle: Text(
              model.planDate!,
              style: TextStyle(color: Colors.grey),
            ),
            trailing: GestureDetector(
              onTap: () {
                showAlertDialog(
                  context: context,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Text(model.authorID == userID
                            ? "Delete Plan"
                            : "Leave Plan"),
                        onTap: () async {
                          model.authorID == userID
                              ? await cubit.deleteplan(
                                  planID: planID, planName: model.planName!)
                              : await cubit.leaveplan(
                                  planID: planID,
                                  planName: model.planName!,
                                  planAuthorID: model.authorID!);
                        },
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(Icons.more_horiz),
            )),
        Text(
          model.planDescription!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp),
        ),
        SizedBox(
          height: 12.h,
        ),
        GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PlanDetails(planModel: model, planID: planID)));
            },
            child: Image.network(
              model.planImage!,
              fit: BoxFit.fill,
              width: double.infinity,
              height: 200.h,
            )),
        SizedBox(
          height: 10.h,
        ),
        Divider(
          color: Colors.black.withOpacity(0.4),
          thickness: 0.2,
        ),
      ],
    );
  }
}
