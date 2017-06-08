
/* Author : Samet Keserci
 * Create Date: 2017-05-08
 * 
 * */


import net.sf.javaml.core.Dataset;
import java.util.Random; 

import net.sf.javaml.core.Dataset; 
import net.sf.javaml.core.DefaultDataset; 
import net.sf.javaml.core.DenseInstance; 
import net.sf.javaml.core.Instance; 
import net.sf.javaml.distance.DistanceMeasure; 
import net.sf.javaml.distance.EuclideanDistance; 
import net.sf.javaml.tools.DatasetTools;
 




import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.TreeMap;
import java.util.TreeSet;

public class PIRscores {
	static String home = System.getProperty("user.home");
	static String work_dir = home + "/labdata1/NETELabs_CaseStudies/Network/";
	static String input_dir = home + "/labdata1/NETELabs_CaseStudies/Network/input/";
	static String inter_output_dir = home + "/labdata1/NETELabs_CaseStudies/Network/intermediate_output/";
	static String final_output_dir = home + "/labdata1/NETELabs_CaseStudies/Network/final_output/";

	public HashMap<String, Integer> CitationScore(String drug_name,String input_dir, String output_dir) throws IOException {

		String drug_name_pub = drug_name + "_pubref.tsv";
		String drug_name_auth = drug_name + "_authref.tsv";
		
		HashMap<String, Integer> out = new HashMap<String, Integer>();
		FileWriter writer = new FileWriter(output_dir+drug_name+"_citationsCount.csv");
		writer.write("pubSID,citationCount\n");
		DataLoader loader = new DataLoader();

		HashSet<String> pubSet = loader.pubSet(drug_name, input_dir, output_dir);
		HashMap<String, HashSet<String>> pub_citingPubSet = loader.pub_citingPubSET(drug_name, input_dir, output_dir);

		for (String pub : pubSet) {
			if (pub_citingPubSet.containsKey(pub))
				out.put(pub, pub_citingPubSet.get(pub).size());
			else {
				out.put(pub, 0);
			}
			
			writer.write(pub+","+out.get(pub)+"\n");
			
		}
		writer.close();
		int limit = 0;
		/*
		 * for (String k : out.keySet()) { if (out.get(k)>10){
		 * System.out.println(k + "-->" + out.get(k)); if (limit++ == 100)
		 * break; } }
		 */
		return out;
	}

	public HashMap<String, Integer> weightedCitationScore(String drug_name, String input_dir, String output_dir) throws IOException {

		String drug_name_pub = drug_name + "_pubref.tsv";
		String drug_name_auth = drug_name + "_authref.tsv";
		
		HashMap<String, Integer> out = new HashMap<String, Integer>();

		DataLoader loader = new DataLoader();

		HashSet<String> pubSet = loader.pubSet(drug_name, input_dir, output_dir);
		HashMap<String, HashSet<String>> pub_citingPubSet = loader.pub_citingPubSET(drug_name, input_dir, output_dir);
		HashMap<String, Integer> pub_citation = CitationScore(drug_name, input_dir, output_dir);;

		FileWriter writer = new FileWriter(output_dir+drug_name+"_weigtedCitationCount.csv");
		writer.write("pubSID,WeightedCitCount\n");
		int total_score;
		for (String pub : pubSet) {
			if (pub_citingPubSet.containsKey(pub)) {
				total_score = 0;
				for (String citing_pubs : pub_citingPubSet.get(pub)) {
					total_score += pub_citation.get(citing_pubs);
				}
				out.put(pub, total_score + pub_citation.get(pub));
			} else {
				out.put(pub, 0);
			}
			
			writer.write(pub+","+out.get(pub)+"\n");
		}
		
		writer.close();

		int limit = 0;

		// for (String k : out.keySet()) { if (out.get(k)>10){
		// System.out.println(k + "-->" + out.get(k)); if (limit++ == 100)
		// break; } }

		// System.out.println("citatation of 25652892: " +
		// pub_citation.get("25652892"));
		// System.out.println("weighted citatation of 25652892: " +
		// out.get("25652892"));
		// int total = 0;
		// for (String p: pub_citingPubSet.get("25652892")){
		// total += pub_citation.get(p);
		// System.out.println(pub_citation.get(p)+ " " + total);
		// }
		//
		//

		return out;
	}

	/**
	 * This methods calculates the PIR score of the Authors.
	 * 
	 * 
	 * */
	public HashMap<String, Integer> authPIR(String drug_name, String input_dir, String output_dir)
			throws NoSuchAlgorithmException, IOException {

		String drug_name_pub = drug_name + "_pubref.tsv";
		String drug_name_auth = drug_name + "_authref.tsv";
		
		DataLoader loader = new DataLoader();
		HashMap<String, Integer> out = new HashMap<String, Integer>();
		HashMap<String, String> authorSet = loader.AuthSet(drug_name, input_dir, output_dir);
		HashMap<String, Integer> weighted_citation = weightedCitationScore(drug_name, input_dir, output_dir);
		HashMap<String, HashSet<String>> author_pubSet = loader.auth_pubSET(drug_name, input_dir, output_dir);
		
		FileWriter writer = new FileWriter(output_dir+drug_name+"_PIR.csv");
		writer.write("autSID,authorName,PIR\n");

		int score = 0;
		for (String auth : authorSet.keySet()) {
			score = 0;
			if (author_pubSet.containsKey(auth)) {
				for (String pub : author_pubSet.get(auth)) {
					int pubScore = 0;
					if (weighted_citation.containsKey(pub)){
						pubScore = weighted_citation.get(pub);
					}
					
					score += pubScore;
				}
				out.put(auth, score);
			} else {
				out.put(auth, 0);
			}

		writer.write(auth+","+authorSet.get(auth)+","+out.get(auth)+"\n");	
		
		}

		writer.close();
		
		int limit = 0;
		for (String k : out.keySet()) {
			if (out.get(k) > 1000) {
		//		System.out.println(out.get(k)+ " --> " + k + " --> " +authorSet.get(k));
				if (limit++ == 100)
					break;
			}
		}
		
		return out;
	}

	
	/** 
	 * This method will print the all PIR score in one file;
	 * @throws IOException 
	 * @throws NoSuchAlgorithmException 
	 * */
	
	public void allAuthorPIR(String global, String[] drug_list, String input_dir, String output_dir) throws NoSuchAlgorithmException, IOException {
		
		HashMap<String, String[]> out = new HashMap<String, String[]>();
		
		HashMap<String, Integer> nPIR  = authPIR(global,input_dir,output_dir);
		
		List<HashMap<String, Integer>> PIRlist = new ArrayList<HashMap<String, Integer>>();
		DataLoader loader = new DataLoader();
		HashMap<String,String> allAuthSet = loader.AuthSet(global,input_dir,output_dir);
		
		String fileHeader = "authSID,authName,nPIR,";
		
		for (String drug: drug_list) {
			
			HashMap<String, Integer> drugPIR = authPIR(drug,input_dir,output_dir);
			fileHeader +=drug+"_pir,";
			
			PIRlist.add(drugPIR);
			
		}
		
		
		
		FileWriter writer = new FileWriter(output_dir+"all_PIR.csv");
		writer.write(fileHeader+"totalPIR,PIRpartitionRatio,intersectCount\n");
		
		for (String auth : nPIR.keySet()) {
			
			int globalPIRscore = nPIR.get(auth);
			String authName = allAuthSet.get(auth);
			
			writer.write(auth+","+authName+","+globalPIRscore+",");
			int total_sum = 0;
			int intersect_count = 0;
			for (HashMap<String, Integer> drugPIR: PIRlist ) {
				
				int drug_PIRscore = drugPIR.getOrDefault(auth, 0);
				total_sum += drug_PIRscore;
				intersect_count = drug_PIRscore == 0 ?intersect_count : intersect_count + 1;
				writer.write(drug_PIRscore + ",");
				
			}
			
			writer.write(total_sum+","+globalPIRscore/(float)total_sum+","+intersect_count+"\n");
					
		}		
		
		writer.close();
	}
	
	
	
	public static void main(String[] args) throws IOException, NoSuchAlgorithmException {
		
		PIRscores sc = new PIRscores();
		
		String[] drugList = {"alem","imat","nela","ramu","suni"};
		
		for (String drug: drugList){
		
		System.out.println("\nDrug Name: " + drug.toUpperCase()+"\n");	

		sc.CitationScore(drug,input_dir, inter_output_dir);
		sc.weightedCitationScore(drug, input_dir, inter_output_dir);
		sc.authPIR(drug,input_dir, inter_output_dir);	
		
		}
		
		sc.CitationScore("glob",input_dir, inter_output_dir);
		sc.weightedCitationScore("glob",input_dir, inter_output_dir);
		sc.authPIR("glob",input_dir, inter_output_dir);
		sc.allAuthorPIR("glob", drugList, input_dir, inter_output_dir);
	
		HashMap<String,Integer> map = sc.authPIR("glob",input_dir, inter_output_dir);
		
		
		for (String auth: map.keySet()){
			if (auth.equals("6602514094"))
			System.out.println(map.get(auth));
		}

	
	
	}

}
