var dsFastsalesForms = 'ds_fastsales_crud_form';

var formId = null;

var modal;

var editando;

var edicaoDocumentid;

var edicaoVersion;

var loadingUploadCSV;

var that;

var datatable;

var nomeDataset = null;

var headerDatatable;

var filter;
var dados;

var cbrow;

var aditionalSort;

var sqlLimit = 0;

var columnSearch;

var fatorIncrementoExclusao = 0;
var fatorIncrementoInativos = 0;
var fatorIncrementoCadastro = 0;
var progressoExclusao = 0;
var progressoInativos = 0;
var progresso = 0;
var countCadastro = 0;
var countInativo = 0;
var countTotalCadastro = 0;
var countTotalInativo = 0;
var datasetFormIdCSVFilho;
var modoImportacao = 0;
var dataFileInput = '';

function handleFileSelectFilho(evt) {

    if (modoImportacao == 0) {
        return;
    }

    loadingUploadCSV = FLUIGC.loading(window);
    loadingUploadCSV.show();

    var files = evt.target.files; // FileList object

    // use the 1st file from the list
    var f = files[0];

    var fileExtension = f.name.substring(f.name.lastIndexOf(".") + 1, f.name.length);

    //if (fileExtension != 'csv' || f.type != 'text/csv') {
    if (fileExtension != 'csv' && f.type != 'text/csv') {
        FLUIGC.toast({
            message: 'O arquivo selecionado não é do tipo .CSV!',
            type: 'danger'
        });
        loadingUploadCSV.hide();
        return;
    }

    var reader = new FileReader();

    reader.onerror = function (event) {
        //alert(event.target.error.name);
        loadingUploadCSV.hide();
    };
    // Closure to capture the file information.
    reader.onload = (function (theFile) {
        return function (e) {

            // By lines
            var lines = e.target.result.split('\n');
            var colunas = '';
            var valores = new Object();
            var countValores = 0;
            var countColunas = 0;
            var countDelimitPontoVirgula = lines[0].split(';').length;
            var countDelimitVirgula = lines[0].split(',').length;
            if (countDelimitPontoVirgula < 1 && countDelimitVirgula < 1) {
                FLUIGC.toast({
                    message: 'Formato de arquivo inv&aacute;lido, n&atilde;o foi poss&iacute;vel identificar o delimitador, utilize ; ou , como delimitador do arquivo CSV!',
                    type: 'danger'
                });
                loadingUploadCSV.hide();
                return;
            }
            var delimiter = countDelimitPontoVirgula > countDelimitVirgula ? ';' : ',';

            for (var line = 0; line < lines.length; line++) {
                if (colunas == '') {
                    colunas = lines[line].split(delimiter);
                    countColunas = colunas.length;
                } else {
                    if (lines[line].split(delimiter).length > 0 && lines[line].split(delimiter)[0] != '') {
                        //console.log(lines[line]);
                        if (countColunas != lines[line].split(delimiter).length) {
                            FLUIGC.toast({
                                message: 'Inconsist&ecirc;ncia detectada! Ignorando linha: ' + lines[line],
                                type: 'danger'
                            });
                            continue;
                        }
                        valores[countValores] = lines[line].split(delimiter);
                        countValores++;
                    }
                }
            }

            if (colunas == '') {
                FLUIGC.toast({
                    message: 'N&atilde;o foi poss&iacute;vel encontrar as colunas na primeira linha do arquivo, os campos devem ser separados por ponto e v&iacute;rgula (;) verifique os dados do arquivo CSV!',
                    type: 'danger'
                });
                loadingUploadCSV.hide();
                return;
            }
            //console.log('colunas:');
            //console.log(colunas);

            //ENCONTRA CAMPO _codigo
            var campoCodigoTabela = colunas[0];
            var campoCodigoProduto = colunas[1];

            if (campoCodigoTabela == '') {
                FLUIGC.toast({
                    message: 'N&atilde;o foi poss&iacute;vel encontrar o campo c&oacute;digo no arquivo CSV selecionado, verifique os dados do arquivo CSV!',
                    type: 'danger'
                });
                loadingUploadCSV.hide();
                return;
            }
            //console.log('campo codigo tabela: ');
            //console.log(campoCodigoTabela);

            if (campoCodigoProduto == '') {
                FLUIGC.toast({
                    message: 'N&atilde;o foi poss&iacute;vel encontrar o campo c&oacute;digo no arquivo CSV selecionado, verifique os dados do arquivo CSV!',
                    type: 'danger'
                });
                loadingUploadCSV.hide();
                return;
            }
            //console.log('campo codigo produto: ');
            //console.log(campoCodigoProduto);

            if (countValores < 1) {
                FLUIGC.toast({
                    message: 'N&atilde;o foram encontrados valores para importa&ccedil;&atilde;o, verifique os dados arquivo CSV!;',
                    type: 'danger'
                });
                loadingUploadCSV.hide();
                return;
            }

            //console.log('valores: ' + countValores);

            $('#progresso-importacao-filho').show();
            $('.progress-bar-cadastro-filho').css('width', '0%').attr('aria-valuenow', 0).text('0%');
            $('.progress-bar-exclusao').css('width', '0%').attr('aria-valuenow', 0).text('0%');
            $('#progress-bar-cadastro-filho').addClass('active');
            $('#progress-bar-exclusao').addClass('active');

            var filtro = [DatasetFactory.createConstraint("dataset-name", $('#upload-csv-filho').attr('dataset-name'), $('#upload-csv-filho').attr('dataset-name'), ConstraintType.MUST)];
            var dt = DatasetFactory.getDataset('ds_fastsales_crud_form', null, filtro, null);

            if (dt.values != undefined && dt.values.length > 0) {
                for (var i = 0; i < dt.values.length; i++) {
                    var item = dt.values[i];

                    if (item["dataset-name"] == $('#upload-csv-filho').attr('dataset-name')) {
                        datasetFormIdCSVFilho = item["folder-id"];
                    }
                }
            }

            var dataset = DatasetFactory.getDataset($('#upload-csv-filho').attr('dataset-name'), null, null, null);

            fatorIncrementoExclusao = 0;
            progressoExclusao = 0;
            fatorIncrementoCadastro = 0;
            progresso = 0;

            if (dataset.values && dataset.values.length > 0) {

                fatorIncrementoExclusao = 100 / dataset.values.length;

                for (var i = 0; i < dataset.values.length; i++) {
                    deletaRegistro(dataset.values[i]["metadata#id"], function (err, dt) {
                        if (err) {
                            //console.log('error:');
                            //console.log(err);
                            return;
                        }
                        progressoExclusao += fatorIncrementoExclusao;
                        $('.progress-bar-exclusao').css('width', progressoExclusao + '%').attr('aria-valuenow', progressoExclusao).text(parseInt(progressoExclusao) + '%');
                        if (progressoExclusao > 99) {
                            $('#progress-bar-exclusao').removeClass('active');
                        }
                    });
                }
            } else {
                $('.progress-bar-exclusao').css('width', 100 + '%').attr('aria-valuenow', 100).text(100 + '%');
                $('#progress-bar-exclusao').removeClass('active');
            }

            fatorIncrementoCadastro = 100 / countValores;

            populateDataCSV(countValores, valores, colunas, function (data) {
                criaRegistro(datasetFormIdCSVFilho, data, function (err, dt) {
                    if (err) {
                        //console.log('error:');
                        //console.log(err);
                    }
                    progresso += fatorIncrementoCadastro;
                    $('.progress-bar-cadastro-filho').css('width', progresso + '%').attr('aria-valuenow', progresso).text(parseInt(progresso) + '%');
                    if (progresso > 99) {
                        $('#progress-bar-cadastro-filho').removeClass('active');
                    }
                });
            });

            loadingUploadCSV.hide();
            FLUIGC.toast({
                message: 'Importa&ccedil;&atilde;o realizada com sucesso, atualize a p&aacute;gina para ver os dados!',
                type: 'success'
            });

        };
    })(f);

    // Read in the image file as a data URL.
    reader.readAsText(f);
}

function incrementaProgressoCadastro() {
    $('#imp-csv-cad-progresso').text(countCadastro + ' / ' + countTotalCadastro + ' registro(s)');
    progresso += fatorIncrementoCadastro;
    $('.progress-bar-cadastro').css('width', progresso + '%').attr('aria-valuenow', progresso).text(parseInt(progresso) + '%');
    if (progresso > 99) {
        $('#progress-bar-cadastro').removeClass('active');
    }
    countCadastro++;
}

function incrementaProgressoInativo() {
    $('#imp-csv-inat-progresso').text(countInativo + ' / ' + countTotalInativo + ' registro(s)');
    progressoInativos += fatorIncrementoInativos;
    $('.progress-bar-inativos').css('width', progressoInativos + '%').attr('aria-valuenow', progressoInativos).text(parseInt(progressoInativos) + '%');
    if (progressoInativos > 99) {
        $('#progress-bar-inativos').removeClass('active');
    }
    countInativo++;
}

function handleFileSelect(evt) {

    if (modoImportacao == 0) {
        return;
    }

    loadingUploadCSV = FLUIGC.loading(window);
    loadingUploadCSV.show();

    var files = evt.target.files; // FileList object

    // use the 1st file from the list
    var f = files[0];

    var fileExtension = f.name.substring(f.name.lastIndexOf(".") + 1, f.name.length);

    //if (fileExtension != 'csv' || f.type != 'text/csv') {
    if (fileExtension != 'csv' && f.type != 'text/csv') {
        FLUIGC.toast({
            message: 'O arquivo selecionado n&atilde;o &eacute; do tipo .CSV!',
            type: 'danger'
        });
        loadingUploadCSV.hide();
        return;
    }

    var reader = new FileReader();

    reader.onerror = function (event) {
        //alert(event.target.error.name);
        loadingUploadCSV.hide();
    };
    // Closure to capture the file information.
    reader.onload = (function (theFile) {
        return function (e) {

            // By lines
            var lines = e.target.result.split('\n');
            var colunas = '';
            var valores = new Object();
            var countValores = 0;
            var countColunas = 0;
            var countDelimitPontoVirgula = lines[0].split(';').length;
            var countDelimitVirgula = lines[0].split(',').length;
            if (countDelimitPontoVirgula < 1 && countDelimitVirgula < 1) {
                FLUIGC.toast({
                    message: 'Formato de arquivo inv&aacute;lido, n&atilde;o foi poss&iacute;vel identificar o delimitador, utilize ; ou , como delimitador do arquivo CSV!',
                    type: 'danger'
                });
                loadingUploadCSV.hide();
                return;
            }
            var delimiter = countDelimitPontoVirgula > countDelimitVirgula ? ';' : ',';

            for (var line = 0; line < lines.length; line++) {
                if (colunas == '') {
                    colunas = lines[line].split(delimiter);
                    countColunas = colunas.length;
                } else {
                    if (lines[line].split(delimiter).length > 0 && lines[line].split(delimiter)[0] != '') {
                        //console.log(lines[line]);
                        if (countColunas != lines[line].split(delimiter).length) {
                            FLUIGC.toast({
                                message: 'Inconsist&ecirc;ncia detectada! Ignorando linha: ' + lines[line],
                                type: 'danger'
                            });
                            continue;
                        }
                        valores[countValores] = lines[line].split(delimiter);
                        countValores++;
                    }
                }
            }

            if (colunas == '') {
                FLUIGC.toast({
                    message: 'N&atilde;o foi poss&iacute;vel encontrar as colunas na primeira linha do arquivo, os campos devem ser separados por ponto e v&iacute;rgula (;) verifique os dados do arquivo CSV!',
                    type: 'danger'
                });
                loadingUploadCSV.hide();
                return;
            }
            //console.log('colunas:');
            //console.log(colunas);

            //ENCONTRA CAMPO _codigo
            var campoCodigo = colunas[0];

            if (campoCodigo == '') {
                FLUIGC.toast({
                    message: 'N&atilde;o foi poss&iacute;vel encontrar o campo c&oacute;digo no arquivo CSV selecionado, verifique os dados do arquivo CSV!',
                    type: 'danger'
                });
                loadingUploadCSV.hide();
                return;
            }
            //console.log('campo codigo: ');
            //console.log(campoCodigo);

            if (countValores < 1) {
                FLUIGC.toast({
                    message: 'N&atilde;o foram encontrados valores para importa&ccedil;&atilde;o, verifique os dados arquivo CSV!',
                    type: 'danger'
                });
                loadingUploadCSV.hide();
                return;
            }

            //console.log('valores: ' + countValores);

            $('#progresso-importacao').show();
            $('.progress-bar-cadastro').css('width', '0%').attr('aria-valuenow', 0).text('0%');
            $('.progress-bar-inativos').css('width', '0%').attr('aria-valuenow', 0).text('0%');
            $('#progress-bar-cadastro').addClass('active');
            $('#progress-bar-inativos').addClass('active');
            $('#imp-csv-cad-progresso').text('0 registro(s)');
            $('#imp-csv-inat-progresso').text('0 registro(s)');

            var fieldsCodigo = new Array(campoCodigo, 'status');

            var dataset = DatasetFactory.getDataset(nomeDataset, fieldsCodigo, null, null);

            fatorIncrementoCadastro = 100 / countValores;
            fatorIncrementoInativos = 0;
            progresso = 0;
            progressoInativos = 0;
            countCadastro = 1;
            countTotalCadastro = 0;

            //if (dataset.values && dataset.values.length > 0 && modoImportacao == 1) {
            if (dataset.values && dataset.values.length > 0) {

                fatorIncrementoInativos = 100 / dataset.values.length;

                countTotalCadastro = countValores;

                $('#csv-rel-cad').append('- - -  Importando registro(s)  - - -\n');

                populateDataCSV(countValores, valores, colunas, function (data) {

                    var registroDataset = DatasetFactory.getDataset(nomeDataset, null, new Array(DatasetFactory.createConstraint(campoCodigo, data[0]['value'], data[0]['value'], ConstraintType.MUST)), null);

                    //console.log('criando registros');
                    //console.log(registroDataset.values);

                    if (registroDataset.values && registroDataset.values.length > 0) {
                        $('#csv-rel-cad').append('--> atualizando registro: ' + data[0]['value'] + ' <--\n');
                        atualizaRegistro(registroDataset.values[0]["metadata#id"], registroDataset.values[0]["metadata#version"], data, function (err, dt) {
                            if (err) {
                                var msg = (err && err.responseText ? err.responseText : err.responseJSON && err.responseJSON.message && err.responseJSON.message.message ? err.responseJSON.message.message : err);
                                $('#csv-rel-cad').append('  --> erro: ' + msg + ' <--\n');
                            }
                            incrementaProgressoCadastro();
                        });
                    } else {
                        $('#csv-rel-cad').append('--> criando novo registro: ' + data[0]['value'] + ' <--\n');
                        criaRegistro(that.formId, data, function (err, dt) {
                            if (err) {
                                var msg = (err && err.responseText ? err.responseText : err.responseJSON && err.responseJSON.message && err.responseJSON.message.message ? err.responseJSON.message.message : err);
                                $('#csv-rel-cad').append('  --> ERRO:  ' + msg + ' <--\n');
                            }
                            incrementaProgressoCadastro();
                        });
                    }
                });

                $('#csv-rel-cad').append('- - -      Fim importa&ccedil;&atilde;o      - - -');

                countTotalInativo = dataset.values.length;
                countInativo = 1;

                if (modoImportacao == 1) { //Total
                    $('#csv-rel-inat').append('- - -  Inativando registro(s)  - - -\n');

                    //INATIVA TODOS OS REGISTROS QUE ESTÃO NO DATASET E NÃO VIERAM NA IMPORTAÇÃO DO CSV
                    //PERCORRE OS REGISTROS DO DATASET
                    for (var k = 0; k < dataset.values.length; k++) {

                        //console.log('inativando');

                        var encontrouRegistro = false;

                        //PERCORRE OS REGISTROS DO CSV
                        for (var i = 0; i < countValores; i++) {

                            var codigoCSV = valores[i][0];
                            var codigoDataset = dataset.values[k][campoCodigo];
                            if (codigoCSV == codigoDataset) {
                                encontrouRegistro = true;
                                break;
                            }
                        }

                        if (!encontrouRegistro) {

                            $('#csv-rel-inat').append('--> inativando registro: ' + dataset.values[k][campoCodigo] + ' <--\n');

                            //console.log('inativando registro: ' + dataset.values[k][campoCodigo]);
                            var datasetInativar = DatasetFactory.getDataset(nomeDataset, null, new Array(DatasetFactory.createConstraint(campoCodigo, dataset.values[k][campoCodigo], dataset.values[k][campoCodigo], ConstraintType.MUST)), null);

                            if (datasetInativar.values && datasetInativar.values.length > 0) {
                                datasetInativar.values[0]['status'] = 'INATIVO';
                                var data = jsonToFluigRecord(datasetInativar.values[0]);
                                atualizaRegistro(datasetInativar.values[0]['metadata#id'], datasetInativar.values[0]['metadata#version'], data, function (err, dt) {
                                    if (err) {
                                        var msg = (err && err.responseText ? err.responseText : err.responseJSON && err.responseJSON.message && err.responseJSON.message.message ? err.responseJSON.message.message : err);
                                        $('#csv-rel-inat').append('  --> erro: ' + msg + ' <--\n');
                                    }
                                    incrementaProgressoInativo();
                                });
                            }
                        } else {
                            incrementaProgressoInativo();
                        }
                    }

                    $('#csv-rel-inat').append('- - -       Fim Inativa&ccedil;&atilde;o     - - -\n');
                }

            } else {

                $('#csv-rel-cad').append('- - -  Importando registro(s)  - - -\n');

                //NENHUM REGISTRO ENCONTRADO INSERINDO TODOS OS VALORES DO CSV
                //console.log('nenhum registro encontrado para o formulario de ID:' + that.formId);
                //console.log('importando todos os registros: ' + countValores);

                populateDataCSV(countValores, valores, colunas, function (data) {

                    $('#csv-rel-cad').append('--> criando novo registro:' + data[0]['value'] + ' <--\n');
                    criaRegistro(that.formId, data, function (err, dt) {
                        if (err) {
                            var msg = (err && err.responseText ? err.responseText : err.responseJSON && err.responseJSON.message && err.responseJSON.message.message ? err.responseJSON.message.message : err);
                            $('#csv-rel-cad').append('  --> ERRO: ' + msg + ' <--\n');
                        }
                        incrementaProgressoCadastro();
                    });
                });

                $('.progress-bar-inativos').css('width', 100 + '%').attr('aria-valuenow', 100).text(100 + '%');
                $('#progress-bar-inativos').removeClass('active');

                $('#csv-rel-cad').append('- - -      Fim importação      - - -');
            }

            loadingUploadCSV.hide();
            FLUIGC.toast({
                message: 'Importa&ccedil;&atilde;o realizada com sucesso, atualize a p&aacute;gina para ver os dados!',
                type: 'success'
            });
            window.location.reload();

        };
    })(f);

    // Read in the image file as a data URL.
    reader.readAsText(f);
}

function hasClass(ele, cls) {
    return ele.className.match(new RegExp('(\\s|^)' + cls + '(\\s|$)'));
}

function removeClass(ele, cls) {
    if (hasClass(ele, cls)) {
        var reg = new RegExp('(\\s|^)' + cls + '(\\s|$)');
        ele.className = ele.className.replace(reg, ' ');
    }
}

function sleepFor(sleepDuration) {
    var now = new Date().getTime();
    while (new Date().getTime() < now + sleepDuration) {
        /* do nothing */
    }
}

function jsonToFluigRecord(json) {
    var records = new Array();
    for (var key in json) {
        if (!key.includes('metadata#')) {
            var record = {};
            //console.log("Key: " + key);
            //console.log("Value: " + json[key]);
            record['name'] = key;
            record['value'] = json[key];
            records.push(record);
        }
    }
    return records;
}

function populateDataCSV(countValores, valores, colunas, cb) {
    for (var i = 0; i < countValores; i++) {

        var data = [];

        for (var j = 0; j < colunas.length; j++) {
            if (colunas[j] && valores[i][j]) {
                var record = {};
                record['name'] = colunas[j].replace(/\n|\r/g, "");
                record['value'] = valores[i][j].replace(/\n|\r/g, "");
                //console.log(record);
                data.push(record);
            }
        }

        if (data.length > 0) {
            cb(data);
        }
    }
}

function fastsales(nomeDataset, headerDatatable, filter, cb, cbrow, aditionalSort, columnSearch) {
    that = this;

    var filtros = new Array();
    //var filter = new Array();
    filtros.push(DatasetFactory.createConstraint("datasetName", nomeDataset, nomeDataset, ConstraintType.MUST));

    var datasets = DatasetFactory.getDataset("document", null, filtros, null);
    if (datasets && datasets.values && datasets.values.length > 0) {
        that.formId = parseFloat(datasets.values[0]["documentPK.documentId"]);
    } else {
        throw "Dataset informado não encontrado!";
    }

    sqlLimit = 0;
    if (filter && filter.length > 0) {
        for (var i = 0; i < filter.length; i++) {
            if (filter[i]['_field'] == 'sqlLimit') {
                try {
                    sqlLimit = parseInt(filter[i]['_initialValue']);
                } catch (error) {
                    console.log(error);
                }
            }
        }
    }

    that.columnSearch = columnSearch;

    $('#ver-mais').unbind('click').on('click', function () {
        listData(that.formId, 'list', that.headerDatatable, that.filter, that.cb, that.cbrow, that.aditionalSort, that.columnSearch);
    });

    FLUIGC.popover('.bs-docs-popover-click', {
        trigger: 'click',
        placement: 'auto'
    });

    //console.log('verificando licença');
    //FLUIGC.loading('#crudArea').show();

    $('[data-novo-registro]').hide();

    $('#crudArea').show();

    that.nomeDataset = nomeDataset;
    that.headerDatatable = headerDatatable;
    that.filter = filter;
    that.cb = cb;
    that.cbrow = cbrow;
    that.aditionalSort = aditionalSort;

    $('[data-novo-registro]').show();

    listData(that.formId, 'list', headerDatatable, filter, cb, cbrow, aditionalSort, columnSearch);
}

function listData(formId, datatableId, headerDatatable, filter, cb, cbrow, aditionalSort, columnSearch) {
    that.columnSearch = columnSearch;

    var loading = FLUIGC.loading(window);
    loading.show();
    //console.log('loading');

    if (dados == null)
        dados = [];

    that.datatable = FLUIGC.datatable('#' + datatableId, {
        dataRequest: dados,
        renderContent: '.template-tr',
        classSelected: 'active',
        search: {
            enabled: that.columnSearch && that.columnSearch.length > 0,
            onlyEnterkey: true,
            searchAreaStyle: 'col-md-12',
            onSearch: function (res) {
                if (!res) {
                    that.datatable.reload(dados);
                }
                var search = dados.filter(function (el) {
                    if (that.columnSearch && that.columnSearch.length < 1)
                        return false;

                    for (var i = 0; i < that.columnSearch.length; i++) {
                        var element = el[that.columnSearch[i]];
                        if (element) {
                            var conditionResult = element.toUpperCase().indexOf(res.toUpperCase()) >= 0;
                            if (conditionResult) {
                                return true;
                            }
                        }
                    }
                    return false;
                });
                if (search && search.length) {
                    that.datatable.reload(search);
                } else {
                    that.datatable.reload([]);
                }
            }
        },
        navButtons: {
            enabled: false
        },
        header: headerDatatable,
    }, function (err, data) {
        if (err) {
            //console.log(err);
            var msg = (err && err.responseText ? err.responseText : err.responseJSON && err.responseJSON.message && err.responseJSON.message.message ? err.responseJSON.message.message : err);
            FLUIGC.toast({
                message: msg,
                type: 'danger'
            });
        }
    });

    var sort = new Array();

    //sort.push('status');


    if (aditionalSort) {
        for (var i = 0; i < aditionalSort.length; i++) {
            sort.push(aditionalSort[i]);
        }
    }
    console.log('ordenando:', sort);

    if (filter == null)
        filter = new Array();

    for (var i = 0; i < filter.length; i++) {
        if (filter[i]['_field'] == 'sqlLimit') {
            filter.splice(i, 1);
            break;
        }
    }

    if (that.sqlLimit > 0) {
        var limit = DatasetFactory.createConstraint("sqlLimit", that.sqlLimit, that.sqlLimit, ConstraintType.MUST);
        filter.push(limit);
    }

    // DatasetFactory.getDataset(nomeDataset, null, null, sort, {
    DatasetFactory.getDataset(nomeDataset, null, filter, sort, {
        success: function (dataset) {
            datatable.reload([]);
            if (dataset.values) {

                //console.log(dataset.values);

                var item = dataset.values;

                var valuesDataset = new Array();

                for (var i = 0; i < item.length; i++) {

                    var value = item[i];

                    if (value["metadata#id"] != "") {
                        if (value["status"] == 'INATIVO') {
                            value["inativo"] = true;
                        }

                        that.cbrow(value);

                        that.datatable.addRow(i, value);
                        valuesDataset.push(value);
                    }
                }

                that.dados = valuesDataset;
            }

            //console.log(formId);

            loading.hide();

            that.cb(that.datatable);

            that.sqlLimit = that.sqlLimit + 30;
        }
    });
}

function novo(nomeForm) {
    editar(null, null, false, nomeForm);
}

function novoRegistro(formId, nomeForm) {
    this.formId = formId;
    editar(null, null, false, nomeForm);
}

function editarRegistro(documentid, version, parentDocumentid, editando, nomeForm) {
    this.formId = parentDocumentid;
    editar(documentid, version, editando, nomeForm);
}

function editar(documentid, version, editando, nomeForm) {

    this.editando = editando;

    if (this.editando) {
        this.edicaoDocumentid = documentid;
        this.edicaoVersion = version;
    }

    var serverURL = window.location.protocol + "//" + window.location.hostname + (window.location.port == '80' || window.location.port == '443' ? '' : (':' + window.location.port));
    var url = serverURL + '/webdesk/streamcontrol/' +
        this.formId + '/' + (documentid != null ? documentid : '') +
        '/' + (version != null ? version : '') + '//?WDCompanyId=1&' + (documentid != null ? ('WDNrDocto=' + documentid + '&') : '') + '' + (version != null ? ('WDNrVersao=' + version + '&') : '') +
        'WDParentDocumentId=' + this.formId + '&edit=' + (editando ? 'true' : 'false');

    console.log('abrindo formulario: ');
    console.log(url);

    // DIALOGO PARA INCLUSÃO DE UM NOVO REGISTRO
    this.modal = FLUIGC.modal({
        title: nomeForm,
        size: 'full',
        actions: [{
            'label': 'Salvar',
            'bind': 'data-save-modal',
        }],
        content: '<div id="modal_content">' +
            '</div>' +
            '<iframe id="iframe-manutencao-crud" name="docframe" frameborder="0" style="width:100%;height:500px;" src="' + url + '"></iframe>' +
            '',
        id: 'fluig-modal'
    }, function (err, data) {
        if (err) {
            //console.log(err);
            var msg = (err && err.responseText ? err.responseText : err.responseJSON && err.responseJSON.message && err.responseJSON.message.message ? err.responseJSON.message.message : err);
            FLUIGC.toast({
                message: msg,
                type: 'danger'
            });
        }
    });
}

function preparaDados(input, data) {
    var record = {};
    // if (input.attr('name')) {
    //     record['name'] = input.attr('name');
    //     var value = input.val();
    //     record['value'] = value;
    //     data.push(record);
    // }

    var nome = input.attr("name");
    var valor = input.val();
    if ((input.attr("type") == "checkbox") && (input.is("checked"))) {
        valor = "on";
    }
    if (input.attr("type") == "zoom") {
        valor = valor.join(",");
    }
    if ((nome) && (nome != "")) {
        record['name'] = nome;
        record['value'] = valor;
        data.push(record);
    }

}

function atualizaRegistro(documentoId, documentoVersion, data, cb) {
    console.log(JSON.stringify(data));
    var options, url = '/ecm/api/rest/ecm/cardView/editCard/' + documentoId + '/' + documentoVersion;
    options = {
        url: url,
        contentType: 'application/json',
        data: JSON.stringify(data),
        dataType: 'json',
        type: 'POST',
        loading: false,
        async: false
    };
    FLUIGC.ajax(options, function (err, data) {
        cb(err, data);
    });
}

function deletaRegistro(documentId, cb) {
    var options, url = '/api/public/2.0/documents/deleteDocument/' + documentId;
    options = {
        url: url,
        contentType: 'application/json',
        dataType: 'json',
        type: 'POST',
        loading: false,
        async: false
    };
    FLUIGC.ajax(options, cb);
}

function criaRegistro(formId, data, cb) {
    var options, url = '/api/public/2.0/cards/create';
    var params = {
        'documentDescription': new Date().getTime(),
        'parentDocumentId': formId,
        'version': 1000,
        'inheritSecurity': true,
        'attachments': [],
        'formData': data
    };
    options = {
        url: url,
        contentType: 'application/json',
        data: JSON.stringify(params),
        dataType: 'json',
        type: 'POST',
        loading: false,
        async: false
    };
    FLUIGC.ajax(options, function (err, data) {
        cb(err, data);
    });
}

function salvar(closeDialog, callback, atualizarList = true) {
    var data = [];
    that = this;

    $('#iframe-manutencao-crud').contents().find('input').each(function () {
        preparaDados($(this), data);
    });

    $('#iframe-manutencao-crud').contents().find('select').each(function () {
        preparaDados($(this), data);
    });

    $('#iframe-manutencao-crud').contents().find('textarea').each(function () {
        preparaDados($(this), data);
    });

    if (!editando) {
        console.log("criando novo registro: ", formId, data);
        criaRegistro(formId, data, function (err, data) {
            if (!err) {
                FLUIGC.toast({
                    message: 'Registro salvo com sucesso!',
                    type: 'success'
                });
                callback(data.content);
                console.log("fechando modal: ", closeDialog);
                if (closeDialog) {
                    console.log("modal fechando: ", that.modal);
                    that.modal.remove();
                }
                if (atualizarList) {
                    that.sqlLimit = 30;
                    listData(that.formId, 'list', that.headerDatatable, that.filter, that.cb, that.cbrow, that.aditionalSort, that.columnSearch);
                }
            } else {
                //console.log(err);
                var msg = '';
                if (err.responseJSON) {
                    msg = err.responseJSON.message.message;
                } else if (err.responseText) {
                    msg = err.responseText;
                } else {
                    msg = err;
                }
                FLUIGC.toast({
                    message: msg,
                    type: 'danger'
                });
            }
        });
    } else {
        console.log("atualizando registro: ", this.edicaoDocumentid, this.edicaoVersion, data);
        atualizaRegistro(this.edicaoDocumentid, this.edicaoVersion, data, function (err, data) {
            if (!err) {
                FLUIGC.toast({
                    message: 'Registro atualizado com sucesso!',
                    type: 'success'
                });
                callback(data);
                console.log("fechando modal: ", closeDialog);
                if (closeDialog) {
                    console.log("modal fechando: ", that.modal);
                    that.modal.remove();
                } else {
                    edicaoVersion = parseFloat(edicaoVersion) + 1000;
                }
                if (atualizarList) {
                    that.sqlLimit = 30;
                    listData(that.formId, 'list', that.headerDatatable, that.filter, that.cb, that.cbrow, that.aditionalSort, that.columnSearch);
                }
            } else {
                //console.log(err);
                var msg = (err && err.responseText ? err.responseText : err.responseJSON && err.responseJSON.message && err.responseJSON.message.message ? err.responseJSON.message.message : err);
                if (msg.indexOf("rro ao criar uma nova versão do formulário") >= 0) msg = "Registro alterado por outro usuário, atualize a pagina e tente novamente!";
                FLUIGC.toast({
                    message: msg,
                    type: 'danger'
                });
            }
        });
    }
}

function initFluigForm() {
    $('[data-only-numbers]').on('keypress', function (e) {
        if (!e) {
            var e = window.event;
        }

        if (e.keyCode > 0 && e.which == 0) {
            return true;
        }

        if (e.keyCode) {
            code = e.keyCode;
        } else if (e.which) {
            code = e.which;
        }

        if (code == 46) {
            return true;
        }

        var character = String.fromCharCode(code);
        if (character == '\b' || character == ' ' || character == '\t') {
            return true;
        }
        if (keyDown && (code == vKey || code == Vkey)) {
            return (character);
        } else {
            return (/[0-9]$/.test(character));
        }
    }).on('focusout', function (e) {
        var $this = $(this);
        if ($this.val() == "") {
            return true;
        }
        $this.val($this.val().replace(/[^0-9\.]/g, ''));
    }).on('paste', function (e) {
        var $this = $(this);
        setTimeout(function () {
            $this.val($this.val().replace(/[^0-9\.]/g, ''));
        }, 5);
    });

    $('[data-currency]').on('keypress', function (e) {
        if (!e) {
            var e = window.event;
        }

        if (e.keyCode > 0 && e.which == 0) {
            return true;
        }

        if (e.keyCode) {
            code = e.keyCode;
        } else if (e.which) {
            code = e.which;
        }

        if (code == 46) {
            return true;
        }

        var character = String.fromCharCode(code);
        if (character == '\b' || character == ' ' || character == '\t') {
            return true;
        }
        if (keyDown && (code == vKey || code == Vkey)) {
            return (character);
        } else {
            return (/[0-9]$/.test(character));
        }
    });


    $('.create-form-components').on('keyup', 'input[required="required"][type="text"], input[required="required"][type="number"], input[required="required"][type="date"], textarea[required="required"]', function () {
        validationFieldsForm($(this), $(this).parents('.form-field').data('type'));
    });

    $('.create-form-components').on('change', 'input[required="required"][type="checkbox"], input[required="required"][type="radio"], select[required="required"]', function () {
        validationFieldsForm($(this), $(this).parents('.form-field').data('type'));
    });

    var $zoomPreview = $(".zoom-preview");
    if ($zoomPreview.length) {
        $zoomPreview.parent().removeClass("input-group");
        $zoomPreview.remove();
    }

    var ratings = $(".rating");
    if (ratings.length > 0) ratingStars(ratings);

    $.each($("[data-date]"), function (i, o) {
        var id = $(o).attr("id");
        FLUIGC.calendar("#" + id);
    });
}

function initCalendar() {
    $.each($("[data-date]"), function (i, o) {
        var id = $(o).attr("id");
        if ($("#" + id).attr("readonly")) {
            $("#" + id).data('DateTimePicker').disable();
        }
    });
}

function validationFieldsForm(field, type) {
    if (type === "checkbox" || type === "radio") {
        if (!field.is(':checked')) {
            field.parents('.form-field').addClass('required');
        } else {
            field.parents('.form-field').removeClass('required');
        }
    } else {
        if (!field.val().trim()) {
            field.parents('.form-field').addClass('required');
        } else {
            field.parents('.form-field').removeClass('required');
        }
    }
}

function ratingStars(stars) {
    $.each(stars, function (i, obj) {
        var field = $(this).closest(".form-group").find(".rating-value");
        var tgt = $(obj);
        tgt.html("");
        var rating = FLUIGC.stars(tgt, {
            value: field.val()
        });
        rating.on("click", function (o) {
            field.val($(this).index() + 1);
        });
    });
}

var keyDown = false,
    ctrl = 17,
    vKey = 86,
    Vkey = 118;

$(document).keydown(function (e) {
    if (e.keyCode == ctrl) keyDown = true;
}).keyup(function (e) {
    if (e.keyCode == ctrl) keyDown = false;
});

$(document).ready(function () {
    initForms();
});

function initUploadCSV() {

    $(document).on('click', '[data-show-message-page-csv]', function (ev) {
        modoImportacao = 0;
        dataFileInput = $(this).attr('data-file-input');
        //console.log(dataFileInput);

        FLUIGC.message.confirm({
            message: '<p style="font-weight: bold">Carga Total: Este modo l&ecirc; todos os dados do arquivo CSV, cadastra ou atualiza os registros e inativa os registros antigos que n&atilde;o est&atilde;o no arquivo CSV.</p>' +
                '<p style="font-weight: bold">Carga Parcial: Este modo l&ecirc; todos os dados do arquivo CSV e apenas cadastra novo registros.</p>' +
                '<select class="form-control" name="csv-modo-importacao" id="csv-modo-importacao">' +
                '<option value="0">--- SELECIONE ---</option>' +
                '<option value="1">Carga Total</option>' +
                '<option value="2">Carga Parcial</option>' +
                '</select>',
            title: 'Escolha como importar os dados: ',
            labelYes: 'Confirmar',
            labelNo: 'Cancelar'
        }, function (result, el, ev) {
            //Callback action executed by the user...

            //result: Result chosen by the user...
            //el: Element (button) clicked...
            //ev: Event triggered...
            //console.log($('#csv-modo-importacao').val());

            if ($('#csv-modo-importacao').val() == '0' && result) {
                el.preventDefault();
                return;
            }

            if (!result)
                return;

            modoImportacao = $('#csv-modo-importacao').val();
            if ($('#upload-csv') && dataFileInput == 'upload-csv') {
                $('#upload-csv').trigger('click');
            }
            if ($('#upload-csv-filho') && dataFileInput == 'upload-csv-filho') {
                $('#upload-csv-filho').trigger('click');
            }
        });
    });

    if (document.getElementById('upload-csv')) {
        document.getElementById('upload-csv').addEventListener('change', handleFileSelect, false);
    }
    if (document.getElementById('upload-csv-filho')) {
        document.getElementById('upload-csv-filho').addEventListener('change', handleFileSelectFilho, false);
    }
}

function initForms() {
    initFluigForm();
    initCalendar();
    $('.date').mask('00/00/0000');
    $('.time').mask('00:00:00');
    $('.date_time').mask('00/00/0000 00:00:00');
    $('.cep').mask('00000-000');
    $('.phone').mask('0000-0000');
    $('.phone_with_ddd').mask('(00) 0000-0000');
    $('.phone_us').mask('(000) 000-0000');
    $('.mixed').mask('AAA 000-S0S');
    $('.cpf').mask('000.000.000-00', {
        reverse: true
    });
    $('.cnpj').mask('00.000.000/0000-00', {
        reverse: true
    });
    $('.money').mask('000.000.000.000.000,00', {
        reverse: true
    });
    $('.money2').mask("#.##0,00", {
        reverse: true
    });
    $('.ip_address').mask('0ZZ.0ZZ.0ZZ.0ZZ', {
        translation: {
            'Z': {
                pattern: /[0-9]/,
                optional: true
            }
        }
    });
    $('.ip_address').mask('099.099.099.099');
    $('.percent').mask('##0,00%', {
        reverse: true
    });
    $('.clear-if-not-match').mask("00/00/0000", {
        clearIfNotMatch: true
    });
    $('.date-placeholder').mask("00/00/0000", {
        placeholder: "__/__/____"
    });
    $('.fallback').mask("00r00r0000", {
        translation: {
            'r': {
                pattern: /[\/]/,
                fallback: '/'
            },
            placeholder: "__/__/____"
        }
    });
    $('.selectonfocus').mask("00/00/0000", {
        selectOnFocus: true
    });
    /*var inputs = $("[mask]");
    MaskEvent.initMask(inputs);*/

    initUploadCSV();

    setTimeout(function () {
        $(".workflow-card-view-frame", window.parent.document).css('padding-bottom', '50px');
    }, 1000);
}

/**
 * jquery.mask.js
 * @version: v1.7.7
 * @author: Igor Escobar
 *
 * Created by Igor Escobar on 2012-03-10. Please report any bug at http://blog.igorescobar.com
 *
 * Copyright (c) 2012 Igor Escobar http://blog.igorescobar.com
 *
 * The MIT License (http://www.opensource.org/licenses/mit-license.php)
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
/*jshint laxbreak: true */
/* global define */

// UMD (Universal Module Definition) patterns for JavaScript modules that work everywhere.
// https://github.com/umdjs/umd/blob/master/jqueryPlugin.js
(function (factory) {
    if (typeof define === "function" && define.amd) {
        // AMD. Register as an anonymous module.
        define(["jquery"], factory);
    } else {
        // Browser globals
        factory(window.jQuery || window.Zepto);
    }
}(function ($) {
    "use strict";
    var Mask = function (el, mask, options) {
        var jMask = this,
            old_value, regexMask;
        el = $(el);

        mask = typeof mask === "function" ? mask(el.val(), undefined, el, options) : mask;

        var p = {
            getCaret: function () {
                try {
                    var sel,
                        pos = 0,
                        ctrl = el.get(0),
                        dSel = document.selection,
                        cSelStart = ctrl.selectionStart;

                    // IE Support
                    if (dSel && !~navigator.appVersion.indexOf("MSIE 10")) {
                        sel = dSel.createRange();
                        sel.moveStart('character', el.is("input") ? -el.val().length : -el.text().length);
                        pos = sel.text.length;
                    }
                    // Firefox support
                    else if (cSelStart || cSelStart === '0') {
                        pos = cSelStart;
                    }

                    return pos;
                } catch (e) {}
            },
            setCaret: function (pos) {
                try {
                    if (el.is(":focus")) {
                        var range, ctrl = el.get(0);

                        if (ctrl.setSelectionRange) {
                            ctrl.setSelectionRange(pos, pos);
                        } else if (ctrl.createTextRange) {
                            range = ctrl.createTextRange();
                            range.collapse(true);
                            range.moveEnd('character', pos);
                            range.moveStart('character', pos);
                            range.select();
                        }
                    }
                } catch (e) {}
            },
            events: function () {
                el
                    .on('keydown.mask', function () {
                        old_value = p.val();
                    })
                    .on('keyup.mask', p.behaviour)
                    .on("paste.mask drop.mask", function () {
                        setTimeout(function () {
                            el.keydown().keyup();
                        }, 100);
                    })
                    .on("change.mask", function () {
                        el.data("changed", true);
                    })
                    .on("blur.mask", function () {
                        if (old_value !== el.val() && !el.data("changed")) {
                            el.trigger("change");
                        }
                        el.data("changed", false);
                    })
                    // clear the value if it not complete the mask
                    .on("focusout.mask", function () {
                        if (options.clearIfNotMatch && !regexMask.test(p.val())) {
                            p.val('');
                        }
                    });
            },
            getRegexMask: function () {
                var maskChunks = [],
                    translation, pattern, optional, recursive, oRecursive, r;

                for (var i = 0; i < mask.length; i++) {
                    translation = jMask.translation[mask[i]];

                    if (translation) {

                        pattern = translation.pattern.toString().replace(/.{1}$|^.{1}/g, "");
                        optional = translation.optional;
                        recursive = translation.recursive;

                        if (recursive) {
                            maskChunks.push(mask[i]);
                            oRecursive = {
                                digit: mask[i],
                                pattern: pattern
                            };
                        } else {
                            maskChunks.push(!optional && !recursive ? pattern : (pattern + "?"));
                        }

                    } else {
                        maskChunks.push(mask[i].replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'));
                    }
                }

                r = maskChunks.join("");

                if (oRecursive) {
                    r = r.replace(new RegExp("(" + oRecursive.digit + "(.*" + oRecursive.digit + ")?)"), "($1)?")
                        .replace(new RegExp(oRecursive.digit, "g"), oRecursive.pattern);
                }

                return new RegExp(r);
            },
            destroyEvents: function () {
                el.off(['keydown', 'keyup', 'paste', 'drop', 'change', 'blur', 'focusout', 'DOMNodeInserted', ''].join('.mask '))
                    .removeData("changeCalled");
            },
            val: function (v) {
                var isInput = el.is('input');
                return arguments.length > 0 ?
                    (isInput ? el.val(v) : el.text(v)) :
                    (isInput ? el.val() : el.text());
            },
            getMCharsBeforeCount: function (index, onCleanVal) {
                for (var count = 0, i = 0, maskL = mask.length; i < maskL && i < index; i++) {
                    if (!jMask.translation[mask.charAt(i)]) {
                        index = onCleanVal ? index + 1 : index;
                        count++;
                    }
                }
                return count;
            },
            caretPos: function (originalCaretPos, oldLength, newLength, maskDif) {
                var translation = jMask.translation[mask.charAt(Math.min(originalCaretPos - 1, mask.length - 1))];

                return !translation ? p.caretPos(originalCaretPos + 1, oldLength, newLength, maskDif) :
                    Math.min(originalCaretPos + newLength - oldLength - maskDif, newLength);
            },
            behaviour: function (e) {
                e = e || window.event;
                var keyCode = e.keyCode || e.which;
                if ($.inArray(keyCode, jMask.byPassKeys) === -1) {

                    var caretPos = p.getCaret(),
                        currVal = p.val(),
                        currValL = currVal.length,
                        changeCaret = caretPos < currValL,
                        newVal = p.getMasked(),
                        newValL = newVal.length,
                        maskDif = p.getMCharsBeforeCount(newValL - 1) - p.getMCharsBeforeCount(currValL - 1);

                    if (newVal !== currVal) {
                        p.val(newVal);
                    }

                    // change caret but avoid CTRL+A
                    if (changeCaret && !(keyCode === 65 && e.ctrlKey)) {
                        // Avoid adjusting caret on backspace or delete
                        if (!(keyCode === 8 || keyCode === 46)) {
                            caretPos = p.caretPos(caretPos, currValL, newValL, maskDif);
                        }
                        p.setCaret(caretPos);
                    }

                    return p.callbacks(e);
                }
            },
            getMasked: function (skipMaskChars) {
                var buf = [],
                    value = p.val(),
                    m = 0,
                    maskLen = mask.length,
                    v = 0,
                    valLen = value.length,
                    offset = 1,
                    addMethod = "push",
                    resetPos = -1,
                    lastMaskChar,
                    check;

                if (options.reverse) {
                    addMethod = "unshift";
                    offset = -1;
                    lastMaskChar = 0;
                    m = maskLen - 1;
                    v = valLen - 1;
                    check = function () {
                        return m > -1 && v > -1;
                    };
                } else {
                    lastMaskChar = maskLen - 1;
                    check = function () {
                        return m < maskLen && v < valLen;
                    };
                }

                while (check()) {
                    var maskDigit = mask.charAt(m),
                        valDigit = value.charAt(v),
                        translation = jMask.translation[maskDigit];

                    if (translation) {
                        if (valDigit.match(translation.pattern)) {
                            buf[addMethod](valDigit);
                            if (translation.recursive) {
                                if (resetPos === -1) {
                                    resetPos = m;
                                } else if (m === lastMaskChar) {
                                    m = resetPos - offset;
                                }

                                if (lastMaskChar === resetPos) {
                                    m -= offset;
                                }
                            }
                            m += offset;
                        } else if (translation.optional) {
                            m += offset;
                            v -= offset;
                        }
                        v += offset;
                    } else {
                        if (!skipMaskChars) {
                            buf[addMethod](maskDigit);
                        }

                        if (valDigit === maskDigit) {
                            v += offset;
                        }

                        m += offset;
                    }
                }

                var lastMaskCharDigit = mask.charAt(lastMaskChar);
                if (maskLen === valLen + 1 && !jMask.translation[lastMaskCharDigit]) {
                    buf.push(lastMaskCharDigit);
                }

                return buf.join("");
            },
            callbacks: function (e) {
                var val = p.val(),
                    changed = val !== old_value;
                if (changed === true) {
                    if (typeof options.onChange === "function") {
                        options.onChange(val, e, el, options);
                    }
                }

                if (changed === true && typeof options.onKeyPress === "function") {
                    options.onKeyPress(val, e, el, options);
                }

                if (typeof options.onComplete === "function" && val.length === mask.length) {
                    options.onComplete(val, e, el, options);
                }
            }
        };


        // public methods
        jMask.mask = mask;
        jMask.options = options;
        jMask.remove = function () {
            var caret;
            p.destroyEvents();
            p.val(jMask.getCleanVal()).removeAttr('maxlength');

            caret = p.getCaret();
            p.setCaret(caret - p.getMCharsBeforeCount(caret));
            return el;
        };

        // get value without mask
        jMask.getCleanVal = function () {
            return p.getMasked(true);
        };

        jMask.init = function () {
            options = options || {};

            jMask.byPassKeys = [9, 16, 17, 18, 36, 37, 38, 39, 40, 91];
            jMask.translation = {
                '0': {
                    pattern: /\d/
                },
                '9': {
                    pattern: /\d/,
                    optional: true
                },
                '#': {
                    pattern: /\d/,
                    recursive: true
                },
                'A': {
                    pattern: /[a-zA-Z0-9]/
                },
                'S': {
                    pattern: /[a-zA-Z]/
                }
            };

            jMask.translation = $.extend({}, jMask.translation, options.translation);
            jMask = $.extend(true, {}, jMask, options);

            regexMask = p.getRegexMask();

            if (options.maxlength !== false) {
                el.attr('maxlength', mask.length);
            }

            if (options.placeholder) {
                el.attr('placeholder', options.placeholder);
            }

            el.attr('autocomplete', 'off');
            p.destroyEvents();
            p.events();

            var caret = p.getCaret();

            p.val(p.getMasked());
            p.setCaret(caret + p.getMCharsBeforeCount(caret, true));

        }();

    };

    var watchers = {},
        live = 'DOMNodeInserted.mask',
        HTMLAttributes = function () {
            var input = $(this),
                options = {},
                prefix = "data-mask-";

            if (input.attr(prefix + 'reverse')) {
                options.reverse = true;
            }

            if (input.attr(prefix + 'maxlength') === 'false') {
                options.maxlength = false;
            }

            if (input.attr(prefix + 'clearifnotmatch')) {
                options.clearIfNotMatch = true;
            }

            input.mask(input.attr('data-mask'), options);
        };

    $.fn.mask = function (mask, options) {
        var selector = this.selector,
            maskFunction = function () {
                var maskObject = $(this).data('mask'),
                    stringify = JSON.stringify;

                if (typeof maskObject !== "object" || stringify(maskObject.options) !== stringify(options) || maskObject.mask !== mask) {
                    return $(this).data('mask', new Mask(this, mask, options));
                }
            };

        this.each(maskFunction);

        if (selector && !watchers[selector]) {
            // dynamically added elements.
            watchers[selector] = true;
            setTimeout(function () {
                $(document).on(live, selector, maskFunction);
            }, 500);
        }
    };

    $.fn.unmask = function () {
        try {
            return this.each(function () {
                $(this).data('mask').remove().removeData('mask');
            });
        } catch (e) {};
    };

    $.fn.cleanVal = function () {
        return this.data('mask').getCleanVal();
    };

    // looking for inputs with data-mask attribute
    $('*[data-mask]').each(HTMLAttributes);

    // dynamically added elements with data-mask html notation.
    $(document).on(live, '*[data-mask]', HTMLAttributes);

}));

function excluir(documentid, callback) {

    that = this;

    FLUIGC.message.confirm({
        message: 'Confirma a exclusão do registro ' + documentid + '?',
        title: 'Confirmar exclusão',
        labelYes: 'Sim',
        labelNo: 'Não'
    }, function (result, el, ev) {

        if (!result) {
            return;
        }

        var myLoading2 = FLUIGC.loading(window);
        myLoading2.show();

        var structureDelete = {
            "docsToDelete": [{
                "docId": documentid,
                "isLink": false,
                "parentId": that.formId
            }],
            "metadataFormsToDelete": []
        };

        console.log('excluindo registro: ' + documentid);

        var options, url = '/ecm/api/rest/ecm/navigation/removeDoc/';
        var params = JSON.stringify(structureDelete);

        console.log(url);
        console.log(params);

        options = {
            url: url,
            contentType: 'application/json',
            dataType: 'json',
            data: params,
            type: 'DELETE',
            loading: false
        };

        FLUIGC.ajax(options, function (error, data) {
            console.log('registro excluido: ', error, data);
            if (error) {
                console.log(error);
                FLUIGC.toast({
                    message: error,
                    type: 'danger'
                });
            } else {
                FLUIGC.toast({
                    title: 'Sucesso:',
                    message: "Registro excluido com sucesso.",
                    type: 'success'
                });
                callback();
                that.sqlLimit = 30;
                listData(that.formId, 'list', that.headerDatatable, that.filter, that.cb, that.cbrow, that.aditionalSort, that.columnSearch);
            }
            var myLoading2 = FLUIGC.loading(window);
            myLoading2.hide();
        });

    });

}