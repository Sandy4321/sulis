import java.util.ArrayList;

public class tbow{
	
	private ArrayList<String> sterms;
	private ArrayList<String> sstrings;
	private int[][] result;
	
	public tbow(){
		sterms = new ArrayList<String>();
		sstrings = new ArrayList<String>();
	}
	
	private static int[][] tbow_parse(String[] sterms, String[] sstrings){
		int[][] r = new int[sstrings.length][sterms.length];
		for(int ii = 0; ii < sstrings.length; ii++){
			String[] tempstrings = sstrings[ii].split(" ");
			for(int jj =  0; jj<sterms.length; jj++){
				for(int kk = 0; kk<tempstrings.length; kk++){
					if(tempstrings[kk].equalsIgnoreCase(sterms[jj])) r[ii][jj]++;
				}
			}
		}
		return r;
	}
	
	private static void printGrid(int[][] a){
		int n = a.length;
		int m = a[0].length;
		for(int i = 0; i < n; i++){
			for(int j = 0; j < m; j++){
				System.out.printf("%5d ", a[i][j]);
			}
			System.out.println();
		}
	}
	
	private static String[] convertArrayList(ArrayList<String> s){
		Object[] o = s.toArray();
		int len = o.length;
		String[] sa = new String[len];
		//Arrays.fill(sa,"");
		for(int ii = 0; ii<len; ii++){
			sa[ii] = o[ii].toString();
			//System.out.println(sa[ii]);
		}
		return sa;
	}
	
	public int[][] analyze(){
		result = tbow_parse(convertArrayList(this.sterms),convertArrayList(this.sstrings));
		return result;
	}
	
	public void addSearchTerm(String s){
		this.sterms.add(s);
		return;
	}
	
	public void addSearchString(String s){
		this.sstrings.add(s);
		return;
	}	
	
	public void printResults(){
		System.out.println("\n\nResults:");
		printGrid(result);
		return;
	}
	
}
