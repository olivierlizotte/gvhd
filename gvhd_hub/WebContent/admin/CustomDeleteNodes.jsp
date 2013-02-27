<%@page import="org.neo4j.graphdb.Transaction"%>
<%@page import="graphDB.explore.DefaultTemplate"%>
<%@page import="org.neo4j.kernel.EmbeddedGraphDatabase"%>
<%@page import="org.neo4j.graphdb.Node"%>
<%@page import="graphDB.explore.NodeHelper"%>
<%@page import="org.neo4j.graphdb.Relationship"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>
<%
EmbeddedGraphDatabase graphDb = DefaultTemplate.graphDb();

//Node ResultHeadNode = graphDb.createNode();
//ResultHeadNode.setProperty("information", "Result of a database query");
try
{
	Transaction tx = graphDb.beginTx();
	Node tempNode = graphDb.getNodeById(1257146);
	for(Relationship rel : tempNode.getRelationships())
	{
		Node other = rel.getOtherNode(tempNode);
		if( NodeHelper.getType(other).equals("Protein Sequence"))
		{
			other.delete();
		}
		rel.delete();
	}
	tempNode.delete();
	tx.success();
	tx.finish();
	out.print("Done");	
}
catch(Exception e)
{
	e.printStackTrace();
}
finally
{
	//graphDb.shutdown();
}

%>
</body>
</html>