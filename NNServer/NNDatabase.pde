import javax.script.*;

// 쿼리 파서까지 직접 만들어봤으면 좋았겠지만...ㅠ 쿼리로는 자바스크립트를 사용하기로 했다.
ScriptEngineManager seManager = new ScriptEngineManager();
ScriptEngine js = seManager.getEngineByName("js");    

/**
 * 텍스트 파일기반의 간단한 데이터베이스이다.
 * 아래 클래스는 데이터베이스 객체로, 테이블을 관리한다.
 * 한번 로딩된 데이터베이스는 다시 파일에서 로딩하지 않고 메모리에 캐싱해두고있다가 재사용한다.
 * 데이터베이스는 크게 tablename.schema 파일과 tablename.data 파일로 구성된다.
 * .schema에서 PK를 정의할 경우 해당 컬럼에 대해서 Auto Increment가 적용되는데 이 경우는 tablename_columnname_last.value파일이 필요하다.
 * Join은 따로 지원하지 않고... 그냥 쿼리를 두번때리면 된다ㅋ
 */
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

/**
 * 테이블의 스키마를 저장하는 객체이다.
 * 모든 NNTable, NNRow객체가 이 NNTableSchema를 참조하며 이를 기반으로 데이터를 생성하고 관리한다.
 * PK의 자동증가 (AutoIncrement)도 본 객체가 관장한다.
 */
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

/**
 * 테이블의 행을 저장하는 객체이다.
 * NNTable 객체가 직접적으로 NNRow를 이용해 데이터를 저장하지는 않고, 쿼리 결과로 NNRow를 반환한다.
 * 사용의 편의성을 위해 다중정의된 메소드가 있다.
 */
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

	/**
	 * n번째 컬럼의 값을 가져온다.
	 */
	public NNValue column (int columnId) {
		return (NNValue)(this.row.get(columnId));
	}

	/**
	 * Column의 값을 가져온다.
	 * NNTableSchema의 내용을 기반으로 컬럼이름에 대한 index를 가져온다.
	 */
	public NNValue column (String column) {
		return (NNValue)(this.row.get(this.schema.indexOfName(column)));
	}

	/**
	 * Column의 값을 설정한다.
	 */
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

/**
 * 컬럼값을 저장하는 객체이다.
 * NNDynamicValue와 차이가 없어보이지만 NNDynamicValue는 Object를 그대로 저장하는 반면 NNValue는 무조건 String으로 저장한다.
 * 이는 본 데이터베이스가 텍스트파일 기반이기 때문이다.
 */
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

/**
 * 데이터베이스의 테이블로 CRUD 작업을 담당한다.
 * 데이터는 ArrayList로 관리된다.
 */
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

	/**
	 * Row와 Column의 값으로 ArrayList data에서의 index를 계산한다.
	 */
	private int position (int row, int column) {
		return row * this.schema.count + column;
	}

	/**
	 * Row와 Column의 값으로 해당 위치의 NNValue를 가져온다.
	 */
	private NNValue get (int row, int column) {
		return (NNValue)(this.data.get(this.position(row, column)));
	}

	/**
	 * schema의 getter
	 */
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

	/**
	 * 데이터 갯수
	 */
	public int length () {
		return data.size() / this.schema.count;
	}

	/**
	 * 테이블의 모든 데이터 가져오기
	 * NNRow가 담긴 ArrayList를 반환한다.
	 */
	public ArrayList find () {
		return this.find("true");
	}

	/**
	 * 주어진 조건을 만족하는 행을 모두 가져온다.
	 * NNRow가 담긴 ArrayList를 반환한다.
	 * 조건(쿼리)는 자바스크립트로 처리되기때문에 비교적 자유롭다. ":컬럼이름"으로 컬럼값을 이용할 수 있다.
	 * 예시로 id값이 30 보다 큰 데이터를 모두 가져오려면 ":id > 30" 을 이용한다. 
	 */
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

	/**
	 * 주어진 조건을 만족하는 행을 하나만 가져온다.
	 * NNRow를 반환한다.
	 */
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

	/**
	 * NNRow 객체 내용을 이 테이블의 끝에 추가한다.
	 */
	public void insert (NNRow row) {
		for(int i = 0; i < row.schema.count; i++){
			this.data.add(row.row.get(i));
		}
	}

	/**
	 * 주어진 조건을 만족하는 행을 모두 삭제한다.
	 */
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

	/**
	 * 주어진 조건을 만족하는 행을 하나만 삭제한다.
	 */
	public void removeOne (String condition) {
		int rEnd = this.length();
		for(int r = 0; r < rEnd; r++){
			String test = condition + "";
			try{
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

	/**
	 * 메모리에 들어있는 데이터를 .data 파일에 저장한다.
	 * insert, remove를 실행이후 파일에 바로 반영되는 것이 아니므로 save()를 통해 저장할 수 있다.
	 */
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