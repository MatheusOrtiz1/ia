function defineStructure() {
}

function onSync(lastSyncDate) {
}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
    var empresa = '';
    var filial = '';
    var codigo = '';
    var params = ''; 
	
    dataset.addColumn("empresa");
    dataset.addColumn("filial");
    dataset.addColumn("codigo");
    dataset.addColumn("tipo");
    dataset.addColumn("valor");
    
  	if (constraints != null){  
		for(var nIdx = 0; nIdx < constraints.length; nIdx++){
			if (constraints[nIdx].fieldName.toUpperCase() == "EMPRESA"){
				empresa = constraints[nIdx].initialValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "FILIAL"){
				filial = constraints[nIdx].initialValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "CODIGO"){
				codigo = constraints[nIdx].initialValue;
			}
    	}
   	}

    if (empresa != '' || filial != '' || codigo != '') {
    	params = '?';
    		
    	if (empresa != '') {
    		params += (params.length > 1 ? '&' : '') + 'empresa=' + empresa;
    	}
    		
    	if (filial != '') {
    		params += (params.length > 1 ? '&' : '') + 'filial=' + filial;
    	}
    		
    	if (codigo != '') {
    		params += (params.length > 1 ? '&' : '') + 'codigo=' + codigo;
    	}
    }
    
    var clientService = fluigAPI.getAuthorizeClientService();
    var data = {                                                   
        companyId: getValue("WKCompany") + '',
        serviceCode: 'ProtheusRest',
        endpoint: '/rest/cstParametros' + params,  
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
			            , oRow.codigo
			            , oRow.tipo
			            , oRow.valor]);
    }
    
    return dataset;
}

function onMobileSync(user) {
}
