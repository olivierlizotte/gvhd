<%@page import="gvhd.Helper"%><%@page import="gvhd.Pair"%><%@page import="org.neo4j.graphdb.DynamicRelationshipType"%><%@page import="scala.util.parsing.json.JSONFormat"%><%@ page import="graphDB.explore.*" %><%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import ="org.neo4j.graphdb.Direction" %><%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import ="org.neo4j.graphdb.Node" %><%@ page import ="org.neo4j.graphdb.Relationship" %><%@ page import ="org.neo4j.graphdb.RelationshipType" %><%@ page import ="org.neo4j.graphdb.Transaction" %><%@ page import ="org.neo4j.graphdb.index.Index" %><%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %><%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %><%@page import="org.neo4j.cypher.javacompat.*"%><%@page import="java.util.*" %><%@ page import="java.util.List"%><%@ page import="java.util.Map"%><%@ page import="java.util.Map.Entry"%><%@ page import="java.text.*"%><%@ page import="java.io.*" %><%
try{
	
	EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
	Node project = graphDb.getNodeById(2);

	final SimpleDateFormat formater = new SimpleDateFormat("dd/MM/yyyy");
	Transaction tx = graphDb.beginTx();
	
	List<Pair<Double, Pair<Double, Double>>> des = new ArrayList<Pair<Double, Pair<Double, Double>>>();
	
	List<String> names = new ArrayList<String>();
	List<String> namesGV = new ArrayList<String>();
	List<List<Pair<Double,Double>>> arrayDes = new ArrayList<List<Pair<Double,Double>>>();
	List<List<Pair<Double,Double>>> arrayDesGV = new ArrayList<List<Pair<Double,Double>>>();
	List<List<Pair<Double,Double>>> arrayHp = new ArrayList<List<Pair<Double,Double>>>();
	List<List<Pair<Double,Double>>> arrayHpGV = new ArrayList<List<Pair<Double,Double>>>();
	List<List<Pair<Double,Double>>> arrayLp = new ArrayList<List<Pair<Double,Double>>>();
	List<List<Pair<Double,Double>>> arrayLpGV = new ArrayList<List<Pair<Double,Double>>>();
	
	long averageGVHDDate = 0;
	int nbGvHd = 0;
	for (Relationship idRel : project.getRelationships())
	{
		Node patient = idRel.getOtherNode(project);
		if (NodeHelper.getType(patient).equals("Patient"))
		{			
			long dateT0 = 0;
			long dateTMinusOne = 0;
			double dateY = 0;
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
					}
					if(sample.hasProperty("GVHD"))
					{
						dateY = (double)formater.parse(sample.getProperty("Date").toString()).getTime();
					}
				}
			}
			if(dateT0 > 0 && dateY > 0)// && avg1 > 0 && avg2 > 0 && avg3 > 0 && avg4 > 0 && avg5 > 0 && avg6 > 0)// && desLibreDivider > 0)
			{
				dateY = (dateY - dateT0) /(1000.0*60*60*24);
				averageGVHDDate += dateY;
				nbGvHd++;
			}
		}
	}
	averageGVHDDate = averageGVHDDate / nbGvHd;

	//Compute Control related info (D4-D0 ratios, Protein Averages)
	for (Relationship idRel : project.getRelationships())
	{
		Node patient = idRel.getOtherNode(project);
		if (NodeHelper.getType(patient).equals("Patient"))
		{
			des.clear();
			long dateT0 = 0;
			long dateTMinusOne = 0;
			double dateY = averageGVHDDate;
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
				List<Pair<Double,Double>> tmpArrayDes = new ArrayList<Pair<Double,Double>>();
				List<Pair<Double,Double>> tmpArrayHp = new ArrayList<Pair<Double,Double>>();
				List<Pair<Double,Double>> tmpArrayLp = new ArrayList<Pair<Double,Double>>();
				if(gv)
					dateY = (dateY - dateT0) /(1000.0*60*60*24);
				for (Relationship sampleRel : patient.getRelationships())
				{
					Node sample = sampleRel.getOtherNode(patient);
					if (NodeHelper.getType(sample).equals("Sample") && sample.hasProperty("Sample"))
					{
						String date = sample.getProperty("Date").toString();
						double daySince = (formater.parse(date).getTime() - dateT0) /(1000.0*60*60*24);
						if(daySince >= 0 && daySince <= dateY)
						{
							if(sample.hasProperty("Ratio DES Libre") && sample.hasProperty("Ratio DES Total") && sample.hasProperty("Ratio HP Libre") &&
									   sample.hasProperty("Ratio HP Total")  && sample.hasProperty("Ratio LP Libre")  && sample.hasProperty("Ratio LP Total"))
							{
								double tmp1 = 0.5 * (NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Libre")) / sommeDesL +
													 NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Total")) / sommeDesT);							
								tmpArrayDes.add(new Pair<Double,Double>(daySince, tmp1));
								
								double tmp2 = 0.5 * (NodeHelper.PropertyToDouble(sample.getProperty("Ratio HP Libre")) / sommeHpL +
										 			 NodeHelper.PropertyToDouble(sample.getProperty("Ratio HP Total")) / sommeHpT);				
								tmpArrayHp.add(new Pair<Double,Double>(daySince, tmp2));
								
								double tmp3 = 0.5 * (NodeHelper.PropertyToDouble(sample.getProperty("Ratio LP Libre")) / sommeLpL +
							 						 NodeHelper.PropertyToDouble(sample.getProperty("Ratio LP Total")) / sommeLpT);	
								tmpArrayLp.add(new Pair<Double,Double>(daySince, tmp3));
							}
						}
					}
				}
				if(gv)
				{
					namesGV.add(patient.getProperty("Name").toString());
					arrayDesGV.add(tmpArrayDes);
					arrayHpGV.add(tmpArrayHp);
					arrayLpGV.add(tmpArrayLp);
				}
				else
				{
					names.add(patient.getProperty("Name").toString());
					arrayDes.add(tmpArrayDes);
					arrayHp.add(tmpArrayHp);
					arrayLp.add(tmpArrayLp);
				}
			}
		}
	}

   	String json = Helper.BuildGraphValues(arrayDes, arrayDesGV, names, namesGV, averageGVHDDate);
	Node desChart = graphDb.createNode();
	desChart.setProperty("Name", "Des");
	desChart.setProperty("type", "Chart");
	desChart.setProperty("data", json);
	project.createRelationshipTo(desChart, DynamicRelationshipType.withName("Tool_output"));			
	System.out.println("just created " + desChart.getId());	

   	json = Helper.BuildGraphValues(arrayHp, arrayHpGV, names, namesGV, averageGVHDDate);
	desChart = graphDb.createNode();
	desChart.setProperty("Name", "Hp");
	desChart.setProperty("type", "Chart");
	desChart.setProperty("data", json);
	project.createRelationshipTo(desChart, DynamicRelationshipType.withName("Tool_output"));			
	System.out.println("just created " + desChart.getId());	

   	json = Helper.BuildGraphValues(arrayLp, arrayLpGV, names, namesGV, averageGVHDDate);
	desChart = graphDb.createNode();
	desChart.setProperty("Name", "Lp");
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