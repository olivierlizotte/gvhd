<%@page import="gvhd.Helper"%><%@ page import="graphDB.users.*" %><%@page import="org.neo4j.shell.util.json.JSONArray"%><%@page import="org.neo4j.shell.util.json.JSONObject"%><%@page import="java.io.File" %><%@page import="org.neo4j.graphdb.PropertyContainer"%><%@ page language="java" contentType="text/html; charset=ISO-8859-1"    pageEncoding="ISO-8859-1"%><%@ page import="org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import="org.neo4j.graphdb.Direction" %><%@ page import="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import="org.neo4j.graphdb.Node" %><%@ page import="org.neo4j.graphdb.DynamicRelationshipType" %><%@ page import="org.neo4j.graphdb.Relationship" %><%@ page import="org.neo4j.graphdb.RelationshipType" %><%@ page import="org.neo4j.graphdb.Transaction" %><%@ page import="org.neo4j.graphdb.index.Index" %><%@ page import="org.neo4j.kernel.AbstractGraphDatabase" %><%@ page import="org.neo4j.kernel.EmbeddedGraphDatabase" %><%@ page import="java.util.*" %><%@ page import="java.io.*" %><%@ page import="graphDB.explore.*" %><%

try{
	//XmlToDb.RUN("G:\\Thibault\\-=Proteomics_Raw_Data=-\\ELITE\\JUN27_2012\\MR 4Rep DS\\Proteoprofile HGR DB all Mascot score\\PigInfo.clusterML", "dev");

	 
	File file = new File("files/Gvhd_Transpose.csv");	 
	BufferedReader bufRdr  = new BufferedReader(new FileReader(file));
	String line = bufRdr.readLine();
	//Handle title line with properties
	String[] properties = line.split(",");		
	List<String> patients = new ArrayList<String>();

	
	
	long userID = Login.addUser("Administrator","admin", "test");
	
	EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
	
	Transaction tx = graphDb.beginTx();
	
	RelationshipType newNodeRel = DynamicRelationshipType.withName("Link");
	
	Node theUser = graphDb.getNodeById(userID);
	
	Node project = graphDb.createNode();
	theUser.createRelationshipTo(project, newNodeRel);
	project.setProperty("type", "Project");
	
	Node patient = null;
	
	
	//read each line of text file
	while((line = bufRdr.readLine()) != null)
	{
		String[] cols = line.split(",");
		if(cols.length > 1)
		{
			boolean newPatient = true;
			for(int i = 0; i < patients.size(); i++)
				if(patients.get(i).equals(cols[0]))
					newPatient = false;
			if(newPatient)
			{
				patients.add(cols[0]);
				patient = Helper.CreatePatient(graphDb, project, cols[0]);
			}
			String date = cols[1];//.replace('/', '-');
			String creatinine = "";
			if(cols.length > 2)
				creatinine = cols[2];
			String comment = "";
			if(cols.length > 3)
				comment = cols[3];//.replace(('\'', '');
	
			Node sample  = Helper.CreateSample(graphDb, patient, cols[0], date,  creatinine, comment);
			Node total = null; Node totalR1 = null; Node totalR2 = null;
			Node libre = null; Node libreR1 = null; Node libreR2 = null;
			
			for(int i = 4; i < cols.length && i < properties.length; i++)
			{
				if(!cols[i].isEmpty())
				{
					Node toUpdate = sample;
					if(properties[i].equals("Sample") && !cols[i].isEmpty())
						toUpdate.setProperty("Name", cols[i]);
					if(properties[i].startsWith("Total"))
					{
						if(total == null)
						{
							total = graphDb.createNode();
							sample.createRelationshipTo(total, newNodeRel);
							total.setProperty("type", "Total");
						}
						toUpdate = total;
						
						if(properties[i].endsWith("R1"))
						{
							if(totalR1 == null)
							{
								totalR1 = graphDb.createNode();
								total.createRelationshipTo(totalR1, newNodeRel);
								totalR1.setProperty("type", "Replicate");
								totalR1.setProperty("Replicate", "1");
							}
							toUpdate = totalR1;
						}
						if(properties[i].endsWith("R2"))
						{
							if(totalR2 == null)
							{
								totalR2 = graphDb.createNode();
								total.createRelationshipTo(totalR2, newNodeRel);
								totalR2.setProperty("type", "Replicate");
								totalR2.setProperty("Replicate", "2");
							}
							toUpdate = totalR2;
						}
					}
					else if(properties[i].startsWith("Libre"))
					{
						if(libre == null)
						{
							libre = graphDb.createNode();
							sample.createRelationshipTo(libre, newNodeRel);
							libre.setProperty("type", "Libre");
						}
						toUpdate = libre;
						
						if(properties[i].endsWith("R1"))
						{
							if(libreR1 == null)
							{
								libreR1 = graphDb.createNode();
								libre.createRelationshipTo(libreR1, newNodeRel);
								libreR1.setProperty("type", "Replicate");
								libreR1.setProperty("Replicate", "1");
							}
							toUpdate = libreR1;			
						}
						if(properties[i].endsWith("R2"))
						{
							if(libreR2 == null)
							{
								libreR2 = graphDb.createNode();
								libre.createRelationshipTo(libreR2, newNodeRel);
								libreR2.setProperty("type", "Replicate");
								libreR2.setProperty("Replicate", "2");
							}
							toUpdate = libreR2;
						}
					}
					
					String property = properties[i].replaceAll("Libre ", "");
					property = property.replaceAll("Total ", "");
					property = property.replaceAll(" R1", "");
					property = property.replaceAll(" R2", "");
					if(NodeHelper.isNumeric(cols[i]))
						toUpdate.setProperty(property, Double.parseDouble(cols[i]));
					else
						toUpdate.setProperty(property, cols[i]);
				}
			}
		}
	}
	 
	//close the file
	bufRdr.close();

	tx.success();
	tx.finish();
	
	out.println("Done!");
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
