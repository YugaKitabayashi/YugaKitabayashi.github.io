<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.net.*" %>
<%!
public class HttpSendJSON {
	public String postJson(String strPostUrl, String json) {
		HttpURLConnection uc;
		try {
			URL url = new URL(strPostUrl);
			uc = (HttpURLConnection) url.openConnection();
			uc.setRequestMethod("POST");
			uc.setUseCaches(false);
			uc.setDoOutput(true);
			uc.setRequestProperty("Content-Type", "application/json; charset=utf-8");
			OutputStreamWriter out = new OutputStreamWriter(new BufferedOutputStream(uc.getOutputStream()),"UTF-8");
			out.write(json);
			out.close();

			BufferedReader in = new BufferedReader(new InputStreamReader(uc.getInputStream()));
			String line = in.readLine();
			String body = "";
			while (line != null) {
				body = body + line;
				line = in.readLine();
			}
			uc.disconnect();
			return body;
		} catch (IOException e) {
			e.printStackTrace();
			return "client - IOException : " + e.getMessage();
		}
	}
}

String prettyPrintHTML(String s) {
    if (s == null)
    return "";
    return s.replace("&", "&amp;")
    .replace("\"", "&quot;")
    .replace("<", "&lt;")
    .replace(">", "&gt;")
    .replace("'", "&#39;")
    .replace("\n", "<br>\n");
}

public class MyHttpClient {
    public String url = "https://www.debian.org/"; /* URL */
    public String encoding = "UTF-8"; /* レスポンスの文字コード */
    public String header = ""; /* レスポンスヘッダ文字列 */
    public String body = ""; /* レスポンスボディ */

    /* 2つの引数（URL，エンコーディング）をとるコンストラクタ */
    public MyHttpClient(String url_, String encoding_) {
	url = url_;
	encoding = encoding_;
    }

    /* 1つの引数（URL）をとるコンストラクタ */
    public MyHttpClient(String url_) {
	url = url_;
    }

    /* 実際にアクセスし，フィールドheaderおよびbodyに値を格納する */
    public void doAccess()
    throws MalformedURLException, ProtocolException, IOException {

	/* 接続準備 */
	URL u = new URL(url);
	HttpURLConnection con = (HttpURLConnection)u.openConnection();
	con.setRequestMethod("GET");
	con.setInstanceFollowRedirects(true);

	/* 接続 */
	con.connect();

	/* レスポンスヘッダの獲得 */
	Map<String, List<String>> headers = con.getHeaderFields();
	StringBuilder sb = new StringBuilder();
	Iterator<String> it = headers.keySet().iterator();

	while (it.hasNext()) {
	    String key = (String) it.next();
	    sb.append("  " + key + ": " + headers.get(key) + "\n");
	}

	/* レスポンスコードとメッセージ */
	sb.append("RESPONSE CODE [" + con.getResponseCode() + "]\n");
	sb.append("RESPONSE MESSAGE [" + con.getResponseMessage() + "]\n");

	header = sb.toString();

	/* レスポンスボディの獲得 */
	BufferedReader reader = new BufferedReader(
	    new InputStreamReader(con.getInputStream(),
		encoding));
	String line;
	sb = new StringBuilder();

	while ((line = reader.readLine()) != null) {
	    sb.append(line + "\n");
	}

	body = sb.toString();

	/* 接続終了 */
	reader.close();
	con.disconnect();
    }
}

%>
<%!
class Wordnode{
	String word;
	int hierarchy;
	int parent;
	boolean open;
	Wordnode(String word_,int hierarchy_,int parent_){
		word=word_;
		hierarchy=hierarchy_;
		parent=parent_;
		open=false;
	}

	String htmlSentense(int index,String root,String chain){
		if(open){
			return "<div class=\"node" + hierarchy + " parent" + parent + "\" id=\"word" + index + "\">"
					+"<div class=\"word\">"+word+"</div>"
					+"</div>";
		}else{
			return "<div class=\"node" + hierarchy + " parent" + parent + "\" id=\"word" + index + "\">"
					+"<div class=\"word\"><a href=\"result.jsp?root="+root+"&chain="+chain+"-"+index+"\">"+word+"</a></div>"
					+"</div>";
		}
	}

}

static class APIkey{
	static String[] key={
		"cac075a8292cd8303dbefdf0f5de7c3f95a20837c49f8f7605088d716d0f38cc",
		"a23720fb5760489f137081b10e8c609cbd197887e888bb9d56cdd6ad84175fbc",
		"c8ef89b400c5f65963f025274cb108fe9b13c0dc515f824bbac360e81b712f5c",
		"c5012790a1fba87e6d39bf44f34cbbb77490e80716d57997f77d033b4657841a"
	};
	static String getkey(){
		Random random=new Random();
		return key[random.nextInt(key.length)];
	}
}
String removeBracket(String str){
	StringBuilder sb = new StringBuilder(str);
	int h=0;
	for(int i=0;i<str.length();i++){
		if(str.charAt(i)=='（' || str.charAt(i)=='(' || str.charAt(i)=='['){
			sb.setCharAt(i,' ');
			h++;
		}else if(str.charAt(i)=='）' || str.charAt(i)==')' || str.charAt(i)==']'){
			sb.setCharAt(i,' ');
			h--;
		}
		if(h>0){
			sb.setCharAt(i,' ');
		}
	}
	return sb.toString().replaceAll(" ", "");
}

String[] getSentense(String word){
	String[] msg = {"",""};
	String[] error = {"",""};
	MyHttpClient mhc; // HTTPで通信するためのインスタンス

	String url = "http://wikipedia.simpleapi.net/api?keyword=" + word + "&output=xml";
    try {
	mhc = new MyHttpClient(url);
	mhc.doAccess();
	msg[0] = mhc.body;

	while(msg[0].indexOf("<body>")!=-1){
		if(msg[0].indexOf("</body>")-msg[0].indexOf("<body>")>50){
			msg[1] = msg[0].substring(msg[0].indexOf("<url>")+5,msg[0].indexOf("</url>"));
			msg[0] = msg[0].substring(msg[0].indexOf("<body>")+6,msg[0].indexOf("</body>"));
			msg[0] = removeBracket(msg[0]);
			msg[0] = msg[0].replaceAll("出典", "");
			msg[0] = msg[0].replaceAll("関連項目", "");
			return msg;
		}else{
			msg[0]=msg[0].substring(msg[0].indexOf("</result>"));
		}
	}
    return error;
    } catch(MalformedURLException e) {
        return error;
    } catch(ProtocolException e) {
        return error;
    } catch(IOException e) {
        return error;
    }
}

float Corr(String a,String b){
	float sum=0;
	for(int i=0;i<a.length();i++){
		for(int j=0;j<b.length();j++){
			if(a.charAt(i)==b.charAt(j))sum+=1;
		}
	}
	return sum;
}

String[] getKeyword(String sentense,String word){
	String app_id = APIkey.getkey();
	HttpSendJSON hsj;
	String url = "https://labs.goo.ne.jp/api/keyword";
	String json = "{\"app_id\":\""+app_id+"\","
	+"\"title\":\"" + word + "\",\"body\":\""+sentense+"\",\"max_num\":30}";
	hsj = new HttpSendJSON();
	json = hsj.postJson(url, json);

	float cw = Corr(word,word);
	if(sentense!="" && json.indexOf("[")!=-1){
		json = json.substring(json.indexOf("[")+1, json.indexOf("]"));
		Comparator<String> comparator = (s1, s2)->s2.compareTo(s1);
		Map<String, Float> map = new TreeMap<>();

		while(json.indexOf("{")!=-1){
			String str = json.substring(json.indexOf("{\"")+2,json.indexOf("\":"));
			float weight = Float.parseFloat(json.substring(json.indexOf(":")+1,json.indexOf("}")));
			if(json.indexOf(",")!=-1)json=json.substring(json.indexOf(",")+1);
			else break;
			float cj = Corr(str,str);
			map.put(str, weight*(float)(0.5-Corr(str,word)/(cw+cj)));
		}

		String[] keywords = {"","","","",""};
		for(int i=0;i<5;i++){
			float max = 0;
			for(String w:map.keySet()){
				if(max < map.get(w)){
					max = map.get(w);
					keywords[i] = w;
				}
			}
			map.remove(keywords[i]);
		}
		return keywords;
	}else{
		return new String[0];
	}
}

String[] buildHTML(String root,String chain){
	List<Wordnode> nodes = new ArrayList<Wordnode>();
	String[] sentense = getSentense(root);
	Wordnode rootnode = new Wordnode(root,0,-1);
	nodes.add(rootnode);
	String[] msg = {"","","",""};

	int[] chainnum = chainIndex(chain);
	for(int i:chainnum){
		sentense = getSentense(nodes.get(i).word);
		String[] child = getKeyword(sentense[0],nodes.get(i).word);
		if(!sentense[0].equals("")){
			msg[1]=nodes.get(i).word;
			msg[2]=sentense[1];
			if(i!=0){
				msg[3]=nodes.get(i).word;
			}
		}
		if(i==0 && child.length<5){
			nodes.get(0).open = true;
			msg[0]="<div class=\"node0 id=\"word0\">"
					+"<div class=\"word\">API Error</div>"
					+"</div>";
			return msg;
		}
		int h = nodes.get(i).hierarchy + 1;
		for(String w:child){
			Wordnode wordnode = new Wordnode(w,h,i);
			nodes.add(wordnode);
		}
		nodes.get(i).open = true;
	}
	String html="";
	for(int i=0;i<nodes.size();i++){
		html=nodes.get(i).htmlSentense(i,root,chain)+html;
	}
	msg[0]=html;
	return msg;
}

int[] chainIndex(String chain){
	String[] splitnum = chain.split("-");
	int[] num = new int[splitnum.length];
	for(int i=0;i<num.length;i++){
		num[i]=Integer.parseInt(splitnum[i]);
	}
	return num;
}

%>
<%
//リクエスト・レスポンスとも文字コードをUTF-8に
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

String root = request.getParameter("root");
String chain = request.getParameter("chain");

String[] msg = buildHTML(root,chain);

%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Chain Word</title>
        <link rel="stylesheet" href="styles.css">
    </head>
    <body>
    	<h2><span><i class="fas fa-star"></i></span>Chain Word</h2>
    	<script src="coding.js"></script>
    	<script src="anime-master/lib/anime.js"></script>
    	<div class="tree" style="position: relative;">
    	<canvas id="canvas" width="800" height="800"></canvas>
    	<%=msg[0]%>
    	</div>
    	<% if(!msg[1].equals("")){ %>
		<div>
			<a class="home" href=<%=msg[2]%>><%=msg[1]%></a>についてWikipediaで見る。
		</div>
    	<%}%>
    	<% if(!msg[3].equals("")){ %>
		<div>
			<a class="home" href="result.jsp?root=<%=msg[3]%>&chain=0"><%=msg[3]%></a>でChainを始める。
		</div>
    	<%}%>
		<div>
			<a class="home" href="home.jsp">ホームに戻る</a>
		</div>
		<a href="http://www.goo.ne.jp/">
			<img src="//u.xgoo.jp/img/sgoo.png" width="200" alt="supported by goo" title="supported by goo">
		</a>
    </body>
</html>
