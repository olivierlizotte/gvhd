
<%@ page import="graphDB.explore.*" %>
<%@ page import="graphDB.explore.users.*" %>

<%
try{
	//Add 'dev' user
//	Login.addUser("Dev Sriranganadane","dev", "test");
	//Add Ref Database
//	XmlToDb.RUN("/u/caronlo/apps/RefBD.clusterML", "dev");
	//XmlToDb.RUN("C:\\_IRIC\\DATA\\M&R\\Newestest\\BDRef_WithReverse5b.clusterML", "dev");
	//Add M database
	//XmlToDb.RUN("C:\\_IRIC\\DATA\\M&R\\Newestest\\translatedM_WithReverse5b.clusterML", "dev");
	//XmlToDb.RUN("/u/caronlo/apps/MBD.clusterML", "dev");
	//Add R database
	//XmlToDb.RUN("C:\\_IRIC\\DATA\\M&R\\Newestest\\translatedR_WithReverse5b.clusterML", "dev");
	//XmlToDb.RUN("/u/caronlo/apps/RBD.clusterML", "dev");
	//Add R database
//	XmlToDb.RUN("C:\\_IRIC\\DATA\\M&R\\UltraNew\\MnR_Result.clusterML", "dev");
	//XmlToDb.RUN("C:\\_IRIC\\DATA\\MnR\\Project 891\\MnR_Output.clusterML", "dev");
	//XmlToDb.RUN("/u/caronlo/apps/MnR_Result.clusterML", "dev");
	//XmlToDb.RUN("G:\\Thibault\\-=Proteomics_Raw_Data=-\\VELOS\\OCT06_2010\\_NEW\\01July2012\\MandR_RefOnly.clusterML","dev");
	//XmlToDb.RUN("G:\\Thibault\\Olivier\\ForAntoine\\MandR.clusterML","dev");///u/caronlo/MandR.clusterML","dev");
	
	out.println("Adding User:");
	Login.addUser("Dev Sriranganadane","dev", "test");
	out.println("Adding Databases:");
	out.println("EBV...");
	XmlToDb.RUN("G:\\Thibault\\Olivier\\MnR\\2013\\Virus_EBV_WithReverse.clusterML", "dev");//ref
	out.println("Ref...");
	XmlToDb.RUN("G:\\Thibault\\Olivier\\MnR\\2013\\Ref_WithReverse.clusterML", "dev");//ref
	out.println("R...");
	XmlToDb.RUN("G:\\Thibault\\Olivier\\MnR\\2013\\R_2013_02_07b_WithReverse.clusterML", "dev");//ref
	out.println("M...");
	XmlToDb.RUN("G:\\Thibault\\Olivier\\MnR\\2013\\M_2013_02_07b_WithReverse.clusterML", "dev");//ref
	
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
	
	out.println("Done!");
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
