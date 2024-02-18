function defineStructure() {
	//Colunas
    addColumn("empresa");
    addColumn("filial");
    addColumn("codigo");
    addColumn("loja");
    addColumn("cgc");
    addColumn("pessoa");
    addColumn("nome");
    addColumn("nomeReduzido");
    addColumn("cep");
    addColumn("endereco");
    addColumn("bairro");
    addColumn("estado");
    addColumn("cidade");
    addColumn("pais");
    addColumn("ddi");
    addColumn("ddd");
    addColumn("telefone");
    addColumn("contato");
    addColumn("inscricaoEstadual");
    addColumn("inscricaoMunicipal");
    addColumn("email");
    addColumn("homePage");
    addColumn("bloqueado");
	
    //Chave primária
    setKey(["empresa", "codigo", "loja"]);
    
    //Índices
    addIndex(["empresa", "codigo", "loja"]);
    addIndex(["empresa", "nome", "codigo", "loja"]);
}

function onSync(lastSyncDate) {
	//Novo dataset
	var dataset = DatasetBuilder.newDataset();
    
    try {
        var constraintsFiliais = new Array();
        var datasetFiliais = DatasetFactory.getDataset("dsFiliaisOffLine", null, constraintsFiliais, null);
   		var cLast = '??';
        
        for (var row = 0; row < datasetFiliais.rowsCount; row++) {
    		if (cLast != datasetFiliais.getValue(row, 'empresa')) {
    			cLast = datasetFiliais.getValue(row, 'empresa');
    			
    		    var params = '?empresa=' + datasetFiliais.getValue(row, 'empresa');
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

    	    			dataset.addOrUpdateRow([
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
    var fields = new Array('codigo', 'loja', 'nome', 'cgc');
    var result = {
        'fields' : fields,
        'constraints' : constraints,
        'sortFields' : sortFields
    };
    
    return result;
}
