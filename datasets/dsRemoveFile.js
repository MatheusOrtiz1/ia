function defineStructure() {
}

function onSync(lastSyncDate) {
}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();

    dataset.addColumn("documento");
    dataset.addColumn("mensagem");
    
    if (fields == null || fields.length != 1) {
    	dataset.addRow(['ERROR', 'Não foram definidos parâmetros corretamente.'])
    } else {
        var loginAdm = "integrator"; 
        var senhaAdm = "super";
        
        var codEmpresa = 1;
        var documentId = fields[0];
        var colleagueId = getValue("WKUser");

        try {
        	// neste momento, sera instanciado o servidor ECMDocumentService
        	var webServiceProvider = ServiceManager.getService("ECMDocumentService").getBean();	//ServiceManager.getServiceInstance("ECMDocumentService");
        	var webServiceLocator = webServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.ECMDocumentServiceService");
        	var webService = webServiceLocator.getDocumentServicePort();
        	
        	var result = webService.deleteDocument(loginAdm, senhaAdm, codEmpresa, documentId, colleagueId);
    		if (result.getItem().get(0).getDocumentId() == 0) {
            	dataset.addRow(['ERROR', 'Documento com ID: ' + documentId.toString() + ' ==> ' + result.getItem().get(0).getWebServiceMessage().toString()]);
    		} else {
    			dataset.addRow([result.getItem().get(0).getDocumentId(), 'Documento com ID: ' + documentId.toString() + ' removido com sucesso!']);
    		}
        } catch (e) {
        	dataset.addRow(["ERROR", e.message]);
        } 
    }
    
    return dataset;
}

function onMobileSync(user) {
}
