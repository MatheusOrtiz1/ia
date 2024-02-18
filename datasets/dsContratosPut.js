function defineStructure() {

}

function onSync(lastSyncDate) {

}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
 
    dataset.addColumn("messageCode");
    dataset.addColumn("messageText");
    dataset.addColumn("messageType");

    if ((fields == null) || ((fields != null) && (fields.length != 1))) {
        dataset.addRow(new Array("PARAMETROS", "Não foi informado a string de dados corretamente.", "ERROR"));
        return newDataset;
    }

	var json = JSON.parse(fields[1]);
	var stringJson = JSON.stringify(json);
    
    var clientService = fluigAPI.getAuthorizeClientService();
    var data = {                                                   
        companyId: getValue("WKCompany") + '',
        serviceCode: 'ProtheusRest',                     
        endpoint: '/rest/cstContratoFluig',  
        strParams: stringJson,
        timeoutService: '120', 	// segundos
        method: 'put',
        options: {
            encoding : 'UTF-8',
            mediaType: 'application/json',
            useSSL : true
        }
    }

    var vo = clientService.invoke(JSON.stringify(data));
    if(vo.getResult()== null || vo.getResult().isEmpty()){
        throw new Exception("Falha no retorno");
    }else{
        var json = JSON.parse(vo.getResult());
   		var items = json.alerts;
   		
		for (var nPoint = 0 in items){
			var oRow = items[nPoint];

			dataset.addRow([
				oRow.messageCode, 
				oRow.messageText, 
				oRow.messageType
			]);
		}
    }
    
    return dataset;
}

function onMobileSync(user) {

}
