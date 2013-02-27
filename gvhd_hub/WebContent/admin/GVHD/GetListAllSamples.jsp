<%@page import="org.neo4j.graphdb.DynamicRelationshipType"%><%@page import="scala.util.parsing.json.JSONFormat"%><%@ page import="graphDB.explore.*" %><%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import ="org.neo4j.graphdb.Direction" %><%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import ="org.neo4j.graphdb.Node" %><%@ page import ="org.neo4j.graphdb.Relationship" %><%@ page import ="org.neo4j.graphdb.RelationshipType" %><%@ page import ="org.neo4j.graphdb.Transaction" %><%@ page import ="org.neo4j.graphdb.index.Index" %><%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %><%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %><%@page import="org.neo4j.cypher.javacompat.*"%><%@page import="java.util.*" %><%@ page import="java.util.List"%><%@ page import="java.util.Map"%><%@ page import="java.util.Map.Entry"%><%@ page import="java.text.*"%><%@ page import="java.io.*" %><%
try{

	// set the http content type to "APPLICATION/OCTET-STREAM
	response.setContentType("APPLICATION/OCTET-STREAM");

	// initialize the http content-disposition header to
	// indicate a file attachment with the default filename
	String disHeader = "Attachment;	Filename=\"List.csv\"";
	response.setHeader("Content-Disposition", disHeader);
	
	
	EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
	Node project = graphDb.getNodeById(2);

	Transaction tx = graphDb.beginTx();
	
	SimpleDateFormat formater = new SimpleDateFormat("dd/MM/yyyy");
	
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
			
			for (Relationship sampleRel : patient.getRelationships())
			{
				Node sample = sampleRel.getOtherNode(patient);
				if (NodeHelper.getType(sample).equals("Sample") && sample.hasProperty("Sample"))
				{
					double desLibre = NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Libre"));
					double hpLibre  = NodeHelper.PropertyToDouble(sample.getProperty("Ratio HP Libre"));
					double lpLibre  = NodeHelper.PropertyToDouble(sample.getProperty("Ratio LP Libre"));

					double desTotal = NodeHelper.PropertyToDouble(sample.getProperty("Ratio DES Total"));
					double hpTotal  = NodeHelper.PropertyToDouble(sample.getProperty("Ratio HP Total"));
					double lpTotal  = NodeHelper.PropertyToDouble(sample.getProperty("Ratio LP Total"));
					
					String date = sample.getProperty("Date").toString();
					
					long daySince = (formater.parse(date).getTime() - dateT0) /(1000*60*60*24);
					out.println("," + Long.toString(daySince) + "," + desLibre + "," + hpLibre + "," + lpLibre + "," + desTotal + "," + hpTotal + "," + lpTotal + "," );
				}
			}
		}
	}

	tx.success();
	tx.finish();	
}
catch(Exception e)
{
	e.printStackTrace();
}
%>