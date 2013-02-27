<%@page import="org.neo4j.graphdb.DynamicRelationshipType"%><%@page import="scala.util.parsing.json.JSONFormat"%><%@ page import="graphDB.explore.*" %><%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import ="org.neo4j.graphdb.Direction" %><%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import ="org.neo4j.graphdb.Node" %><%@ page import ="org.neo4j.graphdb.Relationship" %><%@ page import ="org.neo4j.graphdb.RelationshipType" %><%@ page import ="org.neo4j.graphdb.Transaction" %><%@ page import ="org.neo4j.graphdb.index.Index" %><%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %><%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %><%@page import="org.neo4j.cypher.javacompat.*"%><%@page import="java.util.*" %><%@ page import="java.util.List"%><%@ page import="java.util.Map"%><%@ page import="java.util.Map.Entry"%><%@ page import="java.text.*"%><%
try{
	EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
	RelationshipType newNodeRel = DynamicRelationshipType.withName("Link");
	
	Node project = graphDb.getNodeById(2);
	HashMap<String, Node> controls = new HashMap<String, Node>();		
	
	for (Relationship idRel : project.getRelationships())
	{
		Node lnkNode = idRel.getOtherNode(project);
		if (NodeHelper.getType(lnkNode).equals("Control"))
			controls.put(lnkNode.getProperty("Control").toString(), lnkNode);
	}

	Transaction tx = graphDb.beginTx();
	for (Relationship idRel : project.getRelationships())
	{
		//PATIENTS ::
		Node patient = idRel.getOtherNode(project);
		if (NodeHelper.getType(patient).equals("Patient"))
		{
			for (Relationship patientRel : patient.getRelationships())
			{
				Node sample = patientRel.getOtherNode(patient);
				if (NodeHelper.getType(sample).equals("Sample"))
				{
					boolean lnkedToControl = false;
					for (Relationship sampleRel : sample.getRelationships())
					{
						Node tmp = sampleRel.getOtherNode(sample);
						if (NodeHelper.getType(tmp).equals("Control"))
							lnkedToControl = true;
					}
					if(!lnkedToControl && sample.hasProperty("CONTROL HP"))
					{
						String ctrlStr = sample.getProperty("CONTROL HP").toString();
						Node control = controls.get(ctrlStr);
						sample.createRelationshipTo(control, newNodeRel);
					}
				}
			}
		}
		
		//CONTROLCD ::
		Node controlCD = idRel.getOtherNode(project);
		if (NodeHelper.getType(patient).equals("ControlCD"))
		{
			boolean lnkedToControl = false;
			for (Relationship sampleRel : controlCD.getRelationships())
			{
				Node tmp = sampleRel.getOtherNode(controlCD);
				if (NodeHelper.getType(tmp).equals("Control"))
					lnkedToControl = true;
			}
			if(!lnkedToControl && controlCD.hasProperty("CONTROL HP"))
			{
				String ctrlStr = controlCD.getProperty("CONTROL HP").toString();
				Node control = controls.get(ctrlStr);
				controlCD.createRelationshipTo(control, newNodeRel);
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
