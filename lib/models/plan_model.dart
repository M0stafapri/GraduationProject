class PlanModel {
  String? authorName;
  String? authorID;
  String? authorFirebaseMessagingToken;
  String? authorImage;
  String? planDate;
  String? planName;
  String? planDescription;
  String? planImage;

  PlanModel(
      this.authorFirebaseMessagingToken,
      this.authorName,
      this.authorID,
      this.authorImage,
      this.planName,
      this.planDate,
      this.planImage,
      this.planDescription);

  // Named Constructor to get Recipe Data from FireStore
  PlanModel.fromJson({required Map<String, dynamic> json}) {
    authorImage = json['userImage'];
    authorID = json['userID'];
    authorFirebaseMessagingToken = json['authorFirebaseMessagingToken'];
    authorName = json['authorName'];
    planImage = json['recipeImage'];
    planDate = json['planDate'];
    planName = json['planName'];
    planDescription = json['planDescription'];
  }

  // TOJson used it when i will sent data to fireStore
  Map<String, dynamic> toJson() {
    return {
      'authorName': authorName,
      'userID': authorID,
      'authorFirebaseMessagingToken': authorFirebaseMessagingToken,
      'userImage': authorImage,
      'planName': planName,
      'planDescription': planDescription,
      'planDate': planDate,
      'recipeImage': planImage,
    };
  }
}
