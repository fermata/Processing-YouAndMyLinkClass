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

	restfulServer.get("/class/*", new NNActivityHandler(){
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			NNRow fetched = db.table("class").findOne(":id == " + params.get(0));
			NNDictionary dictionary = new NNDictionary();
			if(fetched != null){
				dictionary.put("result").set("success");
				NNDictionary subDictionary = new NNDictionary();
				subDictionary.put("id").set(fetched.column("id").integerValue());
				subDictionary.put("code").set(fetched.column("code").stringValue());
				subDictionary.put("name").set(fetched.column("name").stringValue());
				subDictionary.put("professor").set(fetched.column("professor").stringValue());
				dictionary.put("class").set(subDictionary);
			}else{
				dictionary.put("result").set("notfound");
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