NNRestServer app;
NNDatabase db;

String tokenGenerator (String username, int userid) {
	return sha256(username + "vahj1jv8c4k" + userid);
}

String makeAcessToken (String username, int userid) {
	return username + "." + tokenGenerator(username, userid) + Integer.toHexString(userid);
}

int decodeAccessToken (String accessToken) {
	try {
		String[] components = accessToken.split("\\.");
		String username = components[0];
		String token = components[1].substring(0,64);
		String useridHexString = components[1].substring(64, components[1].length());
		int userid = Integer.parseInt(useridHexString, 16);
		if(tokenGenerator(username, userid).equals(token)){
			return userid;
		}else{
			return -1;
		}
	} catch (Exception e) {
		e.printStackTrace();
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
			String passwordHash = sha256(body.key("password").stringValue());
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
				dictionary.key("status").set("USER_NOT_FOUND_OR_INCORRECT_CREDENCIAL");
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
			row.setColumn("password", sha256(body.key("password").stringValue()));
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

	app.begins("/me", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			if(activity.request.getParams.get("access_token") != null){
				String accessToken = (String)(activity.request.getParams.get("access_token"));
				int userId = decodeAccessToken(accessToken);
				if(userId != -1){
					activity.storage.key("userId").set(userId);
					return;
				}
			}
			NNDictionary dictionary = new NNDictionary();
			dictionary.key("success").set(false);
			dictionary.key("status").set("ACCESS_TOKEN_NOT_PROVIDED_OR_TOKEN_INVALID");
			activity.response.json(dictionary);
			activity.quit();
		}
	});

	app.get("/me", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			String query = ":id == " + activity.storage.key("userId").integerValue();
			NNRow user = db.table("users").findOne(query);
			NNDictionary dictionary = new NNDictionary();
			if(user != null){
				NNDictionary userinfo = new NNDictionary();
				userinfo.withRow(user);
				userinfo.remove("password");
				dictionary.key("success").set(true);
				dictionary.key("status").set("OK");
				dictionary.key("user").set(userinfo);
			}else{
				dictionary.key("success").set(false);
				dictionary.key("status").set("USER_NOT_FOUND");
			}
			activity.response.json(dictionary);
			activity.quit();
		}
	});

	app.get("/me/jjim", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			String query1 = ":user == " + activity.storage.key("userId").integerValue();
			NNArray jjimList = new NNArray();
			jjimList.withRows(db.table("jjim").find(query1));
			NNDictionary dictionary = new NNDictionary();
			dictionary.key("success").set(true);
			dictionary.key("status").set("OK");
			final NNArray jjims = new NNArray();
			dictionary.key("jjims").set(jjims);
			jjimList.each(new NNArrayIterator(){
				@Override
				public void iterate (int index, NNDynamicValue value){
					NNDictionary jjimRow = value.dictionaryValue();
					String query2 = ":id == " + jjimRow.key("id").integerValue();
					NNDictionary classInfo = new NNDictionary();
					classInfo.withRow(db.table("class").findOne(query2));
					jjims.add().set(classInfo);
				}
			});
			activity.response.json(dictionary);
			activity.quit();
		}
	});
}

void draw() {
	app.accept();
}