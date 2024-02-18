function defineStructure() {

}

function onSync(lastSyncDate) {

}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
    var empresa = '';
    var codigo = '';
    var params = ''; 

    dataset.addColumn("empresa");
    dataset.addColumn("filial");
    dataset.addColumn("codigo");
    dataset.addColumn("descricao");
      
  	if (constraints != null){
		for(var nIdx = 0; nIdx < constraints.length; nIdx++){
			if (constraints[nIdx].fieldName.toUpperCase() == "EMPRESA"){
				empresa = constraints[nIdx].initialValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "CODIGO"){
				codigo = constraints[nIdx].initialValue;
			}
    	}
   	}

    if (empresa != '' || codigo != '') {
    	params = '?';
		
    	if (empresa != '') {
    		params += (params.length > 1 ? '&' : '') + 'empresa=' + empresa;
    	}
    		
    	if (codigo != '') {
    		params += (params.length > 1 ? '&' : '') + 'codigo=' + codigo;
    	}
    }
    
    var clientService = fluigAPI.getAuthorizeClientService();
    var data = {                                                   
        companyId: getValue("WKCompany") + '',
        serviceCode: 'ProtheusRest',                     
        endpoint: '/rest/cstTipoContrato' + params,
        method: 'get',
        timeoutService: '120',
        options: {
            encoding : 'UTF-8',
            mediaType: 'application/json',
            useSSL : true
        }
    }
    
    var vo = clientService.invoke(JSON.stringify(data));
 
    if (vo.getResult()== null || vo.getResult().isEmpty()){
        throw new Exception("Retorno está vazio");
    } else {
        var json = JSON.parse(vo.getResult());
   		var items = json.tipoDeContrato;
   		
		for (var nPoint = 0 in items){
			var oRow = items[nPoint];

			dataset.addRow([
				oRow.empresa
				, oRow.filial
				, oRow.codigo
			    , oRow.descricao]);
		}
    }
    
    return dataset;
}

function onMobileSync(user) {

}
