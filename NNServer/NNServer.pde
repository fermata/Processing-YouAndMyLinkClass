NNRestServer app;
NNDatabase db;

String tokenGenerator (String username, int userid) {
	return md5(username + "vahj1jv8c4k" + userid);
}

String makeAcessToken (String username, int userid) {
	return username + "." + tokenGenerator(username, userid) + Integer.toHexString(userid);
}

int decodeAccessToken (String accessToken) {
	try {
		String[] components = accessToken.split(".");
		String username = components[0];
		String token = components[1].substring(0,32);
		String useridHexString = components[1].substring(32, components[1].length());
		int userid = Integer.parseInt(useridHexString, 16);
		if(tokenGenerator(username, userid).equals(token)){
			return userid;
		}else{
			return -1;
		}
	} catch (Exception e) {
		return -1;
	}
}

void setup() {
	frameRate(300);

	db = new NNDatabase("database");
	app = new NNRestServer(this, 8080);

	app.post("/user/auth", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			NNDictionary body = activity.request.body;
			String username = body.key("username").stringValue();
			String passwordHash = md5(body.key("password").stringValue());
			String query = ":username == '" + username +  "' && :password == '" + passwordHash + "'";
			NNRow user = db.table("users").findOne(query);
			NNDictionary dictionary = new NNDictionary();
			if(user != null){
				NNDictionary userinfo = new NNDictionary();
				userinfo.withRow(user);
				userinfo.remove("password");
				String accessToken = makeAcessToken(username, user.column("id").integerValue());
				dictionary.key("success").set(true);
				dictionary.key("status").set("OK");
				dictionary.key("user").set(userinfo);
				dictionary.key("access_token").set(accessToken);
			}else{
				dictionary.key("success").set(false);
				dictionary.key("status").set("USER_NOT_FOUND");
			}
			activity.response.json(dictionary);
			activity.quit();
		}
	});

	app.post("/user/add", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			NNDictionary body = activity.request.body;
			NNRow row = new NNRow(db.table("users").schema);
			row.setColumn("username", body.key("username").stringValue());
			row.setColumn("password", md5(body.key("password").stringValue()));
			db.table("users").insert(row);
			db.table("users").save();
			NNDictionary dictionary = new NNDictionary();
			dictionary.key("success").set(true);
			dictionary.key("status").set("USER_ADDED");
			NNDictionary userinfo = new NNDictionary();
			userinfo.key("id").set(row.column("id").integerValue());
			userinfo.key("username").set(body.key("username").stringValue());
			dictionary.key("user").set(userinfo);
			activity.response.json(dictionary);
			activity.quit();
		}
	});

	app.get("/class", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			ArrayList fetched = db.table("class").find();
			NNDictionary dictionary = new NNDictionary();
			if(fetched != null){
				dictionary.key("success").set(true);
				dictionary.key("status").set("OK");
				NNArray dbResults = new NNArray();
				dbResults.withRows(fetched);
				dictionary.key("classes").set(dbResults);
			}else{
				dictionary.key("success").set(false);
				dictionary.key("status").set("NOT_FOUND");
			}
			activity.response.json(dictionary);
			activity.quit();
		}
	});

	app.get("/class/*", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			NNRow fetched = db.table("class").findOne(":code == '" + params.get(0) + "'");
			NNDictionary dictionary = new NNDictionary();
			if(fetched != null){
				dictionary.key("success").set(true);
				dictionary.key("status").set("OK");
				NNDictionary subDictionary = new NNDictionary();
				subDictionary.withRow(fetched);
				dictionary.key("class").set(subDictionary);
			}else{
				dictionary.key("success").set(false);
				dictionary.key("status").set("NOT_FOUND");
			}
			activity.response.json(dictionary);
			activity.quit();
		}
	});

}

void draw() {
	app.accept();
}