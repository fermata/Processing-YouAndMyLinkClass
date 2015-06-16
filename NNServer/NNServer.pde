NNRestServer app;
NNDatabase db;

void setup() {
	frameRate(300);

	db = new NNDatabase("database");
	app = new NNRestServer(this, 8080);

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