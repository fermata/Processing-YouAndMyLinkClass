# 너와나의 연결고리 API 문서

## 일러두기
* 모든 요청의 결과는 JSON형태로 반환된다.
* 모든 요청에 대해서 의도하지 않은 결과가 발생했을 경우 `success`의 값이 `false`로 반환되며 성공시 `true`로 반환된다. 여기서 '의도하지 않은 결과'란 
* 요청의 몸체(Body)는 JSON이 아닌 Query String을 사용한다. 비 라틴 문자는 URL 인코딩을 해야한다.
* JSON의 키 이름이 복수형인 경우 해당 값은 배열이다.

## 회원 가입 및 인증

### 회원 가입

#### 요청
```
	POST /user/add
  
	username=<사용자아이디>&password=<비밀번호>
```
#### 응답 예시
```json
  {
    "success": true,
    "status": "USER_ADDED",
    "user": {
      "id": 1,
      "username": "testuser"
    }
  }
```

### 로그인

추후 인증이 필요한 API를 접근하려면 접근 토큰(Access Token)을 API요청에 실어 보내야한다. 본 API는 아이디와 비밀번호를 받아 사용자의 Access Token을 발급한다. 아이디나 비밀번호가 틀린 경우 `success`에 `false`를 반환한다.
#### 요청
```
	POST /user/auth

	username=<사용자아이디>&password=<비밀번호>
```
#### 응답 예시
```json
  {
    "success": true,
    "status": "OK",
    "user": {
      "id": 1,
      "username": "haechan"
    },
    "access_token": "haechan.7cdc94bc4fa23ff7ce354b80cd6b4129e6ae961e6bccb7231574166ad11092b31"
  }
```

## 수업 조회

### 등록된 모든 수업 조회
#### 요청
```
	GET /class
```
#### 응답 예시
```json
  {
    "success": true,
    "status": "OK",
    "classes": [
      {
        "id": 1,
        "code": "0362",
        "name": "창의적 공학 설계",
        "professor": "민덕기"
      },
      {
        "id": 2,
        "code": "0554",
        "name": "정보 통신 기초",
        "professor": "김민욱"
      },
      {
        "id": 4,
        "code": "0231",
        "name": "두번째 테스트 수업",
        "professor": "최교수"
      }
    ]
  }
```

### 특정 수업 조회 (강의코드)
#### 요청
```
	GET /class/<강의 코드번호>
```
#### 응답 예시
```json
  {
    "success": true,
    "status": "OK",
    "class": {
      "id": 2,
      "code": "0554",
      "name": "정보 통신 기초",
      "professor": "김민욱"
    }
  }
```

## 개인정보 관련
회원 개인에 귀속된 데이터를 조회하는 요청은 모두 `/me`로 시작한다. 이 API는 반드시 `access_token`의 값을 명시해주어야한다.

### 현재 사용자의 정보 조회
#### 요청
```
	GET /me?access_token=<토큰>
```
#### 응답
```json
  {
    "success": true,
    "status": "OK",
    "user": {
      "id": 1,
      "username": "haechan"
    }
  }
```

### 현재 사용자의 찜 정보 조회
현재 사용자가 찜을 누른 강의의 목록을 반환한다.
#### 요청
```
	GET /me/jjim?access_token=토큰
```
#### 응답
```json
  {
    "success": true,
    "status": "OK",
    "jjims": [
      {
        "id": 1,
        "code": "0362",
        "name": "창의적 공학 설계",
        "professor": "민덕기"
      },
      {
        "id": 2,
        "code": "0554",
        "name": "정보 통신 기초",
        "professor": "김민욱"
      }
    ]
  }
```

### 다른 사용자의 찜 조회 (공통찜 여부 포함)
#### 요청
```
  GET /me/jjim/<다른 사람 아이디>?access_token=토큰
```
#### 응답
`classes`에는 타 유저의 찜 수업 목록이 들어간다. 각 수업에는 `common`필드가 있는데 이 필드의 값으로 나와 해당 사람의 공통찜 여부를 확인할 수 있다.
아래와 같은 경우는 0362 수업은 회원 본인과 타 회원이 동시에 찜 한 수업이고, 0231은 타 사용자는 찜해두었지만 회원 본인은 찜하지 않은 수업이다.
```json
  {
    "success": true,
    "status": "OK",
    "classes": [
      {
        "id": 1,
        "code": "0362",
        "name": "창의적 공학 설계",
        "professor": "민덕기",
        "common": true
      },
      {
        "id": 4,
        "code": "0231",
        "name": "두번째 테스트 수업",
        "professor": "최교수",
        "common": false
      }
    ]
  }
```

### 찜목록에 추가
#### 요청
```
  POST /me/jjim?access_token=토큰

  class=<강의 코드번호>
```
#### 응답
강의 코드에 대한 수업을 찾을 수 없으면 `status`에 `CLASS_NOT_FOUND`를 반환한다.
이미 찜이 되어있는 수업은 `ALREADY_ADDED_TO_JJIMS`를 반환한다.
```json
  {
    "success": true,
    "status": "JJIM_ADDED"
  }
```

### 찜목록에서 삭제
#### 요청
```
  DELETE /me/jjim/<강의 코드번호>?access_token=토큰
```
#### 응답
강의 코드에 대한 수업을 찾을 수 없으면 `status`에 `CLASS_NOT_FOUND`를 반환한다.
찜이 이미 취소된 수업이거나 찜이 안된 수업은 `JJIM_NOT_FOUND`를 반환한다.
```json
  {
    "success": true,
    "status": "JJIM_REMOVED"
  }
```