
class NNDictionary {
	private ArrayList dataList;

	public NNDictionary () {
		this.dataList = new ArrayList();
	}

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

	public NNDictionaryValue put (String key) {
		int keyPosition = this.position(key);
		if(keyPosition != -1){
			return ((NNKeyValue)(this.dataList.get(keyPosition))).value();
		}else{
			NNKeyValue keyValue = new NNKeyValue(key);
			this.dataList.add(keyValue);
			return keyValue.value();
		}
	}

	public NNDictionaryValue get (String key) {
		return ((NNKeyValue)(this.dataList.get(this.position(key)))).value();
	}

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
				serialized.append(", ");
			}
		}
		serialized.append("}");
		return serialized.toString();
	}
}

class NNKeyValue {
	private String keyString;
	private NNDictionaryValue value;

	public NNKeyValue (String keyString) {
		this.keyString = keyString;
		this.value = new NNDictionaryValue();
	}

	public NNKeyValue (String keyString, NNDictionaryValue value) {
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

	public void setValue (int value) {
		this.value = new NNDictionaryValue(value);
	}

	public void setValue (String value) {
		this.value = new NNDictionaryValue(value);
	}

	public void setValue (boolean value) {
		this.value = new NNDictionaryValue(value);
	}

	public void setValue (float value) {
		this.value = new NNDictionaryValue(value);
	}

	public boolean is (String keyString) {
		return this.keyString.equals(keyString);
	}

	public String key () {
		return this.keyString;
	}

	public NNDictionaryValue value () {
		return this.value;
	}
}

class NNDictionaryValue {
	private int type;
	private Object value;

	public NNDictionaryValue () {
		this.type = 1;
		this.value = "";
	}
	
	public NNDictionaryValue (String stringValue) {
		this.set(stringValue);
	}

	public NNDictionaryValue (int integerValue) {
		this.set(integerValue);
	}

	public NNDictionaryValue (float floatValue) {
		this.set(floatValue);
	}

	public NNDictionaryValue (boolean booleanValue) {
		this.set(booleanValue);
	}

	public NNDictionaryValue (NNDictionary dictionaryValue) {
		this.set(dictionaryValue);
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

	public Object value () {
		return this.value;
	}

	public String serialize () {
		switch(this.type){
			case 1: return "\"" + ((String)(this.value)).replaceAll("\"", "\\\"") + "\"";
			case 2:	return ((Integer)(this.value)).toString();
			case 3: return ((Float)(this.value)).toString();
			case 4: return ((Boolean)(this.value)).toString();
			case 5: return ((NNDictionary)(this.value)).serialize();
		}
		return "";
	}
}