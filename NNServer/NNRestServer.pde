import processing.net.*;
import java.security.*;

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

String decodeURL (String input) {
	try {
		return new String(input.getBytes("UTF-8"), "ASCII");
	} catch (Exception e) {
		e.printStackTrace();
	}
	return null;
}

class NNRestServer {
	private int port;
	private Server server;
	private NNURLHandlerList handlersAll;
	private NNURLBeginsHandlerList handlersBegins;
	private NNURLHandlerList handlersGet;
	private NNURLHandlerList handlersPost;
	private NNURLHandlerList handlersPut;
	private NNURLHandlerList handlersDelete;

	public NNRestServer (PApplet parent, int port) {
		this.port = port;
		this.server = new Server(parent, port);
		this.handlersAll = new NNURLHandlerList();
		this.handlersBegins = new NNURLBeginsHandlerList();
		this.handlersGet = new NNURLHandlerList();
		this.handlersPost = new NNURLHandlerList();
	}

	public void accept () {
		Client client = this.server.available();
		if (client != null) {
			this.workActivity(new NNRestActivity(this.server, client));
		}
	}

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

	public void get(String urlPattern, NNActivityHandler handler) {
		this.handlersGet.add(urlPattern, handler);
	}

	public void post(String urlPattern, NNActivityHandler handler) {
		this.handlersPost.add(urlPattern, handler);
	}

	public void put(String urlPattern, NNActivityHandler handler) {
		this.handlersPut.add(urlPattern, handler);
	}

	public void delete(String urlPattern, NNActivityHandler handler) {
		this.handlersDelete.add(urlPattern, handler);
	}

	public void begins(String url, NNActivityHandler handler) {
		this.handlersBegins.add(url, handler);
	}

	public void use(String urlPattern, NNActivityHandler handler) {
		this.handlersAll.add(urlPattern, handler);
	}
}

interface NNActivityHandler {
	public void onActivity (NNRestActivity activity, ArrayList params);
}

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

class NNRestActivity {
	public NNRestRequest request;
	public NNRestResponse response;
	private Server server;
	private Client client;
	private boolean next;
	public NNDictionary storage;

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