import processing.net.*;

NNRestServer restfulServer;
NNDatabase db;

void setup() {
	db = new NNDatabase("database");
	restfulServer = new NNRestServer(this, 8080);
	restfulServer.get("/", new NNActivityHanlder{
		@Override
		public void onActivity (NNRestActivity activity, ArrayList params) {
			activity.response.json();
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