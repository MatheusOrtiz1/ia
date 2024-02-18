function defineStructure() {

}

function onSync(lastSyncDate) {

}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();

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
    
    var cLast = '??';
    var constraintsFiliais = new Array();
    var datasetFiliais = DatasetFactory.getDataset("dsFiliaisOffLine", null, constraintsFiliais, null);
    
    for (var row = 0; row < datasetFiliais.rowsCount; row++) {
		if (cLast != datasetFiliais.getValue(row, 'empresa')) {
			cLast = datasetFiliais.getValue(row, 'empresa');
				
			dataset.addRow([
				datasetFiliais.getValue(row, 'empresa')
			    , datasetFiliais.getValue(row, 'nome')
			    , datasetFiliais.getValue(row, 'cnpj')
			    , datasetFiliais.getValue(row, 'incricaoMunicipal')
			    , datasetFiliais.getValue(row, 'cidade')
			    , datasetFiliais.getValue(row, 'estado')
			    , datasetFiliais.getValue(row, 'endereco')
			    , datasetFiliais.getValue(row, 'bairro')
			    , datasetFiliais.getValue(row, 'cep')
			    , datasetFiliais.getValue(row, 'complemento')
		    	, datasetFiliais.getValue(row, 'telefone')]);
		} 
	}
    
    return dataset;
}

function onMobileSync(user) {

}
