var MyWidget = SuperWidget.extend({
    //método iniciado quando a widget é carregada
    init: function() {
        initialize();
        
        $("#anexoDataBrowse").on('change', 'input[type="checkbox"]', function(e) {
        	var hasMark = false;
        	$(document).find(".markBrowse").each(function() {
        		if ($(this)[0].checked) {
    			     hasMark = true;
        		}
    		});
        	
        	document.getElementById("btDown").disabled = !hasMark;
        });        
    },
  
    //BIND de eventos
    bindings: {
        local: {
            'execute': ['click_executeAction'],
    		'open-document': ['click_openDocument'],
    		'download-document': ['click_downloadDocument']
        },
        global: {}
    },
 
    executeAction: function(htmlElement, event) {
    },

    openDocument: function(el, ev) {
        var docId = el.id.replace("btView", "");
        var nome = el.name.replace("btView", "");
    	
        var parentOBJ;
        if (window.opener) {
            parentOBJ = window.opener.parent;
        } else {
            parentOBJ = parent;
        }

        /*
        var cfg = {
            url: "/ecm_documentview/documentView.ftl",
            maximized: true,
            title: nome,
            callBack: function () {
                parentOBJ.ECM.documentView.getDocument(docId);
            },
            customButtons: []
        };

        parentOBJ.WCMC.panel(cfg);
        */

        var url = parentOBJ.WCMAPI.getServerURL() + parentOBJ.WCMAPI.getProtectedContextPath() + "/" + parentOBJ.WCMAPI.getTenantCode() + "/ecmnavigation?app_ecm_navigation_doc=" + docId;
        var myWindow = window.open(url, nome, 'popup=yes,toolbar=no,location=no,directories=no,status=no,menubar=no,width=800,height=600');
        
        myWindow.focus();
        myWindow.opener.document.getElementsByClassName("wcm-panel-header-bt-close")[0].removeAttribute('class')
        myWindow.opener.document.getElementsByClassName("wcm-panel-header-bt-minimize")[0].removeAttribute('class')
    },
    
    downloadDocument: function(el, ev) {
        var documentId = parseInt(el.id.replace("btDown", ""));
	    var constraints = new Array();
	    constraints.push(DatasetFactory.createConstraint("documentId", documentId, documentId, ConstraintType.MUST));
	    constraints.push(DatasetFactory.createConstraint("documentVersion", '1000', '1000', ConstraintType.MUST));

	    var dataset = DatasetFactory.getDataset("dsDocumentGet", null, constraints, null);
	    if (dataset != null && dataset.values != null && dataset.values.length > 0) {
	    	fetch(dataset.values[0].documentDownloadURL)
    	    	 .then(response => response.blob())
    	    	 .then(blob => {
        	    	 var downloadUrl = URL.createObjectURL(blob);
        	    	 var a = document.createElement("a");
        	    	 
        	    	 a.style.display = 'none';
        	    	 a.href = downloadUrl;
        	    	 a.download = dataset.values[0].documentDescription;
        	    	 document.body.appendChild(a);
        	    	 a.click();
        	    	 document.body.removeChild(a);
        	    	 
        	    	 URL.revokeObjectURL(downloadUrl);
	    	});
	    }
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
                    datasetFiliais = DatasetFactory.getDataset('dsFiliaisOffLine', null, constraintsFiliais, null);

                    var constraintsFornecedores = new Array();
                    constraintsFornecedores.push(DatasetFactory.createConstraint("empresa", $('#filtroEmpresaCodigo').val(), $('#filtroEmpresaCodigo').val(), ConstraintType.MUST));
                    datasetFornecedores = DatasetFactory.getDataset('dsFornecedoresOffLineGet', null, constraintsFornecedores, null);

                    var constraintsContratos = new Array();
                    constraintsContratos.push(DatasetFactory.createConstraint("empresa", $('#filtroEmpresaCodigo').val(), $('#filtroEmpresaCodigo').val(), ConstraintType.MUST));
                    var fields = ['noAttachments'];
                    datasetContratos = DatasetFactory.getDataset('dsContratosGet', fields, constraintsContratos, null);

                    var constraintsTipoContrato = new Array();
                    constraintsTipoContrato.push(DatasetFactory.createConstraint("empresa", $('#filtroEmpresaCodigo').val(), $('#filtroEmpresaCodigo').val(), ConstraintType.MUST));
                    datasetTipoContrato = DatasetFactory.getDataset('dsTipoContratoGet', null, constraintsTipoContrato, null);

                    var constraintsResponsaveisJuridicos = new Array();
                    constraintsResponsaveisJuridicos.push(DatasetFactory.createConstraint("empresa", $('#filtroEmpresaCodigo').val(), $('#filtroEmpresaCodigo').val(), ConstraintType.MUST));
                    datasetResponsaveisJuridicos = DatasetFactory.getDataset('dsResponsaveisJuridicosGet', null, constraintsResponsaveisJuridicos, null);
                    
                	resolve('OK');
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
        displayKey: row => (row.filial + " - " + row.nome + " - " + row.cnpj),
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
            let columns = ['numero','revisao','nome','cnpj'];
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
        displayKey: row => (row.numero + " - " + row.revisao + " - " + row.nome + " - " + row.cnpj),
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


function dateConvert(date, cText) {
    day = date.substring(6, 8);
    month = date.substring(4, 6);
    year = date.substring(0, 4);

    if (cText == null || cText.toUpperCase().trim() != 'TEXT') {
        return(year + "-" + month + "-" + day);
    } else {
        return(day + "/" + month + "/" + year);
    }
}


function valueConvert(value, decimals) {
    if (decimals == null) {
        decimals = 2;
    }
    
    var value = value.toLocaleString('pt-br', {style: "currency", currency: "BRL"});
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
        if (frame == 'contrato-dados' || frame == 'contrato-fornecedor' || frame == 'contrato-medicao' || frame == 'contrato-anexo') {
            $(this).show();
        } else {
            $(this).hide();
        }
    });

    $(document).find(".tabs").each(function() {
        if (frame == 'contrato-dados' || frame == 'contrato-fornecedor' || frame == 'contrato-medicao' || frame == 'contrato-anexo') {
            $(this).show();
        } else {
            $(this).hide();
        }
    });
    
    $(document).find(".contrato-ident").each(function() {
        if (frame == 'contrato-dados' || frame == 'contrato-fornecedor' || frame == 'contrato-medicao' || frame == 'contrato-anexo') {
            $(this).show();
        } else {
            $(this).hide();
        }
    });    

    $(document).find(".contrato-dados").each(function() {
        if (frame == 'contrato-dados') {
            $(this).show();
        } else {
            $(this).hide();
        }
    });    

    $(document).find(".contrato-fornecedor").each(function() {
        if (frame == 'contrato-fornecedor') {
            $(this).show();
        } else {
            $(this).hide();
        }
    });    

    $(document).find(".contrato-medicao").each(function() {
        if (frame == 'contrato-medicao') {
            $(this).show();
        } else {
            $(this).hide();
        }
    });    

    $(document).find(".contrato-anexo").each(function() {
        if (frame == 'contrato-anexo') {
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
        show('contrato-dados');
    } else if (el.id == 'tab-2') {
        show('contrato-fornecedor');
    } else if (el.id == 'tab-3') {
        show('contrato-medicao');
    } else if (el.id == 'tab-4') {
        show('contrato-anexo');
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

                    var dataset = DatasetFactory.getDataset("dsContratosGet", null, constraints, null);
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
                                revisao: record.revisao,
                                situacao: record.situacao,
                                fornecedor: record.fornecedor,
                                loja: record.loja,
                                nome: record.nome,
                                tipoContrato: record.tipoContrato,
                                dataInicio: dateConvert(record.dataInicio, 'text'),
                                valorAtual: "<div style='text-align: right;'>" + valueConvert(record.valorAtual) + "  </div>",
                                saldo: "<div style='text-align: right;'>" + valueConvert(record.saldo) + "  </div>",
                                view: "<div class='row-btn-panel' styles='padding-left: 20px !important; text-align: center !important;'><a href='#' tooltip='Visualizar' id='row" + index + "' class='btn btn-info row-btn-icon' onclick='contratoView(\"" + record.numero + '","' + record.revisao + "\")'><i class='flaticon flaticon-pageview icon-md' aria-hidden='true'></i></a></div>",
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
                    title: 'Revis&atilde;o',
                    data: 'revisao',
                    defaultContent: "",
                    width: "5%"
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
                    width: "30%"
                }, {
                    title: 'Tipo',
                    data: 'tipoContrato',
                    defaultContent: "",
                    width: "5%"
                }, {
                    title: 'Data Contrato',
                    data: 'dataInicio',
                    defaultContent: "",
                    width: "8%"
                }, {
                    title: '<div style="text-align: right;">Valor Atual  </div>',
                    data: 'valorAtual',
                    defaultContent: "",
                    width: "12%"
                }, {
                    title: '<div style="text-align: right;">Saldo  </div>',
                    data: 'saldo',
                    defaultContent: "",
                    width: "12%"
                }, {
                    title: '',
                    data: 'view',
                    defaultContent: "",
                    width: "2%"
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


function contratoView(contrato, revisao) {
	tabChange($("#tab-1"));
    formShow("view", contrato, revisao);
};


function formShow(method, contrato, revisao) {
	$("#method").val(method);
	
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
                    
                    if (method == 'view' || method == 'edit') {
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
                    } 
                    
                    $("#empresa").val($("#filtroEmpresa").val());
                    $("#codigoEmpresa").val($("#filtroEmpresaCodigo").val());
                    $("#filial").val($("#filtroFilial").val());
                    $("#codigoFilial").val($("#filtroFilialCodigo").val());
                    
                    var constraintsContratos = new Array();
                    constraintsContratos.push(DatasetFactory.createConstraint("empresa", $('#codigoEmpresa').val(), $('#codigoEmpresa').val(), ConstraintType.MUST));
                    constraintsContratos.push(DatasetFactory.createConstraint("filial", $('#codigoFilial').val(), $('#codigoFilial').val(), ConstraintType.MUST));
                    constraintsContratos.push(DatasetFactory.createConstraint("numero", contrato, contrato, ConstraintType.MUST));
                    constraintsContratos.push(DatasetFactory.createConstraint("revisao", revisao, revisao, ConstraintType.MUST));
                    datasetContratos = DatasetFactory.getDataset('dsContratosGet', null, constraintsContratos, null);
                    
                    if (datasetContratos.values.length > 0) {
                        $("#numeroContrato").val(datasetContratos.values[0]['numero']);
                        $("#revisao").val(datasetContratos.values[0]['revisao']);
                        $("#descricaoContrato").val(datasetContratos.values[0]['descricaoContrato']);
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
                        $("#condicaoPagamento").val(datasetContratos.values[0]['descricaoCondicaoPagamento']);
                        $("#codigoCondicaoPagamento").val(datasetContratos.values[0]['condicaoPagamento']);

                        if (typeof autoCompleteSituacaoContrato != "undefined") {
                            let tagData = {
                                codigo: datasetContratos.values[0]['situacao'],
                                descricao: datasetContratos.values[0]['descricaoSituacao']
                            };
                            
                            autoCompleteSituacaoContrato.add(tagData);
                        }

                        $("#dataInicio").val(dateConvert(datasetContratos.values[0]['dataInicio']));
                        $("#prazo").val(datasetContratos.values[0]['prazo']);
                        $("#dataFinal").val(dateConvert(datasetContratos.values[0]['dataFinal']));
                        $("#diasParaAviso").val(datasetContratos.values[0]['diasParaAviso']);
                        $("#dataAssinatura").val(dateConvert(datasetContratos.values[0]['dataAssinatura']));
                        $("#solicitante").val(datasetContratos.values[0]['solicitante']);
                        $("#valorAtual").val(valueConvert(datasetContratos.values[0]['valorAtual']));
                        $("#saldo").val(valueConvert(datasetContratos.values[0]['saldo']));
                        
                        //Montagem de grid para fornecedor
                        loadFornecedor();
                        
                        //Montagem de grid para medição
                        loadMedicao();
                        
                        //Montagem de grid para anexos
                        loadAnexo();
                    }
                    
                	resolve(myData);
                }
            );
        });
    };    

    myPromise().then((results)=> {
        show("contrato-dados");
    	document.getElementById("btDown").disabled = true;
    }).catch((error)=>{
        FLUIGC.toast({
            title: 'Carga de Dados',
            message: 'Falha na carga de dados!',
            type: 'danger'
        });
    });
    
    myLoader.hide();
};


function goHome() {
	$("#upload-file").val("")
	show('main');
};


function loadFornecedor() {
    var myData = [];
    
    var constraints = new Array();
    constraints.push(DatasetFactory.createConstraint("empresa", $("#codigoEmpresa").val(), $("#codigoEmpresa").val(), ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("filial", $("#codigoFilial").val(), $("#codigoFilial").val(), ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("numero", $("#numeroContrato").val(), $("#numeroContrato").val(), ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("revisao", $("#revisao").val(), $("#revisao").val(), ConstraintType.MUST));

    var dataset = DatasetFactory.getDataset("dsContratosFornecedorGet", null, constraints, null);
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
                fornecedor: record.fornecedor,
                loja: record.loja,
                nome: record.nome,
                cnpj: record.cnpj,
                cidade: record.cidade,
                estado: record.estado,
                noResults: false
            });
        }
    }

	if ($.fn.dataTable.isDataTable('#fornecedorDataBrowse')) {
        dataBrowse.destroy();
    }

    dataBrowse = $('#fornecedorDataBrowse').DataTable({
        dom: '<<"dataTables_top"lf><t><"dataTables_bottom"ip>>',
        paging: true,
        lengthMenu: [
            [ 10, 25, 50, -1 ],
            [ '10 linhas', '25 linhas', '50 linhas', 'Todas as linhas' ]
        ],
        buttons: [
            'pageLength'
        ],
        data: myData,
        responsive: true,
        scroller: false,
        ordering: false,
        destroy: true,
        columns: [
            {
                title: 'Fornecedor',
                data: 'fornecedor',
                defaultContent: "",
                width: "8%"
            }, {
                title: 'loja',
                data: 'loja',
                defaultContent: "",
                width: "3%"
            }, {
                title: 'Nome Fornecedor',
                data: 'nome',
                defaultContent: "",
                width: "70%"
            }, {
                title: 'CNPJ',
                data: 'cnpj',
                defaultContent: "",
                width: "10%"
            }, {
                title: 'Cidade',
                data: 'cidade',
                defaultContent: "",
                width: "20%"
            }, {
                title: 'Estado',
                data: 'estado',
                defaultContent: "",
                width: "5%"
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
}


function loadMedicao() {
    var myData = [];
    
    var constraints = new Array();
    constraints.push(DatasetFactory.createConstraint("empresa", $("#codigoEmpresa").val(), $("#codigoEmpresa").val(), ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("filial", $("#codigoFilial").val(), $("#codigoFilial").val(), ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("numero", $("#numeroContrato").val(), $("#numeroContrato").val(), ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("revisao", $("#revisao").val(), $("#revisao").val(), ConstraintType.MUST));

    var dataset = DatasetFactory.getDataset("dsContratosMedicoesGet", null, constraints, null);
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
                numeroMedicao: record.numeroMedicao,
                numeroPlanilha: record.numeroPlanilha,
                descricaoPlanilha: record.descricaoPlanilha,
                dataInicial: dateConvert(record.dataInicial, 'text'),
                dataFinal: dateConvert(record.dataFinal, 'text'),
                valorPrevisto: "<div style='text-align: right;'>" + valueConvert(record.valorPrevisto) + "  </div>",
                valorTotal: "<div style='text-align: right;'>" + valueConvert(record.valorTotal) + "  </div>",
                saldo: "<div style='text-align: right;'>" + valueConvert(record.saldo) + "  </div>",
                noResults: false
            });
        }
    }
    
	if ($.fn.dataTable.isDataTable('#medicaoDataBrowse')) {
        dataBrowse.destroy();
    }

    dataBrowse = $('#medicaoDataBrowse').DataTable({
        dom: '<<"dataTables_top"lf><t><"dataTables_bottom"ip>>',
        paging: true,
        lengthMenu: [
            [ 10, 25, 50, -1 ],
            [ '10 linhas', '25 linhas', '50 linhas', 'Todas as linhas' ]
        ],
        buttons: [
            'pageLength'
        ],
        data: myData,
        responsive: true,
        scroller: false,
        ordering: false,
        destroy: true,
        columns: [
            {
                title: 'Nro Medição',
                data: 'numeroMedicao',
                defaultContent: "",
                width: "10%"
            }, {
                title: 'Nro Planilha',
                data: 'numeroPlanilha',
                defaultContent: "",
                width: "10%"
            }, {
                title: 'Descrição Planilha',
                data: 'nome',
                defaultContent: "",
                width: "40%"
            }, {
                title: 'Data Inicial',
                data: 'dataInicial',
                defaultContent: "",
                width: "8%"
            }, {
                title: 'Data Final',
                data: 'dataFinal',
                defaultContent: "",
                width: "8%"
            }, {
                title: "<div style='text-align: right;'>Valor Previsto  </div>",
                data: 'valorPrevisto',
                defaultContent: "",
                width: "10%"
            }, {
                title: "<div style='text-align: right;'>Valor Total  </div>",
                data: 'valorTotal',
                defaultContent: "",
                width: "10%"
            }, {
                title: "<div style='text-align: right;'>Saldo  </div>",
                data: 'saldo',
                defaultContent: "",
                width: "10%"
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
}


function loadAnexo() {
    var myData = [];
    
    var constraints = new Array();
    constraints.push(DatasetFactory.createConstraint("empresa", $("#codigoEmpresa").val(), $("#codigoEmpresa").val(), ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("filial", $("#codigoFilial").val(), $("#codigoFilial").val(), ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("numero", $("#numeroContrato").val(), $("#numeroContrato").val(), ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("revisao", $("#revisao").val(), $("#revisao").val(), ConstraintType.MUST));

    var dataset = DatasetFactory.getDataset("dsContratosAnexosGet", null, constraints, null);
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
            
            var rowMark = "";
            var rowIcons = "";
            
            if (record.fluigDocumentId.trim() != "") {
                rowMark = "<div class='row-btn-panel' styles='padding-left: 20px !important; text-align: center !important;'><input type='checkbox' class='markBrowse' name='" + record.objeto.trim() + "' id='chkDown" + record.fluigDocumentId + "' data-mark-document></div>";
                rowIcons  = "<div class='row-icons-panel'>";
                rowIcons += "<div class='row-btn-panel' styles='padding-left: 20px !important; text-align: center !important;'><a href='#' name='btDown" + record.objeto.trim() + "' id='btDown" + record.fluigDocumentId + "' class='btn btn-success row-btn-icon' data-download-document><i class='flaticon flaticon-download icon-md' aria-hidden='true'></i></a></div>";
                rowIcons += "<div class='row-btn-panel' styles='padding-left: 20px !important; text-align: center !important;'><a href='#' name='btView" + record.objeto.trim() + "' id='btView" + record.fluigDocumentId + "' class='btn btn-info row-btn-icon' data-open-document><i class='flaticon flaticon-pageview icon-md' aria-hidden='true'></i></a></div>";
                rowIcons += "</div>"; 
            }
                        
            myData.push({
                row: rowClass,
                codigoObjeto: record.codigoObjeto,
                objeto: record.objeto,
                descricao: record.descricao,
                tamanho: record.tamanho,
                fluigDocumentId: record.fluigDocumentId,
                rowMark: rowMark,
                rowIcons: rowIcons,
                noResults: false
            });
        }
    }

	if ($.fn.dataTable.isDataTable('#anexoDataBrowse')) {
        dataBrowse.destroy();
    }

    dataBrowse = $('#anexoDataBrowse').DataTable({
        dom: '<<"dataTables_top"lf><t><"dataTables_bottom"ip>>',
        paging: true,
        lengthMenu: [
            [ 10, 25, 50, -1 ],
            [ '10 linhas', '25 linhas', '50 linhas', 'Todas as linhas' ]
        ],
        buttons: [
            'pageLength'
        ],
        data: myData,
        responsive: true,
        scroller: false,
        ordering: false,
        destroy: true,
        columns: [
            {
                title: 'Código',
                data: 'codigoObjeto',
                defaultContent: "",
                width: "10%"
            }, {
                title: 'Objeto',
                data: 'objeto',
                defaultContent: "",
                width: "30%"
            }, {
                title: 'Descrição',
                data: 'descricao',
                defaultContent: "",
                width: "50%"
            }, {
                title: 'Tamanho',
                data: 'tamanho',
                defaultContent: "",
                width: "7%"
            }, {
                title: 'ID Documento',
                data: 'fluigDocumentId',
                defaultContent: "",
                width: "8%"
            }, {
                title: '',
                data: 'rowMark',
                defaultContent: "",
                width: "2%"
            }, {
                title: '',
                data: 'rowIcons',
                defaultContent: "",
                width: "2%"
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
}


function downloadAttach() {
	var aFiles = [];

	$(document).find(".markBrowse").each(function() {
		if ($(this)[0].checked) {
    		aFiles.push(parseInt($(this)[0].id.replace("chkDown","")));
		}
	});
	
    if (aFiles.length > 0) {
    	// faz requisição à API do ECM
    	WCMAPI.Create({
    	    url: "/ecm/api/rest/ecm/navigation/scheduleDocumentListDownloadJob/1",
    	    data: aFiles,
    	    async: false,
    	    success: function (data, textStatus, jqXHR) {
    	        if (data.content == 'OK') {
    	        	//Desmarca todos os arquivos
    	        	$(document).find(".markBrowse").each(function() {
    	        		if ($(this)[0].checked) {
    	        			$(this)[0].checked = false;
    	        		}
    	        	});
    	        	 
    	        	document.getElementById("btDown").disabled = true;

    	            FLUIGC.toast({
    	                title: 'Sucesso: ',
    	                message: 'Os arquivos estão sendo compactados e estarão disponíveis em "Meus Documentos" para download.',
    	                type: 'success',
    	                timeout: 'slow'
    	            });
    	        } else {
    	            // seu tratamento de erro usando: data.message
    	    	    FLUIGC.toast({
    	    	        title: 'Arquivos não disponibilizados!',
    	    		    message: data.message,
    	    	        type: 'danger'
    	    	    });
    	        }
    	    },
    	    error: function (jqXHR, textStatus, errorThrown) {
    	        // seu tratamento de erro usando: textStatus
	    	    FLUIGC.toast({
	    	        title: 'Arquivos não disponibilizados!',
	    		    message: textStatus,
	    	        type: 'danger'
	    	    });
    	    }
    	});
    }
}
