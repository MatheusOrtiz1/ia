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
    dataset.addColumn("numeroMedicao");
    dataset.addColumn("numeroPlanilha");
    dataset.addColumn("tipoPlanilha");
    dataset.addColumn("descricaoPlanilha");
    dataset.addColumn("numeroCronograma");
    dataset.addColumn("cronogramaContabil");
    dataset.addColumn("parcelaCronograma");
    dataset.addColumn("dataInicial");
    dataset.addColumn("dataFinal");
    dataset.addColumn("fornecedor");
    dataset.addColumn("lojaFornecedor");
    dataset.addColumn("cliente");
    dataset.addColumn("lojaCliente");
    dataset.addColumn("dataMaxima");
    dataset.addColumn("saldo");
    dataset.addColumn("valorPrevisto");
    dataset.addColumn("valorLiquido");
    dataset.addColumn("valorMulta");
    dataset.addColumn("valorBonificacao");
    dataset.addColumn("valorDesconto");
    dataset.addColumn("valorTotal");
    dataset.addColumn("valorComissao");
    dataset.addColumn("valorReajuste");
    dataset.addColumn("valorAdiantamento");
    dataset.addColumn("valorMultaPedido");
    dataset.addColumn("ValorBonificacaoPedido");
    dataset.addColumn("numeroTitulo");
    dataset.addColumn("dataVencimento");
    dataset.addColumn("medicaoZerada");
    
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
			var oMedicoes = oContrato.medicoes;

			for (var nMedicao = 0 in oMedicoes){
				var oMedicao = oMedicoes[nMedicao];
			
				let aRow = [];
			    aRow.push(oContrato.empresa);
			    aRow.push(oContrato.filial);
			    aRow.push(oContrato.numero);
			    aRow.push(oContrato.revisao);
			    aRow.push(oMedicao.numeroMedicao);
			    aRow.push(oMedicao.numeroPlanilha);
			    aRow.push(oMedicao.tipoPlanilha);
			    aRow.push(oMedicao.descricaoPlanilha);
			    aRow.push(oMedicao.numeroCronograma);
			    aRow.push(oMedicao.cronogramaContabil);
			    aRow.push(oMedicao.parcelaCronograma);
			    aRow.push(oMedicao.dataInicial);
			    aRow.push(oMedicao.dataFinal);
			    aRow.push(oMedicao.fornecedor);
			    aRow.push(oMedicao.lojaFornecedor);
			    aRow.push(oMedicao.cliente);
			    aRow.push(oMedicao.lojaCliente);
			    aRow.push(oMedicao.dataMaxima);
			    aRow.push(oMedicao.saldo);
			    aRow.push(oMedicao.valorPrevisto);
			    aRow.push(oMedicao.valorLiquido);
			    aRow.push(oMedicao.valorMulta);
			    aRow.push(oMedicao.valorBonificacao);
			    aRow.push(oMedicao.valorDesconto);
			    aRow.push(oMedicao.valorTotal);
			    aRow.push(oMedicao.valorComissao);
			    aRow.push(oMedicao.valorReajuste);
			    aRow.push(oMedicao.valorAdiantamento);
			    aRow.push(oMedicao.valorMultaPedido);
			    aRow.push(oMedicao.ValorBonificacaoPedido);
			    aRow.push(oMedicao.numeroTitulo);
			    aRow.push(oMedicao.dataVencimento);
			    aRow.push(oMedicao.medicaoZerada);
			    
			    dataset.addRow(aRow);
			}
		}
    }
    
    return dataset;
}

function onMobileSync(user) {

}
