import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public final FriendWindow friendWindow = new FriendWindow(new ActionListener(){
	@Override
	public void actionPerformed (ActionEvent e) {
		/*if(e.getSource() == friendWindow.jjimButton[0]){

		}*/
	}
});

public final InfoWindow infoWindow = new InfoWindow(new ActionListener(){
	@Override
	public void actionPerformed (ActionEvent e) {
		if(e.getSource() == infoWindow.jjimButton){

		}else if(e.getSource() == infoWindow.unjjimButton){

		}
	}
});

public final JoinWindow joinWindow = new JoinWindow(new ActionListener(){
	@Override
	public void actionPerformed (ActionEvent e) {
		if(e.getSource() == joinWindow.joinButton){

		}else if(e.getSource() == joinWindow.cancelButton){

		}
	}
});

public final LoginWindow loginWindow = new LoginWindow(new ActionListener(){
	@Override
	public void actionPerformed (ActionEvent e) {
		if(e.getSource() == loginWindow.loginButton){
			println("b");
		}else if(e.getSource() == loginWindow.joinButton){
			println("a");
		}
	}
});

public final SearchWindow searchWindow = new SearchWindow(new ActionListener(){
	@Override
	public void actionPerformed (ActionEvent e) {
		if(e.getSource() == searchWindow.codeSearchButton){

		}else if(e.getSource() == searchWindow.nameSearchButton){

		}else if(e.getSource() == searchWindow.jjimButton){

		}
	}
});

void setup () {
	loginWindow.showWindow();
}

void draw () {
	frameRate(0);
}
