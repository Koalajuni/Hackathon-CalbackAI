class CheckBoxState{
  String friendName;
  String friendUid;
  String friendEmail;
  bool? value;

  CheckBoxState({
    this.friendName = "dummy name",
    required this.friendUid,
    this.friendEmail = "dummy Email",
    this.value = false,
  });
}