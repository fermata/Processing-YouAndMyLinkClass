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
			NNDictionary output = new NNDictionary();
			if(user != null){
				NNDictionary userinfo = new NNDictionary();
				userinfo.withRow(user);
				userinfo.remove("password");
				String accessToken = makeAcessToken(username, user.column("id").integerValue());
				output.key("success").set(true);
				output.key("status").set("OK");
				output.key("user").set(userinfo);
				output.key("access_token").set(accessToken);
			}else{
				output.key("success").set(false);
				output.key("status").set("USER_NOT_FOUND_OR_INCORRECT_CREDENCIAL");
			}
			activity.response.json(output);
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
			db.table("users").commit();
			NNDictionary output = new NNDictionary();
			output.key("success").set(true);
			output.key("status").set("USER_ADDED");
			NNDictionary userinfo = new NNDictionary();
			userinfo.key("id").set(row.column("id").integerValue());
			userinfo.key("username").set(body.key("username").stringValue());
			output.key("user").set(userinfo);
			activity.response.json(output);
			activity.quit();
		}
	});

	app.get("/class", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			ArrayList fetched = db.table("class").find();
			NNDictionary output = new NNDictionary();
			if(fetched != null){
				output.key("success").set(true);
				output.key("status").set("OK");
				NNArray dbResults = new NNArray();
				dbResults.withRows(fetched);
				output.key("classes").set(dbResults);
			}else{
				output.key("success").set(false);
				output.key("status").set("NOT_FOUND");
			}
			activity.response.json(output);
			activity.quit();
		}
	});

	app.get("/class/*", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			NNRow fetched = db.table("class").findOne(":code == '" + params.get(0) + "'");
			NNDictionary output = new NNDictionary();
			if(fetched != null){
				output.key("success").set(true);
				output.key("status").set("OK");
				NNDictionary subDictionary = new NNDictionary();
				subDictionary.withRow(fetched);
				output.key("class").set(subDictionary);
			}else{
				output.key("success").set(false);
				output.key("status").set("NOT_FOUND");
			}
			activity.response.json(output);
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
			NNDictionary output = new NNDictionary();
			output.key("success").set(false);
			output.key("status").set("ACCESS_TOKEN_NOT_PROVIDED_OR_TOKEN_INVALID");
			activity.response.json(output);
			activity.quit();
		}
	});

	app.get("/me", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			String query = ":id == " + activity.storage.key("userId").integerValue();
			NNRow user = db.table("users").findOne(query);
			NNDictionary output = new NNDictionary();
			if(user != null){
				NNDictionary userinfo = new NNDictionary();
				userinfo.withRow(user);
				userinfo.remove("password");
				output.key("success").set(true);
				output.key("status").set("OK");
				output.key("user").set(userinfo);
			}else{
				output.key("success").set(false);
				output.key("status").set("USER_NOT_FOUND");
			}
			activity.response.json(output);
			activity.quit();
		}
	});

	app.get("/me/jjim", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			String query1 = ":user == " + activity.storage.key("userId").integerValue();
			NNArray jjimList = new NNArray();
			jjimList.withRows(db.table("jjim").find(query1));
			NNDictionary output = new NNDictionary();
			output.key("success").set(true);
			output.key("status").set("OK");
			NNArray jjims = new NNArray();
			output.key("jjims").set(jjims);
			for(int i = 0; i < jjimList.size(); i++){
				NNDictionary jjimRow = jjimList.get(i).dictionaryValue();
				String query2 = ":id == " + jjimRow.key("id").integerValue();
				NNDictionary classInfo = new NNDictionary();
				classInfo.withRow(db.table("class").findOne(query2));
				jjims.add().set(classInfo);
			}
			activity.response.json(output);
			activity.quit();
		}
	});

	app.get("/me/jjim/other/*", new NNActivityHandler(){

		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			String otherUserQuery = ":username == '" + params.get(0) + "'";
			NNRow otherUserRow = db.table("users").findOne(otherUserQuery);
			if(otherUserRow == null){
				this.userNotFound(activity, params);
			}else{
				this.userFound(activity, params, otherUserRow.column("id").integerValue());
			}
		}

		private void userNotFound (NNRestActivity activity, ArrayList params) {
			NNDictionary output = new NNDictionary();
			output.key("success").set(false);
			output.key("status").set("USER_NOT_FOUND");
			activity.response.json(output);
			activity.quit();
		}

		private void userFound (NNRestActivity activity, ArrayList params, int otherUserId) {
			String myQuery = ":user == " + activity.storage.key("userId").integerValue();
			String othersQuery = ":user == " + otherUserId;
			NNArray myClasses = new NNArray();
			NNArray othersClasses = new NNArray();
			myClasses.withRows(db.table("jjim").find(myQuery));
			othersClasses.withRows(db.table("jjim").find(othersQuery));
			NNArray sharedClasses = new NNArray();
			for(int o = 0; o < othersClasses.size(); o++){
				NNDictionary othersClass = othersClasses.get(o).dictionaryValue();
				int othersClassId = othersClass.key("class").integerValue();
				boolean hasSameClass = false;
				for(int m = 0; m < myClasses.size(); m++){
					NNDictionary myClass = myClasses.get(m).dictionaryValue();
					int myClassId = myClass.key("class").integerValue();
					if(myClassId == othersClassId){
						hasSameClass = true;
						break;
					}
				}
				this.addClass(othersClassId, hasSameClass, sharedClasses);
			}
			this.sendOutput(activity, params, sharedClasses);
		}

		private void addClass (int classId, boolean shared, NNArray sharedClasses) {
			String query = ":id == " + classId;
			NNDictionary classInfo = new NNDictionary();
			classInfo.withRow(db.table("class").findOne(query));
			classInfo.key("common").set(shared);
			sharedClasses.add().set(classInfo);
		}

		private void sendOutput (NNRestActivity activity, ArrayList params, NNArray sharedClasses) {
			NNDictionary output = new NNDictionary();
			output.key("success").set(true);
			output.key("status").set("OK");
			output.key("classes").set(sharedClasses);
			activity.response.json(output);
			activity.quit();
		}
	});

	app.get("/me/jjim/*", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			String targetClassCode = (String)params.get(0);
			String query = ":code == '" + targetClassCode + "'";
			NNRow targetClassRow = db.table("class").findOne(query);
			if(targetClassRow == null){
				this.classNotFound(activity, params);
				return;
			}
			NNDictionary targetClass = new NNDictionary();
			targetClass.withRow(targetClassRow);
			this.classFound(activity, params, targetClass);
		}

		private void classNotFound (NNRestActivity activity, ArrayList params) {
			NNDictionary output = new NNDictionary();
			output.key("success").set(false);
			output.key("status").set("CLASS_NOT_FOUND");
			activity.response.json(output);
			activity.quit();
		}

		private void classFound (NNRestActivity activity, ArrayList params, NNDictionary targetClass) {
			int targetClassId = targetClass.key("id").integerValue();
			int targetUserId = activity.storage.key("userId").integerValue();
			String query = ":user == " + targetUserId + " && :class == " + targetClassId;
			NNRow found = db.table("jjim").findOne(query);
			this.searchResult(activity, params, found != null);
		}

		private void searchResult (NNRestActivity activity, ArrayList params, boolean found) {
			NNDictionary output = new NNDictionary();
			output.key("success").set(true);
			output.key("status").set("OK");
			output.key("jjimed").set(found);
			activity.response.json(output);
			activity.quit();
		}
	});

	app.post("/me/jjim/*", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			String targetClassCode = (String)params.get(0);
			String query = ":code == '" + targetClassCode + "'";
			NNRow targetClassRow = db.table("class").findOne(query);
			if(targetClassRow == null){
				this.classNotFound(activity, params);
				return;
			}
			NNDictionary targetClass = new NNDictionary();
			targetClass.withRow(targetClassRow);
			this.classFound(activity, params, targetClass);
		}

		private void classNotFound (NNRestActivity activity, ArrayList params) {
			NNDictionary output = new NNDictionary();
			output.key("success").set(false);
			output.key("status").set("CLASS_NOT_FOUND");
			activity.response.json(output);
			activity.quit();
		}

		private void classFound (NNRestActivity activity, ArrayList params, NNDictionary targetClass) {
			int targetClassId = targetClass.key("id").integerValue();
			int targetUserId = activity.storage.key("userId").integerValue();
			String query = ":user == " + targetUserId + " && :class == " + targetClassId;
			NNRow duplicate = db.table("jjim").findOne(query);
			if(duplicate == null){
				this.addJjim(activity, params, targetUserId, targetClassId);
			}else{
				this.duplicateFound(activity, params);
			}
		}

		private void duplicateFound (NNRestActivity activity, ArrayList params) {
			NNDictionary output = new NNDictionary();
			output.key("success").set(false);
			output.key("status").set("ALREADY_ADDED_TO_JJIMS");
			activity.response.json(output);
			activity.quit();
		}

		private void addJjim (NNRestActivity activity, ArrayList params, int targetUserId, int targetClassId) {
			NNRow jjimRow = new NNRow(db.table("jjim").schema());
			jjimRow.setColumn("user", targetUserId);
			jjimRow.setColumn("class", targetClassId);
			db.table("jjim").insert(jjimRow);
			db.table("jjim").commit();
			NNDictionary output = new NNDictionary();
			output.key("success").set(true);
			output.key("status").set("JJIM_ADDED");
			activity.response.json(output);
			activity.quit();
		}
	});

	app.delete("/me/jjim/*", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			String targetClassCode = (String)params.get(0);
			String query = ":code == '" + targetClassCode + "'";
			NNRow targetClassRow = db.table("class").findOne(query);
			if(targetClassRow == null){
				this.classNotFound(activity, params);
				return;
			}
			NNDictionary targetClass = new NNDictionary();
			targetClass.withRow(targetClassRow);
			this.classFound(activity, params, targetClass);
		}

		private void classNotFound (NNRestActivity activity, ArrayList params) {
			NNDictionary output = new NNDictionary();
			output.key("success").set(false);
			output.key("status").set("CLASS_NOT_FOUND");
			activity.response.json(output);
			activity.quit();
		}

		private void classFound (NNRestActivity activity, ArrayList params, NNDictionary targetClass) {
			int targetClassId = targetClass.key("id").integerValue();
			int targetUserId = activity.storage.key("userId").integerValue();
			String query = ":user == " + targetUserId + " && :class == " + targetClassId;
			NNRow duplicate = db.table("jjim").findOne(query);
			if(duplicate == null){
				this.jjimNotFound(activity, params);
			}else{
				this.jjimFound(activity, params, duplicate.column("id").integerValue());
			}
		}

		private void jjimNotFound (NNRestActivity activity, ArrayList params) {
			NNDictionary output = new NNDictionary();
			output.key("success").set(false);
			output.key("status").set("JJIM_NOT_FOUND");
			activity.response.json(output);
			activity.quit();
		}

		private void jjimFound (NNRestActivity activity, ArrayList params, int targetJjimId) {
			db.table("jjim").removeOne(":id == " + targetJjimId);
			db.table("jjim").commit();
			NNDictionary output = new NNDictionary();
			output.key("success").set(true);
			output.key("status").set("JJIM_REMOVED");
			activity.response.json(output);
			activity.quit();
		}
	});
}

void draw() {
	app.accept();
}