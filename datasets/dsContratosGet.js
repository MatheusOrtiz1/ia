function defineStructure() {

}

function onSync(lastSyncDate) {

}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
    var empresa = '';
    var filial = '';
    var numeroDe = '';
    var numeroAte = '';
    var fornecedorDe = '';
    var fornecedorAte = '';
    var lojaDe = '';
    var lojaAte = '';
    var dataInicioDe = '';
    var dataInicioAte = '';
    var revisaoDe = '';
    var revisaoAte = '';
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
				numeroDe = constraints[nIdx].initialValue;
				numeroAte = constraints[nIdx].finalValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "FORNECEDOR"){
				fornecedorDe = constraints[nIdx].initialValue;
				fornecedorAte = constraints[nIdx].finalValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "LOJA"){
				lojaDe = constraints[nIdx].initialValue;
				lojaAte = constraints[nIdx].finalValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "DATAINICIO"){
				dataInicioDe = constraints[nIdx].initialValue;
				dataInicioAte = constraints[nIdx].finalValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == "REVISAO"){
				revisaoDe = constraints[nIdx].initialValue;
				revisaoAte = constraints[nIdx].finalValue;
			}
    	}
   	}
 
    dataset.addColumn("empresa");
    dataset.addColumn("filial");
    dataset.addColumn("tipoContrato");
    dataset.addColumn("descricaoTipoContrato"); 
    dataset.addColumn("numero");
    dataset.addColumn("revisao");
    dataset.addColumn("tipoRevisao");
    dataset.addColumn("descricaoTipoRevisao");
    dataset.addColumn("descricaoContrato");
    dataset.addColumn("dataInicio");
    dataset.addColumn("dataFinal"); 
    dataset.addColumn("prazo"); 
    dataset.addColumn("diasParaAviso"); 
    dataset.addColumn("dataSituacaoVigencia");
    dataset.addColumn("unidadeVigencia");
    dataset.addColumn("vigencia");
    dataset.addColumn("dataAssinatura");
    dataset.addColumn("Cliente");
    dataset.addColumn("lojaCliente");
    dataset.addColumn("moeda");
    dataset.addColumn("condicaoPagamento");
    dataset.addColumn("descricaoCondicaoPagamento");
    dataset.addColumn("objeto");
    dataset.addColumn("valorInicial");
    dataset.addColumn("valorAtual");
    dataset.addColumn("reajuste");
    dataset.addColumn("valorPresente");
    dataset.addColumn("valorJuros");
    dataset.addColumn("indiceCorrecao");
    dataset.addColumn("descricaoIndiceCorrecao");
    dataset.addColumn("controlaCaucao");
    dataset.addColumn("tipoControleCaucao");
    dataset.addColumn("minimoCaucao");
    dataset.addColumn("dataEncerramento");
    dataset.addColumn("revisaoAtual");
    dataset.addColumn("saldo");
    dataset.addColumn("motivoParalizacao");
    dataset.addColumn("dataInicioParalizacao");
    dataset.addColumn("dataTerminoParalizacao");
    dataset.addColumn("dataReinicio");
    dataset.addColumn("justificativa");
    dataset.addColumn("dataRevisao");
    dataset.addColumn("dataReajuste");
    dataset.addColumn("valorReajuste");
    dataset.addColumn("valorAditivo");
    dataset.addColumn("tituloProvisorio");
    dataset.addColumn("alteracaoClausula");
    dataset.addColumn("valorMedicaoAcumulada");
    dataset.addColumn("taxaAdministracao");
    dataset.addColumn("formaContratacao");
    dataset.addColumn("dataNecessidade");
    dataset.addColumn("descricaoFinanciamento");
    dataset.addColumn("contratoFinanciamento");
    dataset.addColumn("dataInicioProrrogacao");
    dataset.addColumn("periodoProrrogacao");
    dataset.addColumn("unidadeProrrogacao");
    dataset.addColumn("valorProrrogacao");
    dataset.addColumn("dataProposta");
    dataset.addColumn("dataUltimoStatus");
    dataset.addColumn("situacao"); 
    dataset.addColumn("descricaoSituacao"); 
    dataset.addColumn("aliquotaISS");
    dataset.addColumn("baseINSS");
    dataset.addColumn("baseMaterial");
    dataset.addColumn("validacaoContrato");
    dataset.addColumn("codigoProcessoLicitador");
    dataset.addColumn("numeroProcessoLicitador");
    dataset.addColumn("usuarioAvaliador");
    dataset.addColumn("programacaoAvaliacao");
    dataset.addColumn("dataUltimaAvaliacao");
    dataset.addColumn("dataProximaAvaliacao");
    dataset.addColumn("dataVigenciaFutura");
    dataset.addColumn("grupoAprovacao");
    dataset.addColumn("areaContrato");
    dataset.addColumn("descricaoAreaContrato");
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
	
	if (numeroDe != '') {
		params += (params.length > 1 ? '&' : '') + 'numeroDe=' + numeroDe;
	}
	
	if (numeroAte != '') {
		params += (params.length > 1 ? '&' : '') + 'numeroAte=' + numeroAte;
	}
	
	if (fornecedorDe != '') {
		params += (params.length > 1 ? '&' : '') + 'fornecedorDe=' + fornecedorDe;
	}
	
	if (fornecedorAte != '') {
		params += (params.length > 1 ? '&' : '') + 'fornecedorAte=' + fornecedorAte;
	}
	
	if (lojaDe != '') {
		params += (params.length > 1 ? '&' : '') + 'lojaDe=' + lojaDe;
	}
	
	if (lojaAte != '') {
		params += (params.length > 1 ? '&' : '') + 'lojaAte=' + lojaAte;
	}
	
	if (dataInicioDe != '') {
		params += (params.length > 1 ? '&' : '') + 'dataInicioDe=' + dataInicioDe;
	}
	
	if (dataInicioAte != '') {
		params += (params.length > 1 ? '&' : '') + 'dataInicioAte=' + dataInicioAte;
	}
	
	if (revisaoDe != '') {
		params += (params.length > 1 ? '&' : '') + 'revisaoDe=' + revisaoDe;
	}
	
	if (revisaoAte != '') {
		params += (params.length > 1 ? '&' : '') + 'revisaoAte=' + revisaoAte;
	}
    
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
	   		
			let aRow = [];
		    aRow.push(oContrato.empresa);
		    aRow.push(oContrato.filial);
		    aRow.push(oContrato.tipoContrato);
		    aRow.push(oContrato.descricaoTipoContrato); 
		    aRow.push(oContrato.numero);
		    aRow.push(oContrato.revisao);
		    aRow.push(oContrato.tipoRevisao);
		    aRow.push(oContrato.descricaoTipoRevisao);
		    aRow.push(oContrato.descricaoContrato);
		    aRow.push(oContrato.dataInicio);
		    aRow.push(oContrato.dataFinal); 
		    aRow.push(oContrato.prazo); 
		    aRow.push(oContrato.diasParaAviso); 
		    aRow.push(oContrato.dataSituacaoVigencia);
		    aRow.push(oContrato.unidadeVigencia);
		    aRow.push(oContrato.vigencia);
		    aRow.push(oContrato.dataAssinatura);
		    aRow.push(oContrato.Cliente);
		    aRow.push(oContrato.lojaCliente);
		    aRow.push(oContrato.moeda);
		    aRow.push(oContrato.condicaoPagamento);
		    aRow.push(oContrato.descricaoCondicaoPagamento);
		    aRow.push(oContrato.objeto);
		    aRow.push(oContrato.valorInicial);
		    aRow.push(oContrato.valorAtual);
		    aRow.push(oContrato.reajuste);
		    aRow.push(oContrato.valorPresente);
		    aRow.push(oContrato.valorJuros);
		    aRow.push(oContrato.indiceCorrecao);
		    aRow.push(oContrato.descricaoIndiceCorrecao);
		    aRow.push(oContrato.controlaCaucao);
		    aRow.push(oContrato.tipoControleCaucao);
		    aRow.push(oContrato.minimoCaucao);
		    aRow.push(oContrato.dataEncerramento);
		    aRow.push(oContrato.revisaoAtual);
		    aRow.push(oContrato.saldo);
		    aRow.push(oContrato.motivoParalizacao);
		    aRow.push(oContrato.dataInicioParalizacao);
		    aRow.push(oContrato.dataTerminoParalizacao);
		    aRow.push(oContrato.dataReinicio);
		    aRow.push(oContrato.justificativa);
		    aRow.push(oContrato.dataRevisao);
		    aRow.push(oContrato.dataReajuste);
		    aRow.push(oContrato.valorReajuste);
		    aRow.push(oContrato.valorAditivo);
		    aRow.push(oContrato.tituloProvisorio);
		    aRow.push(oContrato.alteracaoClausula);
		    aRow.push(oContrato.valorMedicaoAcumulada);
		    aRow.push(oContrato.taxaAdministracao);
		    aRow.push(oContrato.formaContratacao);
		    aRow.push(oContrato.dataNecessidade);
		    aRow.push(oContrato.descricaoFinanciamento);
		    aRow.push(oContrato.contratoFinanciamento);
		    aRow.push(oContrato.dataInicioProrrogacao);
		    aRow.push(oContrato.periodoProrrogacao);
		    aRow.push(oContrato.unidadeProrrogacao);
		    aRow.push(oContrato.valorProrrogacao);
		    aRow.push(oContrato.dataProposta);
		    aRow.push(oContrato.dataUltimoStatus);
		    aRow.push(oContrato.situacao); 
		    aRow.push(oContrato.descricaoSituacao); 
		    aRow.push(oContrato.aliquotaISS);
		    aRow.push(oContrato.baseINSS);
		    aRow.push(oContrato.baseMaterial);
		    aRow.push(oContrato.validacaoContrato);
		    aRow.push(oContrato.codigoProcessoLicitador);
		    aRow.push(oContrato.numeroProcessoLicitador);
		    aRow.push(oContrato.usuarioAvaliador);
		    aRow.push(oContrato.programacaoAvaliacao);
		    aRow.push(oContrato.dataUltimaAvaliacao);
		    aRow.push(oContrato.dataProximaAvaliacao);
		    aRow.push(oContrato.dataVigenciaFutura);
		    aRow.push(oContrato.grupoAprovacao);
		    aRow.push(oContrato.areaContrato);
		    aRow.push(oContrato.descricaoAreaContrato);
	        
			var oFornecedores = oContrato.fornecedores;
			for (var nFornecedor = 0 in oFornecedores) {
				var oFornecedor = oFornecedores[nFornecedor];
		    
			    aRow.push(oFornecedor.fornecedor); 
			    aRow.push(oFornecedor.loja);
			    aRow.push(oFornecedor.nome);
			    aRow.push(oFornecedor.cnpj);
			    aRow.push(oFornecedor.endereco);
			    aRow.push(oFornecedor.bairro);
			    aRow.push(oFornecedor.cep);
			    aRow.push(oFornecedor.cidade);
			    aRow.push(oFornecedor.estado);
			    
			    break;
			}
		    
			dataset.addRow(aRow);
		}
    }
    
    return dataset;
}

function onMobileSync(user) {

}
