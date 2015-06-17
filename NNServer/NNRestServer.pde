import processing.net.*;
import java.security.*;

/**
 * SHA256으로 해싱된 문자열을 반환한다.
 */
String sha256 (String message) {
	try {
		MessageDigest md = MessageDigest.getInstance("SHA-256");
		md.update(message.getBytes());
		byte[] byteData = md.digest();
		StringBuffer sb = new StringBuffer(); 
		for(int i = 0 ; i < byteData.length ; i++){
			sb.append(Integer.toString((byteData[i]&0xff) + 0x100, 16).substring(1));
		}
		return sb.toString();
	} catch (Exception e) {
		e.printStackTrace();
		return null;
	}
}

/**
 * URL Encoding 된 문자열을 Decode한다.
 */
String decodeURL (String input) {
	try {
		return new String(input.getBytes("UTF-8"), "ASCII");
	} catch (Exception e) {
		e.printStackTrace();
	}
	return null;
}

/**
 * Processing의 Server객체를 이용하여 구현한 HTTP 서버이다. '너와나의 연결고리' 프로젝트에서 RESTful API서버를 구현하기 위하여 개발하였으며, 간단한 HTTP 요청을 처리할 수 있다.
 * 각 URI에 대한 핸들러를 정의해 보관할 수 있다.
 * 이름은 REST용이지만 그냥 간단한 HTTP서버라서 정적파일 호스팅도 가능하다ㅋ 만들다 보니 그렇게 되었다.
 * https://github.com/Fermata/Processing-YouAndMyLinkClass/blob/master/Documentation.md 에서 자세한 사용법을 확인할 수 있다.
 */
class NNRestServer {
	private int port;
	private Server server;
	private NNURLHandlerList handlersAll;
	private NNURLBeginsHandlerList handlersBegins;
	private NNURLHandlerList handlersGet;
	private NNURLHandlerList handlersPost;
	private NNURLHandlerList handlersPut;
	private NNURLHandlerList handlersDelete;

	/**
	 * 생성자를 사용하는 방법은 Processing의 Server와 동일하다.
	 * @param PApplet parent 상위 PApplet객체. 일반적으로 this를 사용.
	 * @param int port HTTP 요청을 받을 포트번호
	 */
	public NNRestServer (PApplet parent, int port) {
		this.port = port;
		this.server = new Server(parent, port);
		this.handlersAll = new NNURLHandlerList();
		this.handlersBegins = new NNURLBeginsHandlerList();
		this.handlersGet = new NNURLHandlerList();
		this.handlersPost = new NNURLHandlerList();
	}

	/**
	 * draw()에서 호출할 메소드. 요청을 받아들인다.
	 * 서버객체와 클라이언트객체로 NNRestActivity 객체를 생성한 뒤 workActivity()를 실행한다.
	 */
	public void accept () {
		Client client = this.server.available();
		if (client != null) {
			this.workActivity(new NNRestActivity(this.server, client));
		}
	}

	/**
	 * 등록된 Hanlder들을 요청 종류에 따라 처리한다.
	 */
	private void workActivity (NNRestActivity activity) {
		activity.start();
		this.handlersAll.handle(activity);
		if(!activity.shouldStart()) return;
		activity.start();
		this.handlersBegins.handle(activity);
		if(!activity.shouldStart()) return;
		activity.start();
		if(activity.request.method.equals("GET")){
			this.handlersGet.handle(activity);
		}
		if(activity.request.method.equals("POST")){
			this.handlersPost.handle(activity);
		}
		if(activity.request.method.equals("PUT")){
			this.handlersPut.handle(activity);
		}
		if(activity.request.method.equals("DELETE")){
			this.handlersDelete.handle(activity);
		}
		if(!activity.shouldStart()) return;
		activity.response.notFound();
		return;
	}

	/**
	 * urlPattern에 해당하는 GET 요청을 처리할 handler를 등록한다.
	 */
	public void get(String urlPattern, NNActivityHandler handler) {
		this.handlersGet.add(urlPattern, handler);
	}

	/**
	 * urlPattern에 해당하는 POST 요청을 처리할 handler를 등록한다.
	 */
	public void post(String urlPattern, NNActivityHandler handler) {
		this.handlersPost.add(urlPattern, handler);
	}

	/**
	 * urlPattern에 해당하는 PUT 요청을 처리할 handler를 등록한다.
	 */
	public void put(String urlPattern, NNActivityHandler handler) {
		this.handlersPut.add(urlPattern, handler);
	}

	/**
	 * urlPattern에 해당하는 DELETE 요청을 처리할 handler를 등록한다.
	 */
	public void delete(String urlPattern, NNActivityHandler handler) {
		this.handlersDelete.add(urlPattern, handler);
	}

	/**
	 * url로 시작하는 모든 요청에 대해 선행될 handler를 등록한다. 본 프로젝트에서 /me 요청에 대해 인증작업을 선행하는데 사용하고 있다.
	 */
	public void begins(String url, NNActivityHandler handler) {
		this.handlersBegins.add(url, handler);
	}

	/**
	 * urlPattern에 해당하는 모든 방식의 요청을 처리할 handler를 등록한다.
	 */
	public void use(String urlPattern, NNActivityHandler handler) {
		this.handlersAll.add(urlPattern, handler);
	}
}

interface NNActivityHandler {
	public void onActivity (NNRestActivity activity, ArrayList params);
}

/**
 * Handler들을 저장할 수 있는 ArrayList이다. handle()에 activity를 넣으면 URI 패턴에 따라 필요한 핸들러를 실행한다.
 * URI에 *을 넣어서 와일드 카드처리가 가능하다.
 * NNRestServer 내부에서만 사용하므로 외부에서 직접 생성해 사용할 일은 없다.
 */
class NNURLHandlerList {
	private ArrayList handlers;

	public NNURLHandlerList () {
		this.handlers = new ArrayList();
	}

	public boolean handle (NNRestActivity activity) {
		int handlersSize = this.handlers.size();
		for(int i = 0; i < handlersSize; i += 2){
			String pattern = (String)(this.handlers.get(i));
			String regex = ("\\Q" + pattern + "\\E").replace("*", "\\E.*\\Q");
			if(activity.request.path.matches(regex)){
				NNActivityHandler handler = (NNActivityHandler)(this.handlers.get(i+1));
				this.matched(activity, pattern, handler);
				return true;
			}
		}
		return false;
	}

	private void matched (NNRestActivity activity, String pattern, NNActivityHandler handler) {
		String[] patternComponents = pattern.split("/");
		String[] urlComponents = activity.request.path.split("/");
		ArrayList params = new ArrayList();
		for(int c = 0; c < patternComponents.length; c++){
			if(patternComponents[c].equals("*")){
				params.add(decodeURL(urlComponents[c]));
			}
		}
		handler.onActivity(activity, params);
	}

	public void add (String urlPattern, NNActivityHandler handler) {
		this.handlers.add(urlPattern);
		this.handlers.add(handler);
	}
}

/**
 * NNURLHandlerList와 유사하나 패턴일치가 아니라 URI가 특정 문자열로 시작하는지만 확인한다.
 * 마찬가지로 NNRestServer 내부에서만 사용하므로 외부에서 직접 생성해 사용할 일은 없다.
 */
class NNURLBeginsHandlerList {
	private ArrayList handlers;

	public NNURLBeginsHandlerList () {
		this.handlers = new ArrayList();
	}

	public void handle (NNRestActivity activity) {
		int handlersSize = this.handlers.size();
		for(int i = 0; i < handlersSize; i += 2){
			String pattern = (String)(this.handlers.get(i));
			if(activity.request.path.startsWith(pattern)){
				NNActivityHandler handler = (NNActivityHandler)(this.handlers.get(i+1));
				handler.onActivity(activity, new ArrayList());
			}
		}
	}

	public void add (String url, NNActivityHandler handler) {
		this.handlers.add(url);
		this.handlers.add(handler);
	}
}

/**
 * 요청과 응답을 처리할 내용들이 담긴 객체로 매 요청마다 한개씩 생긴다.
 * NNRestServer에 사용자가 접속하면 내부에서 생성하고 핸들러로 전달하게된다.
 */
class NNRestActivity {
	public NNRestRequest request; // 해당 세션에 대한 요청 객체
	public NNRestResponse response; // 해당 세션에 대한 응답 객체
	private Server server;
	private Client client;
	private boolean next;
	public NNDictionary storage; // 해당 세션동안 활용할 데이터를 저장할 임시 저장공간이다. 본 프로젝트에서 Access Token 분석 후 사용자 ID값을 저장하는데 사용한다.

	public NNRestActivity (Server server, Client client) {
		this.server = server;
		this.client = client;
		this.request = new NNRestRequest(client.readString());
		this.response = new NNRestResponse(client);
		this.next = true;
		this.storage = new NNDictionary();
	}

	public void start () {
		this.next = true;
	}

	public void quit () {
		this.next = false;
	}

	public boolean shouldStart () {
		return this.next;
	}
}

/**
 * HTTP 요청에 관한 정보가 담긴 객체이다. Request를 파싱하여 HTTP 헤더 내용을 정리한다.
 * URL 변수, Request Body에 담긴내용, Request URI, 요청 방식이 저장된다.
 */
class NNRestRequest {
	public String method;
	public String path;
	public HashMap<String, String> getParams;
	public NNDictionary body;

	public NNRestRequest (String requestHeaders) {
		this.body = new NNDictionary();
		String[] lines = requestHeaders.split("\n");
		println(lines[0]);
		String[] requestLineComponents = lines[0].split(" ");
		this.method = requestLineComponents[0];
		String requestURI = requestLineComponents[1];
		String[] requestURIComponents = requestURI.split("\\?");
		this.path = requestURIComponents[0];
		this.getParams = new HashMap<String, String>();
		if(requestURIComponents.length > 1){
			String[] getParamsComponents = requestURIComponents[1].split("&");
			for(int i = 0; i < getParamsComponents.length; i++){
				String[] getParamPair = getParamsComponents[i].split("=");
				this.getParams.put(getParamPair[0], decodeURL(getParamPair[1]));
			}
		}
		int bodyStart = -1;
		for(int i = 0; i < lines.length; i++){
			if(lines[i].equals("\r")){
				bodyStart = i + 1;
				break;
			}
		}
		if(bodyStart != -1){
			for(int i = bodyStart; i < lines.length; i++){
				String[] components = lines[i].replaceAll("\r","").split("&");
				for(int j = 0; j < components.length; j++){
					String[] keyValue = components[j].split("=");
					this.body.key(keyValue[0]).set(decodeURL(keyValue[1]));
				}
			}
		}
	}
}

/**
 * HTTP 응답을 담당하는 객체이다.
 * HTTP 응답 헤더를 작성하며, JSON, Plain text, HTML응답을 지원한다.
 */
class NNRestResponse {
	Client client;

	public NNRestResponse (Client client) {
		this.client = client;
	}

	public void json (NNDictionary dictionary) {
		this.statusOK();
		this.contentType("text/json");
		this.writeBody(dictionary.serialize());
		this.end();
	}

	public void plain (String content) {
		this.statusOK();
		this.contentType("text/plain");
		this.writeBody(content);
		this.end();
	}

	public void html (String content) {
		this.statusOK();
		this.contentType("text/html");
		this.writeBody(content);
		this.end();
	}

	public void statusOK () {
		this.writeLine("HTTP/1.0 200 OK");
	}

	public void statusInternalError () {
		this.writeLine("HTTP/1.0 500 Internal Server Error");
	}

	public void statusBadRequest () {
		this.writeLine("HTTP/1.0 400 Bad Request");
	}

	public void notFound () {
		this.statusNotFound();
		this.contentType("text/json");
		this.writeBody("{\"success\":false,\"status\":\"REQUEST_HANDLER_NOT_DEFINED\"}");
		this.end();
	}

	public void statusNotFound () {
		this.writeLine("HTTP/1.0 404 Not Found");
	}

	public void contentType (String mimeType) {
		this.writeLine("Content-Type: " + mimeType + "; charset=utf-8");
	}

	public void write (String content) {
		this.client.write(content);
	}

	public void writeLine (String content) {
		this.client.write(content + "\r\n");
	}

	public void writeBody (String content) {
		this.client.write("\r\n" + content);
	}

	public void end () {
		this.client.stop();
	}
}