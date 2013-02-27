<%@ page import="graphDB.explore.users.*" %>
<%@ page import="graphDB.explore.*" %>

<%
try{
	//XmlToDb.RUN("G:\\Thibault\\-=Proteomics_Raw_Data=-\\ELITE\\JUN27_2012\\MR 4Rep DS\\Proteoprofile HGR DB all Mascot score\\PigInfo.clusterML", "dev");
/*	Login.addUser("Dev Sriranganadane","dev", "test");
	
	XmlToDb.RUN("G:\\Thibault\\Olivier\\MnR\\Databases\\Ref_WithReverse.clusterML", "dev");//ref
	XmlToDb.RUN("G:\\Thibault\\Olivier\\MnR\\Databases\\Virus_EBV_WithReverse.clusterML", "dev");//ebv virus
	XmlToDb.RUN("G:\\Thibault\\Olivier\\MnR\\Databases\\M_WithReverse.clusterML", "dev");//M
	XmlToDb.RUN("G:\\Thibault\\Olivier\\MnR\\Databases\\R_WithReverse.clusterML", "dev");//R
	//*/
/*    out.println("Adding cluster info to DB");
	XmlToDb.RUN("G:\\Thibault\\-=Proteomics_Raw_Data=-\\ELITE\\JUN27_2012\\ProteoProfile MR plus EBV - 5ppm\\Clustering 5ppm 1min 1fr b\\PigInfo.clusterML", "dev");//Clustering result
	out.println("Database added... now matching peptides to protein sequences");
	//*/
/*	out.println("Added the new database... Matching Peptide sequences with available proteomes...");
	PeptideSequence.MatchAllSequences();
	out.println("Sequences matched... Adding precursor and Fragment errors");
	//*/
	//Server side
	/*
	out.println("Adding User:");
	Login.addUser("Dev Sriranganadane","dev", "test");
	out.println("Adding Databases:");
	out.println("EBV...");
	XmlToDb.RUN("/apps/Files/Virus_EBV_WithReverse.clusterML", "dev");//ref
	out.println("Ref...");
	XmlToDb.RUN("/apps/Files/Ref_WithReverse.clusterML", "dev");//ref
	out.println("R...");
	XmlToDb.RUN("/apps/Files/R_2013_02_07b_WithReverse.clusterML", "dev");//ref
	out.println("M...");
	XmlToDb.RUN("/apps/Files/M_2013_02_07b_WithReverse.clusterML", "dev");//ref//*/
	out.println("Adding Clustering results...");
	XmlToDb.RUN("/apps/Files/PigInfo.clusterML", "dev");//ref
%>	
	<jsp:include page="AddPrecursorError.jsp"/>
	<jsp:include page="AddFragmentError.jsp"/>
<%//*/
	out.println("Matching all peptide sequences...");
	PeptideSequence.MatchAllSequences();
	out.println("Done!");
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
