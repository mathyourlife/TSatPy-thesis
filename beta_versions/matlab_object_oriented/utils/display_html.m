%
% modified from: http://undocumentedmatlab.com/blog/gui-integrated-html-panel/
function je = display_html(html)
  hfig = figure();
  
  je = javax.swing.JEditorPane('text/html', html);
  jp = javax.swing.JScrollPane(je);
  
  [hcomponent, hcontainer] = javacomponent(jp, [], hfig);
  set(hcontainer, 'units', 'normalized', 'position', [0,0,1,1]);
  
  %# Turn anti-aliasing on ( R2006a, java 5.0 )
  java.lang.System.setProperty('awt.useSystemAAFontSettings', 'on');
  je.putClientProperty(javax.swing.JEditorPane.HONOR_DISPLAY_PROPERTIES, true);
  je.putClientProperty(com.sun.java.swing.SwingUtilities2.AA_TEXT_PROPERTY_KEY, true);
  
  je.setFont(java.awt.Font('Arial', java.awt.Font.PLAIN, 12));
end