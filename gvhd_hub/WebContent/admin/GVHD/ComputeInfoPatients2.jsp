<%@page import="org.neo4j.graphdb.DynamicRelationshipType"%><%@page import="scala.util.parsing.json.JSONFormat"%><%@ page import="graphDB.explore.*" %><%@ page import =" org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import ="org.neo4j.graphdb.Direction" %><%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import ="org.neo4j.graphdb.Node" %><%@ page import ="org.neo4j.graphdb.Relationship" %><%@ page import ="org.neo4j.graphdb.RelationshipType" %><%@ page import ="org.neo4j.graphdb.Transaction" %><%@ page import ="org.neo4j.graphdb.index.Index" %><%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %><%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %><%@page import="org.neo4j.cypher.javacompat.*"%><%@page import="java.util.*" %><%@ page import="java.util.List"%><%@ page import="java.util.Map"%><%@ page import="java.util.Map.Entry"%><%@ page import="java.text.*"%><%@ page import="java.io.*" %><%
try{

	// set the http content type to "APPLICATION/OCTET-STREAM
	//response.setContentType("APPLICATION/OCTET-STREAM");

	// initialize the http content-disposition header to
	// indicate a file attachment with the default filename
//	String disHeader = "Attachment;	Filename=\"List.csv\"";
//	response.setHeader("Content-Disposition", disHeader);

	
	EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();
	Node project = graphDb.getNodeById(2);

	Transaction tx = graphDb.beginTx();
	
	//Compute Control related info (D4-D0 ratios, Protein Averages)	
	for (Relationship idRel : project.getRelationships())
	{
		Node patient = idRel.getOtherNode(project);
		if (NodeHelper.getType(patient).equals("Patient"))
		{
			for (Relationship sampleRel : patient.getRelationships())
			{
				Node sample = sampleRel.getOtherNode(patient);
				if (NodeHelper.getType(sample).equals("Sample"))
				{
					double creatinine = 10; //Average;
					if(sample.hasProperty("Creatinine"))
						creatinine = NodeHelper.PropertyToDouble(sample.getProperty("Creatinine"));
					double ratioDesCD = 0;
					double ratioD4DesCD = 0;
					double ratioHpCD = 0;
					double ratioD4HpCD = 0;
					double ratioLpCD = 0;
					
					Node controlHP = null;					
					for (Relationship controlRel : sample.getRelationships())
					{
						Node tmpControl = controlRel.getOtherNode(sample);
						if (NodeHelper.getType(tmpControl).equals("Control"))
							controlHP = tmpControl;
					}

					Node controlCD = null;					
					for (Relationship controlRel : sample.getRelationships())
					{
						Node tmpControl = controlRel.getOtherNode(sample);
						if (NodeHelper.getType(tmpControl).equals("ControlCD"))
							controlCD = tmpControl;
					}
					
					for (Relationship formeRel : sample.getRelationships())
					{
						Node forme = formeRel.getOtherNode(sample);
						if (NodeHelper.getType(forme).equals("Libre") ||
							NodeHelper.getType(forme).equals("Total"))
						{
							if(controlCD != null)
							{
								if(NodeHelper.getType(forme).equals("Libre"))
								{
									ratioDesCD = NodeHelper.PropertyToDouble(controlCD.getProperty("DES Corr Libre"));
									ratioD4DesCD = NodeHelper.PropertyToDouble(controlCD.getProperty("D4-DES Libre"));
									ratioHpCD = NodeHelper.PropertyToDouble(controlCD.getProperty("HP Corr Libre"));
									ratioLpCD = NodeHelper.PropertyToDouble(controlCD.getProperty("LP Corr Libre"));
									ratioD4HpCD = NodeHelper.PropertyToDouble(controlCD.getProperty("D4-HP Libre"));
								}
								else
								{
									ratioDesCD = NodeHelper.PropertyToDouble(controlCD.getProperty("DES Corr Total"));
									ratioD4DesCD = NodeHelper.PropertyToDouble(controlCD.getProperty("D4-DES Total"));
									ratioHpCD = NodeHelper.PropertyToDouble(controlCD.getProperty("HP Corr Total"));
									ratioLpCD = NodeHelper.PropertyToDouble(controlCD.getProperty("LP Corr Total"));	
									ratioD4HpCD = NodeHelper.PropertyToDouble(controlCD.getProperty("D4-HP Total"));						
								}//*/
							}
							double desRatioCumul = 0;
							double hpRatioCumul = 0;
							double lpRatioCumul = 0;
							int nbRep = 0;
							for (Relationship repRel : forme.getRelationships())
							{
								//Merge back replicate information into Forme node
								Node replicate = repRel.getOtherNode(forme);
								if (NodeHelper.getType(replicate).equals("Replicate") &&
										replicate.hasProperty("Ratio DES") &&
										replicate.hasProperty("Ratio HP") &&
										replicate.hasProperty("Ratio LP"))
								{
									//For every replicates of forms, compute (DEScorr / DES_CD) / (D4Des / D4Des_CD)
									double cdDES = ratioDesCD / 100000.0; 
									double cdDESD4 = ratioD4DesCD / 100000.0;
									
									double cdHP = ratioHpCD / 3000000.0; 
									double cdLP = ratioHpCD / 600000.0;
									double cdHPD4 = ratioD4HpCD / 100000.0;

									//Corrected (normalized) ratio
									double desRatioTmp = NodeHelper.PropertyToDouble(replicate.getProperty("Ratio DES")) * (cdDESD4 / cdDES);
									double hpRatioTmp = NodeHelper.PropertyToDouble(replicate.getProperty("Ratio HP")) * (cdHPD4 / cdHP);
									double lpRatioTmp = NodeHelper.PropertyToDouble(replicate.getProperty("Ratio LP")) * (cdHPD4 / cdLP);
									//Simple ratio 
									/*
									double desRatioTmp = NodeHelper.PropertyToDouble(replicate.getProperty("Ratio DES"));
									double hpRatioTmp = NodeHelper.PropertyToDouble(replicate.getProperty("Ratio HP"));
									double lpRatioTmp = NodeHelper.PropertyToDouble(replicate.getProperty("Ratio LP"));//*/
									nbRep++;

									//=(Ratio DES - Somme(D4-DES Standard)) / aXPlusB
									//Standard 1 : y =  0.0609x - 0.065 ::> (y - 0.065)/0.0609 where y is Ratio DES
									double hpConcDes = ( desRatioTmp - 0.065) / 0.0609;
									forme.setProperty("Concentration DES", hpConcDes);
									
									//Standard 1 : y =  0.1042x + 0.1491 ::> (y - 0.1491)/0.1042 where y is Ratio DES
									double hpConcHp = ( hpRatioTmp - 0.1491) / 0.1042;
									double hpConcLp = ( lpRatioTmp - 0.1491) / 0.1042;
									forme.setProperty("Concentration HP", hpConcHp);
									forme.setProperty("Concentration LP", hpConcLp);
									
									double concDesCorr = (hpConcDes * 1000) / (creatinine * 113.12);
									double concHpCorr = (hpConcHp * 1000) / (creatinine * 113.12);
									double concLpCorr = (hpConcLp * 1000) / (creatinine * 113.12);
									forme.setProperty("Concentration DES corr", concDesCorr);
									forme.setProperty("Concentration HP corr", concHpCorr);
									forme.setProperty("Concentration LP corr", concLpCorr);
									
									desRatioCumul += concDesCorr;
									hpRatioCumul += concHpCorr;
									lpRatioCumul += concLpCorr;
								}
							}
							if(nbRep > 0)
							{
								forme.setProperty("Ratio DES", desRatioCumul / (double) nbRep);
								forme.setProperty("Ratio HP", hpRatioCumul / (double) nbRep);
								forme.setProperty("Ratio LP", lpRatioCumul / (double) nbRep);
								if(NodeHelper.getType(forme).equals("Libre"))
								{
									sample.setProperty("Ratio DES Libre", desRatioCumul / (double) nbRep);
									sample.setProperty("Ratio HP Libre", hpRatioCumul / (double) nbRep);
									sample.setProperty("Ratio LP Libre", lpRatioCumul / (double) nbRep);									
								}
								else
								{
									sample.setProperty("Ratio DES Total", desRatioCumul / (double) nbRep);
									sample.setProperty("Ratio HP Total", hpRatioCumul / (double) nbRep);
									sample.setProperty("Ratio LP Total", lpRatioCumul / (double) nbRep);
								}
							}
						}
					}					
					//Sample
				}
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