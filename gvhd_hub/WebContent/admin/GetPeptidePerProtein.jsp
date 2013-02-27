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
	
	out.println("Protein Id,nb Pept in M,nb Pep in R");

	HashMap<String, Long> mapProt = new HashMap<String, Long>();
	HashMap<String, Long> mapProtM = new HashMap<String, Long>();
	HashMap<String, Long> mapProtR = new HashMap<String, Long>();
	
	//Compute nb link with protein, per db, for each peptide sequence and place results in peptide nodes
	for (Relationship relPeptidome : peptidome.getRelationships())
	{		
		Node peptide = relPeptidome.getOtherNode(peptidome);

		boolean done = false;
		if (NodeHelper.getType(peptide).equals("Peptide") && peptide.getProperty("Decoy").equals("False"))
		{
			long nbM = 0;
			long nbR = 0;	
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
		 		 					if(protein.getProperty("Unique ID").toString().startsWith("M"))
		 		 					{
		 		 						mapProt.put(protein.getProperty("Protein id").toString(), 0L);
			 		 					if(!mapProtM.containsKey(protein.getProperty("Protein id").toString()))
				 		 					mapProtM.put(protein.getProperty("Protein id").toString(), 1L);
			 		 					else
			 		 						mapProtM.put(protein.getProperty("Protein id").toString(), mapProtM.get(protein.getProperty("Protein id").toString()) + 1L);
		 		 					}
		 		 					if(protein.getProperty("Unique ID").toString().startsWith("R"))
		 		 					{
		 		 						mapProt.put(protein.getProperty("Protein id").toString(), 0L);
			 		 					if(!mapProtR.containsKey(protein.getProperty("Protein id").toString()))
				 		 					mapProtR.put(protein.getProperty("Protein id").toString(), 1L);
			 		 					else
			 		 						mapProtR.put(protein.getProperty("Protein id").toString(), mapProtR.get(protein.getProperty("Protein id").toString()) + 1L);
		 		 					}
		 		 				}	 		 				
	 		 			}
	 		 		}
	 			}
	 		}
		}
	}
	for(String key : mapProt.keySet())
	{
		long nbM = 0;
		if(mapProtM.containsKey(key))
			nbM = mapProtM.get(key);
		long nbR = 0;
		if(mapProtR.containsKey(key))
			nbR = mapProtR.get(key);
		out.println(key + "," + nbM + "," + nbR);
	}
}
catch(Exception e)
{
	e.printStackTrace();
}
%>