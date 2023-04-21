import 'package:flutter/material.dart';
import 'package:simpleui/models/plan_model.dart';
import 'package:simpleui/modules/screens/recipes/create_recipe.dart';
import 'package:simpleui/shared/style/colors.dart';

class PlanDetails extends StatelessWidget {
  final PlanModel planModel;
  final String planID;
  const PlanDetails({Key? key, required this.planModel, required this.planID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainColor,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateRecipeScreen(
                        planAuthorID: planModel.authorID!,
                        planID: planID,
                        planName: planModel.planName!,
                        planImage: planModel.planImage!,
                      )));
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(planModel.planImage!))),
              )),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    planModel.planName!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.amber,
                        backgroundImage: NetworkImage(planModel.authorImage!),
                      ),
                      const SizedBox(width: 15.0),
                      Expanded(
                          child: Text(
                        '${planModel.authorName!} |   ${planModel.planDate!}',
                        overflow: TextOverflow.ellipsis,
                      ))
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: SingleChildScrollView(
                        child: Text(planModel.planDescription!)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
