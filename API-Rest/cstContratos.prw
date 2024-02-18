#include "totvs.ch"
#include "restFul.ch"

/*
Programa.: cstContratos.prw
Tipo.....: API Rest 
Autor....: Odair Batista - TOTVS OESTE (Unidade Londrina)
Data.....: 13/10/2023
Descrição: API para integração com contratos
Notas....: 
*/


/*/{Protheus.doc} cstContratos 
Serviço para chamada externa
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 13/10/2023
@version 1.0
@type service
/*/
WsRestFul cstContratos description "API para integração com contratos" Format Application_JSon 
    WsData Empresa       as string
    WsData Filial        as string
    WsData NumeroDe      as string
    WsData NumeroAte     as string
    WsData FornecedorDe  as string
    WsData FornecedorAte as string
    WsData LojaDe        as string
    WsData LojaAte       as string
    WsData DataInicioDe  as string
    WsData DataInicioAte as string
    WsData RevisaoDe     as string
    WsData RevisaoAte    as string

	WsMethod GET description "Método para consulta" WsSyntax "/cstContratos/{Empresa, Filial, NumeroDe, NumeroAte, FornecedorDe, FornecedorAte, LojaDe, LojaAte, DataInicioDe, DataInicioAte, RevisaoDe, RevisaoAte}"
End WsRestFul 


/*/{Protheus.doc} GET
Método para processamento da consulta
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 13/10/2023
@version 1.0
@type method
@param Empresa      , string, código da empresa
@param Filial       , string, código da filial
@param NumeroDe     , string, número inicial do contrato 
@param NumeroAte    , string, número final do contrato
@param FornecedorDe , string, fornecedor inicial do contrato
@param FornecedorAte, string, fornecedor final do contrato
@param LojaDe       , string, loja inicial do fornecedor do contrato
@param LojaAte      , string, loja final do fornecedor do contrato
@param DataInicioDe , string, data de inicio inicial do contrato (AAAAMMDD)
@param DataInicioAte, string, data de inicio final do contrato (AAAAMMDD)
@param RevisaoDe    , string, revisão inicial do contrato
@param RevisaoAte   , string, revisão final do contrato
/*/
WsMethod GET WSReceive Empresa, Filial, NumeroDe, NumeroAte, FornecedorDe, FornecedorAte, LojaDe, LojaAte, DataInicioDe, DataInicioAte, RevisaoDe, RevisaoAte WsService cstContratos
    local oAlerts   := nil
 	local aAlerts   := {}
	local cJSon     := ""
    local oJSon     := nil
    local oUtils    := nil
    local nRow      := 0
    local cWhereCN9 := ""
    local cWhereCNC := ""
    local cCN9      := getNextAlias()
    local cCNC      := getNextAlias()
    local cCXN      := getNextAlias()
    local cAC9      := getNextAlias()
    local aSituacao := {}
    local cSituacao := ""
    local cDoctoId  := ""

	default Self:Empresa := "01"
	default Self:Filial  := "01"

	rpcSetType(3)			                //Informa que não haverá consumo de licenças
	rpcSetEnv(Self:Empresa, Self:Filial)	//Prepara ambiente para empresa 01 e filial 01

	aAdd(aSituacao, {"01", "Cancelado"})
	aAdd(aSituacao, {"02", "Em Elaboração"})
	aAdd(aSituacao, {"03", "Emitido"})
	aAdd(aSituacao, {"04", "Em Aprovação"})
	aAdd(aSituacao, {"05", "Vigente"})
	aAdd(aSituacao, {"06", "Paralisado"})
	aAdd(aSituacao, {"07", "Solicitado Finalização"})
	aAdd(aSituacao, {"08", "Finalizado"})
	aAdd(aSituacao, {"09", "Em Revisão"})
	aAdd(aSituacao, {"10", "Revisado"})
	aAdd(aSituacao, {"A ", "Revisão Aprovação p/ Alçadas"}) 

    oUtils  := pfwUtils():New()
	oAlerts := pfwAlerts():New()
	oAlerts:Empty()

    //INICIO: preparação de filtro do contrato
    cWhereCN9 := "%"
    
    if Self:NumeroDe != nil
        cWhereCN9 += if(cWhereCN9 == "%", "", "AND ")
        cWhereCN9 += "LTRIM(RTRIM(CN9.CN9_NUMERO)) >= '" + Self:NumeroDe + "' "
    endIf 

    if Self:NumeroAte != nil
        cWhereCN9 += if(cWhereCN9 == "%", "", "AND ")
        cWhereCN9 += "LTRIM(RTRIM(CN9.CN9_NUMERO)) <= '" + Self:NumeroAte + "' "
    endIf

    if Self:DataInicioDe != nil
        cWhereCN9 += if(cWhereCN9 == "%", "", "AND ")
        cWhereCN9 += "CN9.CN9_DTINIC >= '" + Self:DataInicioDe + "' "
    endIf 

    if Self:DataInicioAte != nil
        cWhereCN9 += if(cWhereCN9 == "%", "", "AND ")
        cWhereCN9 += "CN9.CN9_DTINIC <= '" + Self:DataInicioAte + "' "
    endIf 

    if Self:RevisaoDe != nil
        cWhereCN9 += if(cWhereCN9 == "%", "", "AND ")
        cWhereCN9 += "LTRIM(RTRIM(CN9.CN9_REVISA)) >= '" + Self:RevisaoDe + "' "
    endIf 

    if Self:RevisaoAte != nil
        cWhereCN9 += if(cWhereCN9 == "%", "", "AND ")
        cWhereCN9 += "LTRIM(RTRIM(CN9.CN9_REVISA)) <= '" + Self:RevisaoAte + "' "
    endIf 

    if cWhereCN9 == "%"
        cWhereCN9 += " CN9.CN9_NUMERO = CN9.CN9_NUMERO "
    endIf

    cWhereCN9 += "%"
    //FIM: preparação de filtro do contrato

    //INICIO: preparação de filtro dos fornecedores do contrato
    cWhereCNC := "%"

    if Self:FornecedorDe != nil
        cWhereCNC += if(cWhereCNC == "%", "", "AND ")
        cWhereCNC += "LTRIM(RTRIM(CNC.CNC_CODIGO)) >= '" + Self:FornecedorDe + "' "
    endIf 

    if Self:FornecedorAte != nil
        cWhereCNC += if(cWhereCNC == "%", "", "AND ")
        cWhereCNC += "LTRIM(RTRIM(CNC.CNC_CODIGO)) <= '" + Self:FornecedorAte + "' "
    endIf 

    if Self:LojaDe != nil
        cWhereCNC += if(cWhereCNC == "%", "", "AND ")
        cWhereCNC += "LTRIM(RTRIM(CNC.CNC_LOJA)) >= '" + Self:LojaDe + "' "
    endIf 

    if Self:LojaAte != nil
        cWhereCNC += if(cWhereCNC == "%", "", "AND ")
        cWhereCNC += "LTRIM(RTRIM(CNC.CNC_LOJA)) <= '" + Self:LojaAte + "' "
    endIf 

    if cWhereCNC == "%"
        cWhereCNC += " CNC.CNC_NUMERO = CNC.CNC_NUMERO "
    endIf

    cWhereCNC += "%"
    //FIM: preparação de filtro dos fornecedores do contrato

    if select(cCN9) > 0
        (cCN9)->(dbCloseArea())
    endIf

    beginSql alias cCN9
        SELECT CN9.*
            , CN1.CN1_DESCRI
        FROM %table:CN9% CN9
        INNER JOIN %table:CN1% CN1
           ON CN1.%notDel%
          AND CN1.CN1_FILIAL = %xFilial:CN1%
          AND CN1.CN1_CODIGO = CN9.CN9_TPCTO
        INNER JOIN %table:CNC% CNC
           ON CNC.%notDel%
          AND CNC.CNC_FILIAL = %xFilial:CNC%
          AND CNC.CNC_NUMERO = CN9.CN9_NUMERO
          AND CNC.CNC_REVISA = CN9.CN9_REVISA
          AND %exp:cWhereCNC%
        WHERE CN9.%notDel%
          AND CN9.CN9_FILIAL = %xFilial:CN9%
          AND %exp:cWhereCN9%
        ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA
    endSql

    dbSelectArea(cCN9)
    (cCN9)->(dbGoTop())

    if (cCN9)->(eof())
        oAlerts:Add('cstContratos:Get' ;
                    , 'Registros não encontrados!' ;
                    , 'E' ;
                    , 'Não foram encontrados dados para a consulta.')
    else
        oJSon := pfwJSon():New(.f., .f., .t.,,, .t.)
        oJSon:AddNode()
        oJSon:AddArray('contratos')

        cSituacao := ""
        nRow      := aScan(aSituacao, {|x| allTrim(x[1]) == allTrim((cCN9)->CN9_SITUAC)})
        if nRow > 0
            cSituacao := aSituacao[nRow, 2]
        endIf

        do while !(cCN9)->(eof())
            oJSon:AddNode()
            oJSon:AddField("empresa"                   , Self:Empresa)
            oJSon:AddField("filial"                    , (cCN9)->CN9_FILIAL)
            oJSon:AddField("tipoContrato"              , (cCN9)->CN9_TPCTO)
            oJSon:AddField("descricaoTipoContrato"     , (cCN9)->CN1_DESCRI) 
            oJSon:AddField("numero"                    , (cCN9)->CN9_NUMERO)
            oJSon:AddField("revisao"                   , (cCN9)->CN9_REVISA)
            oJSon:AddField("tipoRevisao"               , (cCN9)->CN9_TIPREV)
            oJSon:AddField("descricaoTipoRevisao"      , U_CNT6001A((cCN9)->CN9_TIPREV))
            oJSon:AddField("descricaoContrato"         , (cCN9)->CN9_DESCRI)
            oJSon:AddField("dataInicio"                , (cCN9)->CN9_DTINIC)
            oJSon:AddField("dataFinal"                 , (cCN9)->CN9_DTFIM) 
            oJSon:AddField("prazo"                     , ((sToD((cCN9)->CN9_DTFIM) - sToD((cCN9)->CN9_DTINIC)) + 1))
            oJSon:AddField("diasParaAviso"             , superGetMv("MV_UDIAAVI", .f., 10))
            oJSon:AddField("dataSituacaoVigencia"      , (cCN9)->CN9_DTASSI)
            oJSon:AddField("unidadeVigencia"           , (cCN9)->CN9_UNVIGE)
            oJSon:AddField("vigencia"                  , (cCN9)->CN9_VIGE)
            oJSon:AddField("dataAssinatura"            , (cCN9)->CN9_ASSINA)
            oJSon:AddField("Cliente"                   , (cCN9)->CN9_CLIENT)
            oJSon:AddField("lojaCliente"               , (cCN9)->CN9_LOJACL)
            oJSon:AddField("moeda"                     , (cCN9)->CN9_MOEDA)
            oJSon:AddField("condicaoPagamento"         , (cCN9)->CN9_CONDPG)
            oJSon:AddField("descricaoCondicaoPagamento", posicione("SE4", 1, xFilial("SE4") + (cCN9)->CN9_CONDPG, "E4_DESCRI"))
            oJSon:AddField("objeto"                    , msMm(CN9->CN9_CODOBJ))
            oJSon:AddField("valorInicial"              , (cCN9)->CN9_VLINI)
            oJSon:AddField("valorAtual"                , (cCN9)->CN9_VLATU)
            oJSon:AddField("reajuste"                  , (cCN9)->CN9_FLGREJ)
            oJSon:AddField("valorPresente"             , (cCN9)->CN9_VLPRES)
            oJSon:AddField("valorJuros"                , (cCN9)->CN9_VJUROS)
            oJSon:AddField("indiceCorrecao"            , (cCN9)->CN9_INDICE)
            oJSon:AddField("descricaoIndiceCorrecao"   , posicione("CN6", 1, xFilial("CN6") + (cCN9)->CN9_INDICE, "CN6_DESCRI"))
            oJSon:AddField("controlaCaucao"            , (cCN9)->CN9_FLGCAU)
            oJSon:AddField("tipoControleCaucao"        , (cCN9)->CN9_TPCAUC)
            oJSon:AddField("minimoCaucao"              , (cCN9)->CN9_MINCAU)
            oJSon:AddField("dataEncerramento"          , (cCN9)->CN9_DTENCE)
            oJSon:AddField("revisaoAtual"              , (cCN9)->CN9_REVATU)
            oJSon:AddField("saldo"                     , (cCN9)->CN9_SALDO)
            oJSon:AddField("motivoParalizacao"         , (cCN9)->CN9_MOTPAR)
            oJSon:AddField("dataInicioParalizacao"     , (cCN9)->CN9_DTINCP)
            oJSon:AddField("dataTerminoParalizacao"    , (cCN9)->CN9_DTFIMP)
            oJSon:AddField("dataReinicio"              , (cCN9)->CN9_DTREIN)
            oJSon:AddField("justificativa"             , msMm(CN9->CN9_CODJUS))
            oJSon:AddField("dataRevisao"               , (cCN9)->CN9_DTREV)
            oJSon:AddField("dataReajuste"              , (cCN9)->CN9_DTREAJ)
            oJSon:AddField("valorReajuste"             , (cCN9)->CN9_VLREAJ)
            oJSon:AddField("valorAditivo"              , (cCN9)->CN9_VLADIT)
            oJSon:AddField("tituloProvisorio"          , (cCN9)->CN9_NUMTIT)
            oJSon:AddField("alteracaoClausula"         ,  msMm((cCN9)->CN9_CODCLA))
            oJSon:AddField("valorMedicaoAcumulada"     , (cCN9)->CN9_VLMEAC)
            oJSon:AddField("taxaAdministracao"         , (cCN9)->CN9_TXADM)
            oJSon:AddField("formaContratacao"          , (cCN9)->CN9_FORMA)
            oJSon:AddField("dataNecessidade"           , (cCN9)->CN9_DTENTR)
            oJSon:AddField("descricaoFinanciamento"    , (cCN9)->CN9_DESFIN)
            oJSon:AddField("contratoFinanciamento"     , (cCN9)->CN9_CONTFI)
            oJSon:AddField("dataInicioProrrogacao"     , (cCN9)->CN9_DTINPR)
            oJSon:AddField("periodoProrrogacao"        , (cCN9)->CN9_PERPRO)
            oJSon:AddField("unidadeProrrogacao"        , (cCN9)->CN9_UNIPRO)
            oJSon:AddField("valorProrrogacao"          , (cCN9)->CN9_VLRPRO)
            oJSon:AddField("dataProposta"              , (cCN9)->CN9_DTPROP)
            oJSon:AddField("dataUltimoStatus"          , (cCN9)->CN9_DTULST)
            oJSon:AddField("situacao"                  , (cCN9)->CN9_SITUAC) 
            oJSon:AddField("descricaoSituacao"         , cSituacao) 
            oJSon:AddField("aliquotaISS"               , (cCN9)->CN9_ALCISS)
            oJSon:AddField("baseINSS"                  , (cCN9)->CN9_INSSMO)
            oJSon:AddField("baseMaterial"              , (cCN9)->CN9_INSSME)
            oJSon:AddField("validacaoContrato"         , (cCN9)->CN9_VLDCTR)
            oJSon:AddField("codigoProcessoLicitador"   , (cCN9)->CN9_CODED)
            oJSon:AddField("numeroProcessoLicitador"   , (cCN9)->CN9_NUMPR)
            oJSon:AddField("usuarioAvaliador"          , (cCN9)->CN9_USUAVA)
            oJSon:AddField("programacaoAvaliacao"      , (cCN9)->CN9_PROGRA)
            oJSon:AddField("dataUltimaAvaliacao"       , (cCN9)->CN9_ULTAVA)
            oJSon:AddField("dataProximaAvaliacao"      , (cCN9)->CN9_PROXAV)
            oJSon:AddField("dataVigenciaFutura"        , (cCN9)->CN9_DTVIGE)
            oJSon:AddField("grupoAprovacao"            , (cCN9)->CN9_APROV)
            oJSon:AddField("areaContrato"              , (cCN9)->CN9_DEPART)
            oJSon:AddField("descricaoAreaContrato"     , posicione("CXQ", 1, xFilial("CXQ") + (cCN9)->CN9_DEPART, "CXQ_DESCRI"))

            //INICIO: Obtem fornecedores
            if select(cCNC) > 0
                (cCNC)->(dbCloseArea())
            endIf

            beginSql alias cCNC 
                SELECT CNC.*
                    , SA2.A2_NOME, SA2.A2_CGC, SA2.A2_END, SA2.A2_CEP, SA2.A2_BAIRRO, SA2.A2_MUN, SA2.A2_EST
                FROM %table:CNC% CNC
                INNER JOIN %table:SA2% SA2
                   ON SA2.%notDel%
                  AND SA2.A2_FILIAL = %xFilial:SA2%
                  AND SA2.A2_COD    = CNC.CNC_CODIGO
                  AND SA2.A2_LOJA   = CNC.CNC_LOJA
                WHERE CNC.%notDel%
                  AND CNC.CNC_FILIAL = %exp:(cCN9)->CN9_FILIAL%
                  AND CNC.CNC_NUMERO = %exp:(cCN9)->CN9_NUMERO%
                  AND CNC.CNC_REVISA = %exp:(cCN9)->CN9_REVISA%
            endSql 

            dbSelectArea(cCNC)
            (cCNC)->(dbGoTop())

            if !(cCNC)->(eof())
                oJSon:AddArray('fornecedores')

                do while !(cCNC)->(eof())
                    oJSon:AddNode()
                    oJSon:AddField("fornecedor", (cCNC)->CNC_CODIGO) 
                    oJSon:AddField("loja"      , (cCNC)->CNC_LOJA)
                    oJSon:AddField("nome"      , (cCNC)->A2_NOME)
                    oJSon:AddField("cnpj"      , (cCNC)->A2_CGC)
                    oJSon:AddField("endereco"  , (cCNC)->A2_END)
                    oJSon:AddField("bairro"    , (cCNC)->A2_BAIRRO)
                    oJSon:AddField("cep"       , (cCNC)->A2_CEP)
                    oJSon:AddField("cidade"    , (cCNC)->A2_MUN)
                    oJSon:AddField("estado"    , (cCNC)->A2_EST)
                    oJSon:EndNode()

                    (cCNC)->(dbSkip())
                end 

                oJSon:EndArray()
            endIf 

            (cCNC)->(dbCloseArea())
            //FIM: Obtem fornecedores

            //INICIO: Obtem medições
            if select(cCXN) > 0
                (cCXN)->(dbCloseArea())
            endIf

            beginSql alias cCXN 
                SELECT CXN.*
                FROM %table:CXN% CXN
                WHERE CXN.%notDel%
                  AND CXN.CXN_FILIAL = %exp:(cCN9)->CN9_FILIAL%
                  AND CXN.CXN_CONTRA = %exp:(cCN9)->CN9_NUMERO%
                  AND CXN.CXN_REVISA = %exp:(cCN9)->CN9_REVISA%
            endSql 

            dbSelectArea(cCXN)
            (cCXN)->(dbGoTop())

            if !(cCXN)->(eof())
                oJSon:AddArray('medicoes')

                do while !(cCXN)->(eof())
                    oJSon:AddNode()
                    oJSon:AddField("numeroMedicao"         , (cCXN)->CXN_NUMMED)
                    oJSon:AddField("numeroPlanilha"        , (cCXN)->CXN_NUMPLA)
                    oJSon:AddField("tipoPlanilha"          , (cCXN)->CXN_TIPPLA)
                    oJSon:AddField("descricaoPlanilha"     , posicione("CNL", 1, xFilial("CNL") + (cCXN)->CXN_TIPPLA, "CNL_DESCRI"))
                    oJSon:AddField("numeroCronograma"      , (cCXN)->CXN_CRONOG)
                    oJSon:AddField("cronogramaContabil"    , (cCXN)->CXN_CRONCT)
                    oJSon:AddField("parcelaCronograma"     , (cCXN)->CXN_PARCEL)
                    oJSon:AddField("dataInicial"           , (cCXN)->CXN_DTINI)
                    oJSon:AddField("dataFinal"             , (cCXN)->CXN_DTFIM)
                    oJSon:AddField("fornecedor"            , (cCXN)->CXN_FORNEC)
                    oJSon:AddField("lojaFornecedor"        , (cCXN)->CXN_LJFORN)
                    oJSon:AddField("cliente"               , (cCXN)->CXN_CLIENT)
                    oJSon:AddField("lojaCliente"           , (cCXN)->CXN_LJCLI)
                    oJSon:AddField("dataMaxima"            , (cCXN)->CXN_DTMXMD)
                    oJSon:AddField("saldo"                 , (cCXN)->CXN_VLSALD)
                    oJSon:AddField("valorPrevisto"         , (cCXN)->CXN_VLPREV)
                    oJSon:AddField("valorLiquido"          , (cCXN)->CXN_VLLIQD)
                    oJSon:AddField("valorMulta"            , (cCXN)->CXN_VLMULT)
                    oJSon:AddField("valorBonificacao"      , (cCXN)->CXN_VLBONI)
                    oJSon:AddField("valorDesconto"         , (cCXN)->CXN_VLDESC)
                    oJSon:AddField("valorTotal"            , (cCXN)->CXN_VLTOT)
                    oJSon:AddField("valorComissao"         , (cCXN)->CXN_VLCOMS)
                    oJSon:AddField("valorReajuste"         , (cCXN)->CXN_VLREAJ)
                    oJSon:AddField("valorAdiantamento"     , (cCXN)->CXN_VLRADI)
                    oJSon:AddField("valorMultaPedido"      , (cCXN)->CXN_VLMPED)
                    oJSon:AddField("ValorBonificacaoPedido", (cCXN)->CXN_VLBPED)
                    oJSon:AddField("numeroTitulo"          , (cCXN)->CXN_NUMTIT)
                    oJSon:AddField("dataVencimento"        , (cCXN)->CXN_DTVENC)
                    oJSon:AddField("medicaoZerada"         , (cCXN)->CXN_ZERO)
                    oJSon:EndNode()

                    (cCXN)->(dbSkip())
                end 

                oJSon:EndArray()
            endIf 

            (cCXN)->(dbCloseArea())
            //FIM: Obtem medições

            //INICIO: Obtem documentos anexos
            if select(cAC9) > 0
                (cAC9)->(dbCloseArea())
            endIf

            beginSql alias cAC9 
                SELECT ACB.R_E_C_N_O_ AS ACB_RECNO
                FROM %table:AC9% AC9 
                INNER JOIN %table:ACB% ACB 
                   ON ACB.%notDel%
                  AND ACB.ACB_FILIAL = %xFilial:ACB%
                  AND ACB.ACB_CODOBJ = AC9.AC9_CODOBJ
                WHERE AC9.%notDel%
                  AND AC9.AC9_FILIAL = %xFilial:AC9%
                  AND AC9.AC9_ENTIDA = 'CN9'
                  AND AC9.AC9_CODENT = %exp:(cCN9)->CN9_NUMERO + (cCN9)->CN9_REVISA%
            endSql 

            dbSelectArea(cAC9)
            (cAC9)->(dbGoTop())
     
            if !(cAC9)->(eof())
                oJSon:AddArray('anexos')

                dbSelectArea("ACB")
                dbSelectArea("ZCB")
                ZCB->(dbSetOrder(1))    //ZCB_FILIAL+ZCB_CODOBJ

                do while !(cAC9)->(eof())
                    ACB->(dbGoTo((cAC9)->ACB_RECNO))
                    if !ACB->(eof())
                        cDoctoId := ""

                        if ZCB->(dbSeek(xFilial("ZCB") + ACB->ACB_CODOBJ))
                            cDoctoId := ZCB->ZCB_DOCFLG
                        endIf 

                        oJSon:AddNode()
                        oJSon:AddField("codigoObjeto"   , ACB->ACB_CODOBJ)
                        oJSon:AddField("objeto"         , ACB->ACB_OBJETO)
                        oJSon:AddField("descricao"      , ACB->ACB_DESCRI)
                        oJSon:AddField("tamanho"        , ft340Taman())
                        oJSon:AddField("fluigDocumentId", cDoctoId)
                        oJSon:EndNode()
                    endIf 

                    (cAC9)->(dbSkip())
                end 

                oJSon:EndArray()
            endIf 

            (cAC9)->(dbCloseArea())
            //FIM: Obtem documentos anexos

            oJSon:EndNode()

            (cCN9)->(dbSkip())
        endDo

        oJSon:EndArray()
        oJSon:EndNode()

        cJSon := oJSon:GetJSon()
        oJSon:Destroy()
    endIf

    if select(cCN9) > 0
        (cCN9)->(dbCloseArea())
    endIf

	if oAlerts:HasErrors()
		aAlerts := oAlerts:GetErrors()

        oJSon := pfwJSon():New(.f., .f., .t.)
        oJSon:AddNode()
        oJSon:AddNodeData('alerts')

        for nRow := 1 to len(aAlerts)
            aAlerts[nRow, 3] := upper(allTrim(aAlerts[nRow, 3]))

            oJSon:AddNode()
            oJSon:AddField("messageCode", aAlerts[nRow, 1])
            oJSon:AddField("messageText", aAlerts[nRow, 4])

            if aAlerts[nRow, 3] == 'E'
                oJSon:AddField("messageType", "error")
            elseIf aAlerts[nRow, 3] $ 'I|A'
                oJSon:AddField("messageType", "information")
            endIf 
            oJSon:EndNode()
        next nRow

        oJSon:EndNodeData()
        oJSon:EndNode()

        cJSon := oJSon:GetJSon()
        oJSon:Destroy()
	endIf       

    oUtils:Destroy()
    oAlerts:Destroy()

    rpcClearEnv() //volta a empresa anterior

    Self:SetContentType("application/json; charset=utf-8")
    Self:SetResponse(cJSon)
return(.t.)
