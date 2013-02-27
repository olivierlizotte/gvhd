<%@page import="org.neo4j.graphdb.DynamicRelationshipType"%><%@page import="scala.util.parsing.json.JSONFormat"%><%@ page import="graphDB.explore.*" %><%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import ="org.neo4j.graphdb.Direction" %><%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import ="org.neo4j.graphdb.Node" %><%@ page import ="org.neo4j.graphdb.Relationship" %><%@ page import ="org.neo4j.graphdb.RelationshipType" %><%@ page import ="org.neo4j.graphdb.Transaction" %><%@ page import ="org.neo4j.graphdb.index.Index" %><%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %><%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %><%@page import="org.neo4j.cypher.javacompat.*"%><%@page import="java.util.*" %><%@ page import="java.util.List"%><%@ page import="java.util.Map"%><%@ page import="java.util.Map.Entry"%><%@ page import="java.text.*"%><%@ page import="java.io.*" %><%
try{
	
	EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
	Node project = graphDb.getNodeById(2);

	Transaction tx = graphDb.beginTx();
	
	//Compute Control related info (D4-D0 ratios, Protein Averages)	
	for (Relationship idRel : project.getRelationships())
	{
		Node control = idRel.getOtherNode(project);
		if (NodeHelper.getType(control).equals("Control"))
		{
			//Compute Average Ratios
			double ratioLibreDES = 0;
			double ratioLibreHP = 0;
			double ratioTotalDES = 0;
			double ratioTotalHP = 0;
			int nbLibreDES = 0;
			int nbLibreHP  = 0; 
			int nbTotalDES = 0;
			int nbTotalHP  = 0; 
			
			for (Relationship controlRel : control.getRelationships())
			{
				Node dupControl = controlRel.getOtherNode(control);
				if (NodeHelper.getType(dupControl).equals("ControlDuplicate"))
				{
					for (Relationship dupRel : dupControl.getRelationships())
					{
						Node rep = dupRel.getOtherNode(dupControl);
						if (NodeHelper.getType(rep).equals("Total") || NodeHelper.getType(rep).equals("Libre"))
						{
							for (Relationship typeRel : rep.getRelationships())
							{
								Node tmp = typeRel.getOtherNode(rep);
								if (NodeHelper.getType(tmp).equals("Replicate"))
								{
									double des = 0;
									double d4des = 0;
									double hp= 0;
									double d4hp = 0;
									
									double desCorr;
									double hpCorr;
									
									if(tmp.hasProperty("DES"))
										des = NodeHelper.PropertyToDouble(tmp.getProperty("DES"));
									if(tmp.hasProperty("D4-DES"))
										d4des = NodeHelper.PropertyToDouble(tmp.getProperty("D4-DES"));
									if(tmp.hasProperty("HP"))
										hp = NodeHelper.PropertyToDouble(tmp.getProperty("HP"));
									if(tmp.hasProperty("D4-HP"))
										d4hp = NodeHelper.PropertyToDouble(tmp.getProperty("D4-HP"));
							
									if(d4des > 0)
									{
										double ratio = des / d4des;
										tmp.setProperty("Ratio DES", ratio);
										if (NodeHelper.getType(rep).equals("Libre"))
										{
											ratioLibreDES += ratio;
											nbLibreDES++;
										}
										if (NodeHelper.getType(rep).equals("Total"))
										{
											ratioTotalDES += ratio;
											nbTotalDES++;
										}
									}
									if(d4hp > 0)
									{
										double ratio = hp / d4hp;
										tmp.setProperty("Ratio HP", ratio);
										if (NodeHelper.getType(rep).equals("Libre"))
										{
											ratioLibreHP += ratio;
											nbLibreHP++;
										}
										if (NodeHelper.getType(rep).equals("Total"))
										{
											ratioTotalHP += ratio;
											nbTotalHP++;
										}
									}
								}
							}
						}
					}
				}
			}
			if(nbLibreDES > 0)
			{
				double dblLibDES = ratioLibreDES / (double) nbLibreDES;
				control.setProperty("Ratio DES Libre", dblLibDES);
			}
			if(nbLibreHP > 0)
			{				
				double dblLibHP = ratioLibreHP / (double) nbLibreHP;
				control.setProperty("Ratio HP Libre", dblLibHP);
			}
			if(nbTotalDES > 0)
			{				
				double dblTotDES = ratioTotalDES / (double) nbTotalDES;
				control.setProperty("Ratio DES Total", dblTotDES);
			}
			if(nbTotalHP > 0)
			{				
				double dblTotHP = ratioTotalHP / (double) nbTotalHP;
				control.setProperty("Ratio HP Total", dblTotHP);
			}
		}
	}
/*
	for (Relationship idRel : project.getRelationships())
	{
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
	}
//*/

	tx.success();
	tx.finish();
	
	out.println("Done!");
}
catch(Exception e)
{
	e.printStackTrace();
}
%>