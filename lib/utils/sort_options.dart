/// 정렬 옵션
enum SortOption {
  /// 이름순 (가나다순)
  nameAsc,
  
  /// 최근 통화순 (최근 통화한 순서대로)
  lastCalledDesc,
  
  /// 생성일순 (오래된 순서대로)
  createdAtAsc,
  
  /// 생성일 역순 (최근 생성한 순서대로)
  createdAtDesc,
  
  /// 사용자 지정 순서 (드래그 앤 드롭)
  custom,
}

extension SortOptionExtension on SortOption {
  /// 정렬 옵션 한글 이름
  String get displayName {
    switch (this) {
      case SortOption.nameAsc:
        return '이름순';
      case SortOption.lastCalledDesc:
        return '최근 통화순';
      case SortOption.createdAtAsc:
        return '오래된 순';
      case SortOption.createdAtDesc:
        return '최근 생성순';
      case SortOption.custom:
        return '사용자 지정';
    }
  }

  /// 정렬 옵션 설명
  String get description {
    switch (this) {
      case SortOption.nameAsc:
        return '이름을 가나다순으로 정렬합니다';
      case SortOption.lastCalledDesc:
        return '최근 통화한 순서대로 정렬합니다';
      case SortOption.createdAtAsc:
        return '오래전에 만든 순서대로 정렬합니다';
      case SortOption.createdAtDesc:
        return '최근에 만든 순서대로 정렬합니다';
      case SortOption.custom:
        return '드래그하여 원하는 순서대로 배치합니다';
    }
  }
}