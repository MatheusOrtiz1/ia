function defineStructure() {
}

function onSync(lastSyncDate) {
}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();

    dataset.addColumn("documento");
    dataset.addColumn("mensagem");
    
    if (fields == null || fields.length != 4) {
    	dataset.addRow(['ERROR', 'Não foram definidos parâmetros corretamente.'])
    } else {
        var loginAdm = "integrator"; 
        var senhaAdm = "super";
        
        var codEmpresa = 1;
        var filename = fields[0];
        var base64 = fields[1];
        var fileSize = fields[2];
        var ParentDocumentId = parseInt(fields[3]);
        var DocumentDescription = fields[0];
        
        var PublisherId = getValue("WKUser");
        var ColleagueId = getValue("WKUser");

        try {
        	// neste momento, sera instanciado o servidor ECMDocumentService
        	var webServiceProvider = ServiceManager.getService("ECMDocumentService").getBean();	//ServiceManager.getServiceInstance("ECMDocumentService");
        	var webServiceLocator = webServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.ECMDocumentServiceService");
        	var webService = webServiceLocator.getDocumentServicePort();

        	var documentoArray = webServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.DocumentDtoArray"); 
        	var documento = webServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.DocumentDto");
        	
        	//Definição das propriedades do documento
        	documento.setApprovalAndOr(false);
        	documento.setAtualizationId(1);
        	documento.setColleagueId(ColleagueId);
        	documento.setCompanyId(codEmpresa);
        	documento.setDeleted(false);
        	documento.setDocumentDescription(DocumentDescription);
        	documento.setDocumentType("2"); // 1 - Pasta; 2 - Documento; 3 - Documento Externo; 4 - Fichario; 5 - Fichas; 9 - Aplicativo; 10 - Relatorio.
        	documento.setDownloadEnabled(true);
        	documento.setExpires(false);
        	documento.setInheritSecurity(true);
        	documento.setParentDocumentId(ParentDocumentId);
        	documento.setPrivateDocument(false);
        	documento.setPublisherId(PublisherId);
        	documento.setUpdateIsoProperties(true);
        	documento.setUserNotify(false);
        	documento.setVersionOption("0"); 
        	documento.setDocumentPropertyNumber(0);
        	documento.setDocumentPropertyVersion(0);
        	documento.setVolumeId("Default");  
        	documento.setIconId(2);
        	documento.setLanguageId("pt");
        	documento.setIndexed(true);		//Default: false
        	documento.setActiveVersion(true);
        	documento.setTranslated(false);
        	documento.setTopicId(1);
        	documento.setDocumentTypeId("");
        	documento.setExternalDocumentId("");
        	documento.setDatasetName("");
        	documento.setVersionDescription(""); 
        	documento.setKeyWord("");
        	documento.setImutable(false);
        	documento.setProtectedCopy(false);
        	documento.setAccessCount(0);
        	documento.setVersion(1000);

            documentoArray.getItem().add(documento);

            var content = javax.xml.bind.DatatypeConverter.parseBase64Binary(base64);
            
        	var attachment = webServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.Attachment"); 
        	attachment.setFileName(filename);
        	attachment.setPrincipal(true);
        	attachment.setFileSize(fileSize);
        	attachment.setFilecontent(content);

        	var attachmentArray = webServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.AttachmentArray"); 
        	attachmentArray.getItem().add(attachment);
        	
        	var documentSecurityConfigDtoArray = webServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.DocumentSecurityConfigDtoArray");
        	var approverDtoArray = webServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.ApproverDtoArray"); 
        	var relatedDocumentDtoArray = webServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.RelatedDocumentDtoArray"); 
        	
        	var result = webService.createDocument(loginAdm, senhaAdm, codEmpresa, documentoArray, attachmentArray, documentSecurityConfigDtoArray, approverDtoArray, relatedDocumentDtoArray);
    		if (result.getItem().get(0).getDocumentId() == 0) {
            	dataset.addRow(['ERROR', filename + ' ==> ' + result.getItem().get(0).getWebServiceMessage().toString()]);
    		} else {
    			dataset.addRow([result.getItem().get(0).getDocumentId(), filename + ' implantado com sucesso!']);
    		}
        } catch (e) {
        	dataset.addRow(["ERROR", e.message]);
        } 
    }
    
    return dataset;
}

function onMobileSync(user) {
}
