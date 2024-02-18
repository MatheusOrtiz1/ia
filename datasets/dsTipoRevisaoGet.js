function defineStructure() {
}

function onSync(lastSyncDate) {
}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
	
    dataset.addColumn("codigo");
    dataset.addColumn("descricao");
   		
	dataset.addRow(["00", "Implantação"]);
	dataset.addRow(["01", "Aditivo"]);
	dataset.addRow(["02", "Reajuste"]);
	dataset.addRow(["03", "Realinhamento"]);
	dataset.addRow(["04", "Readequação"]);
	dataset.addRow(["05", "Paralisação"]);
	dataset.addRow(["06", "Reínicio"]);
	dataset.addRow(["07", "Alteração de Cláusulas"]);
	dataset.addRow(["08", "Contábil"]);
	dataset.addRow(["09", "Índice"]);
	dataset.addRow(["10", "Troca de Fornecedor/Cliente"]);
	dataset.addRow(["11", "Grupos de Aprovação"]);
	dataset.addRow(["12", "Renovação"]);
	dataset.addRow(["13", "Multa/Bonificação"]);
	dataset.addRow(["14", "Aberta"]);
	dataset.addRow(["15", "Caução"]);
	
    return dataset;
}

function onMobileSync(user) {
}
