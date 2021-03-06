<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Peptide Immuno Graph</title>

<!-- CSS Files -->
<link type="text/css" href="css/msg.css" rel="stylesheet" />
<link type="text/css" href="css/nv.d3.css" rel="stylesheet">

<!-- JavaScript -->
<script type="text/javascript" src="js/jquery-1.7.2.min.js"></script>

<!-- Ext JS Library file -->
<script type="text/javascript" src="js/ExtJS/bootstrap.js"></script>
<link rel="stylesheet" type="text/css" href="js/ExtJS/resources/css/ext-all.css" />

    <script type="text/javascript" src="js/d3/d3.v2.js" charset="utf-8"></script>
    <!-- script type="text/javascript" src="js/d3/d3.geom.js"></script-->
    <!--  script type="text/javascript" src="js/d3/d3.layout.js"></script -->    
	<script type="text/javascript" src="js/d3/nv.d3_forkarlm.js"></script>
	<script type="text/javascript" src="js/jquery.tipsy.js"></script>
    <link href="css/tipsy.css" rel="stylesheet" type="text/css" />
    
	<script type="text/javascript" src="js/graph.js"></script>

</head>

<script type="text/javascript">

var graphItemNumber=0;

Ext.Loader.setConfig({
    enabled: true
});

<%@include file="getInfo.jsp"%>

<%@include file="createGrid.jsp"%>
var charts=[];
<%@include file="drawCharts.jsp"%>
if (charts.length > 0){
	graphItemNumber=1;
}


MessageTop = function(){
    var msgCt;

    function createBox(t, s)
    {
       return '<div class="msg" style="position:absolute;"><h3>' + t + '</h3><p>' + s + '</p></div>';
    };
    
    return {
        msg : function(title, format){
            if(!msgCt){
                msgCt = Ext.DomHelper.insertFirst(document.body, {id:'msg-div'}, true);
            }
            var s = Ext.String.format.apply(String, Array.prototype.slice.call(arguments, 1));
            var m = Ext.DomHelper.append(msgCt, createBox(title, s), true);
            m.hide();
            m.slideIn('t').ghost("t", { delay: 1000, remove: true});
        },

        init : function(){
        }
    };
}();

function columnDesc(val) {
        return '<div style="overflow: auto !important; white-space: normal !important;">'+val+'</div>';
        return val;
}  

function showHelp (){
	var plotWin = Ext.create('Ext.Window', {
	    title: 'Database structure',
	    width: 400,
	    height: 650,
//	    x: 10,
//	    y: 200,
	    plain: true,
	    headerPosition: 'top',
	    layout: 'fit',
	    items: {
	        xtype: 'image',
	        src: "icons/network.png"
	    }
	});
	plotWin.show();
}

var navigate = function(panel, direction){
    // This routine could contain business logic required to manage the navigation steps.
    // It would call setActiveItem as needed, manage navigation button state, handle any
    // branching logic that might be required, handle alternate actions like cancellation
    // or finalization, etc.  A complete wizard implementation could get pretty
    // sophisticated depending on the complexity required, and should probably be
    // done as a subclass of CardLayout in a real-world implementation.
    var layout = panel.getLayout();
    layout[direction]();
    Ext.getCmp('move-prev').setDisabled(!layout.getPrev());
    Ext.getCmp('move-next').setDisabled(!layout.getNext());
    if (direction=='next'){
    	graphItemNumber+=1;
    	document.getElementById('graphItemNumber').innerHTML='page:'+graphItemNumber+'/'+charts.length;
    }else{
    	graphItemNumber-=1;
    	document.getElementById('graphItemNumber').innerHTML='page:'+graphItemNumber+'/'+charts.length;
    }
};

var viewport;
var commentGrid;
var nodeStoreComment;

function CreateComments(myComments)
{	
	if(!commentGrid)
	{
		Ext.define('ncModel', {
		    extend: 'Ext.data.Model',
		    fields: [{name : "comment", type :'string'}]
		});
		
	    nodeStoreComment = Ext.create('Ext.data.Store', {
	        storeId: 'nodeCommentStoreID',
	        model: 'ncModel',
	        data: myComments
	    });
	    
	    commentGrid = Ext.create('Ext.container.Container', {
	        title: 'Comments',
	        //height: 240,
	        layout: {
	            type: 'vbox',      
	            align: 'stretch'    
	        },
        	border: false,
            //bodyPadding: 0,
	        items: [{             
	            xtype: 'grid',
	            hideHeaders: true,
	            border: true,
	            columns: [{text:'Comments', flex:1, dataIndex:'comment', renderer: columnDesc}],
	            store: nodeStoreComment, 
	            flex: 1                                      
                //layout: 'fit'
	        	},
	        	//{tag:'hr'},
	            {
	                xtype     : 'textareafield',
	                name      : 'newCommentField',
	                emptyText : "Add comment...",
	                //height : 80,
	                maxHeight:40,
	                //flex: 1,
	                //bodyPadding: 0,
	                //padding : 0,
	                margins: '5 0 -5 0',
	                enableKeyEvents: true,
	                listeners: {
	                	keypress: function(field,event)
	                    {	
	                		var theCode = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
	                		if (theCode == 13)//If enter was pressed
	                		{
	                    		AddComment(field, event);
	                    		field.reset();
	                    		event.stopEvent();
	                		}
	                    	else
	                    		if(theCode == 32)//space bar, trap it
	                    			return false;
	                    		else
	                    			return true;
	                    }
	                }
	            }
	        ]
	    });
	}
	else
		nodeStoreComment.loadData(myComments);
    
    return commentGrid;
}

function replaceAll(txt, replace, with_this)
{
	return txt.replace(new RegExp(replace, 'g'), with_this);
}

function AddComment(field, event) 
{
	//Send new comment to a jsp file that will add the comment and return the new list of comments		
	var texte = field.getValue();
	if(!(texte === ""))
	{
		texte = replaceAll(texte,"\f",   "<br/>");
		texte = replaceAll(texte,"\r",   "<br/>");
		texte = replaceAll(texte,"\n",   "<br/>");
		texte = replaceAll(texte,"&",    "&amp;");
		texte = replaceAll(texte,"\"",   "&quot;");
		texte = replaceAll(texte,"/\\/", "&brvbar;");
		texte = replaceAll(texte,"'",    "&apos;")
		texte = replaceAll(texte,"<",    "&lt;")
		texte = replaceAll(texte,">",    "&gt;")
 		
		$.post(	"addComment.jsp",
				{"id":currentNodeID,"user":<%=session.getAttribute("userNodeID")%>, "comment": texte}, 
				function(results)
				{				 	
			 		CreateComments( eval(results) );
			 		MessageTop.msg("Comment added", texte);
				});
	}
	return false; 
}   

function AddAttribute(btn, text)
{
	myAttributeObject[text] = "";
	attribPanel.setSource(myAttributeObject);
	MessageTop.msg('Button Click', 'You clicked the {0} button and entered the text "{1}".', btn, text);
};

function AddNode(btn, text)
{
   	Ext.Ajax.request({
 				url   : "AddNode.jsp?id=" + currentNodeID,
 				type  : 'POST',
 				//data  : myAttributeObject,
 				params: {type: text},
	      		success: function(result) {
	      			MessageTop.msg("Success!", "Node Created");
	      			window.location = "index.jsp?id=" + result.responseText;
	     		}
	    	});
};

function showTools(){
var toolWin = new Ext.create(
		'Ext.Window',
		{
			id : 'autoload-win',
			title : currentNodeType
					+ ' Tools',
			closable : true,
			autoScroll:true,
			width : 400,
			height : 200,
//			x : 10,
//			y : 200,
			plain : true,
			loader : {
				url : "tools.jsp?name=seq&id="+currentNodeID,
				scripts : true,
				autoLoad : true,
				renderer : 'html'
			},
			layout : 'fit',
		//items: attributeForm,
		});
toolWin.show();
}
var attribPanel;

function CreateAttributes(attribs)
{
	if(!attribPanel)
	{
		attribPanel = Ext.create('Ext.grid.property.Grid', {        
	    	border: true,
	        hideHeaders : true,
	        listeners://Add listener to adjust column width of first column
	        {
	        	render: function(grid)
	        	{
	        		grid.columns[0].width = 200;//().setColumnWidth(0, 200);
	        	}
	        },
	        editable:true,
	        /*plugins: [
	              Ext.create('Ext.grid.plugin.RowEditing', {
	               	  clicksToEdit: 1
	               	  /*listeners:{afteredit:
	               			//scope:this,
	               			//afteredit: 
	               				function(roweditor, changes, record, rowIndex) 
	               			{
	               		    	//your save logic here - might look something like this:
	               		    	Ext.Ajax.request({
	               		      		url   : record.phantom ? '/users' : '/users/' + record.get('user_id'),
	               		      		method: record.phantom ? 'POST'   : 'PUT',
	               		      		params: changes,
	               		      		success: function() {
	               				        //post-processing here - this might include reloading the grid if there are calculated fields
	               		     		}
	               		    	});
	               				MessageTop.msg("Attribute edited", "Congratulations");
	               			}
	               	  }
	                 })
	                ],//*/
		   	bbar: [
		   	{	   		
		   		text : 'Add attribute',
	            iconCls: 'icon-plus',
		   		//text   : '<table><tr><td align="center"><img src="icons/plus.png" height="20px"></td>'+
				//'<td align="center">&nbsp Add attribute </td></tr></table>',
		   	    handler: function() 
		   	    {
		   	    	Ext.MessageBox.prompt('New Attribute', 'Please enter the name for the new attribute:', AddAttribute);
		   	    }
		   	},
		   	{	   		
		   		text   : 'Save',
		   		iconCls: 'icon-save',
		   	    handler: function() 
		   	    {
		   	    	Ext.Ajax.request({
   		      				url   : "EditAttribute.jsp?id=" + currentNodeID,
   		      				type  : 'POST',
   		      				//data  : myAttributeObject,
   		      				params: {json: Ext.encode(myAttributeObject)},
           		      		success: function(result) {
//           		      			myAttributeObject = eval(result.responseText);
           		      			attribPanel.setSource(myAttributeObject);           
           		      			MessageTop.msg("Success!", "Attributes saved");
           		     		}
           		    	});
		   	    }
		   	},
		   	{	   		
		   		text   : 'Tools',
		   		iconCls: 'icon-tools',
		   	    handler: function() 
		   	    {
		   	    	showTools();
		   	    }
		   	},
		   	{	   		
		   		text : 'Insert Node',
	            iconCls: 'icon-plus',
		   		//text   : '<table><tr><td align="center"><img src="icons/plus.png" height="20px"></td>'+
				//'<td align="center">&nbsp Add attribute </td></tr></table>',
		   	    handler: function() 
		   	    {
		   	    	Ext.MessageBox.prompt('Insert Node', 'Please enter the type for the new outgoing node:', AddNode);
		   	    }
		   	}],
	        source: attribs
	    });
	}
	return attribPanel;
}

function ShowChartsForm()
{
	 var win = new Ext.create('Ext.window.Window',{//Window({
	        layout:'fit',
	        height: 300,
            width: 300,
	        closable: true,
	        resizable: true,
	        autoScroll:true,
	        id:'tool-win',
//	        plain: true,
	        title:'Tools',
//	        border: false,	        
	        modal:'true',
	        //items: [login]
	        loader:{url:"tools.jsp?name=charts&id="+currentNodeID, scripts:true, autoLoad:true, renderer:'html'}
		});
	 	//win.load({url:"http://slashdot.org", scripts:true, autoLoad:true, renderer:'html'});
		win.center();
		win.show();
	/*
	var msgContent = 'Which chart do you want to draw?<br><br>';
	msgContent += '<form name="chartsForm"> <input type="checkbox" name="lengthDistribution"/> Peptides length distribution<br>';
	msgContent += '<input type="checkbox" name="volcanoplot"/> Volcano plot<br>';
	Ext.Msg.show({
		width:300,
		title: 'Charts form',
		msg: msgContent,
		buttons: Ext.Msg.OKCANCEL,
		fn: function(btn){
			if (btn=='ok'){
				if (document.chartsForm.lengthDistribution.value == 'on'){
					//get information from DB and draw peptides length graph
					fetchPeptidesLength(drawPeptidesLength);
				}
			}
		}
	});//*/
}	 	 

function CreateViewport()
{
	return Ext.create('Ext.container.Viewport', {
	id: 'MainContainer',
    layout: {
        align: 'stretch',
        type: 'vbox'
    },
	border: false,
    renderTo: Ext.getBody(),
    items: [    {
                    xtype: 'panel',
                    layout: {
                        align: 'stretch',
                        type: 'hbox'
                    },
                    margins: '0 0 0 0',
                    collapseDirection: 'top',
                    collapsible: true,
                    frameHeader: false,
                    hideCollapseTool: false,
                    preventHeader: false,
                	border: false,
                    title: 'Immuno Graph :: ' + browserHistory,
                    flex: 1,
                    items: [
                        {
                        	id: 'navigationPanel',
                            xtype: 'panel',
                            minHeight: 100,
                            minWidth: 100,
                            layout: 'fit',
                            collapseDirection: 'left',
                            collapsible: true,
                        	border: false,
                            title: '<span style="cursor:help" title="Navigation" onclick=showHelp()>Navigation</span>',
                            iconCls:'icon-help',
                            /*{
                		   		text : 'Navigation',
                	            iconCls: 'icon-help',
                		   		//text   : '<table><tr><td align="center"><img src="icons/plus.png" height="20px"></td>'+
                				//'<td align="center">&nbsp Add attribute </td></tr></table>',
                		   	    handler: function() 
                		   	    {
                		   	    	showHelp();
                		   	    }},
                            	
                            	   //'Navigation',//<table><tr><td align="center">Navigation</td><td align="center"><button type="button" style="background:none;border:none" onclick="showHelp()">'+
                            	   //'<img src="icons/help.png" height="11px"></button></td>'+
            					   //'</tr></table>',//*/
                            floatable: false,
                            margins: '0 0 0 0',
                            flex: 0.4,
                            items:
                            [{
                                xtype: 'panel',  
                                minHeight: 100,
                                minWidth: 100,
                                layout: 'fit',       
                            	border: true,
                                preventHeader: true,
                                listeners: {'resize': function () { ResizeNavPanel(); } },
                                id: 'idNavigation',
                            	html: "<div id='navigationID'></div>"
                            	//autoEl: {tag: 'div', id:'navigationID'}
                            	/*loader: 
                            	{
	                                url: 'createNav.jsp?id='+currentNodeID,
                                	contentType: 'html',
                                	autoLoad: true,
                                	scripts: true,
                                	loadMask: true
                            	},//*/
                            }]
                        },
                        {
                            xtype: 'splitter'
                        },
                        {
                            xtype: 'container',
                            layout: {
                                align: 'stretch',
                                type: 'vbox'
                            },
                            margins: '0 0 0 0',
                            flex: 1,
                        	border: false,
                            items: [
                                {
                                    xtype: 'container',
                                    //height: 200,
                                    layout: {
                                        align: 'stretch',
                                        type: 'hbox'
                                    },
                                	border: false,
                                    margins: '0 0 0 0',
                                    flex: 1,
                                    items: [
                                        {
                                            xtype: 'panel',
                                            title: 'Attributes [' + currentNodeType + ']',
                                            margins: '0 0 0 0',
                                            flex: 1.5,
                                            layout: 'fit',
                                        	border: false,
                                            id : 'idAttributes',
                                            items: [CreateAttributes(myAttributeObject)]
                                        },
                                        {
                                            xtype: 'splitter'
                                        },
                                        {
                                            xtype: 'panel',//panel',
                                            collapseDirection: 'right',
                                            collapsible: true,
                                            title: 'Comments',
                                        	border: false,
                                            margins: '0 0 0 0',
                                            flex: 1,
                                            id: 'idComments',
                                            layout: 'fit',
                                            items: [CreateComments(myCommentData)]
                                        }//*/
                                    ]
                                },
                                {
                                    xtype: 'splitter'
                                },
                                {
                                    xtype: 'panel',
                                    layout: 'card',
                                    collapseDirection: 'bottom',
                                    collapsible: true,
                                    margins: '0 0 0 0',
                                    flex: 1,
                                    id: 'idGraphs',                                                               
                                    border: false,
                                    preventHeader: true,
                                    bbar:[
                                          {
                                              id: 'idShowChartsForm',
                                              iconCls: 'icon-barchart',
                                              text: 'Charts',
                                              handler: function(btn) {
                                            	  ShowChartsForm();                                              
                                                  //navigate(btn.up("panel"), "prev");
                                              }
                                              //disabled: true
                                          },
                                          {
                                              text: 'Save Chart',
                                              handler: function() {
                                                  Ext.MessageBox.confirm('Confirm Download', 'Would you like to download the chart as an image?', function(choice){
                                                      if(choice == 'yes'){
                                                          charts[graphItemNumber-1].save({
                                                              type: 'image/png'
                                                          });
                                                      }
                                                  });
                                              }
                                          },
                                          '->', // greedy spacer so that the buttons are aligned to each side
                                          {
                                       	   xtype:'text',
                                       	   text:graphItemNumber+'/'+charts.length, 
                                       	   id:'graphItemNumber'
                                          },
                                          '->', // greedy spacer so that the buttons are aligned to each side

                                          {
                                        	  id: 'move-prev',
                                        	  text: 'Back',
                                        	  handler: function(btn) {
                                            	  navigate(btn.up("panel"), "prev");
                                        	  },
                                    	      disabled: true
                                    	  },
                                          {
                                              id: 'move-next',
                                              text: 'Next',
                                              disabled: (charts.length > 1? false: true),
                                              handler: function(btn) {
                                                  navigate(btn.up("panel"), "next");
                                              }
                                          }
                                          ],
                                    /*bbar: [
                                           {
                                               id: 'move-prev',
                                               text: 'Back',
                                               handler: function(btn) {
                                                   navigate(btn.up("panel"), "prev");
                                               },
                                               disabled: true
                                           },
                                           '->',
                                           {
                                        	   xtype:'text',
                                        	   text:graphItemNumber+'/'+charts.length, 
                                        	   id:'graphItemNumber'
                                           },
                                           '->', // greedy spacer so that the buttons are aligned to each side
                                           {
                                               id: 'move-next',
                                               text: 'Next',
                                               disabled: (charts.length > 1? false: true),
                                               handler: function(btn) {
                                                   navigate(btn.up("panel"), "next");
                                               }
                                           }
                                       ],//*/
                                    items: charts
                                }
                            ]
                        }
                    ]
                },
                {
                    xtype: 'splitter'
                },
                {
                    xtype: 'container',
                    animCollapse: false,
                    collapsed: false,
                    //collapsible: false,
                    //collapseDirection: 'top',
                    title: 'List',
                	border: false,
                    loadMask: true,
                    margins: '0 0 0 0',
                    flex: 1,
                    layout: {
                        align: 'stretch',
                        type: 'hbox'
                    },
                    id: 'idGrid',
                    items: Grid
                }
            ]
        });
}
//dynamicPanel = new Ext.Component({
//    loader: {
//       url: 'url_containing_scripts.htm',
//       renderer: 'html',
//       autoLoad: true,
//       scripts: true
//       }
//    });
//Ext.getCmp('specific_panel_id').add(dynamicPanel);  

// This is assuming that the TabPanel is defined as a global variable 'myTabPanel'
function setActiveTabByTitle( tabTitle ) 
{
	var tabPane = Ext.getCmp('tabPanelGrid');
	for(tab in tabPane.items.items)
		if(tabPane.items.items[tab].title == tabTitle)
			tabPane.setActiveTab( Number(tab) );
	//var tabs = tabPane.find( 'title', tabTitle );
	//tabPane.setActiveTab( tabs[ 0 ] );
}

function OnNodeClick(node)
{
	if(node && node.type)//.relationIndex >= 0)
	{
		setActiveTabByTitle( node.type );
        //Ext.getCmp('tabPanelGrid').setActiveTab(node.relationIndex);
	
		MessageTop.msg("Node clicked", node.name + "<br> Showing relation " + node.relation);
	}
}

Ext.onReady(function() {
	viewport = CreateViewport();
	
	CreateGraph(dataObject, "navigationID", OnNodeClick);
});


</script>


<body>

</body>

</html>
