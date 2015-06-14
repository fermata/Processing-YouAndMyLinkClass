# 너와나의 연결고리 문서

## NNRestServer
Processing의 Server객체를 이용하여 구현된 TCP 통신 서버이다. '너와나의 연결고리' 프로젝트에서 RESTful API서버를 구현하기 위하여 개발하였으며, 간단한 HTTP 요청을 처리할 수 있다.

### 생성자

#### NNRestServer (PApplet parent, int port)
생성자를 사용하는 방법은 Processing의 `Server`와 동일하다.
- `parent` : 상위 `PApplet`객체. 일반적으로 `this`를 사용.
- `port` : HTTP 요청을 받을 포트번호

### 메소드

#### void accept()
Processing PApplet의 draw() 메소드에서 호출하여 요청을 받아들인다.

```java
    NNRestServer restfulServer;

    void setup() {
        restfulServer = new NNRestServer(this, 8080);
        // ...
    }

    void draw() {
        restfulServer.accept();
    }
```

#### void get(String urlPattern, NNActionHandler handler)
HTTP `GET` 요청을 처리한다. 요청된 URI와 `urlPattern`을 비교하여 일치하는 경우 `NNActionHandler`의 `onActivity(NNRestActivity, ArrayList)`메소드를 실행한다. `urlPattern`내에는 디렉토리 구분자 `/` 사이에 와일드카드 `*`이 허용되며, `*`부분에 해당하는 내용은 순서대로 `String`형태로 `ArrayList`에 담겨 `NNActionHandler`의 `onActivity()`의 두번째 인자로 전달된다.

```java
    NNRestServer restfulServer;

    void setup() {
        restfulServer = new NNRestServer(this, 8080);

        restfulServer.get("/", new NNActivityHandler(){
            @Override
            public void onActivity (NNRestActivity activity, ArrayList params) {
                activity.response.plain("도메인 루트");
                activity.quit();
            }
        });
        
		/* 와일드카드 사용 예시
           /test/132/work/62
           => TEST:132 WORK:62
        */
        restfulServer.get("/test/*/work/*", new NNActivityHandler(){
            @Override
            public void onActivity (NNRestActivity activity, ArrayList params) {
                String text = "TEST:" + params.get(0) + " WORK:" + params.get(1);
                activity.response.json(text);
                activity.quit();
            }
        });
    }

    void draw() {
        restfulServer.accept();
    }
```

#### void put(String urlPattern, NNActionHandler handler)
HTTP `PUT` 요청을 처리한다. 사용법은 `get(String urlPattern, NNActionHandler handler)`과 동일

#### void post(String urlPattern, NNActionHandler handler)
HTTP `POST` 요청을 처리한다. 사용법은 `get(String urlPattern, NNActionHandler handler)`과 동일

#### void remove(String urlPattern, NNActionHandler handler)
HTTP `REMOVE` 요청을 처리한다. 사용법은 `get(String urlPattern, NNActionHandler handler)`과 동일

#### void use(String urlPattern, NNActionHandler handler)
HTTP 요청 방식에 관계없이 요청 URI의 패턴만 일치하면 실행한다. 단 이후 동일한 패턴으로 `get()`, `put()`, `remove()`, `post()`가 정의 되어있다면 두가지 모두 실행된다. 만약 `use()`만 처리하고 더이상 요청 핸들러가 실행되기를 원하지 않는다면 `activity.quit()`을 해준다. 나머지 사용법은 `get(String urlPattern, NNActionHandler handler)`과 동일 

#### void begins(String urlPrefix, NNActionHandler handler)
HTTP 요청 방식에 관계없이 URI가 `urlPrefix`로 시작한다면 실행한다. 사용자 토큰 유효성 여부 등을 파악하는데 사용 가능하다. 예외처리 이후 더이상 요청이 처리되기를 원하지 않는다면 `activity.quit()`을 해준다.

### NNActivityHandler (Interface)

#### void onActivity(NNRestActivity activity, ArrayList params)
HTTP 요청을 처리하기 위한 핸들러 인터페이스이다. 현재 서버와 클라이언트 사이에 생성된 `NNRestActivity` 객체와 URL 패턴에서 와일드 카드의 위치에 해당하는 값을 순서대로 `params`에 담아 전달한다.

### NNRestActivity

#### void quit()
해당 Activity에 한해서 더 이상 Activity Handler를 실행하지 않는다. 이 메소드를 호출한 핸들러까지만 마저 실행된다.

#### NNRestRequest request
요청에 관한 정보와 메소드가 담긴 객체

#### NNRestResponse response
응답에 관한 정보와 메소드가 담긴 객체

### NNRestRequest

#### String method
HTTP 요청방식이 저장된다. `GET`, `POST` 등...

#### String path
HTTP 요청의 URI가 저장된다. 예를들어 `http://localhost:8080/test/325`로 요청이 되었다면 `/test/325`가 저장된다.

#### HashMap getParams
HTTP 요청의 URL 파라미터가 저장된다. `http://localhost:8080/test/325?key=value&key2=value`가 요청되었다면 `activity.request.getParams.get("key")`는 `"value"`이다.

### NNRestResponse

#### void json (NNDictionary)
`NNDictionary`의 내용을 JSON으로 직렬화하여 `Content-Type: text/json`으로 응답한다.
```java
	restfulServer.get("/", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			NNDictionary dictionary = new NNDictionary();
			dictionary.put("test").set("하하하하");
			dictionary.put("value").set("ahaaha");
			NNDictionary subDictionary = new NNDictionary();
			subDictionary.put("another").set(1523);
			subDictionary.put("value").set(false);
			dictionary.put("subDictionary").set(subDictionary);
			activity.response.json(dictionary);
			activity.quit();
		}
	});
```

#### void plain (String)
`String`의 내용을 `Content-Type: text/plain`으로 응답한다.
```java
	restfulServer.get("/", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			activity.response.plain("안녕하세요");
			activity.quit();
		}
	});
```

#### void html (String)
`String`의 내용을 `Content-Type: text/html`으로 응답한다.
```java
	restfulServer.get("/", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
        	String[] lines = loadStrings("static/index.html");
            StringBuffer sb = new StringBuffer();
            for(int l = 0; l < lines; l++){
            	sb.append(lines[l] + "\n");
            }
			activity.response.html(sb.toString());
			activity.quit();
		}
	});
```




