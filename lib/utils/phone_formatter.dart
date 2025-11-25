/// 전화번호 포맷팅 및 유효성 검사 유틸리티
/// 
/// 앱 전체에서 일관된 전화번호 처리를 제공합니다.
class PhoneFormatter {
  PhoneFormatter._(); // 인스턴스 생성 방지

  /// 전화번호에서 숫자만 추출
  /// 
  /// [phoneNumber]: 원본 전화번호
  /// Returns: 숫자만 포함된 문자열
  /// 
  /// Example:
  /// ```dart
  /// PhoneFormatter.cleanPhoneNumber('010-1234-5678'); // '01012345678'
  /// PhoneFormatter.cleanPhoneNumber('+82-10-1234-5678'); // '+821012345678'
  /// ```
  static String cleanPhoneNumber(String phoneNumber) {
    // + 기호는 유지하고 나머지 특수문자/공백 제거
    return phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// 전화번호를 한국 형식으로 포맷팅
  /// 
  /// [phoneNumber]: 포맷팅할 전화번호
  /// Returns: 하이픈이 포함된 포맷팅된 전화번호
  /// 
  /// 지원 형식:
  /// - 휴대폰: 010-1234-5678 (11자리)
  /// - 서울 지역번호: 02-1234-5678 (10자리, 02로 시작)
  /// - 기타 지역번호: 031-123-4567 (10자리)
  /// - 대표번호: 1588-1234 (8자리)
  /// 
  /// Example:
  /// ```dart
  /// PhoneFormatter.format('01012345678'); // '010-1234-5678'
  /// PhoneFormatter.format('0212345678');  // '02-1234-5678'
  /// PhoneFormatter.format('15881234');    // '1588-1234'
  /// ```
  static String format(String phoneNumber) {
    final cleaned = cleanPhoneNumber(phoneNumber);
    
    // 국제번호 형식 (+82)
    if (cleaned.startsWith('+82')) {
      final withoutPrefix = cleaned.substring(3);
      if (withoutPrefix.length == 10) {
        return '+82-${withoutPrefix.substring(0, 2)}-${withoutPrefix.substring(2, 6)}-${withoutPrefix.substring(6)}';
      } else if (withoutPrefix.length == 9) {
        return '+82-${withoutPrefix.substring(0, 1)}-${withoutPrefix.substring(1, 5)}-${withoutPrefix.substring(5)}';
      }
      return phoneNumber; // 포맷팅 불가능한 경우 원본 반환
    }
    
    // 10자리 (지역번호 포함)
    if (cleaned.length == 10) {
      if (cleaned.startsWith('02')) {
        // 서울: 02-1234-5678
        return '${cleaned.substring(0, 2)}-${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
      }
      // 기타 지역: 031-123-4567
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    
    // 11자리 (휴대폰)
    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
    }
    
    // 8자리 (대표번호: 1588-1234)
    if (cleaned.length == 8 && (cleaned.startsWith('15') || cleaned.startsWith('16'))) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4)}';
    }
    
    // 7자리 (국번: 123-4567)
    if (cleaned.length == 7) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3)}';
    }
    
    // 포맷팅할 수 없는 경우 원본 반환
    return phoneNumber;
  }

  /// 한국 전화번호 유효성 검사
  /// 
  /// [phoneNumber]: 검증할 전화번호
  /// Returns: 유효한 전화번호인 경우 true
  /// 
  /// 검증 규칙:
  /// - 최소 길이: 7자리 (국번)
  /// - 휴대폰: 010/011/016/017/018/019로 시작하는 10-11자리
  /// - 지역번호: 02/031-064로 시작하는 9-10자리
  /// - 대표번호: 1588/1577/1566 등으로 시작하는 8자리
  /// - 긴급전화: 112/119/110 등 3자리
  /// - 국제번호: +82로 시작
  /// 
  /// Example:
  /// ```dart
  /// PhoneFormatter.isValid('010-1234-5678'); // true
  /// PhoneFormatter.isValid('02-1234-5678');  // true
  /// PhoneFormatter.isValid('119');           // true
  /// PhoneFormatter.isValid('123');           // false
  /// ```
  static bool isValid(String phoneNumber) {
    final cleaned = cleanPhoneNumber(phoneNumber);
    
    // 빈 문자열 체크
    if (cleaned.isEmpty) {
      return false;
    }
    
    // 긴급전화 (3자리)
    if (isEmergencyNumber(phoneNumber)) {
      return true;
    }
    
    // 최소 길이 확인 (긴급전화 제외)
    if (cleaned.length < 7) {
      return false;
    }
    
    // 한국 전화번호 패턴
    final patterns = [
      // 휴대폰: 010/011/016/017/018/019 (10-11자리)
      RegExp(r'^01[0-9]\d{7,8}$'),
      
      // 서울 지역번호: 02 (9-10자리)
      RegExp(r'^02\d{7,8}$'),
      
      // 기타 지역번호: 031-064 (9-10자리)
      RegExp(r'^0[3-6]\d\d{6,7}$'),
      
      // 대표번호: 1588/1577/1566/1644/1661/1670/1688 (8자리)
      RegExp(r'^1[5-6]\d{2}\d{4}$'),
      
      // 국제번호: +82 (12-14자리)
      RegExp(r'^\+82\d{9,11}$'),
    ];
    
    return patterns.any((pattern) => pattern.hasMatch(cleaned));
  }

  /// 긴급 전화번호 여부 확인
  /// 
  /// [phoneNumber]: 확인할 전화번호
  /// Returns: 긴급 전화번호인 경우 true
  /// 
  /// 긴급 전화번호 목록:
  /// - 112: 경찰
  /// - 119: 소방/구급
  /// - 110: 민원 (경찰청)
  /// - 113: 국가정보원
  /// - 117: 학교폭력신고
  /// - 118: 해양경비안전본부
  /// - 122: 해양오염신고
  /// - 127: 손해보험협회
  /// - 1339: 응급의료정보센터
  /// - 1388: 청소년전화
  /// - 1577-0199: 법률구조공단
  /// 
  /// Example:
  /// ```dart
  /// PhoneFormatter.isEmergencyNumber('119');  // true
  /// PhoneFormatter.isEmergencyNumber('112');  // true
  /// PhoneFormatter.isEmergencyNumber('1339'); // true
  /// PhoneFormatter.isEmergencyNumber('010-1234-5678'); // false
  /// ```
  static bool isEmergencyNumber(String phoneNumber) {
    final cleaned = cleanPhoneNumber(phoneNumber);
    
    const emergencyNumbers = [
      '112',   // 경찰
      '119',   // 소방/구급
      '110',   // 민원 (경찰청)
      '113',   // 국가정보원
      '117',   // 학교폭력신고
      '118',   // 해양경비안전본부
      '122',   // 해양오염신고
      '127',   // 손해보험협회
      '1339',  // 응급의료정보센터
      '1388',  // 청소년전화
    ];
    
    return emergencyNumbers.contains(cleaned);
  }

  /// 전화번호 타입 확인
  /// 
  /// [phoneNumber]: 확인할 전화번호
  /// Returns: PhoneType enum
  /// 
  /// Example:
  /// ```dart
  /// PhoneFormatter.getType('010-1234-5678'); // PhoneType.mobile
  /// PhoneFormatter.getType('02-1234-5678');  // PhoneType.landline
  /// PhoneFormatter.getType('119');           // PhoneType.emergency
  /// ```
  static PhoneType getType(String phoneNumber) {
    final cleaned = cleanPhoneNumber(phoneNumber);
    
    // 긴급전화
    if (isEmergencyNumber(phoneNumber)) {
      return PhoneType.emergency;
    }
    
    // 휴대폰
    if (cleaned.startsWith('01')) {
      return PhoneType.mobile;
    }
    
    // 서울 지역번호
    if (cleaned.startsWith('02')) {
      return PhoneType.landline;
    }
    
    // 기타 지역번호
    if (cleaned.startsWith('0') && cleaned.length >= 9) {
      return PhoneType.landline;
    }
    
    // 대표번호
    if (cleaned.startsWith('1') && cleaned.length == 8) {
      return PhoneType.representative;
    }
    
    // 국제번호
    if (cleaned.startsWith('+82')) {
      return PhoneType.international;
    }
    
    return PhoneType.unknown;
  }

  /// 두 전화번호가 동일한지 비교 (숫자만 비교)
  /// 
  /// [phone1]: 첫 번째 전화번호
  /// [phone2]: 두 번째 전화번호
  /// Returns: 동일한 번호인 경우 true
  /// 
  /// Example:
  /// ```dart
  /// PhoneFormatter.areEqual('010-1234-5678', '01012345678'); // true
  /// PhoneFormatter.areEqual('010 1234 5678', '010-1234-5678'); // true
  /// ```
  static bool areEqual(String phone1, String phone2) {
    final cleaned1 = cleanPhoneNumber(phone1);
    final cleaned2 = cleanPhoneNumber(phone2);
    return cleaned1 == cleaned2;
  }

  /// 전화번호를 국제 형식(+82)으로 변환
  /// 
  /// [phoneNumber]: 변환할 전화번호
  /// Returns: +82 형식의 전화번호
  /// 
  /// Example:
  /// ```dart
  /// PhoneFormatter.toInternational('010-1234-5678'); // '+82-10-1234-5678'
  /// PhoneFormatter.toInternational('02-1234-5678');  // '+82-2-1234-5678'
  /// ```
  static String toInternational(String phoneNumber) {
    final cleaned = cleanPhoneNumber(phoneNumber);
    
    // 이미 국제 형식인 경우
    if (cleaned.startsWith('+82')) {
      return format(cleaned);
    }
    
    // 0으로 시작하는 경우 0 제거 후 +82 추가
    if (cleaned.startsWith('0')) {
      final withoutZero = cleaned.substring(1);
      return format('+82$withoutZero');
    }
    
    // 그 외의 경우 그대로 +82 추가
    return format('+82$cleaned');
  }

  /// 국제 형식(+82)을 국내 형식으로 변환
  /// 
  /// [phoneNumber]: 변환할 전화번호
  /// Returns: 0으로 시작하는 국내 형식 전화번호
  /// 
  /// Example:
  /// ```dart
  /// PhoneFormatter.toDomestic('+82-10-1234-5678'); // '010-1234-5678'
  /// PhoneFormatter.toDomestic('+82-2-1234-5678');  // '02-1234-5678'
  /// ```
  static String toDomestic(String phoneNumber) {
    final cleaned = cleanPhoneNumber(phoneNumber);
    
    // +82로 시작하는 경우
    if (cleaned.startsWith('+82')) {
      final withoutPrefix = cleaned.substring(3);
      return format('0$withoutPrefix');
    }
    
    // 이미 국내 형식인 경우
    return format(cleaned);
  }

  /// 전화번호가 특정 패턴과 일치하는지 확인
  /// 
  /// [phoneNumber]: 확인할 전화번호
  /// [pattern]: 검색 패턴 (숫자만)
  /// Returns: 패턴이 포함된 경우 true
  /// 
  /// Example:
  /// ```dart
  /// PhoneFormatter.matches('010-1234-5678', '1234'); // true
  /// PhoneFormatter.matches('02-1234-5678', '010');   // false
  /// ```
  static bool matches(String phoneNumber, String pattern) {
    final cleanedPhone = cleanPhoneNumber(phoneNumber);
    final cleanedPattern = cleanPhoneNumber(pattern);
    return cleanedPhone.contains(cleanedPattern);
  }
}

/// 전화번호 타입
enum PhoneType {
  /// 휴대폰 (010, 011, 016, 017, 018, 019)
  mobile,
  
  /// 유선 전화 (지역번호)
  landline,
  
  /// 대표번호 (1588, 1577 등)
  representative,
  
  /// 긴급전화 (112, 119 등)
  emergency,
  
  /// 국제번호 (+82)
  international,
  
  /// 알 수 없음
  unknown,
}

extension PhoneTypeExtension on PhoneType {
  /// 전화번호 타입의 한글 이름
  String get displayName {
    switch (this) {
      case PhoneType.mobile:
        return '휴대폰';
      case PhoneType.landline:
        return '유선전화';
      case PhoneType.representative:
        return '대표번호';
      case PhoneType.emergency:
        return '긴급전화';
      case PhoneType.international:
        return '국제번호';
      case PhoneType.unknown:
        return '알 수 없음';
    }
  }

  /// 전화번호 타입의 아이콘 제안
  String get icon {
    switch (this) {
      case PhoneType.mobile:
        return '📱';
      case PhoneType.landline:
        return '☎️';
      case PhoneType.representative:
        return '🏢';
      case PhoneType.emergency:
        return '🚨';
      case PhoneType.international:
        return '🌐';
      case PhoneType.unknown:
        return '❓';
    }
  }
}