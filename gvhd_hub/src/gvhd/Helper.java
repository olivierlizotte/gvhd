package gvhd;

import graphDB.explore.NodeHelper;

import org.neo4j.graphdb.*;
import org.neo4j.kernel.EmbeddedGraphDatabase;

public class Helper {

	public static Node CreatePatient(EmbeddedGraphDatabase graphDb, Node project, String name)
	{
		RelationshipType newNodeRel = DynamicRelationshipType.withName("Link");
		Node patient = graphDb.createNode();
		project.createRelationshipTo(patient, newNodeRel);
		patient.setProperty("Name", name);
		patient.setProperty("type", "Patient");
		return patient;
	}
	
	public static Node CreateControlCD(EmbeddedGraphDatabase graphDb, Node project, String name)
	{
		RelationshipType newNodeRel = DynamicRelationshipType.withName("Link");
		Node control = graphDb.createNode();
		project.createRelationshipTo(control, newNodeRel);
		control.setProperty("Name", name);
		control.setProperty("type", "ControlCD");
		return control;
	}

	public static Node CreateControl(EmbeddedGraphDatabase graphDb, Node project, String name)
	{
		RelationshipType newNodeRel = DynamicRelationshipType.withName("Link");
		Node control = graphDb.createNode();
		project.createRelationshipTo(control, newNodeRel);
		control.setProperty("Name", name);
		if(NodeHelper.isNumeric(name))
			control.setProperty("Control", Double.parseDouble(name));
		else
			control.setProperty("Control", name);
		control.setProperty("type", "Control");
		return control;
	}
	
	public static Node CreateSample(EmbeddedGraphDatabase graphDb, Node patient, String moment, String date, String creatinine, String comment)
	{
		RelationshipType newNodeRel = DynamicRelationshipType.withName("Link");
		Node sample = graphDb.createNode();
		patient.createRelationshipTo(sample, newNodeRel);

		sample.setProperty("type", "Sample");
		if(!moment.isEmpty())
			sample.setProperty("Moment", moment);
		if(!date.isEmpty())
			sample.setProperty("Date", date);
		if(!creatinine.isEmpty())
			sample.setProperty("Creatinine", Double.parseDouble(creatinine));
		if(!comment.isEmpty())
			sample.setProperty("Comment", comment);
		return sample;
	}
	
	public static Node CreateControlDuplicate(EmbeddedGraphDatabase graphDb, Node patient)
	{
		RelationshipType newNodeRel = DynamicRelationshipType.withName("Link");
		Node sample = graphDb.createNode();
		patient.createRelationshipTo(sample, newNodeRel);

		sample.setProperty("type", "ControlDuplicate");
		return sample;
	}
}
