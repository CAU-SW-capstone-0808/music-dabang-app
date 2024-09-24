import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:music_dabang/models/common/page_request_model.dart';
import 'package:music_dabang/models/common/page_response_model.dart';

abstract class AbstractPageNotifier<T> extends StateNotifier<List<T>> {
  PageRequestModel __pageRequestModel;
  PageResponseModel? lastResponse;

  PageRequestModel get pageRequestModel => __pageRequestModel;
  Map<String, dynamic> get queries => pageRequestModel.toJson();
  set pageRequestModel(PageRequestModel x) {
    if (x != __pageRequestModel) {
      __pageRequestModel = x;
      refresh();
    }
  }

  bool get loading => lastResponse == null;
  bool get pagingDone => lastResponse != null && lastResponse!.cursor == null;
  // PageRequestModel get requestModel => _requestModel;
  //
  // /// requestModel 수정 -> refresh() 호출
  // set requestModel(PageRequestModel x) {
  //   if (x != _requestModel) {
  //     _requestModel = x;
  //     refresh();
  //   }
  // }

  /// StateNotifier를 통한 페이징 공통화
  AbstractPageNotifier({
    PageRequestModel pageRequestModel = const PageRequestModel(),
  })  : __pageRequestModel = pageRequestModel,
        super([]) {
    fetch();
  }

  /// 자식 클래스에서 구현해야 하는 페이징 호출
  /// 자신의 필드를 사용한다.
  Future<PageResponseModel> getList({required PageRequestModel pageRequest});

  /// json으로부터 T를 반환하는 함수 구현을 자식 클래스에게 맡김.
  T fromJson(Map<String, dynamic> json);

  /// fetch(): 리스트를 더 받아올 수 있으면 받아온다.
  Future<List<T>> fetch() async {
    // 마지막 응답에서 cursor가 null이었을 경우 더 받아올 것이 없음
    if (lastResponse != null && lastResponse!.cursor == null) {
      return [];
    }

    // request cursor 조정
    __pageRequestModel =
        __pageRequestModel.copyWith(cursor: lastResponse?.cursor);
    // 응답 처리
    lastResponse = await getList(pageRequest: __pageRequestModel);

    try {
      final data = lastResponse!.getData<T>(this.fromJson);
      state += data;
      return data;
    } catch (e) {
      print("paging type cast error - type:$T $e");
      print(e);
      Fluttertoast.showToast(msg: "데이터를 받아오는 중 오류가 발생했습니다");
    }
    return [];
  }

  Future<List<T>> refresh({bool clear = true}) async {
    if (clear) {
      state = [];
    }
    lastResponse = null;
    __pageRequestModel = __pageRequestModel.cursorCleared;
    return state = await fetch();
  }

  void clear() {
    state = [];
    lastResponse = null;
    __pageRequestModel = const PageRequestModel();
  }
}
