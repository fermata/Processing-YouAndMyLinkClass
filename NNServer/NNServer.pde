import processing.net.*;

NNRestServer restfulServer;
NNDatabase db;

void setup() {
	db = new NNDatabase("database");
	restfulServer = new NNRestServer(this, 8080);

	restfulServer.get("/", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			NNDictionary dictionary = new NNDictionary();
			dictionary.put("test").set("하하하하");
			dictionary.put("value").set("ahaaha");
			NNDictionary subDictionary = new NNDictionary();
			subDictionary.put("another").set(1523);
			subDictionary.put("value").set(false);
			dictionary.put("subDictionary").set(subDictionary);
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