enum SDUIFieldType {
  shortText("short-text"),
  mediumText("medium-text"),
  longText("long-text"),
  text("text"),
  email("email"),
  url("url"),
  number("number"),
  password("password"),
  phone("phone"),
  country("country"),
  boolean("boolean"),
  options("options"),
  date("date"),
  datetime("datetime"),
  file("file"),
  image("image"),
  video("video"),
  document("document"),
  unknown("unknown"),
  tag("tag");

  final String value;
  const SDUIFieldType(this.value);

  factory SDUIFieldType.fromValue(String value) {
    return SDUIFieldType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SDUIFieldType.unknown,
    );
  }
}
