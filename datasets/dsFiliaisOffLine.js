function defineStructure() {
	//Colunas
    addColumn("empresa");
    addColumn("filial");
    addColumn("nome");
    addColumn("cnpj");
    addColumn("incricaoMunicipal");
    addColumn("cidade");
    addColumn("estado");
    addColumn("endereco");
    addColumn("bairro");
    addColumn("cep");
    addColumn("complemento");
    addColumn("telefone");
	
    //Chave primária
    setKey(["empresa", "filial"]);
    
    //Índices
    addIndex(["empresa", "filial"]);
    addIndex(["nome", "filial", "empresa"]);
    addIndex(["cnpj", "filial", "empresa"]);
}

function onSync(lastSyncDate) {
	//Novo dataset
	var dataset = DatasetBuilder.newDataset();
    
    try {
        var clientService = fluigAPI.getAuthorizeClientService();
        var data = {                                                   
            companyId: getValue("WKCompany") + '',
            serviceCode: 'ProtheusRest',                     
            endpoint: '/rest/cstFiliais',
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
       		var items = json.filiais;
       		
    		for (var nPoint = 0 in items){
    			var oRow = items[nPoint];

    			dataset.addOrUpdateRow([
    				oRow.empresa
    				, oRow.filial
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
    } catch (e) {
        log.error("ERRO ==============> " + e.message);
    }
    
    return dataset;
}

function onMobileSync(user) {
    var sortFields = new Array();
    var constraints = new Array();
    var fields = new Array('empresa', 'filial', 'nome', 'cnpj');
    var result = {
        'fields' : fields,
        'constraints' : constraints,
        'sortFields' : sortFields
    };
    
    return result;
}
