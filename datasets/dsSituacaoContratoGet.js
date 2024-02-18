function defineStructure() {
}

function onSync(lastSyncDate) {
}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
	
    dataset.addColumn("codigo");
    dataset.addColumn("descricao");
   		
	dataset.addRow(["01", "Cancelado"]);
	dataset.addRow(["02", "Em Elaboração"]);
	dataset.addRow(["03", "Emitido"]);
	dataset.addRow(["04", "Em Aprovação"]);
	dataset.addRow(["05", "Vigente"]);
	dataset.addRow(["06", "Paralisado"]);
	dataset.addRow(["07", "Solicitado Finalização"]);
	dataset.addRow(["08", "Finalizado"]);
	dataset.addRow(["09", "Em Revisão"]);
	dataset.addRow(["10", "Revisado"]);
	dataset.addRow(["A ", "Revisão Aprovação p/ Alçadas"]); 
	
    return dataset;
}

function onMobileSync(user) {
}
