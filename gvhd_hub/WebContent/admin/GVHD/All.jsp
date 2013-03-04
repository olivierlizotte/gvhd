<%@page import="org.neo4j.graphdb.DynamicRelationshipType"%><%@page import="scala.util.parsing.json.JSONFormat"%><%@ page import="graphDB.explore.*" %><%@ page import ="org.neo4j.cypher.javacompat.ExecutionEngine" %><%@ page import ="org.neo4j.cypher.javacompat.ExecutionResult" %><%@ page import ="org.neo4j.graphdb.Direction" %><%@ page import ="org.neo4j.graphdb.GraphDatabaseService" %><%@ page import ="org.neo4j.graphdb.Node" %><%@ page import ="org.neo4j.graphdb.Relationship" %><%@ page import ="org.neo4j.graphdb.RelationshipType" %><%@ page import ="org.neo4j.graphdb.Transaction" %><%@ page import ="org.neo4j.graphdb.index.Index" %><%@ page import ="org.neo4j.kernel.AbstractGraphDatabase" %><%@ page import ="org.neo4j.kernel.EmbeddedGraphDatabase" %><%@page import="org.neo4j.cypher.javacompat.*"%><%@page import="java.util.*" %><%@ page import="java.util.List"%><%@ page import="java.util.Map"%><%@ page import="java.util.Map.Entry"%><%@ page import="java.text.*"%><%@ page import="java.io.*" %>
Populate Patients ... 				<%@include file="PopulatePatients.jsp"%><br/>
Populate Control (HP) ... 			<%@include file="PopulateControlHP.jsp"%><br/>
Populate Control (CD) ... 			<%@include file="PopulateControlCD.jsp"%><br/>
Link Patients to Control (HP) ... 	<%@include file="LinkPatientsToControls.jsp"%><br/>
Link Patients to Control (CD) ... 	<%@include file="LinkPatientsToControlCD.jsp"%><br/>
Compute Control (HP) ... 			<%@include file="ComputeInfoControls.jsp"%><br/>
Compute Control (CD) ... 			<%@include file="ComputeInfoControlCD.jsp"%><br/>
Compute Patients info (First Pass)  <%@include file="ComputeInfoPatients.jsp"%><br/>
Compute Patients info (Second Pass) <%@include file="ComputeInfoPatients2.jsp"%><br/>
Draw Charts for each Patient ...    <%@include file="ComputePatientsGraph.jsp"%><br/>
Draw overall graph for tendencies...<%@include file="ComputeOverallGraph.jsp"%><br/>
Draw all patients on same graph ... <%@include file="ComputePatientsOverallGraph.jsp"%><br/>
Draw overall tendency ...           <%@include file="ComputePatientsAverageGraph.jsp"%><br/>