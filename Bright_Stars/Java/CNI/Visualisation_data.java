import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;

/* Author : Samet Keserci
 * Create Date: 2017-05-08
 * 
 * */
public class Visualisation_data {
	
	
	static String home = System.getProperty("user.home");
	static String work_dir = home + "/labdata1/NETELabs_CaseStudies/Network/";
	static String input_dir = home + "/labdata1/NETELabs_CaseStudies/Network/input/";
	static String mid_output_dir = home + "/labdata1/NETELabs_CaseStudies/Network/intermediate_output/";
	static String final_output_dir = home + "/labdata1/NETELabs_CaseStudies/Network/final_output/";

	
	
	public void topNpublication(int N, String global, String[] drugList, String input_dir, String out_dir){
		
		
	}
	
	public void topNAuthor(int N, String global, String[] drugList, String input_dir, String out_dir){
		
		
	}
	
	
    public void CoauthorAuthorTopNpub(int N, String global, String[] drugList, String input_dir, String out_dir){
		
		
	}
    
    
    public HashMap<String,Integer> CorePublicationsList(int N, String global, String[] drugList, String input_dir, String out_dir){
		
    	HashMap<String,Integer> out = new HashMap<String,Integer>();
    	
		return out;
	}
    
    
    public HashMap<String,Integer> CoreAuthorsList(int N, String global, String[] drugList, String input_dir, String out_dir){
		
    	HashMap<String,Integer> out = new HashMap<String,Integer>();
    	
		return out;
		
	}
    
    
    public  HashMap<String,HashSet<String>> CorePubNetwork(int N, String global, String[] drugList, String input_dir, String out_dir){
		
    	HashMap<String,HashSet<String>> out = new HashMap<String,HashSet<String>>();
    	
    	return out;
		
	}
	
    public  HashMap<String,HashSet<String>> CoreAuthorNetwork(int N, String global, String[] drugList, String input_dir, String out_dir){
		
    	HashMap<String,HashSet<String>> out = new HashMap<String,HashSet<String>>();
    	
    	return out;
		
	}
	
    
    public static HashSet<String> core14() throws IOException{
    	
    	HashSet<String> out = new HashSet<String>();
    	
    	FileReader fReader = new FileReader(input_dir + "core14.tsv");
		BufferedReader bReader = new BufferedReader(fReader);

		String lines = "";
		while ((lines = bReader.readLine()) != null) {

			//String[] nextLine = lines.trim().replace(",", "").split("\t", -1);
		
			System.out.println(lines);
			
			out.add(lines);
		}
    	return out;
    }
    
    public static void coreAlex(String input_dir, String output_dir) throws IOException{
    	HashSet<String> core = core14();
    	DataLoader loader = new DataLoader();
    	HashMap<String, HashSet<String>> citingSet = loader.pub_citingPubSET("glob",input_dir, mid_output_dir);
    	
    	HashSet<String> alem = loader.pubSet( "alem", input_dir, output_dir);
    	HashSet<String> nela = loader.pubSet( "nela", input_dir, output_dir);
    	HashSet<String> suni = loader.pubSet( "suni", input_dir, output_dir);
    	HashSet<String> ramu = loader.pubSet( "ramu", input_dir, output_dir);
    	HashSet<String> imat = loader.pubSet( "imat", input_dir, output_dir);

    	
    	
    	FileWriter writer = new FileWriter(output_dir+"Core14toAlex.csv");
    	
    	writer.write("SID,citingSID,drug\n");
    	
    	for (String str: core ) {
    		if (citingSet.containsKey(str)){
    			if (str.equals("0000336139"))
    				System.out.println(">>>>>>>>>>>>>");
    			
    		for (String citing: citingSet.get(str)){
    			
    			if (alem.contains(citing))
    				writer.write(str+","+citing+",alem"+"\n");
    			if (nela.contains(citing))
        			writer.write(str+","+citing+",nela"+"\n");
    			if (suni.contains(citing))
        			writer.write(str+","+citing+",suni"+"\n");
    			if (ramu.contains(citing))
        			writer.write(str+","+citing+",ramu"+"\n");
    			if (imat.contains(citing))
        			writer.write(str+","+citing+",imat"+"\n");
    		}
    		
    	  }
    	}
    	
    	
    	System.out.println(core.size());
    	
    	int counter = 0;
    	for (String str: core ) {
    		if (citingSet.containsKey(str)){
    		++counter;
    		}
    	}
    	
    	
    	System.out.println(counter + " " + core.size());
    	writer.close();
    	
    }
    
    
	

	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
		
		
		//System.out.println("   saN   ArNg ,  na j,  sn, ANAna   ".trim().replace("NA", "").replace(",", ""));
		
		//System.out.println("asfg,tdh,ethd,ht2,36,57,575,3".split(",",3)[0]);
		//System.out.println("asfg,tdh,ethd,ht2,36,57,575,3".split(",",3)[1]);
		//System.out.println("asfg,tdh,ethd,ht2,36,57,575,3".split(",",3)[2]);
		
		
		System.out.println(core14());
		
		coreAlex(input_dir, mid_output_dir);
		

		
		//0000336139

	}

}

