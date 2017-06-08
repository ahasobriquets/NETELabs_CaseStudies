
/* Author : Samet Keserci
 * Create Date: 2017-05-08
 * 
 * */


import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;

import org.jgrapht.*;

public class Main {

	static String home = System.getProperty("user.home");
	static String work_dir = home + "/labdata1/NETELabs_CaseStudies/Network/";
	static String input_dir = home + "/labdata1/NETELabs_CaseStudies/Network/input/";
	static String mid_output_dir = home + "/labdata1/NETELabs_CaseStudies/Network/intermediate_output/";
	static String final_output_dir = home + "/labdata1/NETELabs_CaseStudies/Network/final_output/";
	
	
	public void combiner(String global, String[] drug_list, String input_dir, String output_dir) throws IOException, NoSuchAlgorithmException {
	
		
		
		DataLoader loader = new DataLoader();
		//HashMap<String,String> authSet = loader.AuthSet(global, input_dir, output_dir);
		
		HashMap<String,String> map_pir = new HashMap<String,String>();
		HashMap<String,String> map_nrbr = new HashMap<String,String>();
		HashMap<String,String> map_grbr = new HashMap<String,String>();

		
		FileReader fReader_pir = new FileReader(input_dir+"all_PIR.csv");
		FileReader fReader_nrbr = new FileReader(input_dir+"all_nRBR.csv"); 
		FileReader fReader_grbr = new FileReader(input_dir+"all_gRBR.csv"); 


		BufferedReader bReader_pir = new BufferedReader(fReader_pir);
		BufferedReader bReader_nrbr =  new BufferedReader(fReader_nrbr);
		BufferedReader bReader_grbr = new BufferedReader(fReader_grbr);

		
		
		String header_pir = bReader_pir.readLine();
		String header_nrbr = bReader_nrbr.readLine(); 
		String header_grbr = bReader_grbr.readLine();

		
		String header = header_pir +","+ header_nrbr.split(",",3)[2]+","+header_grbr.split(",",3)[2];
		
		System.out.println(header);

		String lines_pir = "";
		String lines_nrbr = "";
		String lines_grbr = "";
 

		int counter = 0;
		int countNA_authSID = 0;
		// author names in the rest list
		while ((lines_pir = bReader_pir.readLine()) != null) {
			
			String[] nextLine = lines_pir.split(",",2);
			String auth = nextLine[0];
			String rest = nextLine[1];
			
			map_pir.put(auth, rest);		
		}
		
		// remove the auther_name from the rest
		while ((lines_nrbr = bReader_nrbr.readLine()) != null) {
			
			String[] nextLine = lines_nrbr.split(",",3);
			String auth = nextLine[0];
			String authName = nextLine[1];
			String rest = nextLine[2];
			
			map_nrbr.put(auth, rest);	
			
			//System.out.println(map_rbr.get("7004995387"));
		}
		
		
		while ((lines_grbr = bReader_grbr.readLine()) != null) {
			
			String[] nextLine = lines_grbr.split(",",3);
			String auth = nextLine[0];
			String authName = nextLine[1];
			String rest = nextLine[2];
			
			map_grbr.put(auth, rest);	
			
			//System.out.println(map_rbr.get("7004995387"));
		}
		System.out.println(map_nrbr.get("7004995387"));

		
		FileWriter writer = new FileWriter(output_dir+"all_pir_nrbr_grbr.csv");
		
		writer.write(header+"\n");
		
		for (String auth: map_pir.keySet()) {
			writer.write(auth+","+map_pir.get(auth)+","+map_nrbr.get(auth)+","+map_grbr.get(auth)+"\n");
		}
		
		writer.close();
		
		
		
		
		
		
	}
	
	
	
	

	public static void main(String[] args) throws IOException, NoSuchAlgorithmException {

		// take drug_name as input ex: alemtuzumab, imatinib
	  // String drug_name = args[0].substring(0,4)+"_pubref.csv";
		// String drug_name_auth = args[0].substring(0,4) +"_authref.csv";

	   //	String drug_pub_filename = "alem" + "_pubref.tsv";
	   //	String drug_auth_filename = "alem" + "_authref.tsv";
	
		String[] drugList = {"alem","imat","nela","ramu","suni"};
		//System.out.println("********************************\n*** DATA LOADER IS IN ACTION ***\n********************************");
		
		DataLoader loader = new DataLoader();

		//loader.pub_citingPubSET(input_dir, drug_pub_filename);
		//loader.auth_pubSET(input_dir, drug_auth_filename);
		
		PIRscores scorePIR = new PIRscores();
		
		for (String drug: drugList){
		//scorePIR.authPIR(drug, input_dir, mid_output_dir);
		}
		
		
		Main driver = new Main();
		double[] x = {1, 2, 4, 8};
	    double[] y = {2, 4, 8, 16};
		
		driver.combiner("global", drugList, mid_output_dir, final_output_dir);
	}

}
