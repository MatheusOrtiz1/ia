#include "totvs.ch"
#include "restFul.ch"

/*
Programa.: cstFornecedores.prw
Tipo.....: API Rest 
Autor....: Odair Batista - TOTVS OESTE (Unidade Londrina)
Data.....: 03/07/2023
Descrição: API para consulta de fornecedores 
Notas....: 
*/


/*/{Protheus.doc} cstFornecedores 
Serviço para chamada externa
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 03/07/2023
@version 1.0
@type service
/*/
WsRestFul cstFornecedores description "API para consulta de fornecedores" Format Application_JSon 
    WsData Empresa as string
    WsData Filial  as string
	WsData Codigo  as string
	WsData Loja    as string
	WsData CGC     as string

	WsMethod GET description "Método para consulta" WsSyntax "/cstFornecedores/{Empresa, Filial, Codigo, Loja, CGC}"
End WsRestFul 


/*/{Protheus.doc} GET
Método para processamento da consulta
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 03/07/2023
@version 1.0
@type method
@param Empresa, string, código da empresa
@parma Filial , string, código da filial
@param Codigo , string, código do fornecedor
@param Loja   , string, loja do fornecedor
@param CGC    , string, CPF/CNPJ do fornecedor
/*/
WsMethod GET WSReceive Empresa, Filial, Codigo, Loja, CGC WsService cstFornecedores   
    local oAlerts := nil
 	local aAlerts := {}
	local cJSon   := ""
    local oJSon   := nil
    local oUtils  := nil
    local nRow    := 0
    local cWhere  := ""

	default Self:Empresa := "01"
	default Self:Filial  := "01"
	default Self:Codigo  := ""
	default Self:Loja    := ""
	default Self:CGC     := ""

	rpcSetType(3)			                //Informa que não haverá consumo de licenças
	rpcSetEnv(Self:Empresa, Self:Filial)	//Prepara ambiente para empresa 01 e filial 01

	Self:Codigo := allTrim(Self:Codigo)
	Self:Loja   := allTrim(Self:Loja)
	Self:CGC    := allTrim(Self:CGC)

    oUtils  := pfwUtils():New()
	oAlerts := pfwAlerts():New()
	oAlerts:Empty()

    cWhere := "%"
    if empty(Self:Codigo)
        cWhere += "SA2.A2_COD = SA2.A2_COD "
    else
        cWhere += "LTRIM(RTRIM(SA2.A2_COD)) = '" + Self:Codigo + "' "
    endIf
    if empty(Self:Loja)
        cWhere += "AND SA2.A2_LOJA = SA2.A2_LOJA "
    else
        cWhere += "AND LTRIM(RTRIM(SA2.A2_LOJA)) = '" + Self:Loja + "' "
    endIf
    if empty(Self:CGC)
        cWhere += "AND SA2.A2_CGC = SA2.A2_CGC "
    else
        cWhere += "AND LTRIM(RTRIM(SA2.A2_CGC)) = '" + Self:CGC + "' "
    endIf
    cWhere += "%"

    if select("qSA2") > 0
        qSA2->(dbCloseArea())
    endIf

    beginSql alias "qSA2"
        SELECT SA2.A2_FILIAL, SA2.A2_COD, SA2.A2_LOJA, SA2.A2_CGC, SA2.A2_TPESSOA, SA2.A2_NOME, SA2.A2_NREDUZ, SA2.A2_CEP
            , SA2.A2_END, SA2.A2_NR_END, SA2.A2_BAIRRO, SA2.A2_EST, SA2.A2_MUN, SA2.A2_PAIS, SA2.A2_DDI, SA2.A2_DDD
            , SA2.A2_TEL, SA2.A2_CONTATO, SA2.A2_INSCR, SA2.A2_INSCRM, SA2.A2_EMAIL, SA2.A2_HPAGE, SA2.A2_MSBLQL
        FROM %table:SA2% SA2
        WHERE SA2.%notDel%
          AND SA2.A2_FILIAL = %xFilial:SA2%
          AND %exp:cWhere%
        ORDER BY SA2.A2_COD, SA2.A2_LOJA
    endSql

    dbSelectArea("qSA2")
    qSA2->(dbGoTop())

    if qSA2->(eof())
        oAlerts:Add('cstFornecedores:Get' ;
                    , 'Registros não encontrados!' ;
                    , 'E' ;
                    , 'Não foram encontrados dados para a consulta.')
    else
        oJSon := pfwJSon():New(.f., .f., .t.)
        oJSon:AddNode()
        oJSon:AddNodeData('fornecedores')

        do while !qSA2->(eof())
            oJSon:AddNode()
            oJSon:AddField("empresa"            , Self:Empresa)
            oJSon:AddField("filial"             , qSA2->A2_FILIAL)
            oJSon:AddField("codigo"             , qSA2->A2_COD)
            oJSon:AddField("loja"               , qSA2->A2_LOJA)
            oJSon:AddField("cgc"                , qSA2->A2_CGC)
            oJSon:AddField("pessoa"             , qSA2->A2_TPESSOA)
            oJSon:AddField("nome"               , qSA2->A2_NOME)
            oJSon:AddField("nomeReduzido"       , qSA2->A2_NREDUZ)
            oJSon:AddField("cep"                , qSA2->A2_CEP)
            oJSon:AddField("endereco"           , qSA2->A2_END)
            oJSon:AddField("bairro"             , qSA2->A2_BAIRRO)
            oJSon:AddField("estado"             , qSA2->A2_EST)
            oJSon:AddField("cidade"             , qSA2->A2_MUN)
            oJSon:AddField("pais"               , qSA2->A2_PAIS)
            oJSon:AddField("ddi"                , qSA2->A2_DDI)
            oJSon:AddField("ddd"                , qSA2->A2_DDD)
            oJSon:AddField("telefone"           , qSA2->A2_TEL)
            oJSon:AddField("contato"            , qSA2->A2_CONTATO)
            oJSon:AddField("inscricaoEstadual"  , qSA2->A2_INSCR)
            oJSon:AddField("inscricaoMunicipal" , qSA2->A2_INSCRM)
            oJSon:AddField("email"              , qSA2->A2_EMAIL)
            oJSon:AddField("homePage"           , qSA2->A2_HPAGE)
            oJSon:AddField("bloqueado"          , qSA2->A2_MSBLQL)
            oJSon:EndNode()

            qSA2->(dbSkip())
        endDo

        oJSon:EndNodeData()
        oJSon:EndNode()

        cJSon := oJSon:GetJSon()
        oJSon:Destroy()
    endIf

    if select('qSA2') > 0
        qSA2->(dbCloseArea())
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
