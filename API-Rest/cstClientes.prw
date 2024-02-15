#include "totvs.ch"
#include "restFul.ch"

/*
Programa.: cstClientes.prw
Tipo.....: API Rest 
Autor....: Odair Batista - TOTVS OESTE (Unidade Londrina)
Data.....: 03/07/2023
Descrição: API para consulta de clientes 
Notas....: 
*/


/*/{Protheus.doc} cstClientes 
Serviço para chamada externa
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 03/07/2023
@version 1.0
@type service
/*/
WsRestFul cstClientes description "API para consulta de clientes" Format Application_JSon 
    WsData Empresa as string
    WsData Filial  as string
	WsData Codigo  as string
	WsData Loja    as string
	WsData CGC     as string

	WsMethod GET description "Método para consulta" WsSyntax "/cstClientes/{Empresa, Filial, Codigo, Loja, CGC}"
End WsRestFul 


/*/{Protheus.doc} GET
Método para processamento da consulta
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 03/07/2023
@version 1.0
@type method
@param Empresa, string, código da empresa
@parma Filial , string, código da filial
@param Codigo , string, código do cliente
@param Loja   , string, loja do cliente
@param CGC    , string, CPF/CNPJ do cliente
/*/
WsMethod GET WSReceive Empresa, Filial, Codigo, Loja, CGC WsService cstClientes   
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

	Self:Codigo := allTrim(Self:Codigo)
	Self:Loja   := allTrim(Self:Loja)
	Self:CGC    := allTrim(Self:CGC)

	rpcSetType(3)			                //Informa que não haverá consumo de licenças
	rpcSetEnv(Self:Empresa, Self:Filial)	//Prepara ambiente para empresa 01 e filial 01

    oUtils  := pfwUtils():New()
	oAlerts := pfwAlerts():New()
	oAlerts:Empty()

    cWhere := "%"
    if empty(Self:Codigo)
        cWhere += "SA1.A1_COD = SA1.A1_COD "
    else
        cWhere += "LTRIM(RTRIM(SA1.A1_COD)) = '" + Self:Codigo + "' "
    endIf
    if empty(Self:Loja)
        cWhere += "AND SA1.A1_LOJA = SA1.A1_LOJA "
    else
        cWhere += "AND LTRIM(RTRIM(SA1.A1_LOJA)) = '" + Self:Loja + "' "
    endIf
    if empty(Self:CGC)
        cWhere += "AND SA1.A1_CGC = SA1.A1_CGC "
    else
        cWhere += "AND LTRIM(RTRIM(SA1.A1_CGC)) = '" + Self:CGC + "' "
    endIf
    cWhere += "%"

    if select("qSA1") > 0
        qSA1->(dbCloseArea())
    endIf

    beginSql alias "qSA1"
        SELECT SA1.A1_FILIAL, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_CGC, SA1.A1_PESSOA, SA1.A1_NOME, SA1.A1_NREDUZ, SA1.A1_CEP
            , SA1.A1_END, SA1.A1_BAIRRO, SA1.A1_EST, SA1.A1_MUN, SA1.A1_PAIS, SA1.A1_DDI, SA1.A1_DDD, SA1.A1_TEL
            , SA1.A1_CONTATO, SA1.A1_INSCR, SA1.A1_INSCRM, SA1.A1_EMAIL, SA1.A1_BLEMAIL, SA1.A1_HPAGE, SA1.A1_DTCAD
            , SA1.A1_METR, SA1.A1_MSBLQL
        FROM %table:SA1% SA1
        WHERE SA1.%notDel%
          AND SA1.A1_FILIAL = %xFilial:SA1%
          AND %exp:cWhere%
        ORDER BY SA1.A1_COD, SA1.A1_LOJA
    endSql

    dbSelectArea("qSA1")
    qSA1->(dbGoTop())

    if qSA1->(eof())
        oAlerts:Add('cstClientes:Get' ;
                    , 'Registros não encontrados!' ;
                    , 'E' ;
                    , 'Não foram encontrados dados para a consulta.')
    else
        oJSon := pfwJSon():New(.f., .f., .t.)
        oJSon:AddNode()
        oJSon:AddNodeData('clientes')

        do while !qSA1->(eof())
            oJSon:AddNode()
            oJSon:AddField("empresa"            , Self:Empresa)
            oJSon:AddField("filial"             , qSA1->A1_FILIAL)
            oJSon:AddField("codigo"             , qSA1->A1_COD)
            oJSon:AddField("loja"               , qSA1->A1_LOJA)
            oJSon:AddField("cgc"                , qSA1->A1_CGC)
            oJSon:AddField("pessoa"             , qSA1->A1_PESSOA)
            oJSon:AddField("ome"                , qSA1->A1_NOME)
            oJSon:AddField("nomeReduzido"       , qSA1->A1_NREDUZ)
            oJSon:AddField("cep"                , qSA1->A1_CEP)
            oJSon:AddField("endereco"           , qSA1->A1_END)
            oJSon:AddField("bairro"             , qSA1->A1_BAIRRO)
            oJSon:AddField("estado"             , qSA1->A1_EST)
            oJSon:AddField("cidade"             , qSA1->A1_MUN)
            oJSon:AddField("pais"               , qSA1->A1_PAIS)
            oJSon:AddField("ddi"                , qSA1->A1_DDI)
            oJSon:AddField("ddd"                , qSA1->A1_DDD)
            oJSon:AddField("telefone"           , qSA1->A1_TEL)
            oJSon:AddField("contato"            , qSA1->A1_CONTATO)
            oJSon:AddField("inscricaoEstadual"  , qSA1->A1_INSCR)
            oJSon:AddField("inscricaoMunicipal" , qSA1->A1_INSCRM)
            oJSon:AddField("email"              , qSA1->A1_EMAIL)
            oJSon:AddField("emailBoleto"        , qSA1->A1_BLEMAIL)
            oJSon:AddField("homePage"           , qSA1->A1_HPAGE)
            oJSon:AddField("diasComoCliente"    , ((dDatabase - sToD(qSA1->A1_DTCAD)) + 1))
            oJSon:AddField("diasEmAtraso"       , qSA1->A1_METR)
            oJSon:AddField("bloqueado"          , qSA1->A1_MSBLQL)
            oJSon:EndNode()

            qSA1->(dbSkip())
        endDo

        oJSon:EndNodeData()
        oJSon:EndNode()

        cJSon := oJSon:GetJSon()
        oJSon:Destroy()
    endIf

    if select('qSA1') > 0
        qSA1->(dbCloseArea())
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
