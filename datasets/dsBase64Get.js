function defineStructure() {
}

function onSync(lastSyncDate) {
}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
    var documentId = 0;
    var documentVersion = '1000';
    var documentDescription = '';
    
  	if (constraints != null){
		for (var nIdx = 0; nIdx < constraints.length; nIdx++){
			if (constraints[nIdx].fieldName.toUpperCase() == "DOCUMENTID"){
				documentId = constraints[nIdx].initialValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "DOCUMENTVERSION"){
				documentVersion = constraints[nIdx].initialValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "DOCUMENTDESCRIPTION"){
				documentDescription = constraints[nIdx].initialValue;
			}
    	}
   	}

    dataset.addColumn("documentId");
    dataset.addColumn("documentVersion");
    dataset.addColumn("documentDescription");
    dataset.addColumn("documentBase64");
    
    var loginAdm = "integrator"; 
    var senhaAdm = "super";
    
	var ECMDocumentServiceProvider = ServiceManager.getServiceInstance("ECMDocumentService");
	var ECMDocumentServiceLocator = ECMDocumentServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.ECMDocumentServiceService");
	var documentService = ECMDocumentServiceLocator.getDocumentServicePort();
	
	var documentByteArray = documentService.getDocumentContent(
	    loginAdm,
	    senhaAdm,
	    1,
	    documentId,
	    getValue("WKUser"),
	    documentVersion,
	    documentDescription
	);
	
    var documentBase64String = javax.xml.bind.DatatypeConverter.printBase64Binary(documentByteArray);
	
	dataset.addRow([documentId, documentVersion, documentDescription, documentBase64String]);
    return dataset;
}

function onMobileSync(user) {
}
