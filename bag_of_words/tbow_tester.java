import java.util.Scanner;

public class tbow_tester{
	public static void main(String[] args){
		tbow T = new tbow();
		
		
		//Dynamic code for demo
		String temp;
		
		boolean done = false;
		Scanner s = new Scanner(System.in);
		System.out.println("Enter a search term: ");
		T.addSearchTerm(s.nextLine());
		
		while (!done){
			System.out.println("Enter another search term (or enter # to finish): ");
			temp = s.nextLine();
			if (temp.equals("#")) done=true;
			else T.addSearchTerm(temp);
		}
		done=false;
		while (!done){
			System.out.println("Enter a search string (or enter # to finish): ");
			temp = s.nextLine();
			if (temp.equals("#")) done=true;
			else T.addSearchString(temp);
		}
		
		int[][] results = T.analyze();
		T.printResults();
		return;
	}
}
