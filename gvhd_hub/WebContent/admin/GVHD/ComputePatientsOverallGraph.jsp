<%@page import="gvhd.Pair"%><%@page import="org.neo4j.graphdb.DynamicRelationshipType"%><%@page import="scala.util.parsing.json.JSONFormat"%><%@ page import="graphDB.explore.*" %><%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import ="org.neo4j.graphdb.Direction" %><%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import ="org.neo4j.graphdb.Node" %><%@ page import ="org.neo4j.graphdb.Relationship" %><%@ page import ="org.neo4j.graphdb.RelationshipType" %><%@ page import ="org.neo4j.graphdb.Transaction" %><%@ page import ="org.neo4j.graphdb.index.Index" %><%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %><%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %><%@page import="org.neo4j.cypher.javacompat.*"%><%@page import="java.util.*" %><%@ page import="java.util.List"%><%@ page import="java.util.Map"%><%@ page import="java.util.Map.Entry"%><%@ page import="java.text.*"%><%@ page import="java.io.*" %><%
try{
	
	EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
	Node project = graphDb.getNodeById(2);

	final SimpleDateFormat formater = new SimpleDateFormat("dd/MM/yyyy");
	Transaction tx = graphDb.beginTx();
	
	List<Pair<Double, Pair<Double, Double>>> des = new ArrayList<Pair<Double, Pair<Double, Double>>>();
	String json = "";
	//Compute Control related info (D4-D0 ratios, Protein Averages)
	for (Relationship idRel : project.getRelationships())
	{
		Node patient = idRel.getOtherNode(project);
		if (NodeHelper.getType(patient).equals("Patient"))
		{
			if(patient.getProperty("Name").equals("004-SI"))
				json = json;
			des.clear();
			long dateT0 = 0;
			long dateTMinusOne = 0;
			double dateY = 0;
			double desLibreDivider = -1; 
			double desTotalDivider = -1; 
			
			//Find date for day 0 (initial time point)
			for (Relationship sampleRel : patient.getRelationships())
			{
				Node sample = sampleRel.getOtherNode(patient);
				if (NodeHelper.getType(sample).equals("Sample"))
				{
					if(sample.hasProperty("Sample"))
					{
						if(sample.getProperty("Sample").toString().endsWith("B"))
						{
							dateT0 = formater.parse(sample.getProperty("Date").toString()).getTime();
						}
						if(sample.getProperty("Sample").toString().endsWith("A"))
						{
							desLibreDivider = NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Libre"));
							desTotalDivider = NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Total"));
						}
						if(sample.getProperty("Sample").toString().endsWith("A"))
						{
							dateTMinusOne = formater.parse(sample.getProperty("Date").toString()).getTime();
						}
					}
					if(sample.hasProperty("GVHD"))
					{
						dateY = (double)formater.parse(sample.getProperty("Date").toString()).getTime();
					}
				}
			}

			if(dateY > 0 && dateT0 > 0 && desLibreDivider > 0)
			{
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
							double tmp = NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Libre"));
							double tmp2 = NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Total"));
							des.add(new Pair(daySince / dateY , new Pair(tmp / desLibreDivider, tmp2 / desTotalDivider)));
						}								
					}
				}
				Collections.sort( des, 
			    		new Comparator<Pair<Double, Pair<Double, Double>>>()
			            {
			                public int compare( Pair<Double, Pair<Double, Double>> n1, Pair<Double, Pair<Double, Double>> n2 )
			                {
			                	try
			                	{		         					
									if(n1.first == n2.first)
										return 0;
									else
										if(n1.first < n2.first)
											return -1;
										else
											return 1;
			                	}
			                	catch(Exception e)
			                	{
			                		e.printStackTrace();
			                	}
			                	return 0;								
			                }} );//*/

			   	String arrayDESLibre = "";           
				for(Pair<Double, Pair<Double, Double>> points : des)		
					arrayDESLibre  += ",{x:" + Double.toString(points.first) + ", y: " + Double.toString(points.second.first) + "}";

			   	String arrayDESTotal = "";           
				for(Pair<Double, Pair<Double, Double>> points : des)		
					arrayDESTotal  += ",{x:" + Double.toString(points.first) + ", y: " + Double.toString(points.second.second) + "}";
					
				json += ",{values:[" + arrayDESLibre.substring(1) + "], key: 'Patient " + patient.getProperty("Name") + "'}";
			}
		}
	}
	
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