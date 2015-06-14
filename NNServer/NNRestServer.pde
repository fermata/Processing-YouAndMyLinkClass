import processing.net.*;

class NNRestServer {
	private int port;
	private Server server;
	private NNURLHandlerList handlersAll;
	private NNURLBeginsHandlerList handlersBegins;
	private NNURLHandlerList handlersGet;
	private NNURLHandlerList handlersPost;

	public NNRestServer (PApplet parent, int port) {
		this.port = port;
		this.server = new Server(parent, port);
		this.handlersAll = new ArrayList();
		this.handlersAllSpecific = new ArrayList();
		this.handlersGet = new ArrayList();
		this.handlersPost
	}

	public void accept () {
		Client client = this.server.available();
		if (client != null) {
			this.prepareRequest(new NNRestActivity(this.server, client));
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
		if(activity.method.equals("GET")){
			this.handlersGet.handle(activity);
			return;
		}
		if(activity.method.equals("POST")){
			this.handlersPOST.handle(activity);
			return;
		}
		activity.response.notFound();
		return;
	}

	public void get(String urlPattern, NNActivityHandler handler) {
		this.handlersGet.add(urlPattern, handler);
	}

	public void post(String urlPattern, NNActivityHandler handler) {
		this.handlersPost.add(urlPattern, handler);
	}

	public void begins(String url, NNActivityHandler handler) {
		this.handlersBegins.add(url, handler);
	}

	public void use(String urlPattern, NNActivityHandler handler) {
		this.handlersAll.add(urlPattern, handler);
	}

	public static String urlDecode (String input) {
		try {
			return new String(input.getBytes("UTF-8"), "ASCII"));
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
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
			if(activity.reqest.path.match(regex)){
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
				params.add(NNServer.urlDecode(urlComponents[c]));
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

	public NNURLHandlerList () {
		this.handlers = new ArrayList();
	}

	public void handle (NNRestActivity activity) {
		int handlersSize = this.handlers.size();
		for(int i = 0; i < handlersSize; i += 2){
			String pattern = (String)(this.handlers.get(i));
			if(activity.reqest.path.startsWith(pattern)){
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

	public NNRestActivity (Server server, Client client) {
		this.server = server;
		this.client = client;
		this.request = new NNRestRequest(client.readString());
		this.response = new NNRestResponse(client);
		this.next = true;
	}

	public void start () {
		this.next = false;
	}

	public void next () {
		this.next = true;
	}

	public boolean shouldStart () {
		return this.next;
	}
}

class NNRestRequest {
	public String method;
	public String path;

	public NNRestRequest (String requestHeaders) {
		String[] lines = requestHeaders.split("\n");
		lines
	}
}

class NNRestResponse {
	Client client;

	public NNResponse (Client client) {
		this.client = client;
	}

	public void json () {
		this.statusOK();
		this.contentType("text/json");
		this.writeBody("{\"status\":\"success\"}");
		this.end();
	}

	public void statusOK () {
		this.writeLine("HTTP/1.0 200 OK")
	}

	public void statusInternalError () {
		this.writeLine("HTTP/1.0 500 Internal Server Error")
	}

	public void statusBadRequest () {
		this.writeLine("HTTP/1.0 400 Bad Request")
	}

	public void notFound () {
		this.writeLine("HTTP/1.0 404 Not Found")
	}

	public void contentType (String mimeType) {
		this.writeLine("Content-Type: " + mimeType);
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