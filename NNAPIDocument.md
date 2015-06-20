# NNAPI 사용법

## 일러두기
- 모든 요청결과는 `JSONObject`로 반환된다. 이 객체에 관한 설명은 [Processing:JSONObject] 참조
- API 요청 진입점과 반환 형태는 API 문서를 참고

## API 객체 생성
```java
  NNAPI api = new NNAPI("<서버 주소>"); // http://localhost:8080
```

## 인스턴스 변수

### accessToken
- __자료형__ : String
서버에서 전달 받은 accessToken을 여기에 저장하면 모든 요청에 자동으로 accessToken이 추가된다.
```java
  api.accessToken = <서버에서 전달받은 토큰>;
```

## 메소드

### .__get__(String _API주소_)
HTTP요청을 GET 방식으로 처리한다.
- __반환형__ : JSONObject
```java
  JSONObject result = api.get("/class");
  println("응답:" + result.getString("status"));
```

### .__post__(String _API주소_)
HTTP요청을 POST 방식으로 처리한다. 단, 전달 값이 없다.
- __반환형__ : JSONObject
```java
  JSONObject result = api.post("/me/");
  println("응답:" + result.getString("status"));
```

### .__post__(String _API주소_, NNDictionary _전달할 값_)
HTTP요청을 POST 방식으로 처리한다. `NNDictionary`객체로 서버에 전달할 값을 받는다.
- __반환형__ : JSONObject
```java
  NNDictionary data = new NNDictionary(); // 새 NNDictionary 객체 생성
  data.key("username").set("haechan"); // username 키에 haechan 값 저장
  data.key("password").set("1234"); // password 키에 1234 값 저장
  JSONObject result = api.post("/user/auth", data);
  println("응답:" + result.getString("status"));
  api.accessToken = result.getString("access_token");
```

### .__post__(String _API주소_)
HTTP요청을 POST 방식으로 처리한다. 단, 전달 값이 없다.
- __반환형__ : JSONObject
```java
  JSONObject result = api.post("/class");
  println("응답:" + result.getString("status"));
```



[Processing:JSONObject]: https://processing.org/reference/JSONObject.html