/// 페이징 요청 시 공통 클래스
class PageRequestModel {
  final String? sortBy;
  final String? sortOrder;
  final int? size;
  final String? cursor;

  const PageRequestModel({
    this.sortBy,
    this.sortOrder,
    this.size,
    this.cursor,
  });

  bool get isDefault =>
      sortBy == null && sortOrder == null && size == null && cursor == null;

  PageRequestModel copyWith({
    String? sortBy,
    String? sortOrder,
    int? size,
    String? cursor,
  }) {
    return PageRequestModel(
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      size: size ?? this.size,
      cursor: cursor ?? this.cursor,
    );
  }

  PageRequestModel get cursorCleared => PageRequestModel(
        sortBy: sortBy,
        sortOrder: sortOrder,
        size: size,
        cursor: null,
      );

  @override
  int get hashCode {
    if (isDefault) {
      return super.hashCode;
    }
    return (sortBy?.hashCode ?? 0) ^
        (sortOrder?.hashCode ?? 0) ^
        (size?.hashCode ?? 0) ^
        (cursor?.hashCode ?? 0);
  }

  @override
  bool operator ==(Object other) {
    if (other is PageRequestModel) {
      return sortBy == other.sortBy &&
          sortOrder == other.sortOrder &&
          size == other.size &&
          cursor == other.cursor;
    } else {
      return false;
    }
  }

  Map<String, dynamic> toJson() {
    final ret = <String, dynamic>{};
    if (sortBy != null) {
      ret['sortBy'] = sortBy;
    }
    if (sortOrder != null) {
      ret['sortOrder'] = sortOrder;
    }
    if (size != null) {
      ret['size'] = size;
    }
    if (cursor != null) {
      ret['cursor'] = cursor;
    }
    return ret;
  }
}
