import javax.script.*;

ScriptEngineManager seManager = new ScriptEngineManager();
ScriptEngine js = seManager.getEngineByName("js");    

class NNDatabase {
	private final String databasePath;
	private String databaseName;
	private ArrayList tables;

	public NNDatabase (String databaseName) {
		this.databasePath = databaseName + "/";
		this.databaseName = databaseName;
		this.tables = new ArrayList();
	}

	public NNTable table (String tableName) {
		int tableCount = tables.size();
		for(int i = 0; i < tableCount; i++){
			NNTable table = (NNTable)(tables.get(i));
			if(table.tableName.equals(tableName)){
				return table;
			}
		}
		NNTable table = new NNTable(this, tableName);
		tables.add(table);
		return table;
	}
}

class NNTableSchema {
	public String[] dataTypes;
	public String[] dataNames;
	public String[] dataOptions;
	private int pkIndex;
	private int pkValue;
	private NNDatabase database;
	private String tableName;
	public int count;

	public NNTableSchema (NNDatabase database, String tableName) {
		this.database = database;
		this.tableName = tableName;
		String[] schemaInfo = loadStrings(database.databasePath + tableName + ".schema");
		this.count = schemaInfo.length;
		this.dataTypes = new String[this.count];
		this.dataNames = new String[this.count];
		this.dataOptions = new String[this.count];
		for(int i = 0; i < this.count; i++){
			String[] datas = schemaInfo[i].split(" ");
			this.dataTypes[i] = datas[0];
			this.dataNames[i] = datas[1];
			this.dataOptions[i] = datas[2];
			if(this.dataOptions[i].equals("PK")){
				this.pkIndex = i;
				this.pkValue = Integer.valueOf(loadStrings(database.databasePath + this.tableName + "_" + this.dataNames[i] + "_last.value")[0]);
			}
		}
	}

	public int indexOfName (String columnName) {
		for(int i = 0; i <= this.count; i++){
			if(this.dataNames[i].equals(columnName)){
				return i;
			}
		}
		return -1;
	}

	public int nextPK() {
		this.pkValue++;
		String[] value = new String[1];
		value[0] = "" + this.pkValue;
		saveStrings(this.database.databasePath + this.tableName + "_" + this.dataNames[this.pkIndex] + "_last.value", value);
		return this.pkValue;
	}
}

class NNRow {
	public ArrayList row;
	private NNTableSchema schema;

	public NNRow (NNTableSchema schema, ArrayList row) {
		this.row = row;
		this.schema = schema;
	}

	public NNRow (NNTableSchema schema) {
		this.row = new ArrayList();
		this.schema = schema;
		for(int i = 0; i < schema.count; i++){
			this.row.add(new NNValue(""));
		}
		this.row.set(this.schema.pkIndex, new NNValue("" + this.schema.nextPK()));
	}

	public NNValue column (int columnId) {
		return (NNValue)(this.row.get(columnId));
	}

	public NNValue column (String column) {
		return (NNValue)(this.row.get(this.schema.indexOfName(column)));
	}

	public void setColumn (String column, NNValue value) {
		this.row.set(this.schema.indexOfName(column), value);
	}

	public void setColumn (String column, String value) {
		this.setColumn(column, new NNValue(value));
	}

	public NNRow set (String column, String value) {
		this.setColumn(column, value);
		return this;
	}

	public NNRow set (String column, NNValue value) {
		this.setColumn(column, value);
		return this;
	}
}

class NNValue {
	private String value;

	public NNValue (String value) {
		this.value = value;
	}

	public int integerValue () {
		return Integer.valueOf(this.value);
	}

	public String stringValue () {
		return this.value;
	}

	public void setValue (int value) {
		this.value = String.valueOf(value);
	}
 
	public void setValue (String value) {
		this.value = value;
	}

	public boolean equals (int value) {
		return this.equals(String.valueOf(value));
	}

	public boolean equals (String value) {
		return this.value.equals(value);
	}
}

class NNTable {
	private NNTableSchema schema;
	private ArrayList data;
	private NNDatabase database;
	public String tableName;
	public NNTable (NNDatabase database, String tableName){
		this.database = database;
		this.tableName = tableName;
		this.schema = new NNTableSchema(database, tableName);
		this.data = new ArrayList();
		String[] lines = loadStrings(database.databasePath + tableName + ".data");
		for(int l = 0; l < lines.length; l++){
			String[] values = lines[l].split("\t");
			for(int v = 0; v < values.length; v++){
				this.data.add(new NNValue(values[v]));
			}
		}
	}

	private int position (int row, int column) {
		return row * this.schema.count + column;
	}

	private NNValue get (int row, int column) {
		return (NNValue)(this.data.get(this.position(row, column)));
	}

	public NNTableSchema schema() {
		return this.schema;
	}

	public ArrayList row (int row) {
		ArrayList result = new ArrayList();
		for(int c = 0; c < this.schema.count; c++){
			NNValue value = this.get(row, c);
			result.add(value);
		}
		return result;
	}

	public int length () {
		return data.size() / this.schema.count;
	}

	public ArrayList find () {
		return this.find("true");
	}

	public ArrayList find (String condition) {
		ArrayList result = new ArrayList();
		int rEnd = this.length();
		for(int r = 0; r < rEnd; r++){
			String test = condition + "";
			for(int c = 0; c < this.schema.count; c++){
				test = test.replaceAll(":" + this.schema.dataNames[c] , "'" + this.get(r, c).stringValue() + "'");
			}
			try {
				String testValue =  js.eval(test).toString();
				if(testValue.equals("true")){
					result.add(new NNRow(this.schema, this.row(r)));
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return result;
	}

	public NNRow findOne (String condition) {
		int rEnd = this.length();
		for(int r = 0; r < rEnd; r++){
			String test = condition + "";
			for(int c = 0; c < this.schema.count; c++){
				test = test.replaceAll(":" + this.schema.dataNames[c] , "'" + this.get(r, c).stringValue() + "'");
			}
			try {
				String testValue =  js.eval(test).toString();
				if(testValue.equals("true")){
					return new NNRow(this.schema, this.row(r));
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return null;
	}

	public void insert (NNRow row) {
		for(int i = 0; i < row.schema.count; i++){
			this.data.add(row.row.get(i));
		}
	}

	public void remove (String condition) {
		int rEnd = this.length();
		for(int r = 0; r < rEnd; r++){
			String test = condition + "";
			for(int c = 0; c < this.schema.count; c++){
				test = test.replaceAll(":" + this.schema.dataNames[c] , "'" + this.get(r, c).stringValue() + "'");
			}
			try {
				String testValue =  js.eval(test).toString();
				if(testValue.equals("true")){
					int p = this.position(r, 0);
					for(int i = 0; i < this.schema.count; i++){
						this.data.remove(p);
					}
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	public void removeOne (String condition) {
		int rEnd = this.length();
		for(int r = 0; r < rEnd; r++){
			String test = condition + "";
			for(int c = 0; c < this.schema.count; c++){
				test = test.replaceAll(":" + this.schema.dataNames[c] , "'" + this.get(r, c).stringValue() + "'");
			}
			try {
				String testValue =  js.eval(test).toString();
				if(testValue.equals("true")){
					int p = this.position(r, 0);
					for(int i = 0; i < this.schema.count; i++){
						this.data.remove(p);
					}
					return;
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	public void save () {
		int rEnd = this.length();
		String[] result = new String[rEnd];
		for(int r = 0; r < rEnd; r++){
			result[r] = "";
			for(int c = 0; c < this.schema.count; c++){
				result[r] += this.get(r, c).stringValue();
				if(c + 1 != this.schema.count){
					result[r] += "\t";
				}
			}
		}
		saveStrings(this.database.databasePath + this.tableName + ".data", result);
	}
}