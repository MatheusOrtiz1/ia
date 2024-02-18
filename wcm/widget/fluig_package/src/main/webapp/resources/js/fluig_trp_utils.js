var restaurouDados = false;

//DESATIVAR REFRESH PELO MOBILE
function disablePullToRefresh() {
    return true;
}

//FILTRO PARA AUTOCOMPLETE
function substringMatcher(listaObjetos, campo, campo2, campo3, campo4) {
    return function findMatches(q, cb) {
        var matches, substrRegex;

        matches = [];

        substrRegex = new RegExp(q, 'i');

        $.each(listaObjetos, function (i, objeto) {
            if (substrRegex.test(objeto[campo])) {
                matches.push(objeto);
            } else if ((campo2) && (substrRegex.test(objeto[campo2]))) {
                matches.push(objeto);
            } else if ((campo3) && (substrRegex.test(objeto[campo3]))) {
                matches.push(objeto);
            } else if ((campo4) && (substrRegex.test(objeto[campo4]))) {
                matches.push(objeto);
            }
        });
        cb(matches);
    };
};

var modificacao;
var inclusao;
var edicao;
var rascunho;
var mobile;
var visualizacao;

//METODO PRINCIPAL QUANDO CARREGA A PAGINA
function carregaPagina() {

    //TRATATIVA DE TIMEOUT PARA O MOBILE (RASCUNHO)
    setTimeout(function () {
        /**
         * ADD: Criacao do formulario

         MOD: Formulario em edicao

         VIEW: Visualizacao do formulario

         NONE: Nao ha comunicacao com o formulario, por exemplo, ocorre no momento da validacao dos campos do formulario onde este nao esta sendo apresentado.
         */
        mobile = $("#WKMobile").val() == "S";
        modificacao = $("#_MOD").val() == "MOD" || $("#MOD_").val() == "MOD";
        inclusao = $("#_MOD").val() == "ADD" || $("#MOD_").val() == "ADD";
        visualizacao = $("#_MOD").val() == "VIEW" || $("#MOD_").val() == "VIEW";
        edicao = modificacao || inclusao;
        rascunho = mobile && inclusao;

        //alert("mobile: "+mobile);
        //alert("modificacao: "+modificacao);
        //alert("inclusao: "+inclusao);
        //alert("edicao: "+edicao);
        //alert("rascunho: "+rascunho);

        var init = initValidate();

        //alert("init: "+init);

        if(typeof init == "undefined"){
            FLUIGC.toast({
                message: 'Metodo initValidate nao implementado no app.js!',
                type: 'warning',
                timeout: 'slow'
            });
            return;
        }

        if(!init)
            return;

        //TRATATIVA PARA EXECUTAR SOMENTE EM MODIFICACAO OU ADICAO
        //if (edicao) {
        //APLICA OS EVENTOS PADROES DO TEMPLATE
        aplicaEventosPadrao();

        //CHAMA METODO QUE DEVE SER IMPLEMENTADO NO JS PARA APLICAR OS EVENTOS AOS INPUTS
        eval("aplicaEventos();");

        guardaValoresTRP();
        eval("guardaValores();");

        trpConsultaDados();
        //}else{
        //    trpInit();
        //}



    }, $("#WKMobile").val() == "S" ? 2000 : 100);

    setTimeout(function() {
        var style = $("#workflowView-cardViewer", window.parent.document).attr("style");
        $("#workflowView-cardViewer", window.parent.document).attr("style",style+"; padding-left:5px !important;padding-top:5px !important");
    }, 1000);
}

function trpInit(){

    restauraValoresTRP();
    eval("restauraValores();");

    restaurouDados = true;

    //SE FOR MODIFICACAO RESTAURA VALORES
    if (inclusao) {
        eval("novoRegistro();")
    }

    if(visualizacao){
        $("input, select, textarea").attr("readonly","readonly");
        $(".btn").hide();
        $(".fluigicon-trash").hide();
    }

    eval("restauraEstados("+(modificacao ? "false":"true")+");");
}

function trpConsultaDados(){
    FLUIGC.loading(window).show();

    setTimeout(function () {
        try{
            eval("preencheDados();");
            trpInit();
        }catch (e) {
            console.log(e);
            FLUIGC.toast({
                message: e,
                type: 'danger',
                timeout: 'slow'
            });
        }finally {
            FLUIGC.loading(window).hide();
        }
    }, 200);
}

var valoresGuardadosAutocomplete = [];
var valoresGuardadosSelect = [];

function guardaValoresTRP(){
    $("input[name$='_OBJ']").each(function(){
        var record = {};
        record["name"] = $(this).attr("name");
        record["filter"] = $(this).attr("filter-name");

        if($("#"+record["name"]).val() == "")
            $("#"+record["name"]).val("{}");

        if($("#"+record["name"]).val() != "{}") {
            record["value"] = JSON.parse($("#" + record["name"]).val());
            valoresGuardadosAutocomplete.push(record);
        }
    });

    $("input[name$='_VAL']").each(function(){
        var record = {};
        record["name"] = $(this).attr("name");
        record["value"] = $(this).val();
        if($(this).val() != "")
            valoresGuardadosSelect.push(record);
    });
}

function restauraValoresTRP(){

    for(var i = 0;i<valoresGuardadosAutocomplete.length;i++){
        var item = valoresGuardadosAutocomplete[i];

        if(item.value != "" && typeof item.value != "undefined" && $("#"+item.name).val() != "{}"){
            eval("if("+item.filter+")"+item.filter+".add(item.value);");

            if(visualizacao) {
                var itemName = item.name.replace("_OBJ","");
                eval("if("+item.filter+")new TRP('"+itemName+"').AutoComplete.Destroy("+item.filter+");")
                //eval(item.filter + ".destroy();");
            }
        }
    }

    for(var i = 0;i<valoresGuardadosSelect.length;i++){
        var item = valoresGuardadosSelect[i];

        $('#'+item.name.split("_VAL")[0]).val(item.value);
    }

    restaurouDados = true;

}

function aplicaEventosPadrao() {

    //INICIALIZA O MOMENT PARA O BRASIL
    moment.locale('pt');

    //INICIALIZA CALENDARIO DO FLUIG PARA CADA CAMPO COM A CLASSE DAT
    $(".date").each(function () {

        var dataInicio = "";

        //CASO TENHA O ATRIBUTO INIT-DATE-NOW INICIALIZA COM A DATA ATUAL CASO AINDA NAO TENHA VALOR NO CAMPO
        if ($(this).attr('init-date-now')) {
            var dataAtual = $(this).val();
            if (dataAtual == "") {
                dataInicio = moment().format('DD/MM/YYYY');
            }
        }

        FLUIGC.calendar('[name=' + $(this).attr('name') + ']', {
            pickDate: true,
            pickTime: false,
            useMinutes: false,
            useSeconds: false,
            useCurrent: true,
            minuteStepping: 1,
            //minDate: '1/1/2014',
            //maxDate: '1/1/2015',
            showToday: true,
            language: 'pt-br',
            defaultDate: dataInicio,
            disabledDates: [],
            enabledDates: [],
            useStrict: false,
            sideBySide: false,
            daysOfWeekDisabled: []
        });
    });

}

//FUNCOES DE DATATABLE
function TablePrototype(selector) {
    this.selector = selector;
    Init = function (responsive, columns) {
        this.Destroy(this.selector);
        var tabela = $(this.selector).DataTable({
            dom: 't',
            responsive: responsive,
            columns: columns,
            autoWidth: false,
            paging: false,
            ordering: true,
            language: {
                info: "Mostrando _TOTAL_ registros",
                infoEmpty: "Nenhum registro para exibir",
                emptyTable: "Nenhum registro para exibir",
                infoFiltered: " de _MAX_ registros",
                search: "Filtrar: "
            }
        });
        return this;
    };
    Reset = function () {
        var table = this.Get(this.selector);
        if (table) {
            table.rows().remove().draw();
        }
        return this;
    };
    Destroy = function () {
        var table = this.Get(this.selector);

        if (table != null) table.destroy();

        //Remove all the DOM elements
        $(this.selector).empty();
        return this;
    };
    Add = function (values) {
        var table = this.Get(this.selector);
        if (table) {
            table.rows.add(values).draw();
            $($.fn.dataTable.tables(true)).css('width', '100%');
            $($.fn.dataTable.tables(true)).DataTable().columns.adjust().draw();
        }
        return this;
    };
    Get = function () {
        if ($.fn.dataTable.isDataTable(this.selector))
            return $(this.selector).DataTable();
        return null;
    };
}

//FUNCOES DE FORMATACAO / CONVERSAO DE DADOS
function FormatPrototype(selector) {
    this.selector = selector;
    strToVlr = function (str, decimal) {
        var decimalPlaces = typeof decimal == "undefined" ? 2 : decimal;
        return Number(str).formatMoney(decimalPlaces, ',', '.');
    };
    strToMoeda = function (str, decimal) {
        return "R$ " + this.strToVlr(str, decimal);
    };
}

//FUNCOES PARA DATASETS
function DSPrototype(selector) {
    this.selector = selector;
    consulta = function (dsName, fields, constraints, order, fnSucess, fnError) {
        FLUIGC.loading(window).show();
        setTimeout(function () {
            DatasetFactory.getDataset(dsName, fields, constraints, order, {
                success: function (retorno) {
                    FLUIGC.loading(window).hide();
                    if (typeof fnSucess != "undefined")
                        fnSucess(retorno);
                },
                error: function (erro) {
                    FLUIGC.loading(window).hide();
                    if (typeof fnError != "undefined")
                        fnError(erro);
                }
            });
        }, 0);
    };
    consultaSinc = function (dsName, fields, constraints, order) {
        return DatasetFactory.getDataset(dsName, fields, constraints, order);
    };
}

//FUNCOES PARA AUTOCOMPLETE
function AutocompletePrototype(selector) {
    this.selector = selector;
    this.RemoveEvents = function(){
        $('#'+this.selector).unbind("fluig.autocomplete.itemAdded");
        $('#'+this.selector).unbind("fluig.autocomplete.itemUpdated");
        $('#'+this.selector).unbind("fluig.autocomplete.itemRemoved");
    };
    this.Destroy = function(filter){

        $("#"+this.selector).attr("readonly","readonly");
        this.RemoveEvents();

        if (typeof filter != "undefined") {
            if(filter)
                filter.destroy();
            delete filter;
            filter = null;
        }
    };
    this.InitGenerico = function (filter, itemAddedUpdated, itemRemoved, source) {
        this.RemoveEvents();
        $("#"+this.selector).removeAttr("readonly");
        filter = FLUIGC.autocomplete('#'+this.selector, {
            source:
                typeof source != "undefined" ? source: ({
                    url:  '/api/public/ecm/dataset/search?datasetId='+($("#"+this.selector).attr("ds-name"))+'&searchField=BUSCA&',
                    contentType: 'application/json',
                    root: 'content',
                    pattern: '',
                    limit: 100,
                    offset: 0,
                    //patternKey: 'pattern',
                    patternKey: 'searchValue',
                    limitkey: 'limit',
                    offsetKey: 'offset'
                }) ,
            displayKey: function (row) {
                return row.BUSCA;
            },
            tagClass: 'tag-gray',
            maxTags: 1,
            type: 'tagAutocomplete',
            tagMaxWidth: 'tag-max-width',
            onMaxTags: function (item, tag) {
                /*FLUIGC.toast({
                    message: 'Maximo de 1 registro permitido.',
                    type: 'warning',
                    timeout: 'slow'
                });*/
            },
            templates: {
                tag: '.tag-template-generico',
                suggestion: '.tag-template-generico'
            }
        });

        filter.on('fluig.autocomplete.itemAdded', function (ev) {
            if(!restaurouDados)
                return;

            $("#"+$(ev.currentTarget).attr("name")+"_OBJ").val(JSON.stringify(ev.item));

            if (typeof itemAddedUpdated != "undefined")
                itemAddedUpdated(ev);
        });

        filter.on('fluig.autocomplete.itemUpdated', function (ev) {
            if(!restaurouDados)
                return;

            $("#"+$(ev.currentTarget).attr("name")+"_OBJ").val(JSON.stringify(ev.item));

            if (typeof itemAddedUpdated != "undefined")
                itemAddedUpdated(ev);
        });

        filter.on('fluig.autocomplete.itemRemoved', function (ev) {
            if(!restaurouDados)
                return;

            $("#"+$(ev.target).attr("name")+"_OBJ").val("{}");

            if (typeof itemRemoved != "undefined")
                itemRemoved(ev);
        });

        return filter;
    };
    this.Init = function (source, displayKey, itemAddedUpdated, itemRemoved) {
        var filter = FLUIGC.autocomplete(this.selector, {
            source: source,
            displayKey: displayKey,
            tagClass: 'tag-default tag-max-width',
            maxTags: 1,
            type: 'tagAutocomplete',
            onMaxTags: function (item, tag) {
                FLUIGC.toast({
                    message: 'Maximo de 1 registro permitido.',
                    type: 'warning',
                    timeout: 'slow'
                });
            }
        });
        if (typeof itemAddedUpdated != "undefined") {
            filter.on('fluig.autocomplete.itemAdded', itemAddedUpdated);
            filter.on('fluig.autocomplete.itemUpdated', itemAddedUpdated);
        }
        if (typeof itemRemoved != "undefined")
            filter.on('fluig.autocomplete.itemRemoved', itemRemoved);
        return filter;
    }
}

function SelectPrototype(selector) {
    this.selector = selector;
    this.Init = function (dsConsulta, cbrow, cbchange, cbsort, cbnoresults) {
        $("#"+this.selector).html('<option></option>');

        if (dsConsulta && dsConsulta.values && dsConsulta.values.length > 0) {
            if(cbsort)
                dsConsulta.values.sort(function (a, b) {
                    return cbsort(a, b);
                });

            _.each(dsConsulta.values, function (obj, key, list) {
                cbrow(obj);
            })
        }else{
            if(cbnoresults)
                cbnoresults();
        }

        $("#"+this.selector).unbind("change").on("change", function () {
            if(!restaurouDados)
                return;

            $("#"+$(this).attr("name")+"_VAL").val(this.value);
            if(cbchange)
                cbchange(this);
        });
    };
}

(function () {
    var TRP = function (arg) {}
})();

//PROTOTIPO PRINCIPAL
var TRP = function (arg) {
    if (!(this instanceof TRP)) {
        return new TRP(arg);
    }
    this.selector = arg;
    this.Select = new SelectPrototype(this.selector);
    this.AutoComplete = new AutocompletePrototype(this.selector);
    this.Table = new TablePrototype(this.selector);
    this.Format = new FormatPrototype(this.selector);
    this.DS = new DSPrototype(this.selector);
};

TRP.fn = TRP.prototype;

window.TRP = TRP;

Number.prototype.formatMoney = function (c, d, t) {
    var n = this;
    if(isNaN(parseFloat(n)))
        return "0";
    if(isNaN(n))
        n = parseFloat(n);
    n = Number(n).toFixed(c);
    var c = isNaN(c = Math.abs(c)) ? 2 : c,
        d = d == undefined ? "." : d,
        t = t == undefined ? "," : t,
        s = n < 0 ? "-" : "",
        i = String(parseInt(n = Math.abs(Number(n) || 0).toFixed(c))),
        j = (j = i.length) > 3 ? j % 3 : 0;
    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
};

Number.prototype.toFixedNoRounding = function(n) {
    var num = this;
    if(isNaN(parseFloat(num)))
        return "0";
    if(isNaN(num))
        num = parseFloat(num);
    const reg = new RegExp("^-?\\d+(?:\\.\\d{0," + n + "})?", "g")
    const a = num.toString().match(reg)[0];
    const dot = a.indexOf(".");
    if (dot === -1) { // integer, insert decimal dot and pad up zeros
        return a + "." + "0".repeat(n);
    }
    const b = n - (a.length - dot) + 1;
    return b > 0 ? (a + "0".repeat(b)) : a;
};

String.prototype.replaceAll = String.prototype.replaceAll || function (needle, replacement) {
    return this.split(needle).join(replacement);
};


$('[readonly]').attr('tabindex', '-1')

var keyDown = false,
    ctrl = 17,
    vKey = 86,
    Vkey = 118;

$(document).keydown(function (e) {
    if (e.keyCode == ctrl) keyDown = true;
}).keyup(function (e) {
    if (e.keyCode == ctrl) keyDown = false;
});

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


$('.create-form-components').on('keyup',
    'input[required="required"][type="text"], input[required="required"][type="number"], input[required="required"][type="date"], textarea[required="required"]',
    function () {
        validationFieldsForm($(this), $(this).parents('.form-field').data('type'));
    });

$('.create-form-components').on('change',
    'input[required="required"][type="checkbox"], input[required="required"][type="radio"], select[required="required"]',
    function () {
        validationFieldsForm($(this), $(this).parents('.form-field').data('type'));
    });

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

var $zoomPreview = $(".zoom-preview");
if ($zoomPreview.length) {
    $zoomPreview.parent().removeClass("input-group");
    $zoomPreview.remove();
}

var ratings = $(".rating");
if (ratings.length > 0) ratingStars(ratings);

function ratingStars(stars) {
    $.each(stars, function (i, obj) {
        var field = $(this).closest(".").find(".rating-value");
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

$.each($("[data-date]"), function (i, o) {
    var id = $(o).attr("id");
    FLUIGC.calendar("#" + id);
});

$(document).ready(function () {
    $.each($("[data-date]"), function (i, o) {
        var id = $(o).attr("id");
        if ($("#" + id).attr("readonly")) {
            $("#" + id).data('DateTimePicker').disable();
        }
    });
});

function consultaCEP(cep, callback, callbackerro) {

    cep = cep.replace(/\D/g, '');

    if (cep != "") {

        //Expressao regular para validar o CEP.
        var validacep = /^[0-9]{8}$/;

        //Valida o formato do CEP.
        if (validacep.test(cep)) {

            //Consulta o webservice viacep.com.br/
            $.getJSON("https://viacep.com.br/ws/" + cep + "/json/?callback=?", function(dados) {

                if (!("erro" in dados))
                    callback(dados);
                else
                    callbackerro('CEP nao encontrado na base de dados do correios!');
            }).error(function() {
                callbackerro('Nao foi possivel consultar o CEP no correios!');
            });
        }
    }
}

function buscaCep(_cep, _rua, _bairro, _cidade, _uf, callback, callbackerro) {

    var cep = $('#' + _cep).val().replace(/\D/g, '');

    if (cep != "") {

        //Expressao regular para validar o CEP.
        var validacep = /^[0-9]{8}$/;

        //Valida o formato do CEP.
        if (validacep.test(cep)) {

            //Consulta o webservice viacep.com.br/
            $.getJSON("https://viacep.com.br/ws/" + cep + "/json/?callback=?", function(dados) {

                if (!("erro" in dados)) {

                    //Atualiza os campos com os valores da consulta.
                    if(dados.logradouro != "")
                        $("#" + _rua).val(dados.logradouro);
                    if(dados.bairro != "")
                        $("#" + _bairro).val(dados.bairro);
                    if(dados.localidade != "")
                        $("#" + _cidade).val(dados.localidade);
                    if(dados.uf != "")
                        $("#" + _uf).val(dados.uf);

                    callback(dados.ibge);
                } //end if.
                else {
                    if(callbackerro)
                        callbackerro('CEP nao encontrado na base de dados do correios!');
                    else {
                        //CEP pesquisado nao foi encontrado.
                        FLUIGC.toast({
                            message: 'CEP nao encontrado na base de dados do correios!',
                            type: 'warning',
                            timeout: 'slow'
                        });
                    }
                }
            })
                .error(function() {
                    if(callbackerro)
                        callbackerro('Nao foi possivel consultar o CEP no correios!');
                    else {
                        //CEP pesquisado nao foi encontrado.
                        FLUIGC.toast({
                            message: 'Nao foi possivel consultar o CEP no correios!',
                            type: 'warning',
                            timeout: 'slow'
                        });
                    }
                });
        }
    }
}

TRP.restauraEstadoPaiFilho = function(row) {
    $(".fw-table-tr").each(function (index) {
        if (index != 0) {
            $("input, select, texarea", this).each(function () {

                if ($(this).hasClass("span")) {
                    var fieldName = $(this).attr("name");
                    if (fieldName && fieldName.lastIndexOf('___') > 0) {
                        var criaSpan = false;
                        if (row) {
                            if (row == fieldName.split("___")[1]) {
                                criaSpan = true;
                            }
                        } else {
                            criaSpan = true;
                        }

                        if (criaSpan) {
                            var classqtd = $(this).hasClass("qtd")
                            var classdinheiro = $(this).hasClass("dinheiro")

                            $(this).after("<span class='" + (classqtd ? "qtd" : "") + (classdinheiro ? "dinheiro" : "") + "' style='display: block'>" + this.value + "</span>");
                        }
                    }
                }
            });
        }
    });
}
