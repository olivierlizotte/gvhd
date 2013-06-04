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
		Node controlCD = idRel.getOtherNode(project);
		if (NodeHelper.getType(controlCD).equals("ControlCD"))
		{
			double ratioDes = 0;
			double ratioHp = 0;
			Node control = null;
			
			for (Relationship controlRel : controlCD.getRelationships())
			{
				Node tmpControl = controlRel.getOtherNode(controlCD);
				if (NodeHelper.getType(tmpControl).equals("Control"))
					control = tmpControl;
			}
			
			for (Relationship formeRel : controlCD.getRelationships())
			{
				Node forme = formeRel.getOtherNode(controlCD);
				if (NodeHelper.getType(forme).equals("Libre") ||
					NodeHelper.getType(forme).equals("Total"))
				{
					if(control != null)
					{
						if(NodeHelper.getType(forme).equals("Libre"))
						{
							ratioDes = NodeHelper.PropertyToDouble(control.getProperty("Ratio DES Libre"));
							ratioHp = NodeHelper.PropertyToDouble(control.getProperty("Ratio HP Libre"));
						}
						else									
						{
							ratioDes = NodeHelper.PropertyToDouble(control.getProperty("Ratio DES Total"));
							ratioHp = NodeHelper.PropertyToDouble(control.getProperty("Ratio HP Total"));									
						}
					}
					double masse = 100;
					if(forme.hasProperty("Masse (mg)"))
						masse = NodeHelper.PropertyToDouble(forme.getProperty("Masse (mg)"));
					
					double desCorr = 0;
					double hpCorr = 0;
					double lpCorr = 0;
					
					double d4Des = 0;
					int nbD4Des = 0;
					double des = 0;
					int nbDes = 0;
					double d4Hp = 0;
					int nbD4Hp = 0;
					double hp = 0;
					int nbHp = 0;
					double lp = 0;
					int nbLp = 0;
					for (Relationship repRel : forme.getRelationships())
					{
						//Merge back replicate information into Forme node
						Node replicate = repRel.getOtherNode(forme);
						if (NodeHelper.getType(replicate).equals("Replicate"))
						{
							double desTmp = 0;
							double hpTmp = 0;
							double lpTmp = 0;
							if(replicate.hasProperty("DES"))
							{
								double tmp = NodeHelper.PropertyToDouble(replicate.getProperty("DES"));
								if(!Double.isNaN(tmp))// && tmp > 0)
								{
									des += tmp;
									nbDes++;
									desCorr += 100 * (tmp / masse);
									desTmp = 100 * (tmp / masse);
								}
							}
							if(replicate.hasProperty("D4-DES"))
							{
								double tmp = NodeHelper.PropertyToDouble(replicate.getProperty("D4-DES"));
								if(!Double.isNaN(tmp) && tmp > 0)
								{
									d4Des += tmp;
									nbD4Des++;
									desCorr -= tmp*ratioDes;
									replicate.setProperty("DES Corr", desTmp - tmp*ratioDes );
								}
							}
							if(replicate.hasProperty("HP"))
							{
								double tmp = NodeHelper.PropertyToDouble(replicate.getProperty("HP"));
								if(!Double.isNaN(tmp) && tmp > 0)
								{
									hp += tmp;
									nbHp++;
									hpCorr += 100 * (tmp / masse);
									hpTmp = 100 * (tmp / masse);
								}
							}
							if(replicate.hasProperty("LP"))
							{
								double tmp = NodeHelper.PropertyToDouble(replicate.getProperty("LP"));
								if(!Double.isNaN(tmp) && tmp > 0)
								{
									lp += tmp;
									nbLp++;
									lpCorr += 100 * (tmp / masse);
									lpTmp = 100 * (tmp / masse);
								}
							}
							if(replicate.hasProperty("D4-HP"))
							{
								double tmp = NodeHelper.PropertyToDouble(replicate.getProperty("D4-HP"));
								if(!Double.isNaN(tmp) && tmp > 0)
								{
									d4Hp += tmp;
									nbD4Hp++;
									hpCorr -= tmp*ratioHp;
									lpCorr -= tmp*ratioHp;
									replicate.setProperty("HP Corr", hpTmp - tmp*ratioHp );
									replicate.setProperty("LP Corr", lpTmp - tmp*ratioHp );
								}
							}
							//Replicate
						}
					}
					
					if(nbD4Des > 0)
						forme.setProperty("D4-DES", d4Des / nbD4Des);
					if(nbDes > 0)
						forme.setProperty("DES", des / nbDes);
					if(nbD4Hp > 0)
						forme.setProperty("D4-HP", d4Hp / nbD4Hp);
					if(nbHp > 0)
						forme.setProperty("HP", hp / nbHp);
					if(nbLp > 0)
						forme.setProperty("LP", lp / nbLp);
					
					if(nbDes > 0)
						forme.setProperty("DES Corr", desCorr / nbDes);
					if(nbHp > 0)
						forme.setProperty("HP Corr", hpCorr / nbHp);
					if(nbLp > 0)
						forme.setProperty("LP Corr", lpCorr / nbLp);
					
					//Forme (Libre ou Total)
					if(NodeHelper.getType(forme).equals("Libre"))
					{
						if(nbD4Des > 0)
							controlCD.setProperty("D4-DES Libre", d4Des / nbD4Des);
						if(nbD4Hp > 0)
							controlCD.setProperty("D4-HP Libre", d4Hp / nbD4Hp);
						if(nbDes > 0)
							controlCD.setProperty("DES Corr Libre", desCorr / nbDes);
						if(nbHp > 0)
							controlCD.setProperty("HP Corr Libre", hpCorr / nbHp);
						if(nbLp > 0)
							controlCD.setProperty("LP Corr Libre", lpCorr / nbLp);
					}
					else
					{
						if(nbD4Des > 0)
							controlCD.setProperty("D4-DES Total", d4Des / nbD4Des);
						if(nbD4Hp > 0)
							controlCD.setProperty("D4-HP Total", d4Hp / nbD4Hp);
						if(nbDes > 0)
							controlCD.setProperty("DES Corr Total", desCorr / nbDes);
						if(nbHp > 0)
							controlCD.setProperty("HP Corr Total", hpCorr / nbHp);
						if(nbLp > 0)
							controlCD.setProperty("LP Corr Total", lpCorr / nbLp);	
					}						
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