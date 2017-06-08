import java.io.FileWriter;
import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.util.*;

/* Author : Samet Keserci
 * Create Date: 2017-05-08
 * 
 * */
public class RRBRscores {

	static String home = System.getProperty("user.home");
	static String work_dir = home + "/labdata1/NETELabs_CaseStudies/Network/";
	static String input_dir = home + "/labdata1/NETELabs_CaseStudies/Network/input/";
	static String mid_output_dir = home + "/labdata1/NETELabs_CaseStudies/Network/intermediate_output/";
	static String final_output_dir = home + "/labdata1/NETELabs_CaseStudies/Network/final_output/";

	/**
	 * RBR based on Alex Pico's method as background we will use total count of
	 * the document in his her lifetime.
	 * 
	 * @throws IOException
	 * @throws NoSuchAlgorithmException
	 * 
	 */

	public static HashMap<String, Double> auth_gRBR(String docCountfileName, String global, String drug_name,
			String input_dir, String output_dir) throws NoSuchAlgorithmException, IOException {

		DataLoader loader = new DataLoader();
		HashMap<String, Double> out = new HashMap<String, Double>();

		HashMap<String, Integer> auth_outDegree_local = loader.auth_outDegree(drug_name, input_dir, output_dir);
		HashMap<String, Integer> auth_outDegree_global = loader.auth_outDegree(global, input_dir, output_dir);

		TreeMap<String, Integer[]> auth_totalDocCount = loader.auth_totalDocCount(docCountfileName, input_dir,
				output_dir);

		FileWriter writer = new FileWriter(output_dir + drug_name + "_gRBR.csv");

		writer.write("auth,indegreeCount,articleCount,gRBR\n");

		for (String auth : auth_outDegree_local.keySet()) {

			if (auth_totalDocCount.containsKey(auth)) {
				Double grbr_a = auth_outDegree_local.get(auth) / (double) auth_totalDocCount.get(auth)[0];
				Double grbr_t = auth_outDegree_local.get(auth) / (double) auth_totalDocCount.get(auth)[1];

				out.put(auth, grbr_a);
				// writer.write(auth + "," + auth_outDegree_local.get(auth) +
				// "," + auth_totalDocCount.get(auth)[0] + "," +
				// auth_totalDocCount.get(auth)[1] + ","+ grbr_a + "," + grbr_t
				// + "\n");
				writer.write(auth + "," + auth_outDegree_local.get(auth) + "," + auth_totalDocCount.get(auth)[0] + ","
						+ grbr_a + "\n");
			}
		}

		writer.close();

		return out;

	}

	/**
	 * RBR based on Alex Pico's method as background we will use whole total
	 * network
	 * 
	 * @throws IOException
	 * @throws NoSuchAlgorithmException
	 * 
	 */

	public static HashMap<String, Double> auth_nRBR(String global, String drug_name, String input_dir,
			String output_dir) throws NoSuchAlgorithmException, IOException {

		DataLoader loader = new DataLoader();
		HashMap<String, Double> out = new HashMap<String, Double>();

		HashMap<String, Integer> auth_outDegree_local = loader.auth_outDegree(drug_name, input_dir, output_dir);
		HashMap<String, Integer> auth_outDegree_global = loader.auth_outDegree(global, input_dir, output_dir);

		FileWriter writer = new FileWriter(output_dir + drug_name + "_nRBR.csv");

		writer.write("auth,nRBR\n");

		for (String auth : auth_outDegree_local.keySet()) {

			Double nrbr = auth_outDegree_local.get(auth) / (double) auth_outDegree_global.get(auth);
			out.put(auth, nrbr);
			writer.write(auth + "," + nrbr + "\n");

		}

		writer.close();

		return out;

	}

	public static void all_auth_gRBR(String global, String[] drug_list, String input_dir, String output_dir)
			throws NoSuchAlgorithmException, IOException {

		DataLoader loader = new DataLoader();
		HashMap<String, Double> out = new HashMap<String, Double>();

		List<HashMap<String, Double>> RRBRlist = new ArrayList<HashMap<String, Double>>();
		List<HashMap<String, Integer>> authOutDegree_list = new ArrayList<HashMap<String, Integer>>();

		HashMap<String, String> allAuthSet = loader.AuthSet(global, input_dir, output_dir);

		HashMap<String, Integer> authDegrees_global = loader.auth_outDegree(global, input_dir, output_dir);
		TreeMap<String, Integer[]> authGDocCount = loader.auth_totalDocCount("auth_counts.csv", input_dir, output_dir);

		String fileHeader = "authSID,authName,";

		for (String drug : drug_list) {

			HashMap<String, Integer> authDegrees = loader.auth_outDegree(drug, input_dir, output_dir);

			authOutDegree_list.add(authDegrees);

		}

		for (String drug : drug_list) {

			HashMap<String, Double> drug_gRBR_at = auth_gRBR("auth_counts.csv", global, drug, input_dir, output_dir);
			fileHeader += drug + "_gRBR,";

			RRBRlist.add(drug_gRBR_at);

		}

		FileWriter writer = new FileWriter(output_dir + "all_gRBR.csv");
		writer.write(fileHeader + "g_ac\n");

		for (String auth : allAuthSet.keySet()) {
			double total_rrbr_sum = 0;
			int total_indegree_sum = 0;
			int global_indegree = authDegrees_global.getOrDefault(auth, 0);

			writer.write(auth + "," + allAuthSet.get(auth) + ",");

			for (int i = 0; i < RRBRlist.size(); ++i) {

				double auth_rbrb_a = 0;
				double auth_rbrb_t = 0;

				if (RRBRlist.get(i).containsKey(auth)) {

					auth_rbrb_a = RRBRlist.get(i).get(auth);
					auth_rbrb_t = RRBRlist.get(i).get(auth);

				}
				int auth_indegree = authOutDegree_list.get(i).getOrDefault(auth, 0);
				total_indegree_sum += auth_indegree;
				//writer.write(auth_rbrb_a + "," + auth_indegree + ",");
				writer.write(auth_rbrb_a + "," );


			}

			if (authGDocCount.containsKey(auth))
				writer.write(authGDocCount.get(auth)[0] + "\n");
			else
				writer.write("NAN\n");

		}

		writer.close();

	}

	public static void all_auth_nRBR(String global, String[] drug_list, String input_dir, String output_dir)
			throws NoSuchAlgorithmException, IOException {

		DataLoader loader = new DataLoader();
		HashMap<String, Double> out = new HashMap<String, Double>();

		List<HashMap<String, Double>> RRBRlist = new ArrayList<HashMap<String, Double>>();
		List<HashMap<String, Integer>> authOutDegree_list = new ArrayList<HashMap<String, Integer>>();

		HashMap<String, String> allAuthSet = loader.AuthSet(global, input_dir, output_dir);

		HashMap<String, Integer> authDegrees_global = loader.auth_outDegree(global, input_dir, output_dir);
		HashMap<String, Integer> authDocCount = loader.auth_docCount(global, input_dir, output_dir);

		String fileHeader = "authSID,authName,";

		for (String drug : drug_list) {

			HashMap<String, Integer> authDegrees = loader.auth_outDegree(drug, input_dir, output_dir);

			authOutDegree_list.add(authDegrees);

		}

		for (String drug : drug_list) {

			HashMap<String, Double> drugRRBR = auth_nRBR(global, drug, input_dir, output_dir);
			fileHeader += drug + "_nRBR," + drug + "_ac,";

			RRBRlist.add(drugRRBR);

		}

		FileWriter writer = new FileWriter(output_dir + "all_nRBR.csv");
		writer.write(fileHeader + "total_nRBR, ac_sum, n_ac\n");

		for (String auth : allAuthSet.keySet()) {
			double total_rrbr_sum = 0;
			int total_indegree_sum = 0;
			int n_articleCount = authDegrees_global.getOrDefault(auth, 0);

			writer.write(auth + "," + allAuthSet.get(auth) + ","); 

			for (int i = 0; i < RRBRlist.size(); ++i) {
				double auth_rbrb = RRBRlist.get(i).getOrDefault(auth, 0.0);
				int auth_indegree = authOutDegree_list.get(i).getOrDefault(auth, 0);
				total_rrbr_sum += auth_rbrb;
				total_indegree_sum += auth_indegree;
				writer.write(auth_rbrb + "," + auth_indegree + ",");

			}

			writer.write(total_rrbr_sum + "," + total_indegree_sum + "," + n_articleCount +"\n");

		}

		writer.close();

	}

	public static void main(String[] args) throws NoSuchAlgorithmException, IOException {

		RRBRscores rrbr = new RRBRscores();
		String[] drugList = { "alem", "imat", "nela", "ramu", "suni" };

		for (String drug : drugList) {
			// rrbr.auth_gRBR("auth_counts.csv", "glob", drug, input_dir,
			// mid_output_dir);
		}
		all_auth_gRBR("glob", drugList, input_dir, mid_output_dir);
		all_auth_nRBR("glob", drugList, input_dir, mid_output_dir);

		// rrbr.auth_gRBR_a("auth_counts.csv", "glob", "alem", input_dir,
		// mid_output_dir);
		// rrbr.auth_gRBR_t("auth_counts.csv", "glob", "alem", input_dir,
		// mid_output_dir);

	}

}
