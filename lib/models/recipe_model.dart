class RecipeModel {
  String? recipeMakerName;
  String? recipeMakerID;
  String? recipeMakerImage;
  String? recipeDate;
  String? recipeCaption;
  String? recipeImage;
  String? planImage;
  String? planName;
  String? planID;
  String? planAuthorID;
  // i will put RecipeLink

  RecipeModel(
      this.recipeMakerName,
      this.recipeMakerID,
      this.recipeMakerImage,
      this.recipeCaption,
      this.recipeDate,
      this.recipeImage,
      this.planName,
      this.planID,
      this.planImage,
      this.planAuthorID);

  // Named Constructor to get Recipe Data from FireStore
  RecipeModel.fromJson({required Map<String, dynamic> json}) {
    recipeMakerImage = json['recipeMakerImage'];
    recipeMakerID = json['recipeMakerID'];
    recipeMakerName = json['recipeMakerName'];
    recipeImage = json['recipeImage'];
    recipeDate = json['recipeDate'];
    recipeCaption = json['recipeCaption'];
    planImage = json['planImage'];
    planName = json['planName'];
    planID = json['planID'];
    planAuthorID = json['planAuthorID'];
  }

  // TOJson used it when i will sent data to fireStore
  Map<String, dynamic> toJson() {
    return {
      'recipeMakerName': recipeMakerName,
      'recipeMakerID': recipeMakerID,
      'recipeMakerImage': recipeMakerImage,
      'recipeCaption': recipeCaption,
      'recipeDate': recipeDate,
      'recipeImage': recipeImage,
      'planImage': planImage,
      'planID': planID,
      'planName': planName,
      'planAuthorID': planAuthorID,
    };
  }
}
