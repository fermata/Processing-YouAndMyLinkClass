import java.awt.*;
import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class SearchWindow extends JFrame
{
  public JLabel title;
  public JLabel cd;
  public JLabel nm;
  public JLabel title2;
  public JTextField codeSearchField;
  public JTextField nameSearchField;
  public JButton codeSearchButton;
  public JButton nameSearchButton;
  public JButton[] jjimButton;
  
  //cd = code, nm = name, title2 = my jjim
  
  public SearchWindow(ActionListener buttonListener)
  {
    Container contentPane = getContentPane();
      contentPane.setBackground(Color.CYAN);
      
    title = new JLabel("너와 나의 연결강의");
      contentPane.add(title);
      title.setBounds(33, 61, 255, 44);
      
      cd = new JLabel("CODE : ");
      contentPane.add(cd);
      cd.setBounds(12, 140, 67, 41);
      
      codeSearchField = new JTextField();
      contentPane.add(codeSearchField);
      codeSearchField.setBounds(87, 140, 106, 44);
      
      nm = new JLabel("NAME : ");
      contentPane.add(nm);
      nm.setBounds(12, 219, 67, 41);
      
      nameSearchField = new JTextField();
      contentPane.add(nameSearchField);
      nameSearchField.setBounds(87, 219, 106, 44);
      
      title2 = new JLabel("MY JJIM");
      contentPane.add(title2);
      title2.setBounds(85,295, 136, 52);
      
      codeSearchButton = new JButton("SEARCH");
      contentPane.add(codeSearchButton);
      codeSearchButton.setBounds(201, 140, 107, 44);
      codeSearchButton.addActionListener(buttonListener);
      
      nameSearchButton = new JButton("SEARCH");
      contentPane.add(nameSearchButton);
      nameSearchButton.setBounds(201, 219, 107, 44);
      nameSearchButton.addActionListener(buttonListener);
      
    jjimButton  = new JButton[6];
    for(int i=0; i<jjimButton.length; i++)
      {
      jjimButton[i] = new JButton("jjim "+(i+1));
      contentPane.add(jjimButton[i]);
      jjimButton[i].addActionListener(buttonListener);
      }
    jjimButton[0].setBounds(12, 362, 95, 73);
      jjimButton[1].setBounds(113, 362, 95, 73);
      jjimButton[2].setBounds(213, 362, 95, 73);
      jjimButton[3].setBounds(12, 442, 95, 73);
      jjimButton[4].setBounds(113, 442, 95, 73);
      jjimButton[5].setBounds(213, 442, 95, 73);
  }
  
  public void showWindow()
  {
    setTitle("너와 나의 연결강의");
      setSize(320, 548);
      setLayout(null);
    setVisible(true);
    setResizable(false);
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
  }
}

