/**
 * JSON으로 직렬화가 가능한 Array객체
 */
class NNArray {
	private ArrayList dataList;

	/**
	 * 기본 생성자
	 */
	public NNArray () {
		this.dataList = new ArrayList();
	}

	/**
	 * 빈 NNArray객체를 NNRow가 담긴 ArrayList로 채워넣는다. 데이터베이스 쿼리 결과를 바로 NNArray객체로 변환할 수 있다.
	 * @param ArrayList rows NNRow가 담긴 ArrayList 객체
	 */
	public void withRows (ArrayList rows) {
		for(int i = 0; i < rows.size(); i++){
			NNRow row = (NNRow)(rows.get(i));
			NNDictionary rowDictionary = new NNDictionary();
			rowDictionary.withRow(row);
			this.add().set(rowDictionary);
		}
	}

	/**
	 * 자신(NNArray)에 새 공간을 끝에 추가하고 해당 공간의 NNDynamicValue를 반환한다.
	 * @return NNDynamicValue 새 공간의 NNDynamicValue
	 */
	public NNDynamicValue add () {
		NNDynamicValue value = new NNDynamicValue();
		this.dataList.add(value);
		return value;
	}

	/**
	 * index(n)번째 공간의 NNDynamicValue를 반환한다.
	 * @param int index 가져올 공간의 위치 (n)
	 * @return NNDynamicValue 새 공간의 NNDynamicValue
	 */
	public NNDynamicValue get (int index) {
		return (NNDynamicValue)(this.dataList.get(index));
	}

	/**
	 * index(n)번째 공간을 제거한다.
	 * @param int index 제거할 공간의 위치 (n)
	 */
	public void remove (int index) {
		this.dataList.remove(index);
	}

	/**
	 * 배열의 크기를 반환한다.
	 */
	public int size () {
		return this.dataList.size();
	}

	/**
	 * 자신(NNArray)를 JSON 형태로 직렬화한다. 하위 객체도 모두 JSON으로 직렬화 된다.
	 * @return String JSON 문자열
	 */
	public String serialize () {
		int dataListSize = this.dataList.size();
		StringBuffer serialized = new StringBuffer();
		serialized.append("[");
		for(int i = 0; i < dataListSize; i++){
			NNDynamicValue value = (NNDynamicValue)(this.dataList.get(i));
			serialized.append(value.serialize());
			if(i + 1 != dataListSize){
				serialized.append(",");
			}
		}
		serialized.append("]");
		return serialized.toString();
	}

	/**
	 * 자신(NNArray) 내부의 값들을 하나하나 반복하여 NNArrayIterator를 실행한다.
	 * @param NNArrayIterator iterator 반복해서 실행할 내용이 담긴 객체
	 */
	public void each (NNArrayIterator iterator) {
		int dataListSize = this.dataList.size();
		for(int i = 0; i < dataListSize; i++){
			NNDynamicValue value = (NNDynamicValue)(this.dataList.get(i));
			iterator.iterate(i, value);
		}
	}
}

/**
 * JSON으로 직렬화가 가능한 Dictionary객체
 */
class NNDictionary {
	private ArrayList dataList;

	/**
	 * 기본 생성자
	 */
	public NNDictionary () {
		this.dataList = new ArrayList();
	}

	/**
	 * 빈 NNDictionary객체를 NNRow로 채워넣는다. 데이터베이스 쿼리 결과를 바로 NNDictionary객체로 변환할 수 있다.
	 * @param NNRow row DB가 반환한 NNRow객체
	 */
	public void withRow (NNRow row) {
		NNTableSchema schema = row.schema;
		for(int i = 0; i < schema.dataNames.length; i++){
			if(schema.dataTypes[i].equals("String")){
				this.key(schema.dataNames[i]).set(row.column(i).stringValue());
			}else if(schema.dataTypes[i].equals("int")){
				this.key(schema.dataNames[i]).set(row.column(i).integerValue());
			}
		}
	}

	/**
	 * 데이터가 사실상 ArrayList에 저장되기 때문에 데이터를 읽어오려면 배열에서의 위치를 알아야한다. 이 메소드가 키값에 대한 배열의 위치를 반환한다.
	 */
	private int position (String key) {
		int dataListSize = this.dataList.size();
		for(int i = 0; i < dataListSize; i++){
			NNKeyValue keyValue = (NNKeyValue)(this.dataList.get(i));
			if(keyValue.is(key)){
				return i;
			}
		}
		return -1;
	}

	/**
	 * Key에 대한 Value를 반환한다. 키가 없을 경우 공간을 생성한다.
	 * @param String key 값을 가져올 키
	 * @return NNDynamicValue 값
	 */
	public NNDynamicValue key (String key) {
		int keyPosition = this.position(key);
		if(keyPosition != -1){
			return ((NNKeyValue)(this.dataList.get(keyPosition))).value();
		}else{
			NNKeyValue keyValue = new NNKeyValue(key);
			this.dataList.add(keyValue);
			return keyValue.value();
		}
	}

	/**
	 * Key에 대한 Value를 반환한다. 키가 없을 경우 공간을 생성하지 않는다. 없는 키를 참조할 경우 NullPointerException이 발생하므로 유의한다.
	 * @param String key 값을 가져올 키
	 * @return NNDynamicValue 값
	 */
	public NNDynamicValue get (String key) {
		return ((NNKeyValue)(this.dataList.get(this.position(key)))).value();
	}

	/**
	 * Key를 삭제한다.
	 * @param String key 삭제할 키
	 */
	public void remove (String key) {
		this.dataList.remove(this.position(key));
	}

	/**
	 * 원소의 갯수를 반환한다.
	 */
	public int size () {
		return this.dataList.size() / 2;
	}

	/**
	 * 자신(NNDictionary)를 JSON 형태로 직렬화한다. 하위 객체도 모두 JSON으로 직렬화 된다.
	 * @return String JSON 문자열
	 */
	public String serialize () {
		int dataListSize = this.dataList.size();
		StringBuffer serialized = new StringBuffer();
		serialized.append("{");
		for(int i = 0; i < dataListSize; i++){
			NNKeyValue keyValue = (NNKeyValue)(this.dataList.get(i));
			serialized.append("\"");
			serialized.append(keyValue.key());
			serialized.append("\":");
			serialized.append(keyValue.value().serialize());
			if(i + 1 != dataListSize){
				serialized.append(",");
			}
		}
		serialized.append("}");
		return serialized.toString();
	}

	/**
	 * 자신(NNDictionary) 내부의 키-값 쌍들을 하나하나 반복하여 NNDictionaryIterator를 실행한다.
	 * @param NNDictionaryIterator iterator 반복해서 실행할 내용이 담긴 객체
	 */
	public void each (NNDictionaryIterator iterator) {
		int dataListSize = this.dataList.size();
		for(int i = 0; i < dataListSize; i++){
			NNKeyValue keyValue = (NNKeyValue)(this.dataList.get(i));
			iterator.iterate(keyValue.key(), keyValue.value());
		}
	}
}

/**
 * NNDictionary 내부에서 사용하는 KeyValue 데이터 구조이다.
 * 외부에선 따로 직접 사용할 일이 없다.
 * 워낙 직관적이므로ㅋ 주석은 생략한다ㅋ
 */
class NNKeyValue {
	private String keyString;
	private NNDynamicValue value;

	public NNKeyValue (String keyString) {
		this.keyString = keyString;
		this.value = new NNDynamicValue();
	}

	public NNKeyValue (String keyString, NNDynamicValue value) {
		this.keyString = keyString;
		this.value = value;
	}

	public NNKeyValue (String keyString, int value) {
		this.keyString = keyString;
		this.setValue(value);
	}

	public NNKeyValue (String keyString, String value) {
		this.keyString = keyString;
		this.setValue(value);
	}

	public NNKeyValue (String keyString, float value) {
		this.keyString = keyString;
		this.setValue(value);
	}

	public NNKeyValue (String keyString, boolean value) {
		this.keyString = keyString;
		this.setValue(value);
	}

	public NNKeyValue (String keyString, NNDictionary value) {
		this.keyString = keyString;
		this.setValue(value);
	}

	public NNKeyValue (String keyString, NNArray value) {
		this.keyString = keyString;
		this.setValue(value);
	}

	public void setValue (int value) {
		this.value = new NNDynamicValue(value);
	}

	public void setValue (String value) {
		this.value = new NNDynamicValue(value);
	}

	public void setValue (boolean value) {
		this.value = new NNDynamicValue(value);
	}

	public void setValue (float value) {
		this.value = new NNDynamicValue(value);
	}

	public void setValue (NNDictionary value) {
		this.value = new NNDynamicValue(value);
	}

	public void setValue (NNArray value) {
		this.value = new NNDynamicValue(value);
	}

	public boolean is (String keyString) {
		return this.keyString.equals(keyString);
	}

	public String key () {
		return this.keyString;
	}

	public NNDynamicValue value () {
		return this.value;
	}
}

/**
 * 자료형에 구애받지 않고 쉽게 데이터를 읽고 쓸 수 있도록 만든 구조이다.
 * 데이터가 set되면 해당 데이터의 자료형에 따라 serialize()메소드의 반환 형태가 달라진다.
 * 이도 너무 직관적이므로 생략 ㅋ
 */
class NNDynamicValue {
	private int type;
	private Object value;

	public NNDynamicValue () {
		this.type = 1;
		this.value = "";
	}
	
	public NNDynamicValue (String stringValue) {
		this.set(stringValue);
	}

	public NNDynamicValue (int integerValue) {
		this.set(integerValue);
	}

	public NNDynamicValue (float floatValue) {
		this.set(floatValue);
	}

	public NNDynamicValue (boolean booleanValue) {
		this.set(booleanValue);
	}

	public NNDynamicValue (NNDictionary dictionaryValue) {
		this.set(dictionaryValue);
	}

	public NNDynamicValue (NNArray arrayValue) {
		this.set(arrayValue);
	}

	public void set (String stringValue) {
		this.type = 1;
		this.value = stringValue;
	}

	public void set (int integerValue) {
		this.type = 2;
		this.value = (Integer)integerValue;
	}

	public void set (float floatValue) {
		this.type = 3;
		this.value = (Float)floatValue;
	}

	public void set (boolean booleanValue) {
		this.type = 4;
		this.value = (Boolean)booleanValue;
	}

	public void set (NNDictionary dictionaryValue) {
		this.type = 5;
		this.value = dictionaryValue;
	}

	public void set (NNArray arrayValue) {
		this.type = 6;
		this.value = arrayValue;
	}

	public Object value () {
		return this.value;
	}

	public String stringValue () {
		return (String)(this.value);
	}

	public int integerValue () {
		return (Integer)(this.value);
	}

	public float floatValue () {
		return (Float)(this.value);
	}

	public boolean booleanValue () {
		return (Boolean)(this.value);
	}

	public NNDictionary dictionaryValue () {
		return (NNDictionary)(this.value);
	}

	public NNArray arrayValue () {
		return (NNArray)(this.value);
	}

	public String serialize () {
		switch(this.type){
			case 1: return "\"" + ((String)(this.value)).replaceAll("\"", "\\\"") + "\"";
			case 2:	return ((Integer)(this.value)).toString();
			case 3: return ((Float)(this.value)).toString();
			case 4: return ((Boolean)(this.value)).toString();
			case 5: return ((NNDictionary)(this.value)).serialize();
			case 6: return ((NNArray)(this.value)).serialize();
		}
		return "";
	}
}

interface NNDictionaryIterator {
	public void iterate (String key, NNDynamicValue value);
}

interface NNArrayIterator {
	public void iterate (int index, NNDynamicValue value);
}