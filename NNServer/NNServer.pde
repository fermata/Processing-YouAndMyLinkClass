NNRestServer restfulServer;
NNDatabase db;

void setup() {
	frameRate(300);

	db = new NNDatabase("database");
	restfulServer = new NNRestServer(this, 8080);

	restfulServer.get("/class", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			ArrayList fetched = db.table("class").find();
			NNDictionary dictionary = new NNDictionary();
			if(fetched != null){
				dictionary.put("success").set(true);
				dictionary.put("status").set("OK");
				NNArray dbResults = new NNArray();
				dbResults.withRows(fetched);
				dictionary.put("classes").set(dbResults);
			}else{
				dictionary.put("success").set(false);
				dictionary.put("status").set("NOT_FOUND");
			}
			activity.response.json(dictionary);
			activity.quit();
		}
	});

	restfulServer.get("/class/*", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			NNRow fetched = db.table("class").findOne(":code == '" + params.get(0) + "'");
			NNDictionary dictionary = new NNDictionary();
			if(fetched != null){
				dictionary.put("success").set(true);
				dictionary.put("status").set("OK");
				NNDictionary subDictionary = new NNDictionary();
				subDictionary.withRow(fetched);
				dictionary.put("class").set(subDictionary);
			}else{
				dictionary.put("success").set(false);
				dictionary.put("status").set("NOT_FOUND");
			}
			activity.response.json(dictionary);
			activity.quit();
		}
	});

}

void draw() {
	restfulServer.accept();
}

	/*
	NNRow fetched = db.table("class").findOne(":professor == '김민욱'");
	print(fetched.column("name").stringValue());
	db.table("class").removeOne(":id == 3");
	db.table("class").save();
	*/