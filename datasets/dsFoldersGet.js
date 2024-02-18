var DOCUMENT_TYPE_FOLDER = "1";		// Tipo do documento que define ser uma pasta
var DOCUMENT_TYPE_NORMAL = "2";		// Tipo do documento que define ser um documento normal

function defineStructure() {
}

function onSync(lastSyncDate) {
}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
    var parent = 0;
    var folderId_1 = null;
    var folderId_2 = null;
    var folderDescription_1 = null;
    var folderDescription_2 = null;

    dataset.addColumn("pai");
    dataset.addColumn("codigo");
    dataset.addColumn("descricao");
 
  	if (constraints != null){
		for (var nIdx = 0; nIdx < constraints.length; nIdx++){
			if (constraints[nIdx].fieldName.toUpperCase() == "PAI"){
				parent = constraints[nIdx].initialValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "CODIGO"){
				folderId_1 = constraints[nIdx].initialValue;
				folderId_2 = constraints[nIdx].finalValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "DESCRICAO"){
				folderDescription_1 = constraints[nIdx].initialValue;
				folderDescription_2 = constraints[nIdx].finalValue;
			}
    	}
   	}
    
    var documents = fluigAPI.getFolderDocumentService().list(parent);
    var iterator = documents.iterator();

    while (iterator.hasNext()) {
    	var document = iterator.next();

    	//Não exibir os deletados
    	if (document.getDeleted() == "true") {
    		continue;
    	}

    	if (document.getDocumentType() == DOCUMENT_TYPE_FOLDER) {
    		if (((folderId_1 == null && folderId_2 == null) 
        		|| (document.getDocumentId() >= folderId_1 
        			&& document.getDocumentId() <= folderId_2))
        		&& ((folderDescription_1 == null && folderDescription_2 == null) 
            		|| (document.getDocumentDescription() >= folderDescription_1 
                		&& document.getDocumentDescription() <= folderDescription_2))) {

    	        dataset.addRow([
    	        	parent,
    	        	document.getDocumentId(),
    	        	document.getDocumentDescription()
    	        ]);
    			
    		}
    	}
    }
    
    return dataset;
}

function onMobileSync(user) {
}
