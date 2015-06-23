import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.*;

final NNAPI api = new NNAPI("http://localhost:8080");

final NNClient globalThis = this;

private boolean updateJJimList () {
	int tries = 0;
	while(true){
		try{
			JSONObject result = api.get("/me/jjim");
			JSONArray classes = result.getJSONArray("jjims");
			for(int i=0; i<classes.size(); i++)
			{
				JSONObject suup = classes.getJSONObject(i);
				searchWindow.jjimButton[i].setText(suup.getString("code"));
			}  
			for(int i = classes.size(); i < 6; i++){
				searchWindow.jjimButton[i].setText("");
			}
			return true;
		} catch (Exception exp) {
			if(tries < 3) tries ++; else {
				JOptionPane.showMessageDialog(null, "서버 통신 오류");
				return false;
			}
		}
	}
}

public final FriendWindow friendWindow = new FriendWindow(new ActionListener() {
	@Override
	public void actionPerformed (ActionEvent e) {

	}
});

public final InfoWindow infoWindow = new InfoWindow(new ActionListener() {
	@Override
	public void actionPerformed (ActionEvent e) {
		if(e.getSource() == infoWindow.jjimButton){
			JSONObject result = api.post("/me/jjim/"+infoWindow.codeLabel.getText());
			println("응답:" +result.getString("status"));
			if (result.getBoolean("success")) {
				JOptionPane.showMessageDialog(null, "찜 되었습니다.");
				globalThis.updateJJimList();
			}else{
				JOptionPane.showMessageDialog(null, "이미 찜한 항목입니다.");
			}
		}
		else if(e.getSource() == infoWindow.unjjimButton){
			JSONObject result = api.delete("/me/jjim/"+infoWindow.codeLabel.getText());
			println("응답:" +result.getString("status"));
			if (result.getBoolean("success")) {
				JOptionPane.showMessageDialog(null, "찜 취소되었습니다.");
				globalThis.updateJJimList();
			}else{
				JOptionPane.showMessageDialog(null, "찜하지 않은 항목입니다.");
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
				JOptionPane.showMessageDialog(null, "회원가입 되었습니다.");
			}
			else {
				JOptionPane.showMessageDialog(null, "회원가입에 실패했습니다.");
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
				if(globalThis.updateJJimList()){
					searchWindow.showWindow();
				}
			}
			else {
				JOptionPane.showMessageDialog(null, "존재하지 않는 계정입니다.");
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
				JOptionPane.showMessageDialog(null, "수업을 찾을 수 없습니다.");
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
						friendWindow.jjimButton[i].setForeground(Color.RED);
					}else{
						friendWindow.jjimButton[i].setForeground(Color.BLACK);
					}
					friendWindow.jjimButton[i].setText(suup.getString("code"));
				}  
				for(int i = classes.size(); i < 6; i++){
					friendWindow.jjimButton[i].setText("");
				}
				int percentage = commons != 0 ? (int)(((float)commons / (float)classes.size()) * 100) : 0;
				friendWindow.similarityLabel.setText(searchWindow.nameSearchField.getText() + "님과 " + percentage + "% 일치");
				friendWindow.friendNameLabel.setText(searchWindow.nameSearchField.getText() + "님의 찜 수업");


			}
			else {
				JOptionPane.showMessageDialog(null, "사용자를 찾을 수 없습니다.");
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