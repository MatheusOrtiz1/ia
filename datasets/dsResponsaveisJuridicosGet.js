function defineStructure() {

}

function onSync(lastSyncDate) {

}

function createDataset(fields, constraints, sortFields) {
    var dataset = DatasetBuilder.newDataset();
    var empresa = '';

    dataset.addColumn("empresa");
    dataset.addColumn("codigo");
    dataset.addColumn("nome");
    dataset.addColumn("login");
    dataset.addColumn("email");
    
  	if (constraints != null){
		for(var nIdx = 0; nIdx < constraints.length; nIdx++){
			if (constraints[nIdx].fieldName.toUpperCase() == "EMPRESA"){
				empresa = constraints[nIdx].initialValue;
			}
    	}
   	}
    
    var constraintsGroup = new Array();
    constraintsGroup.push(DatasetFactory.createConstraint("colleagueGroupPK.groupId", empresa + ".RJ", empresa + ".RJ", ConstraintType.MUST));

    var datasetGroup = DatasetFactory.getDataset("colleagueGroup", null, constraintsGroup, null);
	for (var row = 0; row < datasetGroup.rowsCount; row++) {
        var constraintsUsers = new Array();
        constraintsUsers.push(DatasetFactory.createConstraint("colleagueId", datasetGroup.getValue(row, "colleagueGroupPK.colleagueId"), datasetGroup.getValue(row, "colleagueGroupPK.colleagueId"), ConstraintType.MUST));
		
	    var datasetUsers = DatasetFactory.getDataset("colleague", null, constraintsUsers, null);
	    if (datasetUsers != null && datasetUsers.rowsCount != null && datasetUsers.rowsCount > 0) {
			dataset.addRow([
				empresa
				, datasetUsers.getValue(0, 'colleaguePK.colleagueId')
				, datasetUsers.getValue(0, 'colleagueName')
				, datasetUsers.getValue(0, 'login')
				, datasetUsers.getValue(0, 'email')]);
	    }
	}
    
    return dataset;
}

function onMobileSync(user) {

}
