/**
 * 서버쪽에서 사용하는 NNJSON을 클라이언트용으로 간단하게 만든것. 기능은 비슷하다.
 * JSON 시리얼라이징 기능 등이 빠져있음
 */
class NNArray {
	private ArrayList dataList;

	public NNArray () {
		this.dataList = new ArrayList();
	}

	public NNDynamicValue add () {
		NNDynamicValue value = new NNDynamicValue();
		this.dataList.add(value);
		return value;
	}

	public NNDynamicValue get (int index) {
		return (NNDynamicValue)(this.dataList.get(index));
	}

	public void remove (int index) {
		this.dataList.remove(index);
	}

	public int size () {
		return this.dataList.size();
	}

	public void each (NNArrayIterator iterator) {
		int dataListSize = this.dataList.size();
		for(int i = 0; i < dataListSize; i++){
			NNDynamicValue value = (NNDynamicValue)(this.dataList.get(i));
			iterator.iterate(i, value);
		}
	}
}

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

	public NNDynamicValue get (String key) {
		return ((NNKeyValue)(this.dataList.get(this.position(key)))).value();
	}

	public void remove (String key) {
		this.dataList.remove(this.position(key));
	}

	public int size () {
		return this.dataList.size();
	}

	public void each (NNDictionaryIterator iterator) {
		int dataListSize = this.dataList.size();
		for(int i = 0; i < dataListSize; i++){
			NNKeyValue keyValue = (NNKeyValue)(this.dataList.get(i));
			iterator.iterate(keyValue.key(), keyValue.value());
		}
	}
}

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
}

interface NNDictionaryIterator {
	public void iterate (String key, NNDynamicValue value);
}

interface NNArrayIterator {
	public void iterate (int index, NNDynamicValue value);
}