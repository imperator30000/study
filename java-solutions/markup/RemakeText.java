package markup;

import java.util.List;

public class RemakeText implements markup {
    protected List<markup> list;
    protected final String symb;
    protected final String[] texSymbs = new String[2];
    protected final String[] htmlSymbs = new String[2];


    public RemakeText(List<markup> list, String symb, String startTex, String finTex, String startHtml, String finHtml) {
        this.list = list;
        this.symb = symb;
        this.texSymbs[0] = startTex;
        this.texSymbs[1] = finTex;
        this.htmlSymbs[0] = startHtml;
        this.htmlSymbs[1] = finHtml;
    }

    @Override
    public void toMarkdown(StringBuilder st) {
        st.append(this.symb);
        for (markup o : this.list) {
            o.toMarkdown(st);
        }
        st.append(this.symb);
    }

    @Override
    public void toTex(StringBuilder st) {
        st.append(this.texSymbs[0]);
        for (markup o : this.list) {
            o.toTex(st);
        }
        st.append(this.texSymbs[1]);
    }

    @Override
    public void toHTML(StringBuilder st) {
        st.append(this.htmlSymbs[0]);
        for (markup o : this.list) {
            o.toHTML(st);
        }
        st.append(this.htmlSymbs[1]);
    }
}
