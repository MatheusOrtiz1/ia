var MyWidget = SuperWidget.extend({
    //variáveis da widget
	isAdmin: null,
	isOperador: null,
	currentuserCode: null,
	currentOperatorId: null,

    //método iniciado quando a widget é carregada
    init: function() {
    	initialize();
    },
  
    //BIND de eventos
    bindings: {
        local: {
            'execute': ['click_executeAction']
        },
        global: {}
    },
 
    executeAction: function(htmlElement, event) {
    }

});


function initialize() {
	userCode = WCMAPI.userCode;
	
    datasetEmpresas = [];
    datasetFiliais = [];
    datasetFornecedores = [];
    datasetContratos = [];
    datasetSituacaoContrato = [];
    datasetTipoRevisao = [];
    datasetCentroCusto = [];
    datasetTipoContrato = [];
    datasetResponsaveisJuridicos = [];

    var constraintsUsers = new Array();
    constraintsUsers.push(DatasetFactory.createConstraint("colleagueId", userCode, userCode, ConstraintType.MUST));
    var datasetUsers = DatasetFactory.getDataset("colleague", null, constraintsUsers, null);
    if (datasetUsers == null || datasetUsers.rowsCount <= 0) {
        FLUIGC.toast({
            title: 'ERRO: ',
            message: "Usu&aacute;io n&atilde;o encontrado (colleague)",
            type: 'danger'
        });
    }
    
	datasetEmpresas = DatasetFactory.getDataset('dsEmpresasOffLine', null, null, null);
	datasetSituacaoContrato = DatasetFactory.getDataset('dsSituacaoContratoGet', null, null, null);
	datasetTipoRevisao = DatasetFactory.getDataset('dsTipoRevisaoGet', null, null, null);
	//Estilização para campos obrigatórios
	$(".mandatory").append("<span>*</span>");
	
    createAutoCompleteFiltroEmpresa();
	show('main');
};


function createAutoCompleteFiltroEmpresa() {
    if (typeof autoCompleteFiltroEmpresa != "undefined") {
        autoCompleteFiltroEmpresa.destroy();
        delete autoCompleteFiltroEmpresa;
    }
    
    autoCompleteFiltroEmpresa = FLUIGC.autocomplete('#filtroEmpresa', {
        source: (text, autocomplete) => {
            let data = datasetEmpresas.values;
            let columns = ['empresa','nome','cnpj'];
            let matches = []
            let regex = new RegExp(text, 'i')

            data.forEach((item) => {
                if (columns && columns.length > 0) {
                    for (let index = 0; index < columns.length; index++) {
                        if (regex.test(item[columns[index]])) {
                            matches.push(item)
                            break;
                        }
                    }
                }
            })
            autocomplete(matches)
        },
        displayKey: row => (row.empresa + " - " + row.nome + " - " + row.cnpj),
        tagClass: 'tag-gray',
        type: 'tagAutocomplete',
        tagMaxWidth: 900,
        maxTags: 1,
        onMaxTags: function(item, tag) {
            FLUIGC.toast({
                message: 'Apenas uma empresa pode ser selecionada, por favor remova a empresa atual.',
                type: 'warning',
                timeout: 'slow'
            });
        }
    });
    
    autoCompleteFiltroEmpresa.on('fluig.autocomplete.itemAdded', function(ev) {
    	$("#filtroEmpresaCodigo").val(autoCompleteFiltroEmpresa.items()[0]['empresa']);
    	$("#codigoEmpresa").val(autoCompleteFiltroEmpresa.items()[0]['empresa']);

    	prepareEnvironment();
    });

    autoCompleteFiltroEmpresa.on('fluig.autocomplete.itemRemoved', function(ev) {
        clearFiltroEmpresa();
    });
}


function clearFiltroEmpresa() {
    var autoCompleteFiltroEmpresa = FLUIGC.autocomplete('input#filtroEmpresa');
    if (typeof autoCompleteFiltroEmpresa != "undefined") {
        autoCompleteFiltroEmpresa.removeAll()
    }

	$("#filtroEmpresa").val("");
	$("#filtroEmpresaCodigo").val("");
	$("#codigoEmpresa").val("");
    
    cleanEnvironment();
}


function prepareEnvironment() {
	var myLoader = FLUIGC.loading(window, {
	    textMessage:  'Aguarde... Preparando ambiente!', 
	    title: null,
	    css: {
	        'padding': 0,
	        'margin': 0,
	        'width': '30%',
	        'top': '40%',
	        'left': '35%',
	        'textAlign': 'center',
	        'color': '#000000',
	        'border': '3px solid #aaaaaa',
	        'border-radius': '5px',
	        'backgroundColor':'#f0ea99',
	        'cursor': 'wait'
	    },
	    overlayCSS: { 
	        'backgroundColor': '#000', 
	        'opacity': 0.6, 
	        'border-radius': '5px',
	        'cursor': 'wait'
	    }, 
        	'border-radius': '5px',
	        'cursorReset': 'default',
	        'baseZ': 1000,
	        'centerX': true,
	        'centerY': true,
	        'bindEvents': true,
	        'fadeIn': 200,
	        'fadeOut': 400,
	        'timeout': 0,
	        'showOverlay': true, 
	        'onBlock': null,
	        'onUnblock': null,
	        'ignoreIfBlocked': false
	    }
	);
	
	myLoader.show();
	
	let myPromise = function promiseExecute() {
	    return new Promise((resolve, reject)=> {
	        setTimeout(
	            ()=> {
	                var constraintsFiliais = new Array();
	                constraintsFiliais.push(DatasetFactory.createConstraint("empresa", $('#filtroEmpresaCodigo').val(), $('#filtroEmpresaCodigo').val(), ConstraintType.MUST));
	            	datasetFiliais = DatasetFactory.getDataset('dsFiliaisGet', null, constraintsFiliais, null);

	                var constraintsFornecedores = new Array();
	                constraintsFornecedores.push(DatasetFactory.createConstraint("empresa", $('#filtroEmpresaCodigo').val(), $('#filtroEmpresaCodigo').val(), ConstraintType.MUST));
	            	datasetFornecedores = DatasetFactory.getDataset('dsFornecedoresOffLineGet', null, constraintsFornecedores, null);

	                var constraintsContratos = new Array();
	                constraintsContratos.push(DatasetFactory.createConstraint("empresa", $('#filtroEmpresaCodigo').val(), $('#filtroEmpresaCodigo').val(), ConstraintType.MUST));
	                var fields = ['noAttachments'];
	                datasetContratos = DatasetFactory.getDataset('dsContratosGet', fields, constraintsContratos, null);

	                var constraintsCentroCusto = new Array();
	                constraintsCentroCusto.push(DatasetFactory.createConstraint("empresa", $('#filtroEmpresaCodigo').val(), $('#filtroEmpresaCodigo').val(), ConstraintType.MUST));
	            	datasetCentroCusto = DatasetFactory.getDataset('dsCentroCustoGet', null, constraintsCentroCusto, null);

	                var constraintsTipoContrato = new Array();
	                constraintsTipoContrato.push(DatasetFactory.createConstraint("empresa", $('#filtroEmpresaCodigo').val(), $('#filtroEmpresaCodigo').val(), ConstraintType.MUST));
	            	datasetTipoContrato = DatasetFactory.getDataset('dsTipoContratoGet', null, constraintsTipoContrato, null);

	                var constraintsResponsaveisJuridicos = new Array();
	                constraintsResponsaveisJuridicos.push(DatasetFactory.createConstraint("empresa", $('#filtroEmpresaCodigo').val(), $('#filtroEmpresaCodigo').val(), ConstraintType.MUST));
	            	datasetResponsaveisJuridicos = DatasetFactory.getDataset('dsResponsaveisJuridicosGet', null, constraintsResponsaveisJuridicos, null);
	            	
	                resolve('ok');
            	}
	        );
	    });
	};	

	myPromise().then((results)=> {
		createAutoCompleteFiltroFilial();
		createAutoCompleteFiltroFornecedor();
		createAutoCompleteFiltroContrato();
	}).catch((error)=>{
	    FLUIGC.toast({
	        title: 'Leitura de Dados',
		    message: 'Falha na leitura dos registros!',
	        type: 'danger'
	    });
	});
	
	myLoader.hide();
}


function cleanEnvironment() {
    if ($.fn.dataTable.isDataTable('#dataBrowse')) {
        dataBrowse.destroy();
        $('#dataBrowse').empty();
    }
	
	clearFiltroFilial();
    if (typeof autoCompleteFiltroFilial != "undefined") {
    	autoCompleteFiltroFilial.destroy();
        delete autoCompleteFiltroFilial;
    }

	clearFiltroFornecedor();
    if (typeof autoCompleteFiltroFornecedor != "undefined") {
    	autoCompleteFiltroFornecedor.destroy();
        delete autoCompleteFiltroFornecedor;
    }

	clearFiltroContrato();
    if (typeof autoCompleteFiltroContrato != "undefined") {
    	autoCompleteFiltroContrato.destroy();
        delete autoCompleteFiltroContrato;
    }

	clearFornecedor();
    if (typeof autoCompleteFornecedor != "undefined") {
    	autoCompleteFornecedor.destroy();
        delete autoCompleteFornecedor;
    }

	clearContrato();
    if (typeof autoCompleteContrato != "undefined") {
    	autoCompleteContrato.destroy();
        delete autoCompleteContrato;
    }

	clearSituacaoContrato();
    if (typeof autoCompleteSituacaoContrato != "undefined") {
    	autoCompleteSituacaoContrato.destroy();
        delete autoCompleteSituacaoContrato;
    }

	clearTipoRevisao();
    if (typeof autoCompleteTipoRevisao != "undefined") {
    	autoCompleteTipoRevisao.destroy();
        delete autoCompleteTipoRevisao;
    }

	clearCentroCusto();
    if (typeof autoCompleteCentroCusto != "undefined") {
    	autoCompleteCentroCusto.destroy();
        delete autoCompleteCentroCusto;
    }

	clearTipoContrato();
    if (typeof autoCompleteTipoContrato != "undefined") {
    	autoCompleteTipoContrato.destroy();
        delete autoCompleteTipoContrato;
    }

	clearResponsavelJuridico();
    if (typeof autoCompleteResponsavelJuridico != "undefined") {
    	autoCompleteResponsavelJuridico.destroy();
        delete autoCompleteResponsavelJuridico;
    }
}


function createAutoCompleteFiltroFilial() {
    if (typeof autoCompleteFiltroFilial != "undefined") {
        autoCompleteFiltroFilial.destroy();
        delete autoCompleteFiltroFilial;
    }
    
    autoCompleteFiltroFilial = FLUIGC.autocomplete('#filtroFilial', {
        source: (text, autocomplete) => {
            let data = datasetFiliais.values;
            let columns = ['filial','nome','cnpj','cidade','estado'];
            let matches = []
            let regex = new RegExp(text, 'i')

            data.forEach((item) => {
                if (columns && columns.length > 0) {
                    for (let index = 0; index < columns.length; index++) {
                        if (regex.test(item[columns[index]])) {
                            matches.push(item)
                            break;
                        }
                    }
                }
            })
            autocomplete(matches)
        },
        displayKey: row => (row.empresa + " - " + row.nome + " - " + row.cnpj),
        tagClass: 'tag-gray',
        type: 'tagAutocomplete',
        tagMaxWidth: 900,
        maxTags: 1,
        onMaxTags: function(item, tag) {
            FLUIGC.toast({
                message: 'Apenas uma filial pode ser selecionada, por favor remova a filial atual.',
                type: 'warning',
                timeout: 'slow'
            });
        }
    });
    
    autoCompleteFiltroFilial.on('fluig.autocomplete.itemAdded', function(ev) {
    	$("#filtroFilialCodigo").val(autoCompleteFiltroFilial.items()[0]['filial']);
    	$("#codigoFilial").val(autoCompleteFiltroFilial.items()[0]['filial']);
    });

    autoCompleteFiltroFilial.on('fluig.autocomplete.itemRemoved', function(ev) {
        clearFiltroFilial();
    });
}


function clearFiltroFilial() {
    var autoCompleteFiltroFilial = FLUIGC.autocomplete('input#filtroFilial');
    if (typeof autoCompleteFiltroFilial != "undefined") {
        autoCompleteFiltroFilial.removeAll()
    }
    
	$("#filtroFilial").val("");
	$("#filtroFilialCodigo").val("");
	$("#codigoFilial").val("");
}


function createAutoCompleteFiltroFornecedor() {
    if (typeof autoCompleteFiltroFornecedor != "undefined") {
        autoCompleteFiltroFornecedor.destroy();
        delete autoCompleteFiltroFornecedor;
    }
    
    autoCompleteFiltroFornecedor = FLUIGC.autocomplete('#filtroFornecedor', {
        source: (text, autocomplete) => {
            let data = datasetFornecedores.values;
            let columns = ['nome','codigo','loja','cgc'];
            let matches = []
            let regex = new RegExp(text, 'i')

            data.forEach((item) => {
                if (columns && columns.length > 0) {
                    for (let index = 0; index < columns.length; index++) {
                        if (regex.test(item[columns[index]])) {
                            matches.push(item)
                            break;
                        }
                    }
                }
            })
            autocomplete(matches)
        },
        displayKey: row => (row.nome + " - " + row.codigo + " - " + row.loja + " - " + row.cgc),
        tagClass: 'tag-gray',
        type: 'tagAutocomplete',
        tagMaxWidth: 900,
        maxTags: 1,
        onMaxTags: function(item, tag) {
            FLUIGC.toast({
                message: 'Apenas um fornecedor pode ser selecionado, por favor remova o fornecedor atual.',
                type: 'warning',
                timeout: 'slow'
            });
        }
    });
    
    autoCompleteFiltroFornecedor.on('fluig.autocomplete.itemAdded', function(ev) {
    	$("#filtroFornecedorCodigo").val(autoCompleteFiltroFornecedor.items()[0]['codigo']);
    	$("#filtroFornecedorLoja").val(autoCompleteFiltroFornecedor.items()[0]['loja']);
    });

    autoCompleteFiltroFornecedor.on('fluig.autocomplete.itemRemoved', function(ev) {
        clearFiltroFornecedor();
    });
}


function clearFiltroFornecedor() {
    var autoCompleteFiltroFornecedor = FLUIGC.autocomplete('input#filtroFornecedor');
    if (typeof autoCompleteFiltroFornecedor != "undefined") {
        autoCompleteFiltroFornecedor.removeAll()
    }
    
    $("#filtroFornecedorCodigo").val("");
    $("#filtroFornecedorLoja").val("");
}


function createAutoCompleteFiltroContrato() {
    if (typeof autoCompleteFiltroContrato != "undefined") {
        autoCompleteFiltroContrato.destroy();
        delete autoCompleteFiltroContrato;
    }
    
    autoCompleteFiltroContrato = FLUIGC.autocomplete('#filtroContrato', {
        source: (text, autocomplete) => {
            let data = datasetContratos.values;
            let columns = ['numero','origem','revisao','nome','cnpj'];
            let matches = []
            let regex = new RegExp(text, 'i')

            data.forEach((item) => {
                if (columns && columns.length > 0) {
                    for (let index = 0; index < columns.length; index++) {
                        if (regex.test(item[columns[index]])) {
                            matches.push(item)
                            break;
                        }
                    }
                }
            })
            autocomplete(matches)
        },
        displayKey: row => (row.numero + " - " + row.origem + " - " + row.revisao + " - " + row.nome + " - " + row.cnpj),
        tagClass: 'tag-gray',
        type: 'tagAutocomplete',
        tagMaxWidth: 900,
        maxTags: 1,
        onMaxTags: function(item, tag) {
            FLUIGC.toast({
                message: 'Apenas um contrato pode ser selecionada, por favor remova o contrato atual.',
                type: 'warning',
                timeout: 'slow'
            });
        }
    });
    
    autoCompleteFiltroContrato.on('fluig.autocomplete.itemAdded', function(ev) {
    	$("#filtroContratoNumero").val(autoCompleteFiltroContrato.items()[0]['numero']);
    	$("#filtroContratoOrigem").val(autoCompleteFiltroContrato.items()[0]['origem']);
    });

    autoCompleteFiltroContrato.on('fluig.autocomplete.itemRemoved', function(ev) {
        clearFiltroContrato();
    });
}


function clearFiltroContrato() {
    var autoCompleteFiltroContrato = FLUIGC.autocomplete('input#filtroContrato');
    if (typeof autoCompleteFiltroContrato != "undefined") {
        autoCompleteFiltroContrato.removeAll()
    }
    
	$("#filtroContrato").val("");
	$("#filtroContratoNumero").val("");
	$("#filtroContratoOrigem").val("");
}


function createAutoCompleteTipoRevisao() {
    if (typeof autoCompleteTipoRevisao != "undefined") {
        autoCompleteTipoRevisao.destroy();
        delete autoCompleteTipoRevisao;
    }
    
    autoCompleteTipoRevisao = FLUIGC.autocomplete('#tipoRevisao', {
        source: (text, autocomplete) => {
            let data = datasetTipoRevisao.values;
            let columns = ['codigo','descricao'];
            let matches = []
            let regex = new RegExp(text, 'i')

            data.forEach((item) => {
                if (columns && columns.length > 0) {
                    for (let index = 0; index < columns.length; index++) {
                        if (regex.test(item[columns[index]])) {
                            matches.push(item)
                            break;
                        }
                    }
                }
            })
            autocomplete(matches)
        },
        displayKey: row => (row.descricao),
        tagClass: 'tag-gray',
        type: 'tagAutocomplete',
        tagMaxWidth: 900,
        maxTags: 1,
        onMaxTags: function(item, tag) {
            FLUIGC.toast({
                message: 'Apenas um tipo de revisão pode ser selecionado, por favor remova o tipo de revisão atual.',
                type: 'warning',
                timeout: 'slow'
            });
        }
    });
    
    autoCompleteTipoRevisao.on('fluig.autocomplete.itemAdded', function(ev) {
    	$("#codigoTipoRevisao").val(autoCompleteTipoRevisao.items()[0]['codigo']);
    });

    autoCompleteTipoRevisao.on('fluig.autocomplete.itemRemoved', function(ev) {
        clearTipoRevisao();
    });
}


function clearTipoRevisao() {
    var autoCompleteTipoRevisao = FLUIGC.autocomplete('input#TipoRevisao');
    if (typeof autoCompleteTipoRevisao != "undefined") {
        autoCompleteTipoRevisao.removeAll()
    }
    
    $("#codigoTipoRevisao").val("");
}


function createAutoCompleteCentroCusto() {
    if (typeof autoCompleteCentroCusto != "undefined") {
        autoCompleteCentroCusto.destroy();
        delete autoCompleteCentroCusto;
    }
    
    autoCompleteCentroCusto = FLUIGC.autocomplete('#centroDeCusto', {
        source: (text, autocomplete) => {
            let data = datasetCentroCusto.values;
            let columns = ['codigo','descricao','classe'];
            let matches = []
            let regex = new RegExp(text, 'i')

            data.forEach((item) => {
                if (columns && columns.length > 0) {
                    for (let index = 0; index < columns.length; index++) {
                        if (regex.test(item[columns[index]])) {
                            matches.push(item)
                            break;
                        }
                    }
                }
            })
            autocomplete(matches)
        },
        displayKey: row => (row.codigo + " - " + row.descricao + " - " + row.classe),
        tagClass: 'tag-gray',
        type: 'tagAutocomplete',
        tagMaxWidth: 900,
        maxTags: 1,
        onMaxTags: function(item, tag) {
            FLUIGC.toast({
                message: 'Apenas um centro de custo pode ser selecionado, por favor remova o centro de custo atual.',
                type: 'warning',
                timeout: 'slow'
            });
        }
    });
    
    autoCompleteCentroCusto.on('fluig.autocomplete.itemAdded', function(ev) {
    	$("#codigoCentroDeCusto").val(autoCompleteCentroCusto.items()[0]['codigo']);
    });

    autoCompleteCentroCusto.on('fluig.autocomplete.itemRemoved', function(ev) {
        clearCentroDeCusto();
    });
}


function clearCentroCusto() {
    var autoCompleteCentroCusto = FLUIGC.autocomplete('input#CentroCusto');
    if (typeof autoCompleteCentroCusto != "undefined") {
        autoCompleteCentroCusto.removeAll()
    }
    
    $("#codigoCentroCusto").val("");
}


function createAutoCompleteTipoContrato() {
    if (typeof autoCompleteTipoContrato != "undefined") {
        autoCompleteTipoContrato.destroy();
        delete autoCompleteTipoContrato;
    }
    
    autoCompleteTipoContrato = FLUIGC.autocomplete('#tipoContrato', {
        source: (text, autocomplete) => {
            let data = datasetTipoContrato.values;
            let columns = ['codigo','descricao'];
            let matches = []
            let regex = new RegExp(text, 'i')

            data.forEach((item) => {
                if (columns && columns.length > 0) {
                    for (let index = 0; index < columns.length; index++) {
                        if (regex.test(item[columns[index]])) {
                            matches.push(item)
                            break;
                        }
                    }
                }
            })
            autocomplete(matches)
        },
        displayKey: row => (row.codigo + " - " + row.descricao),
        tagClass: 'tag-gray',
        type: 'tagAutocomplete',
        tagMaxWidth: 900,
        maxTags: 1,
        onMaxTags: function(item, tag) {
            FLUIGC.toast({
                message: 'Apenas um tipo de contrato pode ser selecionado, por favor remova o tipo de contrato atual.',
                type: 'warning',
                timeout: 'slow'
            });
        }
    });
    
    autoCompleteTipoContrato.on('fluig.autocomplete.itemAdded', function(ev) {
    	$("#codigoTipoContrato").val(autoCompleteTipoContrato.items()[0]['codigo']);
    });

    autoCompleteTipoContrato.on('fluig.autocomplete.itemRemoved', function(ev) {
        clearTipoContrato();
    });
}


function clearTipoContrato() {
    var autoCompleteTipoContrato = FLUIGC.autocomplete('input#TipoContrato');
    if (typeof autoCompleteTipoContrato != "undefined") {
        autoCompleteTipoContrato.removeAll()
    }
    
    $("#codigoTipoContrato").val("");
}


function createAutoCompleteSituacaoContrato() {
    if (typeof autoCompleteSituacaoContrato != "undefined") {
        autoCompleteSituacaoContrato.destroy();
        delete autoCompleteSituacaoContrato;
    }
    
    autoCompleteSituacaoContrato = FLUIGC.autocomplete('#situacaoContrato', {
        source: (text, autocomplete) => {
            let data = datasetSituacaoContrato.values;
            let columns = ['codigo','descricao'];
            let matches = []
            let regex = new RegExp(text, 'i')

            data.forEach((item) => {
                if (columns && columns.length > 0) {
                    for (let index = 0; index < columns.length; index++) {
                        if (regex.test(item[columns[index]])) {
                            matches.push(item)
                            break;
                        }
                    }
                }
            })
            autocomplete(matches)
        },
        displayKey: row => (row.codigo + " - " + row.descricao),
        tagClass: 'tag-gray',
        type: 'tagAutocomplete',
        tagMaxWidth: 900,
        maxTags: 1,
        onMaxTags: function(item, tag) {
            FLUIGC.toast({
                message: 'Apenas uma situação de contrato pode ser selecionada, por favor remova a situação de contrato atual.',
                type: 'warning',
                timeout: 'slow'
            });
        }
    });
    
    autoCompleteSituacaoContrato.on('fluig.autocomplete.itemAdded', function(ev) {
    	$("#codigoSituacaoContrato").val(autoCompleteSituacaoContrato.items()[0]['codigo']);
    });

    autoCompleteSituacaoContrato.on('fluig.autocomplete.itemRemoved', function(ev) {
        clearSituacaoContrato();
    });
}


function clearSituacaoContrato() {
    var autoCompleteSituacaoContrato = FLUIGC.autocomplete('input#SituacaoContrato');
    if (typeof autoCompleteSituacaoContrato != "undefined") {
        autoCompleteSituacaoContrato.removeAll()
    }
    
    $("#codigoSituacaoContrato").val("");
}


function createAutoCompleteFornecedor() {
    if (typeof autoCompleteFornecedor != "undefined") {
        autoCompleteFornecedor.destroy();
        delete autoCompleteFornecedor;
    }
    
    autoCompleteFornecedor = FLUIGC.autocomplete('#fornecedor', {
        source: (text, autocomplete) => {
            let data = datasetFornecedores.values;
            let columns = ['nome','codigo','loja','cgc'];
            let matches = []
            let regex = new RegExp(text, 'i')

            data.forEach((item) => {
                if (columns && columns.length > 0) {
                    for (let index = 0; index < columns.length; index++) {
                        if (regex.test(item[columns[index]])) {
                            matches.push(item)
                            break;
                        }
                    }
                }
            })
            autocomplete(matches)
        },
        displayKey: row => (row.nome + " - " + row.codigo + " - " + row.loja + " - " + row.cgc),
        tagClass: 'tag-gray',
        type: 'tagAutocomplete',
        tagMaxWidth: 900,
        maxTags: 1,
        onMaxTags: function(item, tag) {
            FLUIGC.toast({
                message: 'Apenas um fornecedor pode ser selecionado, por favor remova o fornecedor atual.',
                type: 'warning',
                timeout: 'slow'
            });
        }
    });
    
    autoCompleteFornecedor.on('fluig.autocomplete.itemAdded', function(ev) {
    	$("#codigoFornecedor").val(autoCompleteFornecedor.items()[0]['codigo']);
    	$("#lojaFornecedor").val(autoCompleteFornecedor.items()[0]['loja']);
    	$("#endFornecedor").val(autoCompleteFornecedor.items()[0]['endereco']);
    	$("#bairroFornecedor").val(autoCompleteFornecedor.items()[0]['bairro']);
    	$("#cepFornecedor").val(autoCompleteFornecedor.items()[0]['cep']);
    	$("#cidadeFornecedor").val(autoCompleteFornecedor.items()[0]['cidade']);
    	$("#estadoFornecedor").val(autoCompleteFornecedor.items()[0]['estado']);
    });

    autoCompleteFornecedor.on('fluig.autocomplete.itemRemoved', function(ev) {
        clearFornecedor();
    });
}


function clearFornecedor() {
    var autoCompleteFornecedor = FLUIGC.autocomplete('input#Fornecedor');
    if (typeof autoCompleteFornecedor != "undefined") {
        autoCompleteFornecedor.removeAll()
    }
    
    $("#codigoFornecedor").val("");
    $("#lojaFornecedor").val("");
    $("#endFornecedor").val("");
	$("#bairroFornecedor").val("");
	$("#cepFornecedor").val("");
	$("#cidadeFornecedor").val("");
	$("#estadoFornecedor").val("");
}


function createAutoCompleteResponsavelJuridico() {
    if (typeof autoCompleteResponsavelJuridico != "undefined") {
        autoCompleteResponsavelJuridico.destroy();
        delete autoCompleteResponsavelJuridico;
    }
    
    autoCompleteResponsavelJuridico = FLUIGC.autocomplete('#responsavelJuridico', {
        source: (text, autocomplete) => {
            let data = datasetResponsaveisJuridicos.values;
            let columns = ['nome','login'];
            let matches = []
            let regex = new RegExp(text, 'i')

            data.forEach((item) => {
                if (columns && columns.length > 0) {
                    for (let index = 0; index < columns.length; index++) {
                        if (regex.test(item[columns[index]])) {
                            matches.push(item)
                            break;
                        }
                    }
                }
            })
            autocomplete(matches)
        },
        displayKey: row => (row.nome + " - " + row.login),
        tagClass: 'tag-gray',
        type: 'tagAutocomplete',
        tagMaxWidth: 900,
        maxTags: 1,
        onMaxTags: function(item, tag) {
            FLUIGC.toast({
                message: 'Apenas um responsável jurídico pode ser selecionado, por favor remova o responsável jurídico atual.',
                type: 'warning',
                timeout: 'slow'
            });
        }
    });
    
    autoCompleteResponsavelJuridico.on('fluig.autocomplete.itemAdded', function(ev) {
    	$("#loginResponsavelJuridico").val(autoCompleteResponsavelJuridico.items()[0]['login']);
    });

    autoCompleteResponsavelJuridico.on('fluig.autocomplete.itemRemoved', function(ev) {
        clearResponsavelJuridico();
    });
}


function clearResponsavelJuridico() {
    var autoCompleteResponsavelJuridico = FLUIGC.autocomplete('input#ResponsavelJuridico');
    if (typeof autoCompleteResponsavelJuridico != "undefined") {
        autoCompleteResponsavelJuridico.removeAll()
    }
    
    $("#loginResponsavelJuridico").val("");
}


function enviar() {
	var messages = "";

    if (messages != "") {
        FLUIGC.toast({
            message: messages,
            type: 'warning',
            timeout: 'slow'
        });

        return false;
    }
    
    loadSearch();
}


function limpar() {
    clearFiltroEmpresa();
	
    if ($.fn.dataTable.isDataTable('#dataBrowse')) {
        dataBrowse.destroy();
        $('#dataBrowse').empty();
    }
}


function dateConvert(date) {
	day = date.substring(6, 8);
	month = date.substring(4, 6);
	year = date.substring(0, 4);

	return(day + "/" + month + "/" + year);
}


function valueConvert(value, decimals) {
	if (decimals == null) {
		decimals = 2;
	}
	
	var value = value.toLocaleString('pt-br', {minimumFractionDigits: decimals});
	return(value); 
}


function show(frame) {
	$(document).find(".main-screen").each(function() {
		if (frame == 'main') {
			$(this).show();
		} else {
			$(this).hide();
		}
	});	
	
	$(document).find(".toolbar-panel").each(function() {
		if (frame != 'main') {
			$(this).show();
		} else {
			$(this).hide();
		}
	});	

	$(document).find(".tab-container").each(function() {
		if (frame == 'contrato-data' || frame == 'contrato-attach') {
			$(this).show();
		} else {
			$(this).hide();
		}
	});

	$(document).find(".tabs").each(function() {
		if (frame == 'contrato-data' || frame == 'contrato-attach') {
			$(this).show();
		} else {
			$(this).hide();
		}
	});
	
	$(document).find(".contrato-ident").each(function() {
		if (frame == 'contrato-data' || frame == 'contrato-attach') {
			$(this).show();
		} else {
			$(this).hide();
		}
	});	

	$(document).find(".contrato-data").each(function() {
		if (frame == 'contrato-data') {
			$(this).show();
		} else {
			$(this).hide();
		}
	});	

	$(document).find(".contrato-attach").each(function() {
		if (frame == 'contrato-attach') {
			$(this).show();
		} else {
			$(this).hide();
		}
	});	
}


function tabChange(el) {
	$(document).find(".tab").each(function() {
		$(this).removeClass("tab-checked");
	});	

	$(el).addClass("tab-checked");
	
	if (el.id == 'tab-1') {
		show('contrato-data');
	} else if (el.id == 'tab-2') {
		show('contrato-attach');
	}
}


function loadSearch() {
	var myLoader = FLUIGC.loading("#filterPanel");
	myLoader.show();
	
	let myPromise = function promiseExecute() {
	    return new Promise((resolve, reject)=> {
	        setTimeout(
	            ()=> {
					var myData = [];
					
					var constraints = new Array();
				    constraints.push(DatasetFactory.createConstraint("empresa", $("#filtroEmpresaCodigo").val(), $("#filtroEmpresaCodigo").val(), ConstraintType.MUST));
				    constraints.push(DatasetFactory.createConstraint("filial", $("#filtroFilialCodigo").val(), $("#filtroFilialCodigo").val(), ConstraintType.MUST));
				    
					if ($("#filtroFornecedorCodigo").val() != '') {
					    constraints.push(DatasetFactory.createConstraint("fornecedor", $("#filtroFornecedorCodigo").val(), $("#filtroFornecedorCodigo").val(), ConstraintType.MUST));
					}
				    
					if ($("#filtroFornecedorLoja").val() != '') {
					    constraints.push(DatasetFactory.createConstraint("loja", $("#filtroFornecedorLoja").val(), $("#filtroFornecedorLoja").val(), ConstraintType.MUST));
					}

					if ($("#filtroDataContratoInicial").val() != '' || $("#filtroDataContratoFinal").val() != '') {
					    constraints.push(DatasetFactory.createConstraint("dataInicio", $("#filtroDataContratoInicial").val().replace(/-/g, ""), $("#filtroDataContratoFinal").val().replace(/-/g, ""), ConstraintType.MUST));
					}

					if ($("#filtroContratoNumero").val() != '') {
					    constraints.push(DatasetFactory.createConstraint("numero", $("#filtroContratoNumero").val(), $("#filtroContratoNumero").val(), ConstraintType.MUST));
					}

					var origem = "";
				    if ($('#filtroOrigem1').prop('checked')) {
				    	origem = "FLUIG";
				    } else if ($('#filtroOrigem2').prop('checked')) {
				    	origem = "PROTHEUS";
				    } else if ($('#filtroOrigem99').prop('checked')) {
				    	origem = "";
				    } 
					
				    if (origem != "") {
					    constraints.push(DatasetFactory.createConstraint("origem", origem, origem, ConstraintType.MUST));
				    }

					var fields = ["noAttachments"];
				    var dataset = DatasetFactory.getDataset("dsContratosGet", fields, constraints, null);
					if (dataset != null && dataset.values != null && dataset.values.length > 0) {
				    	var records = dataset.values;
				    	var rowClass = 'row-blue';
				    	
				    	for (var index in records) {
				    	    var record = records[index];
				    	    
				    	    if (rowClass == 'row-blue') {
								rowClass = 'row-gray';
							} else {
								rowClass = 'row-blue';
							}
				    	    
				    	    myData.push({
								row: rowClass,
				    	        filial: record.filial,
				    	        numero: record.numero,
				    	        origem: record.origem,
				    	        revisao: record.revisao,
				    	        centroCusto: record.centroCusto,
				    	        situacao: record.situacao,
				    	        fornecedor: record.fornecedor,
				    	        loja: record.loja,
				    	        nome: record.nome,
				    	        tipoContrato: record.tipoContrato,
				    	        dataInicio: dateConvert(record.dataInicio), 
				    	        valor: valueConvert(record.valor),
				    	        view: "<div class='btn-panel' styles='padding-left: 20px !important; text-align: center !important;'><a href='#' tooltip='Visualizar' id='row" + index + "' class='btn btn-info btn-icon' onclick='contratoView(\"" + record.numero + '","' + record.origem + '","' + record.revisao + "\")'><i class='flaticon flaticon-pageview icon-md' aria-hidden='true'></i></a></div>",
				    	        edit: "<div class='btn-panel' styles='padding-left: 20px !important; text-align: center !important;'><a href='#' tooltip='Alterar' id='row" + index + "' class='btn btn-success btn-icon' onclick='contratoEdit(\"" + record.numero + '","' + record.origem + '","' + record.revisao + "\")'><i class='flaticon flaticon-edit-square icon-md' aria-hidden='true'></i></a></div>",
				    	        noResults: false
				    	    });
				    	}
					}

	                resolve(myData);
            	}
	        );
	    });
	};	

	myPromise().then((results)=> {
	    if ($.fn.dataTable.isDataTable('#dataBrowse')) {
	        dataBrowse.destroy();
	    }

	    dataBrowse = $('#dataBrowse').DataTable({
	        dom: '<<"dataTables_top"lf><t><"dataTables_bottom"ip>>',
	        paging: true,
	        lengthMenu: [
	            [ 10, 25, 50, -1 ],
	            [ '10 linhas', '25 linhas', '50 linhas', 'Todas as linhas' ]
	        ],
	        buttons: [
	            'pageLength'
	        ],
	        data: results,
	        responsive: true,
	        scroller: false,
	        ordering: false,
	        destroy: true,
	        columns: [
	        	{
	                title: 'Filial',
	                data: 'filial',
	                defaultContent: "",
	                width: "5%"
	            }, {
	                title: 'N&uacute;mero',
	                data: 'numero',
	                defaultContent: "",
	                width: "10%"
	            }, {
	                title: 'Origem',
	                data: 'origem',
	                defaultContent: "",
	                width: "5%"
	            }, {
	                title: 'Revis&atilde;o',
	                data: 'revisao',
	                defaultContent: "",
	                width: "5%"
	            }, {
	                title: 'C.Custo',
	                data: 'centroCusto',
	                defaultContent: "",
	                width: "10%"
	            }, {
	                title: 'Sit',
	                data: 'situacao',
	                defaultContent: "",
	                width: "5%"
	            }, {
	                title: 'Fornecedor',
	                data: 'fornecedor',
	                defaultContent: "",
	                width: "10%"
	            }, {
	                title: 'loja',
	                data: 'loja',
	                defaultContent: "",
	                width: "5%"
	            }, {
	                title: 'Nome Fornecedor',
	                data: 'nome',
	                defaultContent: "",
	                width: "35%"
	            }, {
	                title: 'Tipo',
	                data: 'tipoContrato',
	                defaultContent: "",
	                width: "5%"
	            }, {
	                title: 'Data Contrato',
	                data: 'dataInicio',
	                defaultContent: "",
	                width: "10%"
	            }, {
	                title: 'Valor',
	                data: 'valor',
	                defaultContent: "",
	                width: "12%"
	            }, {
	                title: '',
	                data: 'view',
	                defaultContent: "",
	                width: "1%"
	            }, {
	                title: "<div class='btn-panel' styles='padding-left: 20px !important; text-align: center !important;'><a href='#' tooltip='Adicionar' id='addContato' class='btn btn-primary btn-icon' onclick='contratoAdd()'><i class='flaticon flaticon-add-box icon-md' aria-hidden='true'></i></a></div>",
	                data: 'edit',
	                defaultContent: "",
	                width: "1%"
	            }
	        ],
		    rowCallback: function (row, data) {
		        $(row).addClass(data.row);
		    }, 
	        language:{
	            "sEmptyTable": "Nenhum registro encontrado",
	            "sInfo": "Mostrando de _START_ até _END_ de _TOTAL_ registros",
	            "sInfoEmpty": "Mostrando 0 até 0 de 0 registros",
	            "sInfoFiltered": "(Filtrados de _MAX_ registros)",
	            "sInfoPostFix": "",
	            "sInfoThousands": ".",
	            "sLengthMenu": "_MENU_ resultados por página",
	            "sLoadingRecords": "Carregando...",
	            "sProcessing": "Processando...",
	            "sZeroRecords": "Nenhum registro encontrado",
	            "sSearch": "Pesquisar ",
	            "oPaginate": {
	                "sNext": "Próximo",
	                "sPrevious": "Anterior",
	                "sFirst": "Primeiro",
	                "sLast": "Último"
	            },
	            "oAria": {
	                "sSortAscending": ": Ordenar colunas de forma ascendente",
	                "sSortDescending": ": Ordenar colunas de forma descendente"
	            }
	        }
	    });
	}).catch((error)=>{
	    FLUIGC.toast({
	        title: 'Leitura de Dados',
		    message: 'Falha na leitura dos registros!',
	        type: 'danger'
	    });
	});
	
	myLoader.hide();
};


function contratoAdd(contrato) {
	formShow("add", contrato, origem, revisao);
};


function contratoView(contrato, origem, revisao) {
	formShow("view", contrato, origem, revisao);
};


function contratoEdit(contrato, origem, revisao) {
	formShow("edit", contrato, origem, revisao);
};

function formShow(method, contrato, origem, revisao) {
	if ($("#filtroFilialCodigo").val() == '') {
	    FLUIGC.toast({
	        title: 'Filial não informado',
		    message: 'Favor informar a filial para prosseguir!',
	        type: 'danger'
	    });
	    
	    return false;
	}
	
	var myLoader = FLUIGC.loading('#mainDataBrowse');
	myLoader.show();
	
	let myPromise = function promiseExecute() {
	    return new Promise((resolve, reject)=> {
	        setTimeout(
	            ()=> {
					var myData = [];
	            	
	            	if (method == 'view') {
	            		$(document).find(".apply-sensitive").each(function() {
	            			$(this).attr("readonly", true);
	            		});	

	            		$(document).find(".apply-hidden").each(function() {
	            			$(this).hide();
	            		});

	            	    if (typeof autoCompleteTipoRevisao != "undefined") {
	            	    	autoCompleteTipoRevisao.destroy();
	            	        delete autoCompleteTipoRevisao;
	            	    }

	            	    if (typeof autoCompleteCentroCusto != "undefined") {
	            	    	autoCompleteCentroCusto.destroy();
	            	        delete autoCompleteCentroCusto;
	            	    }

	            	    if (typeof autoCompleteTipoContrato != "undefined") {
	            	    	autoCompleteTipoContrato.destroy();
	            	        delete autoCompleteTipoContrato;
	            	    }

	            	    if (typeof autoCompleteSituacaoContrato != "undefined") {
	            	    	autoCompleteSituacaoContrato.destroy();
	            	        delete autoCompleteSituacaoContrato;
	            	    }
	            		
	            	    if (typeof autoCompleteFornecedor != "undefined") {
	            	    	autoCompleteFornecedor.destroy();
	            	        delete autoCompleteFornecedor;
	            	    }

	            	    if (typeof autoCompleteResponsavelJuridico != "undefined") {
	            	    	autoCompleteResponsavelJuridico.destroy();
	            	        delete autoCompleteResponsavelJuridico;
	            	    }
	            	} else {
	            		$(document).find(".apply-sensitive").each(function() {
	            			$(this).attr("readonly", false);
	            		});	

	            		$(document).find(".apply-hidden").each(function() {
	            			$(this).show();
	            		});	
	            		
	            		if (method == "add") {
		            	    createAutoCompleteTipoRevisao();
	            		} else {
		            	    if (typeof autoCompleteTipoRevisao != "undefined") {
		            	    	autoCompleteTipoRevisao.destroy();
		            	        delete autoCompleteTipoRevisao;
		            	    }

		            	    $(document).find(".apply-no-insert").each(function() {
		            			$(this).attr("readonly", true);
		            		});	
	            		}
	            		
	            		createAutoCompleteCentroCusto();
	            		createAutoCompleteTipoContrato();
	            	    createAutoCompleteSituacaoContrato();
	            		createAutoCompleteFornecedor();
	            		createAutoCompleteResponsavelJuridico();
	            	} 
	            	
	            	$("#empresa").val($("#filtroEmpresa").val());
	            	$("#codigoEmpresa").val($("#filtroEmpresaCodigo").val());
	            	$("#filial").val($("#filtroFilial").val());
	            	$("#codigoFilial").val($("#filtroFilialCodigo").val());
	            	
	            	if (method == "add") {
	            		$("#numeroContrato").val(contrato);
	            		$("#origem").val("FLUIG");
	            		$("#revisao").val(revisao);
	            		
	            		if (contrato != "") {
	            	        var constraintsRevisao = new Array();
	            	        constraintsRevisao.push(DatasetFactory.createConstraint("empresa", $('#codigoEmpresa').val(), $('#codigoEmpresa').val(), ConstraintType.MUST));
	            	        constraintsRevisao.push(DatasetFactory.createConstraint("filial", $('#codigoFilial').val(), $('#codigoFilial').val(), ConstraintType.MUST));
	            	        constraintsRevisao.push(DatasetFactory.createConstraint("numero", contrato, contrato, ConstraintType.MUST));
	            	        datasetRevisao = DatasetFactory.getDataset('dsNextContratoFluigGet', null, constraintsRevisao, null);
	            			
	            	        if (datasetRevisao.values.length > 0) {
	            	        	$("#revisao").val(datasetRevisao.values[0]['revisao']);
	            	        }
	            		} 
	            	} else {
	                    var constraintsContratos = new Array();
	                    constraintsContratos.push(DatasetFactory.createConstraint("empresa", $('#codigoEmpresa').val(), $('#codigoEmpresa').val(), ConstraintType.MUST));
	                    constraintsContratos.push(DatasetFactory.createConstraint("filial", $('#codigoFilial').val(), $('#codigoFilial').val(), ConstraintType.MUST));
	                    constraintsContratos.push(DatasetFactory.createConstraint("numero", contrato, contrato, ConstraintType.MUST));
	                    constraintsContratos.push(DatasetFactory.createConstraint("origem", origem, origem, ConstraintType.MUST));
	                    constraintsContratos.push(DatasetFactory.createConstraint("revisao", revisao, revisao, ConstraintType.MUST));
	                    datasetContratos = DatasetFactory.getDataset('dsContratosGet', null, constraintsContratos, null);
	                    
	                    if (datasetContratos.values.length > 0) {
	                    	$("#numeroContrato").val(datasetContratos.values[0]['numero']);
	                    	$("#origem").val(datasetContratos.values[0]['origem']);
	                    	$("#revisao").val(datasetContratos.values[0]['revisao']);

	                    	$("#tipoRevisao").val(datasetContratos.values[0]['descricaoTipoRevisao']);
	                    	$("#codigoTipoRevisao").val(datasetContratos.values[0]['tipoRevisao']);

		            	    if (typeof autoCompleteTipoRevisao != "undefined") {
		            	    	let tagData = {
		            	    		codigo: datasetContratos.values[0]['tipoRevisao'],
		            	    		descricao: datasetContratos.values[0]['descricaoTipoRevisao']
		            	    	};

		            	    	autoCompleteTipoRevisao.add(tagData);
		            	    }
	                    	
	                    	$("#justificativa").val(datasetContratos.values[0]['justificativa']);
	                    	$("#objeto").val(datasetContratos.values[0]['objeto']);
	                    	$("#centroDeCusto").val(datasetContratos.values[0]['descricaoCentroCusto']);
	                    	$("#codigoCentroDeCusto").val(datasetContratos.values[0]['centroCusto']);
	                    	
		            	    if (typeof autoCompleteCentroCusto != "undefined") {
		            	    	let tagData = {
		            	    		codigo: datasetContratos.values[0]['centroCusto'],
		            	    		descricao: datasetContratos.values[0]['descricaoCentroCusto'],
		            	    		classe: datasetContratos.values[0]['classeCentroCusto']
			            	    };
		            	    	
		            	    	autoCompleteCentroCusto.add(tagData);
		            	    }
	                    	
	                    	$("#tipoContrato").val(datasetContratos.values[0]['descricaoTipoContrato']);
	                    	$("#codigoTipoContrato").val(datasetContratos.values[0]['tipoContrato']);

		            	    if (typeof autoCompleteTipoContrato != "undefined") {
		            	    	let tagData = {
		            	    		codigo: datasetContratos.values[0]['tipoContrato'],
		            	    		descricao: datasetContratos.values[0]['descricaoTipoContrato']
			            	    };
		            	    	
		            	    	autoCompleteTipoContrato.add(tagData);
		            	    }
	                    	
	                    	$("#situacaoContrato").val(datasetContratos.values[0]['descricaoSituacao']);
	                    	$("#codigoSituacaoContrato").val(datasetContratos.values[0]['situacaoContrato']);

		            	    if (typeof autoCompleteSituacaoContrato != "undefined") {
		            	    	let tagData = {
		            	    		codigo: datasetContratos.values[0]['situacao'],
		            	    		descricao: datasetContratos.values[0]['descricaoSituacao']
			            	    };
		            	    	
		            	    	autoCompleteSituacaoContrato.add(tagData);
		            	    }
		            	    	
		            	    let descricaoFornecedor = datasetContratos.values[0]['nome'] + " - " + datasetContratos.values[0]['fornecedor'] + " - " + datasetContratos.values[0]['loja'] + " - " + datasetContratos.values[0]['cnpj'];
	                    	$("#fornecedor").val(descricaoFornecedor);
	                    	$("#codigoFornecedor").val(datasetContratos.values[0]['fornecedor']);
	                    	$("#lojaFornecedor").val(datasetContratos.values[0]['loja']);
	                    	$("#cgcFornecedor").val(datasetContratos.values[0]['cnpj']);
	                    	$("#endFornecedor").val(datasetContratos.values[0]['endereco']);
	                    	$("#bairroFornecedor").val(datasetContratos.values[0]['bairro']);
	                    	$("#cepFornecedor").val(datasetContratos.values[0]['cep']);
	                    	$("#cidadeFornecedor").val(datasetContratos.values[0]['cidade']);
	                    	$("#estadoFornecedor").val(datasetContratos.values[0]['estado']);
		            		
		            	    if (typeof autoCompleteFornecedor != "undefined") {
		            	    	let tagData = {
		            	    		nome: datasetContratos.values[0]['nome'],
		            	    		codigo: datasetContratos.values[0]['fornecedor'],
		            	    		loja: datasetContratos.values[0]['loja'],
		            	    		cgc: datasetContratos.values[0]['cnpj']
			            	    };
		            	    	
		            	    	autoCompleteFornecedor.add(tagData);
		            	    }

	                    	$("#responsavelJuridico").val(datasetContratos.values[0]['responsavelJuridico']);
	                    	$("#loginResponsavelJuridico").val(datasetContratos.values[0]['loginResponsavelJuridico']);
		            	    
		            	    if (typeof autoCompleteResponsavelJuridico != "undefined") {
		            	    	let tagData = {
			            	    	nome: datasetContratos.values[0]['responsavelJuridico'],
		            	    		login: datasetContratos.values[0]['loginResponsavelJuridico']
			            	    };
		            	    	
		            	    	autoCompleteResponsavelJuridico.add(tagData);
		            	    }

	                    	$("#dataInicio").val(dateConvert(datasetContratos.values[0]['dataInicio']));
	                    	$("#prazo").val(datasetContratos.values[0]['prazo']);
	                    	$("#dataFinal").val(dateConvert(datasetContratos.values[0]['dataFinal']));
	                    	$("#diasParaAviso").val(datasetContratos.values[0]['diasParaAviso']);
	                    	$("#dataAssinatura").val(dateConvert(datasetContratos.values[0]['dataAssinatura']));
	                    	$("#solicitante").val(datasetContratos.values[0]['solicitante']);
	                    	$("#valor").val(valueConvert(datasetContratos.values[0]['valor']));
	                    	$("#saldo").val(valueConvert(datasetContratos.values[0]['saldo']));
	                    	
	                    	//Montagem de grid para anexos
					    	var records = datasetContratos.values;
					    	var rowClass = 'row-blue';
					    	
					    	for (var index in records) {
					    	    var record = records[index];
					    	    
					    	    if (rowClass == 'row-blue') {
									rowClass = 'row-gray';
								} else {
									rowClass = 'row-blue';
								}

						    	var iconRemove = '';
						    	if (method != "view") {
						    		iconRemove = "<div class='btn-panel' styles='padding-left: 20px !important;'><a href='#' tooltip='Remover' id='row" + index + "' class='btn btn-danger btn-icon' onclick='attachRemove(" + index + ")'><i class='flaticon flaticon-trash icon-md' aria-hidden='true'></i></a></div>"; 
						    	}					    	
					    	    
					    	    myData.push({
									row: rowClass,
					    	        nomeOriginal: record.nomeOriginal,
					    	        caminhoOriginal: record.caminhoOriginal,
					    	        idDocumentoFluig: record.idDocumentoFluig,
					    	        view: "<div class='btn-panel' styles='padding-left: 20px !important;'><a href='#' tooltip='Visualizar' id='row" + index + "' class='btn btn-info btn-icon' onclick='attachView(" + index + ")'><i class='flaticon flaticon-pageview icon-md' aria-hidden='true'></i></a></div>",
					    	        remove: iconRemove,
					    	        noResults: false
					    	    });
					    	}
	                    }
	            	}
	            	
	                resolve(myData);
            	}
	        );
	    });
	};	

	myPromise().then((results)=> {
		var iconAdd = '';
    	if (method != "view") {
    		iconAdd = "<div class='btn-panel' styles='padding-left: 20px !important;'><a href='#' tooltip='Anexar' id='add' class='btn btn-primary btn-icon' onclick='attachAdd()'><i class='flaticon flaticon-paperclip icon-md' aria-hidden='true'></i></a></div>"; 
    	}					    	
    	
	    if ($.fn.dataTable.isDataTable('#attachmentsBrowse')) {
	    	attachmentsBrowse.destroy();
	    }

	    attachmentsBrowse = $('#attachmentsBrowse').DataTable({
	        dom: '<<"dataTables_top"lf><t><"dataTables_bottom"ip>>',
	        paging: true,
	        lengthMenu: [
	            [ 10, 25, 50, -1 ],
	            [ '10 linhas', '25 linhas', '50 linhas', 'Todas as linhas' ]
	        ],
	        buttons: [
	            'pageLength'
	        ],
	        data: results,
	        responsive: true,
	        scroller: false,
	        ordering: false,
	        destroy: true,
	        columns: [
	        	{
	                title: 'Nome',
	                data: 'nomeOriginal',
	                defaultContent: "",
	                width: "30%"
	            }, {
	                title: 'Caminho',
	                data: 'caminhoOriginal',
	                defaultContent: "",
	                width: "60%"
	            }, {
	                title: 'ID Fluig',
	                data: 'idDocumentoFluig',
	                defaultContent: "",
	                width: "8%"
	            }, {
	                title: '',
	                data: 'view',
	                defaultContent: "",
	                width: "1%"
	            }, {
	                title: iconAdd,
	                data: 'remove',
	                defaultContent: "",
	                width: "1%"
	            }
	        ],
		    rowCallback: function (row, data) {
		        $(row).addClass(data.row);
		    }, 
	        language:{
	            "sEmptyTable": "Nenhum registro encontrado",
	            "sInfo": "Mostrando de _START_ até _END_ de _TOTAL_ registros",
	            "sInfoEmpty": "Mostrando 0 até 0 de 0 registros",
	            "sInfoFiltered": "(Filtrados de _MAX_ registros)",
	            "sInfoPostFix": "",
	            "sInfoThousands": ".",
	            "sLengthMenu": "_MENU_ resultados por página",
	            "sLoadingRecords": "Carregando...",
	            "sProcessing": "Processando...",
	            "sZeroRecords": "Nenhum registro encontrado",
	            "sSearch": "Pesquisar ",
	            "oPaginate": {
	                "sNext": "Próximo",
	                "sPrevious": "Anterior",
	                "sFirst": "Primeiro",
	                "sLast": "Último"
	            },
	            "oAria": {
	                "sSortAscending": ": Ordenar colunas de forma ascendente",
	                "sSortDescending": ": Ordenar colunas de forma descendente"
	            }
	        }
	    });
		
		show("contrato-data");
	}).catch((error)=>{
	    FLUIGC.toast({
	        title: 'Carga de Dados',
		    message: 'Falha na carga de dados!',
	        type: 'danger'
	    });
	});
	
	myLoader.hide();
};


function attachAdd() {
	var fileContents = "";
	fileContents  = '<div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">';
	fileContents += '	<div class="modal-dialog" role="document">';
	fileContents += '	  <div class="modal-content">';
	fileContents += '		<div class="indicator"></div>';
	fileContents += '		<div class="modal-header">';
	fileContents += '		  <h5 class="modal-title" id="exampleModalLabel"></h5>';
	fileContents += '		  <button type="button" class="close" data-dismiss="modal" aria-label="Close">';
	fileContents += '		  	<span aria-hidden="true">&times;</span>';
	fileContents += '		  </button>';
	fileContents += '		</div>';
	fileContents += '		<div class="modal-body">';
	fileContents += '		  <div class="media mb-3">';
	fileContents += '			<div class="media-body">';
	fileContents += '			  <textarea class="autosize" placeholder="add..." rows="1" id="note" data-emoji="true"></textarea>';
	fileContents += '			  <div class="position-relative">';
	fileContents += '				<input type="file" class="d-none" accept="audio/*|video/*|video/x-m4v|video/webm|video/x-ms-wmv|video/x-msvideo|video/3gpp|video/flv|video/x-flv|video/mp4|video/quicktime|video/mpeg|video/ogv|.ts|.mkv|image/*|image/heic|image/heif" onchange="previewFiles()" id="inputUp" multiple>';
	fileContents += '				<a class="mediaUp mr-4"><i class="material-icons mr-2" data-tippy="add (Video, Audio, Photo)" onclick="trgger(\'inputUp\')">perm_media</i></a>';
	fileContents += '			  </div>';
	fileContents += '			</div>';
	fileContents += '		  </div>';
	fileContents += '		</div>';
	fileContents += '		<div class="row col-md-12 ml-auto mr-auto preview"></div>';
	fileContents += '		<div class="modal-footer">';
	fileContents += '		  <button type="button" class="btn btn-secondary btn-sm" data-dismiss="modal">Close</button>';
	fileContents += '		  <span class="btn btn-info btn-sm" disabled>Save changes</span>';
	fileContents += '		</div>';
	fileContents += '	  </div>';
	fileContents += '	</div>';
	fileContents += '</div>';
	
	var myModal = FLUIGC.modal({
	    title: 'Adicionar Anexo',
	    content: fileContents, 
	    id: 'attach-modal',
	    size: 'large',
	    actions: [{
	        'label': 'Salvar',
	        'bind': 'save-attach-modal',
	    },{
	        'label': 'Cancelar',
	        'autoClose': true
	    }]
	}, function() {
	    $("#attach-modal").find("button[save-attach-modal]").on("click", function() {
	    	/*
	    	var newTexto = $('#textoComentario').val();
	    	
        	if ($('#textoComentario').val().trim() == '') {
			    FLUIGC.toast({
			        title: 'Comentário',
				    message: "<br/>Comentário não informado. (addComment) [error]<br/>",
			        type: 'danger'
			    });
			    
			    return(false);
        	}
        	
			var cMessages = "";
			
			myLoader.show();
			
			let myPromise = function promiseExecute() {
			    return new Promise((resolve, reject)=> {
			        setTimeout(
			            ()=> {
							var today = new Date();
							var cDate = (today.getFullYear() 
									     + ("0" + (today.getMonth() + 1)).slice(-2) 
									     + ('0' + today.getDate()).slice(-2));
							var cTime = (("0" + today.getHours()).slice(-2) 
								         + ":" + ("0" + today.getMinutes()).slice(-2) 
								         + ":" + ('0' + today.getSeconds()).slice(-2)); 
			    			var hasErrors = false;
							var mydata = {
						        contrato: $('#contrato').val(),
						        projeto: $('#projeto').val(),
						        data: cDate,
						        hora: cTime,
						        operador: currentOperatorId,
						        texto: newTexto
							}
							
						    var data = new Array();
						    data.push(DatasetFactory.createConstraint("data", JSON.stringify(mydata), "", ConstraintType.MUST));
			    		    var datasetSave = DatasetFactory.getDataset("dsProjetosChatPost", null, data, null);
			    			var records = datasetSave.values;
			    			
			    			for (var index in records) {
			    			    var record = records[index];
			    			    cMessages += "<br/>" + record.messageText + " (" + record.messageCode + ") [" + record.messageType + "]<br/>";
			    			    
			    			    if (!hasErrors && record.messageType == 'error') {
			    			    	hasErrors = true;
			    			    }
			    			}
			            	
			                if (!hasErrors) {
			                    resolve();
			                }else{
			                    reject();
			                }     
			            }
			        );
			    });
			};	

			myPromise().then((results)=> {
			    FLUIGC.toast({
			        title: 'Anexo',
				    message: cMessages,
			        type: 'success',
			        timeout: 'fast'
			    });
			}).catch((error)=>{
			    FLUIGC.toast({
			        title: 'Anexo',
				    message: cMessages, 
			        type: 'danger'
			    });
			});
			
			myLoader.hide();
			*/
	    	
			myModal.remove();
		});
	});
};


function attachView(index) {
	var title = 'Visualização';
	var idDocto = '59804'; //attachmentsBrowse.row(index).data()['idDocumentoFluig'];
	
	if (idDocto == '') {
	    FLUIGC.toast({
	        title: 'Documento sem visualização',
		    message: 'O documento somente pode ser visualizado se for feito upload pelo Fluig!',
	        type: 'danger'
	    });
	    
	    return false;
	}

	var value = $.ajax({ 
		url: '/api/public/2.0/documents/getDownloadURL/' + idDocto, 
		dataType: 'json', 
		async: true, 
		success: function (response) { 
			win = window.open(response.content, title, "directories=no,titlebar=no,toolbar=no,location=no,status=no,menubar=no,scrollbars=no,resizable=no,width=800,height=600"); 
			win.document.title = title; 
		} 
	});
};


function attachRemove(index) {
	
};


function goHome() {
	show('main');
};


function formSave() {
	
};
