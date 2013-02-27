<%@page import="org.neo4j.graphdb.DynamicRelationshipType"%>
<%@page import="scala.util.parsing.json.JSONFormat"%>
<%@ page import="graphDB.explore.*" %>
<%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %>
<%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %>
<%@ page import ="org.neo4j.graphdb.Direction" %>
<%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %>
<%@ page import ="org.neo4j.graphdb.Node" %>
<%@ page import ="org.neo4j.graphdb.Relationship" %>
<%@ page import ="org.neo4j.graphdb.RelationshipType" %>
<%@ page import ="org.neo4j.graphdb.Transaction" %>
<%@ page import ="org.neo4j.graphdb.index.Index" %>
<%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %>
<%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %>
<%@page import="org.neo4j.cypher.javacompat.*"%>
<%@page import="java.util.*" %>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Map.Entry"%>
<%@ page import="java.text.*"%>
<%@ page import="java.io.*" %>

<%
try{

	// set the http content type to "APPLICATION/OCTET-STREAM
	response.setContentType("APPLICATION/OCTET-STREAM");

	// initialize the http content-disposition header to
	// indicate a file attachment with the default filename
	String disHeader = "Attachment;	Filename=\"List.csv\"";
	response.setHeader("Content-Disposition", disHeader);

EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
Node peptidome = graphDb.getNodeById(581802);

	ArrayList<Node> potential = new ArrayList<Node>();	

	HashMap<Node, ArrayList<Relationship>> peptides = new HashMap<Node, ArrayList<Relationship>>();
	HashMap<String, Integer> properties = new HashMap<String, Integer>();
	
		
	//Cycle through peptides
	for (Relationship relPeptidome : peptidome.getRelationships())
	{
		Node peptide = relPeptidome.getOtherNode(peptidome);	
		if (NodeHelper.getType(peptide).toString().equals("Peptide"))
		{
			String strSequence = peptide.getProperty("Sequence").toString();
			ArrayList<Relationship> proteins = new ArrayList<Relationship>();
			
			//Should we keep this peptide?
			if(peptide.hasProperty("best HLA score") &&
			   (Double)peptide.getProperty("best HLA score") <= 1000 &&
//			   (Double)peptide.getProperty("Precursor Error") <= 5 &&
//			   (Double)peptide.getProperty("Precursor Error") >= -5 &&
			   (Double)peptide.getProperty("Highest Score") >= 23.175 &&
			   peptide.getProperty("Decoy").equals("False"))
			{					
				//Keep all properties for reference
				for(String key : peptide.getPropertyKeys())
					if(DefaultTemplate.keepAttribute(key) && !properties.containsKey(key))
						properties.put(key, 1);
				
				//Look for all associated proteins through peptide sequence		
				for (Relationship relPeptide : peptide.getRelationships())
				{
					Node sequence = relPeptide.getOtherNode(peptide);
					if (NodeHelper.getType(sequence).equals("Peptide Sequence") &&
						sequence.getProperty("Sequence").equals(strSequence))
					{
						int found = 0;
						for (Relationship relSequence : sequence.getRelationships())
						{
							Node protein = relSequence.getOtherNode(sequence);
							if (NodeHelper.getType(relSequence.getOtherNode(sequence)).equals("Protein Sequence"))
							{								
								proteins.add(relSequence);
								found++; 
							}
						}
						if(found == 0)
							System.out.println("No protein associated :" + sequence.getProperty("Sequence"));
					}
				}
				peptides.put(peptide, proteins);
			}
		}
	}
	
	String titleLine = "Proteome(s),Protein(s),Index(es),Position(s),PyGeno(s)";
	for(String prop : properties.keySet())
		titleLine += "," + prop;
	out.println(titleLine + ",Url,Miha(s)...");
		
	for(Node peptide : peptides.keySet())
	{		
		//Lookup Proteome
		String proteome = "";
		String pyGenoHeader = "";
		String positions = "";
		String protIDs   = "";
		String protIndex = "";
		boolean M       = false;
		boolean Ref     = false;
		boolean R       = false;
		boolean EBV     = false;
		boolean Reverse = false;
		if(peptides.get(peptide).size() > 0)
		{
			for(Relationship relProt : peptides.get(peptide))
			{
				Node protein = relProt.getEndNode();
				String id = protein.getProperty("Unique ID").toString();
				if(id.startsWith("REVERSE"))
					Reverse = true;
				else
				{
					if(protein.hasProperty("Protein id"))
					{
						//Chromosome number: 1 | Gene symbol: YBX1  Gene id: ENSG00000065978 | Transcript id: ENST00000318612 | Protein id: ENSP00000361621  Protein x1: 0		
						pyGenoHeader += ";Chromosome number: " + protein.getProperty("Chromosome number").toString() + 
									" | Gene symbol: " + protein.getProperty("Gene symbol").toString() + 
									"  Gene id: " + protein.getProperty("Gene id").toString() + 
									" | Transcript id: " + protein.getProperty("Transcript id").toString() +
									" | Protein id: " + protein.getProperty("Protein id").toString() +
									"  Protein x1: " + protein.getProperty("Protein x1").toString();

						protIDs   += ";" + protein.getProperty("Protein id").toString();
					}
					positions += ";" + relProt.getProperty("Position").toString();
					protIndex += ";" + id;
					if (id.startsWith("Ref"))
						Ref = true;
					else if (id.startsWith("M"))
						M = true; 
					else if (id.startsWith("R"))
						R = true; 
					else if (id.startsWith("VCA"))
						EBV = true;				
					else
						Reverse = true;
				}
			}
			if(protIDs.length() > 0)
			{
				pyGenoHeader = pyGenoHeader.substring(1);
				positions = positions.substring(1);
				protIDs   = protIDs.substring(1);
				protIndex = protIndex.substring(1);			
			
				if(M || R || Ref || EBV)
				{			
					if(M) proteome += ";M";
					if(R) proteome += ";R";
					if(Ref) proteome += ";Ref";
					if(EBV) proteome += ";EBV";
					proteome = proteome.substring(1);
				}
			}
			else
				protIDs = protIDs;
		}
		String line = "[" + proteome + "],[" + protIDs + "],[" + protIndex + "],[" + positions + "],[" + pyGenoHeader + "]";
		
		for(String key : properties.keySet())
			if(peptide.hasProperty(key))
				line += "," + peptide.getProperty(key).toString();
			else
				line += ",";
		line += ",http://proteo2.iric.ca:8080/explorer/index.jsp?id=" + peptide.getId();
		
		ArrayList<ImmunoInfo> mihas = ImmunoExtract.GetSingle(peptide, peptidome);
		for(ImmunoInfo miha : mihas)
			line += miha.GetString();
		out.println(line);		
	}
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
