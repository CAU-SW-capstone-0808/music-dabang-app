enum UserAge {
  age30("30대 이하"),
  age40("40대 [40~49세]"),
  age50("50대 [50~59세]"),
  age60("60대 [60~69세]"),
  age70("70대 [70~79세]"),
  age80("80대 이상");

  final String displayName;

  const UserAge(this.displayName);
}
