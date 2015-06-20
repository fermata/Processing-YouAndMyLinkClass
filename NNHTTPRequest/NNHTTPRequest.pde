import java.net.*;
import java.io.*;

class NNAPI {
	private String serverDomain;
	private String prefix;
	private int port;
	private PApplet parentApplet;
	private String baseURL;
	public String accessToken;
	
	public void setBaseURL (String baseURL) {
		this.baseURL = baseURL;
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

	public NNAPI (PApplet parent) {
		this.serverDomain = "localhost";
		this.port = 8080;
		this.prefix = "";
		this.parentApplet = parent;
	}

	public NNAPI (PApplet parent, String baseURL) {
		this.parentApplet = parent;
		this.setBaseURL(baseURL);
	}

	private String encodeURL (String plain) {
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

	private JSONObject parseJSON (String json) {
		String[] lines = new String[1];
		lines[0] = json;
		saveStrings("tmp.json", lines);
		return loadJSONObject("tmp.json");
	}

	private String cleanURL (String url) {
		return url.split("\\?")[0];
	}

	public JSONObject post (String url) {
		return this.post(url, new NNDictionary());
	}

	public JSONObject post (String url, NNDictionary data) {
		String method = "POST";
		final String[] queryStrings = new String[data.size()];
		final NNAPI api = this;
		data.each(new NNDictionaryIterator(){
			private int iteration = 0;

			public void iterate (String key, NNDynamicValue value) {
				println(this.iteration);
				queryStrings[this.iteration] = key + "=" + api.encodeURL(value.stringValue());
				this.iteration++;
			}
		});
		StringBuffer sb = new StringBuffer();
		for(int i = 0; i < queryStrings.length; i++){
			sb.append(queryStrings[i]);
			if(i + 1 != queryStrings.length){
				sb.append('&');
			}
		}
		String queryString = sb.toString();
		return this.jsonRequest(method, url, queryString);
	}

	public JSONObject get (String url) {
		String method = "GET";
		return this.jsonRequest(method, url, "");
	}

	public JSONObject remove (String url) {
		String method = "REMOVE";
		return this.jsonRequest(method, url, "");
	}

	private JSONObject jsonRequest (String method, String url, String body) {
		url += "?access_token=" + this.accessToken;
		if(body.equals("")){
			try{
				URL requestURL = new URL(this.baseURL + url);
				HttpURLConnection connection = (HttpURLConnection)requestURL.openConnection();
				connection.setRequestMethod(method);
				Reader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
				StringBuffer sb = new StringBuffer();
				int buffer;
				while((buffer = in.read()) != -1){
					sb.append((char)buffer);
				}
				connection.disconnect();
				return this.parseJSON(sb.toString());
			} catch (Exception e) {
				e.printStackTrace();
				return null;
			}
		}else{
			try{
				URL requestURL = new URL(this.baseURL + url);
				HttpURLConnection connection = (HttpURLConnection)requestURL.openConnection();
				connection.setDoOutput(true);
				connection.setRequestMethod(method);
				DataOutputStream dos = new DataOutputStream(connection.getOutputStream());
				dos.write(body.getBytes("UTF-8"));
				Reader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
				StringBuffer sb = new StringBuffer();
				int buffer;
				while((buffer = in.read()) != -1){
					sb.append((char)buffer);
				}
				connection.disconnect();
				return this.parseJSON(sb.toString());
			} catch (Exception e) {
				e.printStackTrace();
				return null;
			}
		}
	}
}