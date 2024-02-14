package markup;

import java.util.Map;

public class Text implements markup {
    private final String text;
    private Map<Character, String> htmlChars = Map.of(
            '>', "&gt;",
            '<', "&lt;",
            '&', "&amp;"
    );
    public Text(String text){
        this.text = text;
    }
    public void toMarkdown(StringBuilder st){
        st.append(this.text);
    }

    public void toTex(StringBuilder st) {
        st.append(this.text);
    }

    @Override
    public void toHTML(StringBuilder st) {
        System.out.println(this.text);
        for (int i = 0; i < this.text.length(); i++){
            char ch = this.text.charAt(i);
            st.append(htmlChars.getOrDefault(ch, String.valueOf(ch)));
        }
    }
}
