<%@page import="gvhd.Pair"%><%@page import="org.neo4j.graphdb.DynamicRelationshipType"%><%@page import="scala.util.parsing.json.JSONFormat"%><%@ page import="graphDB.explore.*" %><%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import ="org.neo4j.graphdb.Direction" %><%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import ="org.neo4j.graphdb.Node" %><%@ page import ="org.neo4j.graphdb.Relationship" %><%@ page import ="org.neo4j.graphdb.RelationshipType" %><%@ page import ="org.neo4j.graphdb.Transaction" %><%@ page import ="org.neo4j.graphdb.index.Index" %><%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %><%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %><%@page import="org.neo4j.cypher.javacompat.*"%><%@page import="java.util.*" %><%@ page import="java.util.List"%><%@ page import="java.util.Map"%><%@ page import="java.util.Map.Entry"%><%@ page import="java.text.*"%><%@ page import="java.io.*" %><%
try{
	
	EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
	Node project = graphDb.getNodeById(2);

	final SimpleDateFormat formater = new SimpleDateFormat("dd/MM/yyyy");
	Transaction tx = graphDb.beginTx();
	
	List<Pair<Double, Pair<Double, Double>>> des = new ArrayList<Pair<Double, Pair<Double, Double>>>();
	
	List<Double> arrayDes = new ArrayList<Double>();
	List<Double> arrayNb = new ArrayList<Double>();

	List<Double> arrayDesGV = new ArrayList<Double>();
	List<Double> arrayNbGV = new ArrayList<Double>();
	for(int i = 0; i < 20; i++)
	{
		arrayDes.add(0.0);
		arrayNb.add(0.0);
		arrayDesGV.add(0.0);
		arrayNbGV.add(0.0);
	}
	//Compute Control related info (D4-D0 ratios, Protein Averages)
	for (Relationship idRel : project.getRelationships())
	{
		Node patient = idRel.getOtherNode(project);
		if (NodeHelper.getType(patient).equals("Patient"))
		{
			des.clear();
			long dateT0 = 0;
			long dateTMinusOne = 0;
			double dateY = 0;
			double sommeDesL = 0;
			double sommeDesT = 0;
			double sommeHpL = 0;
			double sommeHpT = 0;
			double sommeLpL = 0;
			double sommeLpT = 0;
			int nbSample = 0;
			boolean gv = false;
			
			//Find date for day 0 (initial time point)
			for (Relationship sampleRel : patient.getRelationships())
			{
				Node sample = sampleRel.getOtherNode(patient);
				if (NodeHelper.getType(sample).equals("Sample"))
				{
					if(sample.hasProperty("Sample"))
					{
						if(sample.getProperty("Sample").toString().endsWith("A"))
						{
							dateTMinusOne = formater.parse(sample.getProperty("Date").toString()).getTime();
						}
						
						if(sample.getProperty("Sample").toString().endsWith("B"))
						{
							dateT0 = formater.parse(sample.getProperty("Date").toString()).getTime();
						}

						if(sample.hasProperty("Ratio DES Libre") && sample.hasProperty("Ratio DES Total") && sample.hasProperty("Ratio HP Libre") &&
						   sample.hasProperty("Ratio HP Total")  && sample.hasProperty("Ratio LP Libre")  && sample.hasProperty("Ratio LP Total"))
						{
							sommeDesL += NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Libre"));
							sommeDesT += NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Total"));
							sommeHpL += NodeHelper.PropertyToDouble(sample.getProperty("Ratio HP Libre"));
							sommeHpT += NodeHelper.PropertyToDouble(sample.getProperty("Ratio HP Total"));
							sommeLpL += NodeHelper.PropertyToDouble(sample.getProperty("Ratio LP Libre"));
							sommeLpT += NodeHelper.PropertyToDouble(sample.getProperty("Ratio LP Total"));
							nbSample++;						
						}
					}
					if(sample.hasProperty("GVHD"))
					{
						gv = true;
						dateY = (double)formater.parse(sample.getProperty("Date").toString()).getTime();
					}
				}
			}

			if(dateT0 > 0 )//dateY > 0)// && avg1 > 0 && avg2 > 0 && avg3 > 0 && avg4 > 0 && avg5 > 0 && avg6 > 0)// && desLibreDivider > 0)
			{
				dateY = (dateY - dateT0) /(1000.0*60*60*24);
				for (Relationship sampleRel : patient.getRelationships())
				{
					Node sample = sampleRel.getOtherNode(patient);
					if (NodeHelper.getType(sample).equals("Sample") && sample.hasProperty("Sample"))
					{
						String date = sample.getProperty("Date").toString();
						double daySince = (formater.parse(date).getTime() - dateT0) /(1000.0*60*60*24);
						//if(daySince >= 0 && daySince <= dateY)
					if(sample.hasProperty("Ratio DES Libre") && sample.hasProperty("Ratio DES Total"))					
						{
							double tmp1 = 0.5 * (NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Libre")) / sommeDesL +
												 NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Total")) / sommeDesT);
							String strSample = sample.getProperty("Sample").toString();							
							if(gv)
							{
								switch(strSample.charAt(strSample.length() - 1))
								{
									case 'A': arrayDesGV.set(0, arrayDesGV.get(0) + tmp1); arrayNbGV.set(0, arrayNbGV.get(0) + 1); break;
									case 'B': arrayDesGV.set(1, arrayDesGV.get(1) + tmp1); arrayNbGV.set(1, arrayNbGV.get(1) + 1); break;
									case 'C': arrayDesGV.set(2, arrayDesGV.get(2) + tmp1); arrayNbGV.set(2, arrayNbGV.get(2) + 1); break;
									case 'D': arrayDesGV.set(3, arrayDesGV.get(3) + tmp1); arrayNbGV.set(3, arrayNbGV.get(3) + 1); break;
									case 'E': arrayDesGV.set(4, arrayDesGV.get(4) + tmp1); arrayNbGV.set(4, arrayNbGV.get(4) + 1); break;
									case 'F': arrayDesGV.set(5, arrayDesGV.get(5) + tmp1); arrayNbGV.set(5, arrayNbGV.get(5) + 1); break;
									case 'G': arrayDesGV.set(6, arrayDesGV.get(6) + tmp1); arrayNbGV.set(6, arrayNbGV.get(6) + 1); break;
									case 'H': arrayDesGV.set(7, arrayDesGV.get(7) + tmp1); arrayNbGV.set(7, arrayNbGV.get(7) + 1); break;
									case 'I': arrayDesGV.set(8, arrayDesGV.get(8) + tmp1); arrayNbGV.set(8, arrayNbGV.get(8) + 1); break;
									case 'J': arrayDesGV.set(9, arrayDesGV.get(9) + tmp1); arrayNbGV.set(9, arrayNbGV.get(9) + 1); break;
									case 'K': arrayDesGV.set(10, arrayDesGV.get(10) + tmp1); arrayNbGV.set(10, arrayNbGV.get(10) + 1); break;
									case 'L': arrayDesGV.set(11, arrayDesGV.get(11) + tmp1); arrayNbGV.set(11, arrayNbGV.get(11) + 1); break;
									case 'M': arrayDesGV.set(12, arrayDesGV.get(12) + tmp1); arrayNbGV.set(12, arrayNbGV.get(12) + 1); break;
									case 'N': arrayDesGV.set(13, arrayDesGV.get(13) + tmp1); arrayNbGV.set(13, arrayNbGV.get(13) + 1); break;
								}
							}
							else
							{
								switch(strSample.charAt(strSample.length() - 1))
								{
									case 'A': arrayDes.set(0, arrayDes.get(0) + tmp1); arrayNb.set(0, arrayNb.get(0) + 1); break;
									case 'B': arrayDes.set(1, arrayDes.get(1) + tmp1); arrayNb.set(1, arrayNb.get(1) + 1); break;
									case 'C': arrayDes.set(2, arrayDes.get(2) + tmp1); arrayNb.set(2, arrayNb.get(2) + 1); break;
									case 'D': arrayDes.set(3, arrayDes.get(3) + tmp1); arrayNb.set(3, arrayNb.get(3) + 1); break;
									case 'E': arrayDes.set(4, arrayDes.get(4) + tmp1); arrayNb.set(4, arrayNb.get(4) + 1); break;
									case 'F': arrayDes.set(5, arrayDes.get(5) + tmp1); arrayNb.set(5, arrayNb.get(5) + 1); break;
									case 'G': arrayDes.set(6, arrayDes.get(6) + tmp1); arrayNb.set(6, arrayNb.get(6) + 1); break;
									case 'H': arrayDes.set(7, arrayDes.get(7) + tmp1); arrayNb.set(7, arrayNb.get(7) + 1); break;
									case 'I': arrayDes.set(8, arrayDes.get(8) + tmp1); arrayNb.set(8, arrayNb.get(8) + 1); break;
									case 'J': arrayDes.set(9, arrayDes.get(9) + tmp1); arrayNb.set(9, arrayNb.get(9) + 1); break;
									case 'K': arrayDes.set(10, arrayDes.get(10) + tmp1); arrayNb.set(10, arrayNb.get(10) + 1); break;
									case 'L': arrayDes.set(11, arrayDes.get(11) + tmp1); arrayNb.set(11, arrayNb.get(11) + 1); break;
									case 'M': arrayDes.set(12, arrayDes.get(12) + tmp1); arrayNb.set(12, arrayNb.get(12) + 1); break;
									case 'N': arrayDes.set(13, arrayDes.get(13) + tmp1); arrayNb.set(13, arrayNb.get(13) + 1); break;
								}
							}
	/*						
							double tmp3 = NodeHelper.PropertyToDouble(sample.getProperty("Ratio HP Libre")) / sommeHpL;
							double tmp4 = NodeHelper.PropertyToDouble(sample.getProperty("Ratio HP Total")) / sommeHpT;
							double tmp5 = NodeHelper.PropertyToDouble(sample.getProperty("Ratio LP Libre")) / sommeLpL;
							double tmp6 = NodeHelper.PropertyToDouble(sample.getProperty("Ratio LP Total")) / sommeLpT;//*/
						}								
					}
				}
			}
		}
	}

   	String json = "";   	
	String strDES = ""; 
	for(int i = 0; i < arrayNb.size(); i++)
		if(arrayNb.get(i) > 0)
			strDES += ",{x:" + (i+1) + ", y: " + arrayDes.get(i)/arrayNb.get(i) + "}";
	if(!strDES.isEmpty())
		json += ",{values:[" + strDES.substring(1) + "], key: 'DES'}";
   	
	String strDESGV = ""; 

	for(int i = 0; i < arrayNbGV.size(); i++)
		if(arrayNbGV.get(i) > 0)
			strDESGV += ",{x:" + (i+1) + ", y: " + arrayDesGV.get(i)/arrayNbGV.get(i) + "}";
	if(!strDESGV.isEmpty())
		json += ",{values:[" + strDESGV.substring(1) + "], key: 'DES with GVHD'}";
	
	json = "[" + json.substring(1) + "]";
	Node desChart = graphDb.createNode();
	desChart.setProperty("type", "Chart");
	desChart.setProperty("data", json);
	project.createRelationshipTo(desChart, DynamicRelationshipType.withName("Tool_output"));			
	System.out.println("just created " + desChart.getId());	

	tx.success();
	tx.finish();
	
	out.println("Done!");
}
catch(Exception e)
{
	e.printStackTrace();
}
%>