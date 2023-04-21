class CommentModel {
  String? comment;
  String? commentMakerID;
  String? commentMakerName;
  String? commentMakerImage;
  String? dateTime;
  String? recipeID;
  // Constructor
  CommentModel(this.comment, this.commentMakerID, this.commentMakerImage,
      this.commentMakerName, this.dateTime, this.recipeID);

  CommentModel.fromJson({required Map<String, dynamic> json}) {
    comment = json['comment'];
    commentMakerID = json['commentMakerID'];
    commentMakerName = json['commentMakerName'];
    commentMakerImage = json['commentMakerImage'];
    recipeID = json['recipeID'];
  }

  Map<String, dynamic> toJson() {
    return {
      'comment': comment,
      'commentMakerID': commentMakerID,
      'commentMakerName': commentMakerName,
      'commentMakerImage': commentMakerImage,
      'recipeID': recipeID,
    };
  }
}
