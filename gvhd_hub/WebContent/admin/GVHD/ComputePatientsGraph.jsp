<%@page import="gvhd.Helper"%><%@page import="org.neo4j.graphdb.DynamicRelationshipType"%><%@page import="scala.util.parsing.json.JSONFormat"%><%@ page import="graphDB.explore.*" %><%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import ="org.neo4j.graphdb.Direction" %><%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import ="org.neo4j.graphdb.Node" %><%@ page import ="org.neo4j.graphdb.Relationship" %><%@ page import ="org.neo4j.graphdb.RelationshipType" %><%@ page import ="org.neo4j.graphdb.Transaction" %><%@ page import ="org.neo4j.graphdb.index.Index" %><%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %><%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %><%@page import="org.neo4j.cypher.javacompat.*"%><%@page import="java.util.*" %><%@ page import="java.util.List"%><%@ page import="java.util.Map"%><%@ page import="java.util.Map.Entry"%><%@ page import="java.text.*"%><%@ page import="java.io.*" %><%
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
				List<String> arrayDates = new ArrayList<String>();
				List<String> arrayToAdd = new ArrayList<String>();
				List<Double> arrayDESLibre = new ArrayList<Double>();
				List<Double> arrayHPLibre = new ArrayList<Double>();
				List<Double> arrayLPLibre = new ArrayList<Double>();
				List<Double> arrayDESTotal = new ArrayList<Double>();
				List<Double> arrayHPTotal = new ArrayList<Double>();
				List<Double> arrayLPTotal = new ArrayList<Double>();
				//List<Double> arrayGrouped = new ArrayList<Double>();
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

					if(sample.hasProperty("Ratio DES Libre") && sample.hasProperty("Ratio DES Total") && sample.hasProperty("Ratio HP Libre") &&
					   sample.hasProperty("Ratio HP Total")  && sample.hasProperty("Ratio LP Libre")  && sample.hasProperty("Ratio LP Total"))
					{
						arrayDates.add(Long.toString(daySince));
						arrayToAdd.add(strToAdd);
						
						arrayDESLibre.add(NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Libre")));
					
						arrayDESTotal.add(NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Total")));
					
						arrayHPLibre.add(NodeHelper.PropertyToDouble(sample.getProperty("Ratio HP Libre")));
					
						arrayHPTotal.add(NodeHelper.PropertyToDouble(sample.getProperty("Ratio HP Total")));
					
						arrayLPLibre.add(NodeHelper.PropertyToDouble(sample.getProperty("Ratio LP Libre")));
					
						arrayLPTotal.add(NodeHelper.PropertyToDouble(sample.getProperty("Ratio LP Total")));
					}
					//arrayGrouped.add((tmp1 + tmp2 + tmp3 + tmp4 + tmp5 + tmp6) / 6.0);
					//arrayDESLibre  += ",{x:" + Long.toString(daySince) + ", y: " + sample.getProperty("Ratio DES Libre") + strToAdd + "}";					
				}

				//Overall patient graph
				json = "[{values:[" + Helper.BuildGraphAxis(arrayDates, Helper.NormalizeArray(arrayDESLibre), arrayToAdd) + "], key: 'DES Libre'},";
				json += "{values:[" + Helper.BuildGraphAxis(arrayDates, Helper.NormalizeArray(arrayDESTotal), arrayToAdd) + "], key: 'DES Total'},";				
				json += "{values:[" + Helper.BuildGraphAxis(arrayDates, Helper.NormalizeArray(arrayHPLibre), arrayToAdd) + "], key: 'HP Libre'},";
				json += "{values:[" + Helper.BuildGraphAxis(arrayDates, Helper.NormalizeArray(arrayHPTotal), arrayToAdd) + "], key: 'HP Total'},";	
				json += "{values:[" + Helper.BuildGraphAxis(arrayDates, Helper.NormalizeArray(arrayLPLibre), arrayToAdd) + "], key: 'LP Libre'},";
				json += "{values:[" + Helper.BuildGraphAxis(arrayDates, Helper.NormalizeArray(arrayLPTotal), arrayToAdd) + "], key: 'LP Total'}]";
				
				Node overallChart = graphDb.createNode();
				overallChart.setProperty("type", "Chart");
				overallChart.setProperty("data", json);
				patient.createRelationshipTo(overallChart, DynamicRelationshipType.withName("Tool_output"));			
				System.out.println("just created "+overallChart.getId());
				
		        
				json = "[{values:[" + Helper.BuildGraphAxis(arrayDates, arrayDESLibre, arrayToAdd) + "], key: 'DES Libre'},";
				//json += "{values:[" + arrayGrouped.substring(1) + "], key: 'Grouped Average'},";
				json += "{values:[" + Helper.BuildGraphAxis(arrayDates, arrayDESTotal, arrayToAdd) + "], key: 'DES Total'}]";				
				Node desChart = graphDb.createNode();
				desChart.setProperty("type", "Chart");
				desChart.setProperty("data", json);
				patient.createRelationshipTo(desChart, DynamicRelationshipType.withName("Tool_output"));			
				System.out.println("just created " + desChart.getId());			
				//*/
				
				json = "[{values:[" + Helper.BuildGraphAxis(arrayDates, arrayHPLibre, arrayToAdd) + "], key: 'HP Libre'},";
				//json += "{values:[" + arrayGrouped.substring(1) + "], key: 'Grouped Average'},";
				json += "{values:[" + Helper.BuildGraphAxis(arrayDates, arrayHPTotal, arrayToAdd) + "], key: 'HP Total'}]";				
				Node hpChart = graphDb.createNode();
				hpChart.setProperty("type", "Chart");
				hpChart.setProperty("data", json);
				patient.createRelationshipTo(hpChart, DynamicRelationshipType.withName("Tool_output"));			
				System.out.println("just created "+hpChart.getId());	
				//*/
	
				json = "[{values:[" + Helper.BuildGraphAxis(arrayDates, arrayLPLibre, arrayToAdd) + "], key: 'LP Libre'},";
				//json += "{values:[" + arrayGrouped.substring(1) + "], key: 'Grouped Average'},";
				json += "{values:[" + Helper.BuildGraphAxis(arrayDates, arrayLPTotal, arrayToAdd) + "], key: 'LP Total'}]";				
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