function defineStructure() {

}

function onSync(lastSyncDate) {

}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
    var empresa = '';
    var filial = '';
    var codigo = '';
    var loja = '';
    var cgc = '';
    var params = ''; 

    dataset.addColumn("empresa");
    dataset.addColumn("filial");
    dataset.addColumn("codigo");
    dataset.addColumn("loja");
    dataset.addColumn("cgc");
    dataset.addColumn("pessoa");
    dataset.addColumn("nome");
    dataset.addColumn("nomeReduzido");
    dataset.addColumn("cep");
    dataset.addColumn("endereco");
    dataset.addColumn("bairro");
    dataset.addColumn("estado");
    dataset.addColumn("cidade");
    dataset.addColumn("pais");
    dataset.addColumn("ddi");
    dataset.addColumn("ddd");
    dataset.addColumn("telefone");
    dataset.addColumn("contato");
    dataset.addColumn("inscricaoEstadual");
    dataset.addColumn("inscricaoMunicipal");
    dataset.addColumn("email");
    dataset.addColumn("homePage");
    dataset.addColumn("bloqueado");
    
  	if (constraints != null){
		for(var nIdx = 0; nIdx < constraints.length; nIdx++){
			if (constraints[nIdx].fieldName.toUpperCase() == "EMPRESA"){
				empresa = constraints[nIdx].initialValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "CODIGO"){
				codigo = constraints[nIdx].initialValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "LOJA"){
				loja = constraints[nIdx].initialValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "CGC"){
				cgc = constraints[nIdx].initialValue;
			}
    	}
   	}

    if (empresa != '' || codigo != '' || loja != '' || cgc != '') {
    	params = '?';
		
    	if (empresa != '') {
    		params += (params.length > 1 ? '&' : '') + 'empresa=' + empresa;
    	}
    		
    	if (codigo != '') {
    		params += (params.length > 1 ? '&' : '') + 'codigo=' + codigo;
    	}
		
    	if (loja != '') {
    		params += (params.length > 1 ? '&' : '') + 'loja=' + loja;
    	}
		
    	if (cgc != '') {
    		params += (params.length > 1 ? '&' : '') + 'cgc=' + cgc;
    	}
    }
    
    var clientService = fluigAPI.getAuthorizeClientService();
    var data = {                                                   
        companyId: getValue("WKCompany") + '',
        serviceCode: 'ProtheusRest',                     
        endpoint: '/rest/cstFornecedores' + params,
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
   		var items = json.fornecedores;
   		
		for (var nPoint = 0 in items){
			var oRow = items[nPoint];

			dataset.addRow([
				oRow.empresa
				, oRow.filial
				, oRow.codigo
			    , oRow.loja
			    , oRow.cgc
			    , oRow.pessoa
			    , oRow.nome
			    , oRow.nomeReduzido
			    , oRow.cep
			    , oRow.endereco
			    , oRow.bairro
			    , oRow.estado
			    , oRow.cidade
			    , oRow.pais
			    , oRow.ddi
			    , oRow.ddd
			    , oRow.telefone
			    , oRow.contato
			    , oRow.inscricaoEstadual
			    , oRow.inscricaoMunicipal
			    , oRow.email
			    , oRow.homePage
		    	, oRow.bloqueado]);
		}
    }
    
    return dataset;
}

function onMobileSync(user) {

}
