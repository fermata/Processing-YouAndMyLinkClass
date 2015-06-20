class NNAPI {
	private String serverDomain;
	private String prefix;
	private int port;
	public String accessToken;
	
	public void setBaseURL (String baseURL) {
		String[] baseURLComponents = baseURL.split("/");
		String[] connectionParts = baseURLComponents[2].split(":");
		if(connectionParts.length > 1){
			this.serverDomain = connectionParts[0];
			this.port = Integer.valueOf(connectionParts[1]);
		}else{
			this.serverDomain = connectionParts[0];
			this.port = 80;
		}
		this.prefix = "";
		if(baseURLComponents.length > 3){
			for(int i = 3; i < baseURLComponents.length; i++){
				this.prefix += "/" + baseURLComponents[i];
			}
		}
	}

	public NNAPI () {
		this.serverDomain = "localhost";
		this.port = 8080;
		this.prefix = "";
	}

	private String encodeURL(String plain){
		StringBuffer sb = new StringBuffer();
		try{
			byte[] input = plain.getBytes("UTF-8");
			for(int i = 0; i < input.length; i++){
				if(input[i] < 0){
					sb.append('%' + hex(input[i]));
				}else if(input[i] == 32){
					sb.append('+');
				}else{
					sb.append(char(input[i]));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return sb.toString();
	}

	public NNAPI (String baseURL) {
		this.setBaseURL(baseURL);
	}

	private NNDictionary urlParam (String url) {
		String params = url.split("\\?")[1];
		String[] keyValues = url.split
	}

	private String cleanURL (String url) {
		return url.split("\\?")[0];
	}

	public NNDictionary post (String url, NNAPIHandler handler) {
		return this.post(url, new NNDictionary(), handler);
	}

	public NNDictionary post (String url, NNDictionary data, NNAPIHandler handler) {
		String method = "POST";
		final String[] queryString = new String[data.size()];
		data.each(new NNDictionaryIterator(){
			private int iteration = 0;

			public void iterate (String key, NNDynamicValue value) {
				queryString[this.iteration] = key + "=" + this.encodeURL(value.stringValue());
				this.iteration++;
			}
		});
		for()
	}

	public NNDictionary get (String url, NNAPIHandler handler) {
		String method = "GET";
	}

	public NNDictionary remove (String url, NNAPIHandler handler) {
		String method = "REMOVE";
	}

	private NNDictionary jsonRequest (String method, String url, NNDictionary urlParam, String body) {

	}
}

interface NNAPIHandler {
	public void onSuccess (String status);
	public void onError (String status);
}