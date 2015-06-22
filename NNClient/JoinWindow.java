import java.awt.*;
import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class JoinWindow extends JFrame
{
  public JLabel title ;
  public JLabel id;
  public JLabel pw;
  public JTextField idField;
  public JTextField passwordField;;
  public JButton joinButton;
  public JButton cancelButton;
  
  public JoinWindow(ActionListener buttonListener)
  {
    Container contentPane = getContentPane();
      contentPane.setBackground(Color.CYAN);
      
      title = new JLabel("너와 나의 연결강의");
      title.setHorizontalAlignment(SwingConstants.CENTER);
      title.setFont(title.getFont().deriveFont(20.0f));
      contentPane.add(title);
      title.setBounds(33, 61, 255, 44);
      
      id = new JLabel("ID : ");
      contentPane.add(id);
      id.setBounds(33, 175, 67, 41);
      
      idField = new JTextField();
      contentPane.add(idField);
      idField.setBounds(121, 175, 167, 44);
      
      pw = new JLabel("PW : ");
      contentPane.add(pw);
      pw.setBounds(33, 254, 67, 41);
      
      passwordField = new JTextField();
      contentPane.add(passwordField);
      passwordField.setBounds(121, 252, 167, 44);
      
      joinButton = new JButton("JOIN");
      contentPane.add(joinButton);
      joinButton.setBounds(33, 351, 117, 55);
      joinButton.addActionListener(buttonListener);
      
      cancelButton = new JButton("CANCEL");
      contentPane.add(cancelButton);
      cancelButton.setBounds(171, 351, 117, 55);
      cancelButton.addActionListener(buttonListener);
  }
  
  public void showWindow()
  {
    setTitle("너와 나의 연결강의");
    setSize(320, 548);
    setLayout(null);
    setVisible(true);
    setResizable(false);
   // setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
  }

}

