void setup() {
	NNDatabase db = new NNDatabase("database");
	NNRow fetched = db.table("class").findOne(":professor == '김민욱'");
	print(fetched.column("name").stringValue());
	db.table("class").removeOne(":id == 3");
	db.table("class").save();
}

void draw() {
	
}