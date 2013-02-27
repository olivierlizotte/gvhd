<%@page import="org.neo4j.graphdb.DynamicRelationshipType"%><%@page import="scala.util.parsing.json.JSONFormat"%><%@ page import="graphDB.explore.*" %><%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import ="org.neo4j.graphdb.Direction" %><%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import ="org.neo4j.graphdb.Node" %><%@ page import ="org.neo4j.graphdb.Relationship" %><%@ page import ="org.neo4j.graphdb.RelationshipType" %><%@ page import ="org.neo4j.graphdb.Transaction" %><%@ page import ="org.neo4j.graphdb.index.Index" %><%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %><%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %><%@page import="org.neo4j.cypher.javacompat.*"%><%@page import="java.util.*" %><%@ page import="java.util.List"%><%@ page import="java.util.Map"%><%@ page import="java.util.Map.Entry"%><%@ page import="java.text.*"%><%
try{

	// set the http content type to "APPLICATION/OCTET-STREAM
	response.setContentType("APPLICATION/OCTET-STREAM");

	// initialize the http content-disposition header to
	// indicate a file attachment with the default filename
	String disHeader = "Attachment;	Filename=\"List.csv\"";
	response.setHeader("Content-Disposition", disHeader);

	EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
	Node peptidome = graphDb.getNodeById(875149);	
	
	out.println("Sequence,nb Prot M,nb Prot R"); 
	//Compute nb link with protein, per db, for each peptide sequence and place results in peptide nodes
	for (Relationship relPeptidome : peptidome.getRelationships())
	{		
		Node peptide = relPeptidome.getOtherNode(peptidome);

		boolean done = false;
		if (NodeHelper.getType(peptide).equals("Peptide") && peptide.getProperty("Decoy").equals("False"))
		{
			long nbM = 0;
			long nbR = 0;
			HashMap<String, Long> mapProtM = new HashMap<String, Long>();	
			HashMap<String, Long> mapProtR = new HashMap<String, Long>();
	 		for (Relationship relPeptide : peptide.getRelationships())
	 		{
	 			Node sequence = relPeptide.getOtherNode(peptide); 			
	 			if (!done && NodeHelper.getType(sequence).equals("Peptide Sequence"))
	 			{
	 				done = true;
	 		 		for (Relationship relSequence : sequence.getRelationships())
	 		 		{
	 		 			Node protein = relSequence.getOtherNode(sequence); 		 		
	 		 			if (NodeHelper.getType(protein).equals("Protein Sequence") && protein.hasProperty("Protein id"))
	 		 			{	 		 				
	 		 				if(!protein.getProperty("Unique ID").toString().startsWith("REVERSE") && 
	 		 				   !protein.getProperty("Unique ID").toString().startsWith("Ref"))
	 		 				{
		 		 				if(protein.getProperty("Unique ID").toString().startsWith("M") && !mapProtM.containsValue(protein.getProperty("Protein id").toString()))
			 		 			{
		 		 					nbM++;
		 		 					mapProtM.put(protein.getProperty("Protein id").toString(), protein.getId());
			 		 			}
		 		 				if(protein.getProperty("Unique ID").toString().startsWith("R") && !mapProtR.containsValue(protein.getProperty("Protein id").toString()))
		 		 				{
		 		 					nbR++;
			 		 				mapProtR.put(protein.getProperty("Protein id").toString(), protein.getId());
		 		 				}
	 		 				}
	 		 			}
	 		 		}
	 			}
	 		}
	 		out.println(peptide.getProperty("Sequence") + "," + nbM + "," + nbR);
		}
	}
}
catch(Exception e)
{
	e.printStackTrace();
}
%>