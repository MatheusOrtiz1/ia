function defineStructure() {

}

function onSync(lastSyncDate) {

}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
    var empresa = '';
    var filial = '';
    var numero = '';
    var revisao = '';
    var params = '';
    
  	if (constraints != null){
		for (var nIdx = 0; nIdx < constraints.length; nIdx++){
			if (constraints[nIdx].fieldName.toUpperCase() == "EMPRESA"){
				empresa = constraints[nIdx].initialValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "FILIAL"){
				filial = constraints[nIdx].initialValue;
			}      
			if (constraints[nIdx].fieldName.toUpperCase() == "NUMERO"){
				numero = constraints[nIdx].initialValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "REVISAO"){
				revisao = constraints[nIdx].initialValue;
			}
    	}
   	}
 
    dataset.addColumn("empresa");
    dataset.addColumn("filial");
    dataset.addColumn("numero");
    dataset.addColumn("revisao");
    dataset.addColumn("fornecedor"); 
    dataset.addColumn("loja");
    dataset.addColumn("nome");
    dataset.addColumn("cnpj");
    dataset.addColumn("endereco");
    dataset.addColumn("bairro");
    dataset.addColumn("cep");
    dataset.addColumn("cidade");
    dataset.addColumn("estado");
    
	params = '?';
	params += (params.length > 1 ? '&' : '') + 'empresa=' + empresa;
	params += (params.length > 1 ? '&' : '') + 'filial=' + filial;
	params += (params.length > 1 ? '&' : '') + 'numeroDe=' + numero;
	params += (params.length > 1 ? '&' : '') + 'numeroAte=' + numero;
	params += (params.length > 1 ? '&' : '') + 'revisaoDe=' + revisao;
	params += (params.length > 1 ? '&' : '') + 'revisaoAte=' + revisao;
    
    var clientService = fluigAPI.getAuthorizeClientService();
    var data = {                                                   
        companyId: getValue("WKCompany") + '',
        serviceCode: 'ProtheusRest',                     
        endpoint: '/rest/cstContratos' + params,
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
   		var items = json.contratos;

   		for (var nPoint = 0 in items){
			var oContrato = items[nPoint];
			var oFornecedores = oContrato.fornecedores;

			for (var nFornecedor = 0 in oFornecedores){
				var oFornecedor = oFornecedores[nFornecedor];
			
				let aRow = [];
			    aRow.push(oContrato.empresa);
			    aRow.push(oContrato.filial);
			    aRow.push(oContrato.numero);
			    aRow.push(oContrato.revisao);
			    aRow.push(oFornecedor.fornecedor); 
			    aRow.push(oFornecedor.loja);
			    aRow.push(oFornecedor.nome);
			    aRow.push(oFornecedor.cnpj);
			    aRow.push(oFornecedor.endereco);
			    aRow.push(oFornecedor.bairro);
			    aRow.push(oFornecedor.cep);
			    aRow.push(oFornecedor.cidade);
			    aRow.push(oFornecedor.estado);
	        
			    dataset.addRow(aRow);
			}
		}
    }
    
    return dataset;
}

function onMobileSync(user) {

}
