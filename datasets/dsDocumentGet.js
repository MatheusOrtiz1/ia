function defineStructure() {
}

function onSync(lastSyncDate) {
}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
    var documentId = 0;
    var documentVersion = '1000';
    
  	if (constraints != null){
		for (var nIdx = 0; nIdx < constraints.length; nIdx++){
			if (constraints[nIdx].fieldName.toUpperCase() == "DOCUMENTID"){
				documentId = constraints[nIdx].initialValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "DOCUMENTVERSION"){
				documentVersion = constraints[nIdx].initialValue;
			}
    	}
   	}

    dataset.addColumn("documentId");
    dataset.addColumn("documentVersion");
    dataset.addColumn("documentDescription");
    dataset.addColumn("documentType");
    dataset.addColumn("documentBase64Byte");
    dataset.addColumn("documentDownloadURL");
    
    if (documentId != "" && documentVersion != "") {
        var loginAdm = "integrator"; 
        var senhaAdm = "super";
        
    	var ECMDocumentServiceProvider = ServiceManager.getServiceInstance("ECMDocumentService");
    	var ECMDocumentServiceLocator = ECMDocumentServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.ECMDocumentServiceService");
    	var documentService = ECMDocumentServiceLocator.getDocumentServicePort();

    	var documentResults = documentService.getDocumentVersion(
    	    loginAdm,
    	    senhaAdm,
    	    1,
    	    documentId,
    	    documentVersion,
    	    getValue("WKUser")
        );         
    	
    	var documentByteArray = documentService.getDocumentContent(
    	    loginAdm,
    	    senhaAdm,
    	    1,
    	    documentId,
    	    getValue("WKUser"),
    	    documentVersion,
    	    ""
    	);
    	
		var oDocument = documentResults.getItem().get(0);
        var documentBase64Byte = javax.xml.bind.DatatypeConverter.printBase64Binary(documentByteArray);
		var documentDownloadURL = "http://fluig.conasa.com:8072"   
								  + "/webdesk/webdownload?documentId=" + oDocument.documentId 
								  + "&version=" + oDocument.version 
								  + "&tenantId=1" 
		
    	dataset.addRow([
    		oDocument.documentId, 
    		oDocument.version, 
    		oDocument.documentDescription, 
    		oDocument.documentTypeId, 
    		documentBase64Byte, 
    		documentDownloadURL]
    	);
    }
    
    return dataset;
}

function onMobileSync(user) {
}
