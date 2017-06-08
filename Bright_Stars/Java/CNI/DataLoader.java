
/* Author : Samet Keserci
 * Create Date: 2017-05-08
 * 
 * */

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

import sun.security.provider.MD5;
import sun.security.rsa.RSASignature.MD5withRSA;

/*
'ar': 'Article',
'ip': 'Article in Press',
'ab': 'Abstract Report',
'bk': 'Book',
'ch': 'Book Chapter',
'bz': 'Business Article',
'cp': 'Conference Paper',
'cr': 'Conference Review',
'ed': 'Editorial',
'er': 'Erratum',
'le': 'Letter',
'no': 'Note',
'pr': 'Press Release',
'rp': 'Report',
're': 'Review',
'sh': 'Short Survey'
*/

public class DataLoader {

	static String home = System.getProperty("user.home");
	static String work_dir = home + "/labdata1/NETELabs_CaseStudies/Network/";
	static String input_dir = home + "/labdata1/NETELabs_CaseStudies/Network/input/";
	static String mid_output_dir = home + "/labdata1/NETELabs_CaseStudies/Network/final_output/";
	static String final_output_dir = home + "/labdata1/NETELabs_CaseStudies/Network/output/";

	public HashMap<String, HashSet<String>> pub_citingPubSET(String drug_name, String input_dir, String output_dir)
			throws IOException {

		String drug_name_pub = drug_name + "_pubref.tsv";
		String drug_name_auth = drug_name + "_authref.tsv";

		HashMap<String, HashSet<String>> out = new HashMap<String, HashSet<String>>();

		FileReader fReader = new FileReader(input_dir + drug_name_pub);
		BufferedReader bReader = new BufferedReader(fReader);

		String header = bReader.readLine();
		String lines = "";

		int counter = 0;
		while ((lines = bReader.readLine()) != null) {
			++counter;
			String[] nextLine = lines.trim().replace(",", "").split("\t", -1);
			String citingPmid = nextLine[0];
			String citingSID = nextLine[1];
			String citedSID = nextLine[2];
			String citedPmid = nextLine[3];
			//String citingSIDyear = nextLine[4];
			//if ((Integer.valueOf(citingSIDyear) < 1900 ||  Integer.valueOf(citingSIDyear) > 2015)) {
			//	 continue;
			 //}
			// String drugName = nextLine[5];

			if (!out.containsKey(citedSID)) {
				HashSet<String> localRef = new HashSet<String>();
				localRef.add(citingSID);
				out.put(citedSID, localRef);
			} else {
				out.get(citedSID).add(citingSID);
			}

		}

		bReader.close();
		fReader.close();

		/*
		 * int limit =1; for (String k: out.keySet()){ System.out.println(k +
		 * "-->" +out.get(k)); if (limit++ == 100) break; }
		 * 
		 */
		System.out.println("pub_citingPubSET line counter: " + counter);
		System.out.println("pub_citingPubSET map size: " + out.size());
		// System.out.println("pub_citingPubSET map size: " +
		// out.get("25652892"));

		System.out.println(out.get("0031059348"));
		
		
		return out;
	}

	/**
	 * Mapping of authors to his/her publication set. For NA authSID, we get md5
	 * of merged the fullname/lastname/firstname if exist, and trim it to 11
	 * char. Those authSID begining with a 'M' character are merged
	 * identification number of the author (MID).
	 * 
	 * @throws NoSuchAlgorithmException
	 * 
	 */

	public HashMap<String, HashSet<String>> auth_pubSET(String drug_name, String input_dir, String output_dir)
			throws IOException, NoSuchAlgorithmException {

		String drug_name_pub = drug_name + "_pubref.tsv";
		String drug_name_auth = drug_name + "_authref.tsv";

		HashMap<String, HashSet<String>> out = new HashMap<String, HashSet<String>>();

		FileReader fReader = new FileReader(input_dir + drug_name_auth);
		BufferedReader bReader = new BufferedReader(fReader);

		String header = bReader.readLine();
		String lines = "";

		int counter = 0;
		int countNA_authSID = 0;
		while ((lines = bReader.readLine()) != null) {
			++counter;
			String[] nextLine = lines.trim().replace(",", "").split("\t", -1);
			String docSID = nextLine[0];
			String authSID = nextLine[1];
			String fullName = nextLine[2];
			String lastName = nextLine[3];
			String firstName = nextLine[4];
			String initials = nextLine[5];
			String docCount = nextLine[6];
			// String drugName = nextLine[7];
			String authMerged = fullName + "\t" + lastName + "\t" + firstName;

			if (authSID.equals("NA")) {
				++countNA_authSID;
				if (fullName.equals("NA") && lastName.equals("NA") && firstName.equals("NA")) {
					continue;
				}
				MessageDigest md5 = MessageDigest.getInstance("MD5");
				md5.update(StandardCharsets.UTF_8.encode(authMerged));
				authSID = "MID" + String.format("%032x", new BigInteger(1, md5.digest())).substring(0, 8);

				System.out.println(authSID + " " + authMerged);
			}

			if (!out.containsKey(authSID)) {
				HashSet<String> localRef = new HashSet<String>();
				localRef.add(docSID);
				out.put(authSID, localRef);
			} else {
				out.get(authSID).add(docSID);
			}

		}

		bReader.close();
		fReader.close();

		System.out.println("auth_pubSET line counter: " + counter);
		System.out.println("auth_pubSET map size: " + out.size());
		
		//System.out.println(">>>>>>>>>>>>>>>>>>>"+out.get("6602514094").size()+ ">>>>>>>>>>>>>>>>>>>"+out.get("6602514094"));

		return out;
	}

	public HashMap<String, Integer> auth_outDegree(String drug_name, String input, String output)
			throws NoSuchAlgorithmException, IOException {

		HashMap<String, Integer> out = new HashMap<String, Integer>();
		HashMap<String, HashSet<String>> auth_pubSet = auth_pubSET(drug_name, input, output);

		int zero_counter = 0;
		for (String auth : auth_pubSet.keySet()) {

			out.put(auth, auth_pubSet.get(auth).size());

			zero_counter = auth_pubSet.size() == 0 ? ++zero_counter : zero_counter;

		}

		System.out.println("auth_outDegree map size: " + out.size());
		System.out.println(">>>>>>>>>>>>>>>"+out.get("7003873023"));
		
		

		return out;
	}

	/**
	 * Elsevier data - total count is based on counting the actual number of
	 * document in Elsevier database, rather than reading as a attribute.
	 */

	/*
	 * 'ar': 'Article', 'ip': 'Article in Press', 'ab': 'Abstract Report', 'bk':
	 * 'Book', 'ch': 'Book Chapter', 'bz': 'Business Article', 'cp': 'Conference
	 * Paper', 'cr': 'Conference Review', 'ed': 'Editorial', 'er': 'Erratum',
	 * 'le': 'Letter', 'no': 'Note', 'pr': 'Press Release', 'rp': 'Report',
	 * 're': 'Review', 'sh': 'Short Survey'
	 */
	public TreeMap<String, Integer[]> auth_totalDocCount(String file_name, String input_dir, String output_dir)
			throws IOException, NoSuchAlgorithmException {

		TreeMap<String, Integer[]> author_artCount_totalCount = new TreeMap<String, Integer[]>();

		// String filename = file_name + ".csv";
		FileReader fReader = new FileReader(input_dir + file_name);
		BufferedReader bReader = new BufferedReader(fReader);

		String header = bReader.readLine();
		String lines = "";

		int counter = 0;

		int total_count = 0;

		while ((lines = bReader.readLine()) != null) {

			String SID = "";
			String type = "";
			int type_count = 0;

			String[] nextLine = lines.trim().replace("\"", "").split(",", -1);
			if (nextLine[0].length() != 0) {
				SID = nextLine[0];
			}

			if (nextLine[1].length() != 0) {
				type = nextLine[1];
			} else {
				type = "na";
			}

			if (nextLine[2].length() != 0) {
				type_count = Integer.valueOf(nextLine[2]);
			}

			if (type.equals("ab") || type.equals("bz") || type.equals("pr") || type.equals("sh")) {
				continue;
			}

			if (author_artCount_totalCount.containsKey(SID)) {

				if (type.equals("ar") || type.equals("ip")) {

					author_artCount_totalCount.get(SID)[0] += type_count;
					author_artCount_totalCount.get(SID)[1] += type_count;

					
					
				} else {

					author_artCount_totalCount.get(SID)[1] += type_count;

				}

			} else {
				
				Integer[] temp = new Integer[2];
				
				if (type.equals("ar") || type.equals("ip")) {
					temp[0] = type_count;
					temp[1] = type_count;
					
					author_artCount_totalCount.put(SID, temp);
				} else {
					
					temp[0] = 0;
					temp[1] = type_count;
					
					author_artCount_totalCount.put(SID, temp);
					
				}

			}

			// System.out.println(nextLine[0] + " ---> " + nextLine[1] + " --->
			// " + nextLine[2]);
			// System.out.println(SID + " ---> " + type + " ---> " + count);

			//if (counter++ == 1000)
			//	break;
		}

		
		for (String s: author_artCount_totalCount.keySet()) {
			System.out.println(s+ " ---> " +author_artCount_totalCount.get(s)[0]+ " ---> " +author_artCount_totalCount.get(s)[1]);
			
		}
		
		
		bReader.close();
		fReader.close();
		
		
		System.out.println(author_artCount_totalCount.size());

		return author_artCount_totalCount;

	}

	/**
	 * Author and corresponding document count mapper method. If no any
	 * information found regarding document count, it is set to be -1. Also, if
	 * the total indegree count is greater than docCount it is again set to be
	 * -2
	 * 
	 */
	public HashMap<String, Integer> auth_docCount(String drug_name, String input_dir, String output_dir)
			throws IOException, NoSuchAlgorithmException {

		String drug_name_pub = drug_name + "_pubref.tsv";
		String drug_name_auth = drug_name + "_authref.tsv";

		HashMap<String, Integer> out = new HashMap<String, Integer>();

		DataLoader loader = new DataLoader();
		HashMap<String, Integer> authGlobalOutDegree = loader.auth_outDegree(drug_name, input_dir, output_dir);

		FileReader fReader = new FileReader(input_dir + drug_name_auth);
		BufferedReader bReader = new BufferedReader(fReader);

		String header = bReader.readLine();
		String lines = "";

		int counter = 0;
		int countAllNA_docCount = 0;
		int countValidSID_NAdocCount = 0;
		int countNA_authSID = 0;
		int defective_docCount = 0;
		while ((lines = bReader.readLine()) != null) {
			++counter;
			String[] nextLine = lines.trim().replace(",", "").split("\t", -1);
			String docSID = nextLine[0];
			String authSID = nextLine[1];
			String fullName = nextLine[2];
			String lastName = nextLine[3];
			String firstName = nextLine[4];
			String initials = nextLine[5];
			Integer docCount = nextLine[6].equals("NA") ? -1 : Integer.valueOf(nextLine[6]);
			countAllNA_docCount = docCount == -1 ? countAllNA_docCount + 1 : countAllNA_docCount;
			countValidSID_NAdocCount = (!authSID.equals("NA") && docCount == -1) ? countAllNA_docCount + 1
					: countAllNA_docCount;

			// String drugName = nextLine[7];
			String authMerged = fullName + "\t" + lastName + "\t" + firstName;

			if (authSID.equals("NA")) {
				++countNA_authSID;
				if (fullName.equals("NA") && lastName.equals("NA") && firstName.equals("NA")) {
					continue;
				}
				MessageDigest md5 = MessageDigest.getInstance("MD5");
				md5.update(StandardCharsets.UTF_8.encode(authMerged));
				authSID = "MID" + String.format("%032x", new BigInteger(1, md5.digest())).substring(0, 8);

				System.out.println(authSID + " " + authMerged);
			}

			if (docCount != -1) {
				// docCount = Integer.valueOf(nextLine[6]);
				defective_docCount = docCount > authGlobalOutDegree.get(authSID) ? defective_docCount
						: defective_docCount + 1;
				docCount = docCount < authGlobalOutDegree.get(authSID) ? -2 : docCount;
			}

			if (docCount > 800) {
				docCount = 800;
			}

			out.put(authSID, docCount);

		}

		bReader.close();
		fReader.close();

		int count_invalidDocCount = 0;
		int count_overlimit = 0;
		int limit = 800;
		for (String auth : out.keySet()) {
			count_invalidDocCount = out.get(auth) == -1 ? count_invalidDocCount + 1 : count_invalidDocCount;
			// System.out.println(auth + " " + out.get(auth));
			count_overlimit = out.get(auth) > limit ? count_overlimit + 1 : count_overlimit;

		}

		System.out.println("auth_docCount line counter: " + counter);
		System.out.println("auth_docCount map size: " + out.size());
		System.out.println("defective doc count: " + defective_docCount);
		System.out.println("defective doc count percentage: " + (100 * defective_docCount) / (float) out.size());
		System.out.println("all NA count for doc_count: " + countAllNA_docCount);
		System.out.println("all NA docCount percentage: " + (100 * countAllNA_docCount) / (float) out.size());
		System.out.println("Valid SID but NA for document count: " + countValidSID_NAdocCount);
		System.out.println("total invalid doc Count data: " + count_invalidDocCount);
		System.out.println("total invalid doc Count percentage: " + 100 * count_invalidDocCount / (float) out.size());
		System.out.println("total number of author=" + count_overlimit + " exeeding the limit= " + limit);

		return out;
	}

	public HashMap<String, Integer> auth_docCount_predicted(String drug_name, String input_dir, String output_dir)
			throws IOException, NoSuchAlgorithmException {

		String drug_name_pub = drug_name + "_pubref.tsv";
		String drug_name_auth = drug_name + "_authref.tsv";

		HashMap<String, Integer> out = new HashMap<String, Integer>();

		DataLoader loader = new DataLoader();
		HashMap<String, Integer> authGlobalInDegree = loader.auth_outDegree("glob", input_dir, output_dir);

		HashMap<String, Integer> doc_Count = loader.auth_docCount(drug_name, input_dir, output_dir);

		TreeMap<Integer, ArrayList<Integer>> indeg_docCountSET_training = new TreeMap<Integer, ArrayList<Integer>>();

		for (String auth : authGlobalInDegree.keySet()) {
			Integer indegree = authGlobalInDegree.get(auth);
			Integer docCount = doc_Count.get(auth);

			if (docCount > -1) {

				if (indeg_docCountSET_training.containsKey(indegree)) {
					indeg_docCountSET_training.get(indegree).add(docCount);
				} else {
					ArrayList<Integer> temp = new ArrayList<Integer>();
					temp.add(docCount);
					indeg_docCountSET_training.put(indegree, temp);
				}

			}

		}

		int limit = 0;
		for (Integer n : indeg_docCountSET_training.keySet()) {
			if (limit++ < 100) {
				float mean = 0;
				for (Integer nn : indeg_docCountSET_training.get(n)) {
					mean += nn;
				}

				// System.out.println(n + " " + mean /
				// indeg_docCountSET_training.get(n).size() + " " +
				// median(indeg_docCountSET_training.get(n)) + " " +
				// indeg_docCountSET_training.get(n));

			}

		}

		int neg1_count = 0;
		int neg2_count = 0;

		for (String auth : doc_Count.keySet()) {

			Integer newValue = -3;
			Integer docCount = doc_Count.get(auth);
			Integer Indegree = authGlobalInDegree.get(auth);

			if (indeg_docCountSET_training.containsKey(Indegree)) {
				if (docCount == -1) {
					neg1_count++;

					newValue = median(indeg_docCountSET_training.get(Indegree));
					if ((newValue + 20) % 20 == 0)
						System.out.println(docCount + " " + Indegree + " " + newValue + " "
								+ median(indeg_docCountSET_training.get(Indegree)) + " "
								+ indeg_docCountSET_training.get(Indegree));

				} else if (docCount == -2) {
					neg2_count++;
					Collections.sort(indeg_docCountSET_training.get(Indegree));
					newValue = indeg_docCountSET_training.get(Indegree).get(0);
					if ((newValue + 20) % 20 == 0)
						System.out.println(docCount + " " + Indegree + " " + newValue + " "
								+ median(indeg_docCountSET_training.get(Indegree)) + " "
								+ indeg_docCountSET_training.get(Indegree));

				} else {

				}

			}

			out.put(auth, newValue);

		}

		System.out.println(neg1_count);
		System.out.println(neg2_count);

		return out;
	}

	public static int median(List<Integer> list) {

		if (list.isEmpty()) {
			return Integer.MAX_VALUE;
		}

		Collections.sort(list);

		int len = list.size();

		return len % 2 == 0 ? (list.get(len / 2) + list.get(len / 2 - 1)) / 2 : list.get(len / 2);
	}

	/**
	 * It is a set of all publication in the Network.
	 */
	public HashSet<String> pubSet(String drug_name, String input_dir, String output_dir) throws IOException {

		String drug_name_pub = drug_name + "_pubref.tsv";
		String drug_name_auth = drug_name + "_authref.tsv";

		HashSet<String> out = new HashSet<String>();
		FileReader fReader = new FileReader(input_dir + drug_name_pub);
		BufferedReader bReader = new BufferedReader(fReader);

		String header = bReader.readLine();
		String lines = "";

		// int count_citingPmid = 0;
		// int count_citingSID = 0;
		// int count_citedSID = 0;
		// int count_citedPmid = 0;
		int countNA = 0;

		while ((lines = bReader.readLine()) != null) {

			String[] nextLine = lines.trim().replace(",", "").split("\t", -1);

			String citingPmid = nextLine[0];
			String citingSID = nextLine[1];
			String citedSID = nextLine[2];
			String citedPmid = nextLine[3];
			//String citingSIDyear = nextLine[4];
			 
			//if ((Integer.valueOf(citingSIDyear) < 1900 ||  Integer.valueOf(citingSIDyear) > 2015)) {
				// continue;
			 //}
			
			// String drugName = nextLine[5];

			// System.out.println (citingPmid + "->" + citingSID + "->"
			// +citedSID+ "->" +citedPmid);

			if (!citingSID.equals("NA"))
				out.add(citingSID);

			if (!citedSID.equals("NA"))
				out.add(citedSID);

			if (citedPmid.equals("NA")) {
				++countNA;
			}

			// if (countNA == 10)MID725ce158 Wong R.M.		
			//auth_pubSET line counter: 589237
			//auth_pubSET map size: 237766
			// break;

			// if (citingSID.equals("56486") || citedSID.equals("56486"))
			// System.out.println (citingPmid + "->" + citingSID + "->"
			// +citedSID+ "->" +citedPmid);

		}

		 System.out.println("count of NA in cited pmid: " + countNA);
		 System.out.println("Size of Network gen1 + gen2: " + out.size());
		 System.out.println(out.contains("56486"));

		return out;
	}

	public HashMap<String, String> AuthSet(String drug_name, String input_dir, String output_dir)
			throws IOException, NoSuchAlgorithmException {

		String drug_name_pub = drug_name + "_pubref.tsv";
		String drug_name_auth = drug_name + "_authref.tsv";

		HashMap<String, String> out = new HashMap<String, String>();
		FileReader fReader = new FileReader(input_dir + drug_name_auth);
		BufferedReader bReader = new BufferedReader(fReader);

		String header = bReader.readLine();
		String lines = "";

		int countNA = 0;
		int countNA_authSID = 0;

		while ((lines = bReader.readLine()) != null) {

			String[] nextLine = lines.trim().replace(",", "").split("\t", -1);
			String docSID = nextLine[0];
			String authSID = nextLine[1];
			String fullName = nextLine[2];
			String lastName = nextLine[3];
			String firstName = nextLine[4];
			String initials = nextLine[5];
			String docCount = nextLine[6];
			// String drugName = nextLine[7];
			String authMerged = fullName + "\t" + lastName + "\t" + firstName;

			if (authSID.equals("NA")) {
				++countNA_authSID;
				if (fullName.equals("NA") && lastName.equals("NA") && firstName.equals("NA")) {
					continue;
				}

				MessageDigest md5 = MessageDigest.getInstance("MD5");
				md5.update(StandardCharsets.UTF_8.encode(authMerged));
				authSID = "MID" + String.format("%032x", new BigInteger(1, md5.digest())).substring(0, 8);

				System.out.println(authSID + " " + authMerged);
			}

			out.put(authSID, authMerged.replace("NA", "").replace(",", ""));

		}

		System.out.println("count of NA in authSID: " + countNA_authSID);
		System.out.println("Size of Authors: " + out.size());

		int limit = 10;
		for (String s : out.keySet()) {
			// System.out.println(s +"\t"+ out.get(s));
		}

		return out;
	}

	public void intersectAllComb(String[] drugs, String based_on, String input_dir, String output_dir)
			throws IOException {

		List<HashSet<String>> allComb = new ArrayList<HashSet<String>>();

		allCombo(drugs, allComb, new HashSet<String>(), 0);
		FileWriter writer = new FileWriter(output_dir + "intersectMatrix.csv");
		writer.write("alem,imat,nela,ramu,suni,abrevation,count\n");

		for (HashSet<String> strArr : allComb) {
			if (!strArr.isEmpty())
				writer.write(intersectingSet(strArr, based_on, input_dir, output_dir) + "\n");
		}

		writer.close();
		System.out.println(allComb.size() + " " + allComb);

	}

	public void allCombo(String[] drugs, List<HashSet<String>> listStr, HashSet<String> basket, int index) {

		if (index == drugs.length) {
			listStr.add(basket);
			return;
		}
		allCombo(drugs, listStr, new HashSet<String>(basket), index + 1);
		basket.add(drugs[index]);

		allCombo(drugs, listStr, new HashSet<String>(basket), index + 1);

	}

	/*
	 * a , i ,n ,r ,s
	 */

	public String intersectingSet(HashSet<String> drugs, String based_on, String input_dir, String output_dir)
			throws IOException {

		HashSet<String> out = new HashSet<String>();
		ArrayList<HashSet<String>> list = new ArrayList<HashSet<String>>();
		String sets = "";
		for (String drug : drugs) {
			HashSet<String> drugSet = pubSet(drug, input_dir, output_dir);
			sets += drug.charAt(0);
			list.add(drugSet);
		}

		int ind = 0;

		for (ind = 0; ind < list.size() - 1; ++ind) {
			list.get(ind).retainAll(list.get(ind + 1));
			list.get(ind + 1).retainAll(list.get(ind));
		}

		int a = sets.contains("a") ? 1 : 0;
		int i = sets.contains("i") ? 1 : 0;
		int n = sets.contains("n") ? 1 : 0;
		int r = sets.contains("r") ? 1 : 0;
		int s = sets.contains("s") ? 1 : 0;

		System.out.println(a + "," + i + "," + n + "," + r + "," + s + "," + sets + "," + list.get(ind).size());

		return a + "," + i + "," + n + "," + r + "," + s + "," + sets + "," + list.get(ind).size();

	}

	public static void main(String[] args) throws IOException, NoSuchAlgorithmException {

		DataLoader loader = new DataLoader();

		String[] drugList = { "alem", "imat", "nela", "ramu", "suni" };
		String[] drugs = { "a", "b", "c", "d", "e" };

		for (String drug : drugList) {

			// System.out.println("\nDrug Name: " + drug.toUpperCase() + "\n");

			// loader.pub_citingPubSET(drug,input_dir, mid_output_dir);
			// loader.auth_pubSET(drug, input_dir,mid_output_dir );
			// loader.pubSet(drug, input_dir,mid_output_dir );
			// loader.AuthSet("glob", input_dir,mid_output_dir);
			// loader.auth_docCount("glob", input_dir, mid_output_dir);

			// loader.auth_outDegree(drug, input_dir,mid_output_dir );

		}

		 //loader.pub_citingPubSET("glob",input_dir, mid_output_dir);

		
		// loader.auth_docCount("alem", input_dir, mid_output_dir);
		// loader.intersectingSet(drugList, "sid", input_dir, mid_output_dir);
		// loader.pubSet("ramu", input_dir,mid_output_dir );

		 loader.auth_pubSET("imat", input_dir,mid_output_dir );
		 loader.auth_pubSET("alem", input_dir,mid_output_dir );

		// loader.auth_outDegree("glob", input_dir,mid_output_dir );
		//loader.AuthSet("glob", input_dir,mid_output_dir);
		// loader.auth_docCount_predicted("glob", input_dir, mid_output_dir);

		// loader.intersectingSet(drugList, "sid", input_dir, mid_output_dir);

		// loader.intersectAllComb(drugList,"sid",input_dir, mid_output_dir);
		//loader.auth_totalDocCount("auth_counts.csv", input_dir, mid_output_dir);

		// System.out.println(median(set));

	}

}
