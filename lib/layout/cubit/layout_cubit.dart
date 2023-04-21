import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simpleui/layout/cubit/layout_states.dart';
import 'package:simpleui/models/comment_model.dart';
import 'package:simpleui/models/plan_model.dart';
import 'package:simpleui/models/like_model.dart';
import 'package:simpleui/models/recipe_model.dart';
import 'package:simpleui/modules/screens/certificates/certificates_screen.dart';
import 'package:simpleui/modules/screens/profile/profile_screen.dart';
import 'dart:io';
import '../../models/user_model.dart';
import '../../modules/screens/home/home_screen.dart';
import '../../shared/constants.dart';
import '../../shared/network/local_network.dart';
import 'package:http/http.dart' as http;

class LayoutCubit extends Cubit<LayoutStates> {
  LayoutCubit() : super(InitialAppState());

  // Todo: get instance from this cubit
  static LayoutCubit getInstance(BuildContext context) =>
      BlocProvider.of<LayoutCubit>(context);

  // Todo: Method for changeBottomNavIndex
  int bottomNavIndex = 0;
  void changeBottomNavIndex(int index) {
    bottomNavIndex = index;
    emit(ChangeBottomNavIndexState());
  }

  List<Widget> layoutScreens = [
    const HomeScreen(),
    const ProfileScreen(),
    const CertificatesScreen()
  ];

  // Todo: get My Data to show in Profile screen and use it in other screens
  UserModel? userData;
  Future<void> getMyData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(CacheHelper.getCacheData(key: 'uid') ?? userID)
        .get()
        .then((value) {
      userData = UserModel.fromJson(value.data()!);
      emit(GetUserDataSuccessState());
    });
  }

  // Todo : log out
  dynamic logOut() async {
    emit(LogOutLoadingState());
    bool clearCache = await CacheHelper.clearCache();
    if (clearCache) {
      userData = null;
      recipesData.clear();
      RecipesID.clear();
      myPlansData.clear();
      myPlansID.clear();
      joinedplansID.clear();
    }
    return clearCache ? true : false;
  }

  File? userImageFile;
  Future<void> getUserImage() async {
    emit(GetProfileImageLoadingState());
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      userImageFile = File(pickedImage.path);
      emit(ChosenImageSuccessfullyState());
    } else {
      emit(ChosenImageErrorState());
    }
  }

  void updateUserDataWithoutImage(
      {required String email,
      required String phoneNumber,
      required String userName,
      String? image}) {
    emit(UpdateUserDataWithoutImageLoadingState());
    final model = UserModel(
        image: image ?? userData!.image,
        email: email,
        phoneNumber: phoneNumber,
        userName: userName,
        userID: userData!.userID,
        firebase_messaging_token: firebase_messaging_token);
    FirebaseFirestore.instance
        .collection('users')
        .doc(userData!.userID)
        .update(model.toJson())
        .then((value) {
      getMyData(); // هنا مش عارف المشكله بتاعه اما ارفع الداتا اللي كان مكتوب داخل textFormField بيتغير وبيأخد الحاجه القديمه عما يخرج من صفحه update
      emit(UpdateUserDataWithoutImageSuccessState());
    }).catchError((e) {
      emit(UpdateUserDataWithoutImageErrorState());
    });
  }

  void updateUserDataWithImage(
      {required String email,
      required String phoneNumber,
      required String userName}) {
    emit(UpdateUserDataWithImageLoadingState());
    FirebaseStorage.instance
        .ref()
        .child("users/${Uri.file(userImageFile!.path).pathSegments.last}")
        .putFile(userImageFile!)
        .then((val) {
      val.ref.getDownloadURL().then((imageUrl) {
        // upload Update for userData to FireStore
        updateUserDataWithoutImage(
            email: email,
            phoneNumber: phoneNumber,
            userName: userName,
            image: imageUrl);
      }).catchError((onError) {
        emit(UploadUserImageErrorState());
      });
    }).catchError((error) {
      emit(UpdateUserDataWithImageErrorState());
    });
  }

  //Todo : made this function as if i change profile photo but canceled update imageProfileUrl will show on EditProfileScreen as i canceled update and i use profileImageUrl to be shown not userData!.image
  void canceledUpdateUserData() {
    emit(CanceledUpdateUserDataState());
  }

  // Todo: get Image for Plan on Create Plan Screen
  File? planImageFile;
  void getplanImage() async {
    final pickedrecipeImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedrecipeImage != null) {
      planImageFile = File(pickedrecipeImage.path);
      emit(SelectplanImageSuccessState());
    } else {
      emit(SelectplanImageSuccessState());
    }
  }

  // Todo: create Plan Method
  void createMyplan(
      {required String planName, required String planDescription}) {
    String topicName = "${planName}${userID!}";
    emit(CreateMyplanLoadingState());
    FirebaseStorage.instance
        .ref()
        .child("plans/${Uri.file(planImageFile!.path).pathSegments.last}")
        .putFile(planImageFile!)
        .then((value) {
      value.ref.getDownloadURL().then((imageUrl) async {
        final model = PlanModel(
            userData!.firebase_messaging_token,
            userData!.userName,
            userData!.userID,
            userData!.image,
            planName,
            timeNow,
            imageUrl,
            planDescription);
        debugPrint("Plan's image added successfully $imageUrl");
        // Todo: my own plans mean which I have created not joined
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userID ?? userData!.userID)
            .collection('own_plans')
            .add(model.toJson());
        // Todo: made this condition to use on validate name for Topic as + not validate like C++ this isn't a validate name for Topic
        if (RegExp(r'^[a-zA-Z0-9-_.~%]{1,900}$').hasMatch(topicName) == true) {
          print("Condition is True >>>>>>>>>>>>>>>>>>>>>>");
          await FirebaseMessaging.instance.subscribeToTopic(
              topicName); // Todo: to get notifications when anyone else add a new Recipe on this plan
        }
        await getMyAllPlansData();
        emit(CreateMyplanSuccessfullyState());
      });
    }).catchError((onError) {
      emit(FailedToCreateMyplanState());
    });
  }

  // Todo: delete my Okab using its ID
  Future<void> deleteplan(
      {required String planID, required String planName}) async {
    String topicName = "${planName}${userData!.userID ?? userID}";
    emit(DeleteplanLoadingState());
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID ?? userData!.userID)
          .collection('own_plans')
          .doc(planID)
          .delete();
      // Todo: made this condition to use on validate name for Topic as + not validate like C++ this isn't a validate name for Topic
      if (RegExp(r'^[a-zA-Z0-9-_.~%]{1,900}$').hasMatch(topicName) == true) {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topicName);
      }
      await getMyAllPlansData();
      emit(DeleteplanSuccessfullyState());
    } catch (e) {
      emit(FailedToDeleteplanState(error: e.toString()));
    }
  }

  // Todo: add plan to joined plans (( I will get The ID for Plan throw plansID variable when i click on it ))
  void addToJoinedPlan(
      {required PlanModel planModel, required String planID}) async {
    joinedplansID.add(planID);
    sendNotificationAfterJoinPlan(
        receiverFirebaseMessagingToken: planModel.authorFirebaseMessagingToken!,
        planID: planID,
        planModel: planModel);
    emit(addToJoinedPlanLoadingState());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userID ?? userData!.userID)
        .collection('joined_plans')
        .doc(planID)
        .set(planModel.toJson())
        .catchError((error) {
      emit(FailedToaddToJoinedPlanState());
    });
    await FirebaseMessaging.instance.subscribeToTopic(
        "${planModel.planName!.substring(0, 3)}${planModel.authorID!.substring(0, 3)}"); // Todo: use it to get notifications after anyone create Recipe on this plan
    await getMyAllPlansData();
    emit(addToJoinedPlanSuccessfullyState());
  }

  // Todo: add plan to joined plans (( I will get The ID for Plan throw plansID variable when I click on it))
  Future<void> leaveplan(
      {required String planID,
      required String planName,
      required String planAuthorID}) async {
    String topicName = "${planName}${planAuthorID}";
    emit(LeaveplanLoadingState());
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID ?? userData!.userID)
          .collection('joined_plans')
          .doc(planID)
          .delete();
      joinedplansID
          .remove(planID); // Todo: to delete Plan ID from Set(joinedplansID)
      await FirebaseMessaging.instance.unsubscribeFromTopic(topicName);
      // Todo: made this condition to use on validate name for Topic as + not validate like C++ this isn't a validate name for Topic
      if (RegExp(r'^[a-zA-Z0-9-_.~%]{1,900}$').hasMatch(topicName) == true) {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topicName);
      }
      await getMyAllPlansData();
      emit(LeaveplanSuccessfullyState());
    } catch (e) {
      emit(LeaveplanWithErrorState(error: e.toString()));
    }
  }

  void updateplan({required PlanModel model, required String planID}) async {
    emit(UpdateplanLoadingState());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userID ?? userData!.userID)
        .collection('own_plans')
        .doc(planID)
        .update(model.toJson());
    await getMyAllPlansData();
    emit(UpdateplanSuccessfullyState());
  }

  void canceledplanImage() {
    planImageFile = null;
    emit(CanceledplanImageState());
  }

  // Todo: get Joined plans to use it under when I get MyAllplans
  List<PlanModel> myPlansData = [];
  List<String> myPlansID = [];
  Future<void> getMyJoinedplansData() async {
    myPlansData.clear();
    myPlansID.clear();
    await getJoinedplansID();
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((usersDocs) {
      for (var userDoc in usersDocs.docs) {
        if (userDoc.id != userID) {
          userDoc.reference.collection('own_plans').get().then((items) {
            for (var planItem in items.docs) {
              if (joinedplansID.contains(planItem
                  .id)) // Todo: this mean that this plan on my joined_plans
              {
                myPlansData.add(PlanModel.fromJson(json: planItem.data()));
                myPlansID.add(planItem.id);
              }
            }
            emit(GetJoinedplansSuccessState());
          });
        }
      }
    }).catchError((error) {
      emit(GetJoinedplansErrorState());
    });
  }

  // Todo: This contain own plans with plans that I have joined to display on Home Screen
  Future<void> getMyAllPlansData() async {
    await getMyJoinedplansData(); // Todo : to display my own plans beside the plans that i have joined
    emit(GetMyplansLoadingState());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userID ?? userData!.userID)
        .collection('own_plans')
        .get()
        .then((value) async {
      for (var planItem in value.docs) {
        myPlansData.add(PlanModel.fromJson(json: planItem.data()));
        myPlansID.add(planItem.id);
      }
      recipesData.clear();
      RecipesID.clear();
      await getMyAllrecipesData();
      emit(GetMyplansSuccessState());
    }).catchError((error) {
      debugPrint("Error reason : $error");
      emit(GetMyplansErrorState());
    });
  }

  // Todo : related t add like || remove || get it
  void addLike(
      {required String planID,
      required String recipeMakerID,
      required String recipeID,
      required String planAuthorID}) async {
    final model = LikeModel(
        userData!.image, userData!.userID, userData!.userName, timeNow, true);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(planAuthorID)
        .collection('own_plans')
        .doc(planID)
        .collection('Recipes')
        .doc(recipeID)
        .collection('likes')
        .doc(userID ?? userData!.userID)
        .set(model.toJson());
  }

  void removeLike(
      {required String planID,
      required String recipeMakerID,
      required String recipeID,
      required String planAuthorID}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(planAuthorID)
        .collection('own_plans')
        .doc(planID)
        .collection('Recipes')
        .doc(recipeID)
        .collection('likes')
        .doc(userID ?? userData!.userID)
        .delete();
  }

  // Todo: Add a comment to specific Recipe on specific plan
  void addComment(
      {required String comment,
      required RecipeModel RecipeModel,
      required String recipeID}) async {
    try {
      final commentModel = CommentModel(comment, userID ?? userData!.userID,
          userData!.image, userData!.userName, timeNow, recipeID);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(RecipeModel.planAuthorID)
          .collection('own_plans')
          .doc(RecipeModel.planID)
          .collection('Recipes')
          .doc(recipeID)
          .collection('comments')
          .add(commentModel.toJson());
      await getAllComments(
          planAuthorID: RecipeModel.planAuthorID!,
          planID: RecipeModel.planID!,
          recipeID: recipeID);
      emit(AddCommentSuccessState());
    } catch (error) {
      emit(FailedToAddCommentState());
    }
  }

  List<CommentModel> comments = [];
  List<String> commentsID = [];
  Future<void> getAllComments(
      {required String planID,
      required String planAuthorID,
      required String recipeID}) async {
    comments.clear();
    commentsID.clear();
    emit(GetCommentsLoadingState());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(planAuthorID)
        .collection('own_plans')
        .doc(planID)
        .collection('Recipes')
        .doc(recipeID)
        .collection('comments')
        .get()
        .then((value) {
      for (var commentItem in value.docs) {
        commentsID.add(commentItem.id);
        comments.add(CommentModel.fromJson(json: commentItem.data()));
      }
    }).catchError((e) {
      debugPrint("Error during get comments, reason : ${e.toString()}");
      emit(GetCommentsErrorState());
    });
    emit(GetCommentsSuccessState());
  }

  Future<void> deleteComment(
      {required RecipeModel RecipeModel,
      required String commentID,
      required String recipeID}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(RecipeModel.planAuthorID)
        .collection('own_plans')
        .doc(RecipeModel.planID)
        .collection('Recipes')
        .doc(recipeID)
        .collection('comments')
        .doc(commentID)
        .delete()
        .then((value) {
      emit(DeleteCommentSuccessState());
    }).catchError((e) {
      emit(FailedToDeleteCommentState());
    });
    await getAllComments(
        planID: RecipeModel.planID!,
        planAuthorID: RecipeModel.planAuthorID!,
        recipeID: recipeID);
  }

  // Todo: get likes Data to display it on LikesViewScreen
  List<LikeModel> likesData = [];
  void getLikesForSpecificRecipe(
      {required String planID,
      required String recipeMakerID,
      required String recipeID,
      required String planAuthorID}) async {
    likesData.clear();
    emit(GetLikesLoadingState());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(planAuthorID)
        .collection('own_plans')
        .doc(planID)
        .collection('Recipes')
        .doc(recipeID)
        .collection('likes')
        .get()
        .then((value) {
      for (var element in value.docs) {
        likesData.add(LikeModel.fromJson(json: element.data()));
      }
      emit(GetLikesSuccessfullyState());
    }).catchError((e) {
      debugPrint("Error during get likes and the reason is : $e");
    });
  }

  Future<void> deleteRecipe(
      {required String planID,
      required String recipeMakerID,
      required String recipeID,
      required String planAuthorID}) async {
    try {
      emit(DeleteRecipeLoadingState());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(planAuthorID)
          .collection('own_plans')
          .doc(planID)
          .collection('Recipes')
          .doc(recipeID)
          .delete();
      await getMyAllrecipesData(); // Todo: need to change it ti get Recipes
      emit(DeleteRecipeSuccessState());
    } catch (e) {
      emit(DeleteRecipeErrorState());
    }
  }

  Future<void> updateRecipe(
      {required String planID,
      required String recipeMakerID,
      required String recipeID,
      required String planAuthorID,
      required RecipeModel model}) async {
    emit(UpdateRecipeLoadingState());
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(planAuthorID)
          .collection('own_plans')
          .doc(planID)
          .collection('Recipes')
          .doc(recipeID)
          .update(model.toJson());
      await getMyAllrecipesData();
      emit(UpdateRecipeSuccessState());
    } catch (e) {
      debugPrint("Error during update Recipe, reason : $e");
      emit(UpdateRecipeErrorState());
    }
  }

  // Todo: get other plans to display on search screen
  List<PlanModel> otherPlansData = [];
  List<String> otherPlansID = [];
  Future<void> getOtherplans({required String input}) async {
    otherPlansID.clear();
    otherPlansData.clear();
    emit(GetOtherplansLoadingState());
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((usersDocs) {
        otherPlansID.clear();
        otherPlansData.clear();
        for (var userDoc in usersDocs.docs) {
          if (userDoc.id != userID) {
            userDoc.reference.collection('own_plans').get().then((planDocs) {
              for (var planDoc in planDocs.docs) {
                if (planDoc
                    .data()['planName']
                    .toString()
                    .toLowerCase()
                    .startsWith(input)) {
                  otherPlansData.add(PlanModel.fromJson(json: planDoc.data()));
                  otherPlansID.add(planDoc.id);
                  emit(GetOtherplansSuccessState());
                }
              }
            });
          }
        }
      });
      debugPrint(otherPlansData.length.toString());
    } catch (exception) {
      debugPrint("Error during get other plans, reason : $exception");
      emit(GetOtherplansErrorState());
    }
  }

  // Todo: related to Recipes || likes on it
  File? recipeImageFile;
  void getrecipeImage() async {
    final pickedrecipeImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedrecipeImage != null) {
      recipeImageFile = File(pickedrecipeImage.path);
      emit(ChosenrecipeImageSuccessfullyState());
    } else {
      emit(ChosenrecipeImageErrorState());
    }
  }

  Future<void> createRecipeWithoutImage(
      {required String recipeCaption,
      String? recipeImage,
      required String planName,
      required String planID,
      required String planImage,
      required String planAuthorID}) async {
    emit(UploadRecipeWithoutImageLoadingState()); // loading
    final model = RecipeModel(
        userData!.userName,
        userData!.userID,
        userData!.image,
        recipeCaption,
        timeNow.toString(),
        recipeImage ?? "",
        planName,
        planID,
        planImage,
        planAuthorID);
    if (planAuthorID == userID) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID ?? userData!.userID)
          .collection('own_plans')
          .doc(planID)
          .collection('Recipes')
          .add(model.toJson());
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(planAuthorID)
          .collection('own_plans')
          .doc(planID)
          .collection('Recipes')
          .add(model.toJson());
    }
    // Todo: Send a Notification if I am not the Author for This Plan
    if (userID != planAuthorID)
      sendNotifyAfterAddRecipe(planID, planAuthorID, planName, planImage);
    await getMyAllrecipesData();
    emit(UploadRecipeWithoutImageSuccessState());
  }

  void createRecipeWithImage(
      {required String recipeCaption,
      required String planName,
      required String planID,
      required String planImage,
      required String planAuthorID}) async {
    emit(UploadRecipeWithImageLoadingState()); // loading
    await FirebaseStorage.instance
        .ref()
        .child("Recipes/${Uri.file(recipeImageFile!.path).pathSegments.last}")
        .putFile(recipeImageFile!)
        .then((value) {
      value.ref.getDownloadURL().then((imageUrl) async {
        debugPrint("New Recipe image added $imageUrl");
        await createRecipeWithoutImage(
            recipeCaption: recipeCaption,
            recipeImage: imageUrl,
            planID: planID,
            planImage: planImage,
            planName: planName,
            planAuthorID: planAuthorID);
      }).catchError((e) {
        debugPrint("Error during upload Recipe Image => ${e.toString()}");
        emit(
            UploadImageForRecipeErrorState()); // error during upload recipeImage not totally Recipe
      });
    }).catchError((onError) {
      emit(UploadRecipeWithImageErrorState());
    });
  }

  void canceledrecipeImage() {
    recipeImageFile = null;
    emit(CanceledImageForRecipeState());
  }

  // Todo: get joinedplans ID to use in get Recipes that on this plan
  Set<String> joinedplansID = {};
  Future<void> getJoinedplansID() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userID ?? userData!.userID)
        .collection('joined_plans')
        .get()
        .then((value) {
      for (var element in value.docs) {
        joinedplansID.add(element.id);
      }
      debugPrint("Joined plans ID is ................ $joinedplansID");
    });
  }

  // Todo: get All Recipes ( include my Recipes from my plans and other plans which i follow )
  List<RecipeModel> recipesData = [];
  List<String> RecipesID = [];
  Map<String, bool> likesStatus =
      {}; // Todo: store recipeID as a key and status as a value
  // Todo: This contain own plans with plans that I have joined to display on Home Screen
  Future<void> getMyAllrecipesData() async {
    recipesData.clear();
    RecipesID.clear();
    likesStatus.clear();
    await getJoinedplansID();
    emit(GetAllRecipesLoadingState());
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) async {
      for (var val in value.docs) {
        if (val.id != userID) {
          await val.reference.collection('own_plans').get().then((value) {
            for (var val in value.docs) {
              if (joinedplansID.contains(val.id)) {
                val.reference.collection('Recipes').get().then((items) {
                  for (var item in items.docs) {
                    debugPrint(
                        "... Recipe added to joined Recipes success ...");
                    recipesData.add(RecipeModel.fromJson(json: item.data()));
                    RecipesID.add(item.id);
                    emit(GetJoinedRecipesSuccessState());
                    item.reference.collection('likes').get().then((value) {
                      for (var val in value.docs) {
                        if (val.id == userID)
                          likesStatus.addAll({item.id: true});
                      }
                    });
                  }
                });
              }
            }
          }).catchError((error) {
            debugPrint("error during get joined Recipes, reason : $error");
            emit(FailedToGetJoinedRecipesState());
          });
        }
        if (val.id == userID) {
          await val.reference.collection('own_plans').get().then((value) {
            for (var element in value.docs) {
              element.reference.collection('Recipes').get().then((items) {
                for (var item in items.docs) {
                  item.reference.collection('likes').get().then((value) {
                    if (value.docs.isNotEmpty) {
                      for (var element in value.docs) {
                        if (element.id == userID)
                          likesStatus.addAll(
                              {item.id: true}); // Todo: item.id == recipeID
                        recipesData
                            .add(RecipeModel.fromJson(json: item.data()));
                        RecipesID.add(item.id);
                      }
                    } else {
                      recipesData.add(RecipeModel.fromJson(json: item.data()));
                      RecipesID.add(item.id);
                    }
                  });
                }
              });
            }
          });
        }
      }
      emit(GetAllRecipesSuccessfullyState());
    }).catchError((error) {
      emit(FailedToGetAllRecipesState());
    });
  }

  // Todo: Send Notification to Plan's author after anyone join to his plan
  Future<void> sendNotificationAfterJoinPlan(
      {required String receiverFirebaseMessagingToken,
      required planID,
      required PlanModel planModel}) async {
    await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"), headers: {
      'Content-Type': "application/json",
      // Todo: Authorization to know from App will send Notifications
      'Authorization':
          "key=AAAAZFCracs:APA91bFst8il3hmARx8In4PTVFBKePI2cM7JSob9wewr5rW-rkYjYlkQuikPJ9KEdUY0BH-t1eHsizKH2oprEbpEY47mYOAMzppjUbJsSyE6vWkMIoeKAUYohz9_L1oe7PR6p6hshsnc"
    }, body: {
      {
        "to":
            receiverFirebaseMessagingToken, // Todo: receiverFirebaseMessagingToken == firebase_messaging_token for plan's author
        "notification": {
          "title": "New Follower",
          "body":
              "${userData!.userName!} start following your %${planModel.planName} plan",
          "image": userData!.image!,
          "mutable_content": true,
          "sound": "Tri-tone"
        },
        "data": {
          "type":
              "Notification after ${userData!.userName} followed your ${planModel.planName} plan",
          "senderName": userData!.userName!,
          "senderID": userData!.userID!,
          "planID": planID
        }
      }
    });
  }

  // Todo: send a notification for all users who join to a specific plan after adding a Recipe on this plan
  Future<void> sendNotifyAfterAddRecipe(String planID, String planAuthorID,
      String planName, String planImage) async {
    String topicName = "${planName}${planAuthorID}";
    await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"), headers: {
      'Content-Type': "application/json",
      // Todo: Authorization to know from App will send Notifications
      'Authorization':
          "key=AAAAZFCracs:APA91bFst8il3hmARx8In4PTVFBKePI2cM7JSob9wewr5rW-rkYjYlkQuikPJ9KEdUY0BH-t1eHsizKH2oprEbpEY47mYOAMzppjUbJsSyE6vWkMIoeKAUYohz9_L1oe7PR6p6hshsnc"
    }, body: {
      {
        // Todo: I used planID as The Topic that users subscribe to it.
        "to":
            "/topics/$topicName", // Todo: receiver token == firebase_messaging_token for plan's author
        "notification": {
          "title": "New Recipe",
          "body": "${userData!.userName} add a new Recipe on %$planName plan",
          "image": planImage,
          "mutable_content": true,
          "sound": "Tri-tone"
        },
        "data": {
          "senderName": userData!.userName!,
          "planID": planID,
          "planAuthorID": planAuthorID,
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        }
      }
    });
  }
}
