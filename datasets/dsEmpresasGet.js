function defineStructure() {

}

function onSync(lastSyncDate) {

}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
    var empresa = '';
    var params = ''; 

    dataset.addColumn("empresa");
    dataset.addColumn("nome");
    dataset.addColumn("cnpj");
    dataset.addColumn("incricaoMunicipal");
    dataset.addColumn("cidade");
    dataset.addColumn("estado");
    dataset.addColumn("endereco");
    dataset.addColumn("bairro");
    dataset.addColumn("cep");
    dataset.addColumn("complemento");
    dataset.addColumn("telefone");
    
  	if (constraints != null){
		for(var nIdx = 0; nIdx < constraints.length; nIdx++){
			if (constraints[nIdx].fieldName.toUpperCase() == "EMPRESA"){
				empresa = constraints[nIdx].initialValue;
			}
    	}
   	}

    if (empresa != '') {
    	params = '?';
		
    	if (empresa != '') {
    		params += (params.length > 1 ? '&' : '') + 'empresa=' + empresa;
    	}
    }
    
    var clientService = fluigAPI.getAuthorizeClientService();
    var data = {                                                   
        companyId: getValue("WKCompany") + '',
        serviceCode: 'ProtheusRest',                     
        endpoint: '/rest/cstFiliais' + params,
        method: 'get',
        timeoutService: '320',
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
        var json  = JSON.parse(vo.getResult());
   		var items = json.filiais;
   		var cLast = '??';
   		
		for (var nPoint = 0 in items){
			var oRow = items[nPoint];

			if (cLast != oRow.empresa) {
				cLast = oRow.empresa;
					
				dataset.addRow([
					oRow.empresa
				    , oRow.nome
				    , oRow.cnpj
				    , oRow.incricaoMunicipal
				    , oRow.cidade
				    , oRow.estado
				    , oRow.endereco
				    , oRow.bairro
				    , oRow.cep
				    , oRow.complemento
			    	, oRow.telefone]);
			} 
		}
    }
    
    return dataset;
}

function onMobileSync(user) {

}
