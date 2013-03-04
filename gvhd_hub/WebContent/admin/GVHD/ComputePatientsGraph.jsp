<%@page import="org.neo4j.graphdb.DynamicRelationshipType"%><%@page import="scala.util.parsing.json.JSONFormat"%><%@ page import="graphDB.explore.*" %><%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import ="org.neo4j.graphdb.Direction" %><%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import ="org.neo4j.graphdb.Node" %><%@ page import ="org.neo4j.graphdb.Relationship" %><%@ page import ="org.neo4j.graphdb.RelationshipType" %><%@ page import ="org.neo4j.graphdb.Transaction" %><%@ page import ="org.neo4j.graphdb.index.Index" %><%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %><%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %><%@page import="org.neo4j.cypher.javacompat.*"%><%@page import="java.util.*" %><%@ page import="java.util.List"%><%@ page import="java.util.Map"%><%@ page import="java.util.Map.Entry"%><%@ page import="java.text.*"%><%@ page import="java.io.*" %><%
try{
	
	EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
	Node project = graphDb.getNodeById(2);

	final SimpleDateFormat formater = new SimpleDateFormat("dd/MM/yyyy");
	Transaction tx = graphDb.beginTx();
	
	//Compute Control related info (D4-D0 ratios, Protein Averages)	
	for (Relationship idRel : project.getRelationships())
	{
		Node patient = idRel.getOtherNode(project);
		if (NodeHelper.getType(patient).equals("Patient"))
		{
			long dateT0 = 0;

			//Find date for day 0 (initial time point)
			for (Relationship sampleRel : patient.getRelationships())
			{
				Node sample = sampleRel.getOtherNode(patient);
				if (NodeHelper.getType(sample).equals("Sample") && sample.hasProperty("Sample"))
				{					
					if(sample.getProperty("Sample").toString().endsWith("B"))
						dateT0 = formater.parse(sample.getProperty("Date").toString()).getTime();					
				}
			}

			if(dateT0 > 0)
			{
				String json = "";
				String arrayDESLibre = "";
				String arrayHPLibre = "";
				String arrayLPLibre = "";
				String arrayDESTotal = "";
				String arrayHPTotal = "";
				String arrayLPTotal = "";
				String arrayGrouped = "";
				List<Node> samples = new ArrayList<Node>();
				final long timePoint0 = dateT0;
				
				for (Relationship sampleRel : patient.getRelationships())
				{
					Node sample = sampleRel.getOtherNode(patient);
					if (NodeHelper.getType(sample).equals("Sample") && sample.hasProperty("Sample"))
					{				
						samples.add(sample);
					}
				}				
				Collections.sort( samples, 
		        		new Comparator<Node>()
		                {
		                    public int compare( Node n1, Node n2 )
		                    {
		                    	try
		                    	{		                    	
									String date1 = n1.getProperty("Date").toString();					
									long daySince1 = (formater.parse(date1).getTime() - timePoint0) /(1000*60*60*24);
									String date2 = n2.getProperty("Date").toString();					
									long daySince2 = (formater.parse(date2).getTime() - timePoint0) /(1000*60*60*24);
																	
									if(daySince1 == daySince2)
										return 0;
									else
										if(daySince1 < daySince2)
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
		        for(Node sample : samples)
		        {
					String date = sample.getProperty("Date").toString();					
					long daySince = (formater.parse(date).getTime() - dateT0) /(1000*60*60*24);
											
					String strDate = sample.getProperty("Sample").toString().substring(3);
					
					String strToAdd = "";
					if(sample.hasProperty("GVHD") && NodeHelper.PropertyToDouble(sample.getProperty("GVHD")) == 1.0)
					{					
						strToAdd += ", GVHD: 'true'";
					}
					if(sample.hasProperty("Comment"))
					{					
						strToAdd += ", Comment: '" + sample.getProperty("Comment") + "'";
					}
					if(daySince == 0L)
					{					
						strToAdd += ", 'Day 0': '" + sample.getProperty("Date") + "'";
					}

					double tmp1 = NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Libre"));
					double tmp2 = NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Total"));
					double tmp3 = NodeHelper.PropertyToDouble(sample.getProperty("Ratio HP Libre"));
					double tmp4 = NodeHelper.PropertyToDouble(sample.getProperty("Ratio HP Total"));
					double tmp5 = NodeHelper.PropertyToDouble(sample.getProperty("Ratio LP Libre"));
					double tmp6 = NodeHelper.PropertyToDouble(sample.getProperty("Ratio LP Total"));
					double average = (tmp1 + tmp2 + tmp3 + tmp4 + tmp5 + tmp6) / 6.0;
					arrayGrouped   += ",{x:" + Long.toString(daySince) + ", y: " + average + strToAdd + "}";
					arrayDESLibre  += ",{x:" + Long.toString(daySince) + ", y: " + sample.getProperty("Ratio DES Libre") + strToAdd + "}";
					arrayHPLibre   += ",{x:" + Long.toString(daySince) + ", y: " + sample.getProperty("Ratio HP Libre")  + strToAdd + "}";
					arrayLPLibre   += ",{x:" + Long.toString(daySince) + ", y: " + sample.getProperty("Ratio LP Libre")  + strToAdd + "}";
					arrayDESTotal  += ",{x:" + Long.toString(daySince) + ", y: " + sample.getProperty("Ratio DES Total") + strToAdd + "}";
					arrayHPTotal   += ",{x:" + Long.toString(daySince) + ", y: " + sample.getProperty("Ratio HP Total")  + strToAdd + "}";
					arrayLPTotal   += ",{x:" + Long.toString(daySince) + ", y: " + sample.getProperty("Ratio LP Total")  + strToAdd + "}";					
				}
				
				json = "[{values:[" + arrayDESLibre.substring(1) + "], key: 'DES Libre'},";
				json += "{values:[" + arrayGrouped.substring(1) + "], key: 'Grouped Average'},";
				json += "{values:[" + arrayDESTotal.substring(1) + "], key: 'DES Total'}]";
				
				Node desChart = graphDb.createNode();
				desChart.setProperty("type", "Chart");
				desChart.setProperty("data", json);
				patient.createRelationshipTo(desChart, DynamicRelationshipType.withName("Tool_output"));			
				System.out.println("just created " + desChart.getId());			
				
				
				json = "[{values:[" + arrayHPLibre.substring(1) + "], key: 'HP Libre'},";
				json += "{values:[" + arrayGrouped.substring(1) + "], key: 'Grouped Average'},";
				json += "{values:[" + arrayHPTotal.substring(1) + "], key: 'HP Total'}]";
				
				Node hpChart = graphDb.createNode();
				hpChart.setProperty("type", "Chart");
				hpChart.setProperty("data", json);
				patient.createRelationshipTo(hpChart, DynamicRelationshipType.withName("Tool_output"));			
				System.out.println("just created "+hpChart.getId());	
				
	
				json = "[{values:[" + arrayLPLibre.substring(1) + "], key: 'LP Libre'},";
				json += "{values:[" + arrayGrouped.substring(1) + "], key: 'Grouped Average'},";
				json += "{values:[" + arrayLPTotal.substring(1) + "], key: 'LP Total'}]";
				
				Node lpChart = graphDb.createNode();
				lpChart.setProperty("type", "Chart");
				lpChart.setProperty("data", json);
				patient.createRelationshipTo(lpChart, DynamicRelationshipType.withName("Tool_output"));			
				System.out.println("just created "+lpChart.getId());
			}
		}
	}

	tx.success();
	tx.finish();
	
	out.println("Done!");
}
catch(Exception e)
{
	e.printStackTrace();
}
%>