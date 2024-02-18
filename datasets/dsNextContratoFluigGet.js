function defineStructure() {
}

function onSync(lastSyncDate) {
}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
    var empresa = '';
    var filial = '';
    var numero = '';
    var params = ''; 
	
    dataset.addColumn("empresa");
    dataset.addColumn("filial");
    dataset.addColumn("numero");
    dataset.addColumn("revisao");
  
  	if (constraints != null){  
		for(var nIdx = 0; nIdx < constraints.length; nIdx++){
			if (constraints[nIdx].fieldName.toUpperCase() == "EMPRESA"){
				empresa = constraints[nIdx].initialValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "FILIAL"){
				filial = constraints[nIdx].initialValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "NUMERO"){
				numero = constraints[nIdx].initialValue;
			}
    	}
   	}

    if (empresa != '' || filial != '' || numero != '') {
    	params = '?';
    		
    	if (empresa != '') {
    		params += (params.length > 1 ? '&' : '') + 'empresa=' + empresa;
    	}
    		
    	if (filial != '') {
    		params += (params.length > 1 ? '&' : '') + 'filial=' + filial;
    	}
    		
    	if (numero != '') {
    		params += (params.length > 1 ? '&' : '') + 'numero=' + numero;
    	}
    }
    
    var clientService = fluigAPI.getAuthorizeClientService();
    var data = {                                                   
        companyId: getValue("WKCompany") + '',
        serviceCode: 'ProtheusRest',
        endpoint: '/rest/cstNextContratoFluig' + params,  
        method: 'get',
        options: {
            encoding : 'UTF-8',
            mediaType: 'application/json',
            useSSL : true
        }
    }
    
    var vo = clientService.invoke(JSON.stringify(data));
 
    if(vo.getResult()== null || vo.getResult().isEmpty()){
        throw new Exception("Retorno está vazio");
    }else{
   		var oRow = JSON.parse(vo.getResult());
   		
		dataset.addRow([oRow.empresa
			            , oRow.filial
			            , oRow.numero
			            , oRow.revisao]);
    }
    
    return dataset;
}

function onMobileSync(user) {
}
