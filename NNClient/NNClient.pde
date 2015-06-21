import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

final NNAPI api = new NNAPI("http://172.30.1.40:8080");

public final FriendWindow friendWindow = new FriendWindow(new ActionListener() {
	@Override
	public void actionPerformed (ActionEvent e) {
		/*if(e.getSource() == friendWindow.jjimButton[0]){

		}*/
	}
});

public final InfoWindow infoWindow = new InfoWindow(new ActionListener() {
	@Override
	public void actionPerformed (ActionEvent e) {
		if(e.getSource() == infoWindow.jjimButton){
                        JSONObject result = api.post("/me/jjim/"+infoWindow.codeLabel.getText());
                        println("응답:" +result.getString("status"));
                        if (result.getBoolean("success")) {
                          println("JJim succeeded");
                        }
		}
                else if(e.getSource() == infoWindow.unjjimButton){
                        JSONObject result = api.delete("/me/jjim/"+infoWindow.codeLabel.getText());
                        println("응답:" +result.getString("status"));
                        if (result.getBoolean("success")) {
                          println("UnJJim succeeded");
                        }

		}
	}
});

public final JoinWindow joinWindow = new JoinWindow(new ActionListener() {
	@Override
	public void actionPerformed (ActionEvent e) {
		if(e.getSource() == joinWindow.joinButton){
                        NNDictionary data = new NNDictionary();
                        data.key("username").set(joinWindow.idField.getText());
                        data.key("password").set(joinWindow.passwordField.getText());
                        JSONObject result = api.post("/user/add", data);
                        println("응답:" +result.getString("status"));
                        if (result.getBoolean("success")) {
                          println("join succeeded");
                        }
                        else {
                          println("join failed");
                        }
		}else if(e.getSource() == joinWindow.cancelButton){

		}
	}
});

public final LoginWindow loginWindow = new LoginWindow(new ActionListener() {
	@Override
	public void actionPerformed (ActionEvent e) {
		if(e.getSource() == loginWindow.loginButton){
                        NNDictionary data = new NNDictionary();
                        data.key("username").set(loginWindow.idField.getText());
                        data.key("password").set(loginWindow.passwordField.getText());
                        JSONObject result = api.post("/user/auth", data);
                        println("응답:" +result.getString("status"));
                        if (result.getBoolean("success")) {
                          api.accessToken = result.getString("access_token");
                          searchWindow.showWindow();
                          result = api.get("/me/jjim");
                          JSONArray classes = result.getJSONArray("jjims");
                          int commons = 0;
                          for(int i=0; i<classes.size(); i++)
                          {
                            JSONObject suup = classes.getJSONObject(i);
                            if(suup.getBoolean("common")) {
                              commons++;
                            }
                            searchWindow.jjimButton[i].setText(suup.getString("code"));
                          }  
                          for(int i = classes.size(); i < 6; i++){
                            searchWindow.jjimButton[i].setText("");
                          }
                        }
                        else {
                          println("login failed");
                        }
		}else if(e.getSource() == loginWindow.joinButton){
                        joinWindow.showWindow();
		}
	}
});

public final SearchWindow searchWindow = new SearchWindow(new ActionListener(){
	@Override
	public void actionPerformed (ActionEvent e) {
		if(e.getSource() == searchWindow.codeSearchButton){
                        JSONObject result = api.get("/class/"+searchWindow.codeSearchField.getText());
                        println("응답:" +result.getString("status"));
                        if (result.getBoolean("success")) {
                          infoWindow.showWindow();
                          JSONObject suup = result.getJSONObject("class");
                          infoWindow.codeLabel.setText(suup.getString("code"));
                          infoWindow.classNameLabel.setText(suup.getString("name"));
                          infoWindow.profNameLabel.setText(suup.getString("professor"));
                          println(suup);
                        }
                        else {
                          println("class not found");
                        }

		}else if(e.getSource() == searchWindow.nameSearchButton){
                       JSONObject result = api.get("/me/jjim/other/"+searchWindow.nameSearchField.getText());
                        println("응답:" +result.getString("status"));
                        if (result.getBoolean("success")) {
                           friendWindow.showWindow();
                          JSONArray classes = result.getJSONArray("classes");
                          int commons = 0;
                          for(int i=0; i<classes.size(); i++)
                          {
                            JSONObject suup = classes.getJSONObject(i);
                            if(suup.getBoolean("common")) {
                              commons++;
                            }
                            friendWindow.jjimButton[i].setText(suup.getString("code"));
                          }  
                          for(int i = classes.size(); i < 6; i++){
                            friendWindow.jjimButton[i].setText("");
                          }
                          int percentage = commons != 0 ? (int)(((float)commons / (float)classes.size()) * 100) : 0;
                          friendWindow.similarityLabel.setText(percentage + "%");
                          friendWindow.friendNameLabel.setText(searchWindow.nameSearchField.getText());


                        }
                        else {
                          println("user not found");
                        }

		}
	}
});

void setup () {
	loginWindow.showWindow();
}

void draw () {
	frameRate(0);
}
