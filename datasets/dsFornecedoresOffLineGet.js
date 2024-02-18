function defineStructure() {

}

function onSync(lastSyncDate) {

}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
	var codEmpresaIni = '  ';
	var codEmpresaFim = 'ZZ';
	var codFornecIni = '         ';
	var codFornecFim = 'ZZZZZZZZZ';
	var codLojaIni = '   ';
	var codLojaFim = 'ZZZ';

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
    
    var constraintsFornecedores = new Array();
    
  	if (constraints != null){
		for (var nIdx = 0; nIdx < constraints.length; nIdx++) {
			if (constraints[nIdx].fieldName.toUpperCase() == 'EMPRESA') {
				codEmpresaIni = constraints[nIdx].initialValue;
				codEmpresaFim = constraints[nIdx].finalValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == 'CODIGO') {
				codFornecIni = constraints[nIdx].initialValue;
				codFornecFim = constraints[nIdx].finalValue;
			}
			if (constraints[nIdx].fieldName.toUpperCase() == 'LOJA') {
				codLojaIni = constraints[nIdx].initialValue;
				codLojaFim = constraints[nIdx].finalValue;
			}
    	}
   	}
    
    var datasetFornecedores = DatasetFactory.getDataset("dsFornecedoresOffLine", null, null, null);
    
    for (var row = 0; row < datasetFornecedores.rowsCount; row++) {
    	if (datasetProdutos.getValue(row, 'empresa') >= codEmpresaIni 
    		&& datasetProdutos.getValue(row, 'empresa') <= codEmpresaFim
    		&& datasetProdutos.getValue(row, 'codigo') >= codFornecIni
    		&& datasetProdutos.getValue(row, 'codigo') <= codFornecFim
    		&& datasetProdutos.getValue(row, 'loja') >= codLojaIni
    		&& datasetProdutos.getValue(row, 'loja') <= codLojaFim) {
		
			dataset.addRow([
				datasetFornecedores.getValue(row, 'empresa'),
				datasetFornecedores.getValue(row, 'filial'),
				datasetFornecedores.getValue(row, 'codigo'),
				datasetFornecedores.getValue(row, 'loja'),
				datasetFornecedores.getValue(row, 'cgc'),
				datasetFornecedores.getValue(row, 'pessoa'),
				datasetFornecedores.getValue(row, 'nome'),
				datasetFornecedores.getValue(row, 'nomeReduzido'),
				datasetFornecedores.getValue(row, 'cep'),
				datasetFornecedores.getValue(row, 'endereco'),
				datasetFornecedores.getValue(row, 'bairro'),
				datasetFornecedores.getValue(row, 'estado'),
				datasetFornecedores.getValue(row, 'cidade'),
				datasetFornecedores.getValue(row, 'pais'),
				datasetFornecedores.getValue(row, 'ddi'),
				datasetFornecedores.getValue(row, 'ddd'),
				datasetFornecedores.getValue(row, 'telefone'),
				datasetFornecedores.getValue(row, 'contato'),
				datasetFornecedores.getValue(row, 'inscricaoEstadual'),
				datasetFornecedores.getValue(row, 'inscricaoMunicipal'),
				datasetFornecedores.getValue(row, 'email'),
				datasetFornecedores.getValue(row, 'homePage'),
				datasetFornecedores.getValue(row, 'bloqueado')
			]);
		}
	}
    
    return dataset;
}

function onMobileSync(user) {

}
