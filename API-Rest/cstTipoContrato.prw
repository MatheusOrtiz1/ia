#include "totvs.ch"
#include "restFul.ch"

/*
Programa.: cstTipoContrato.prw
Tipo.....: API Rest 
Autor....: Odair Batista - TOTVS OESTE (Unidade Londrina)
Data.....: 24/07/2023
Descrição: API para consulta de tipo de contrato 
Notas....: 
*/


/*/{Protheus.doc} cstTipoContrato 
Serviço para chamada externa
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 24/07/2023
@version 1.0
@type service
/*/
WsRestFul cstTipoContrato description "API para consulta de tipo de contrato" Format Application_JSon 
    WsData Empresa as string
    WsData Filial  as string
	WsData Codigo  as string

	WsMethod GET description "Método para consulta" WsSyntax "/cstTipoContrato/{Empresa, Filial, Codigo}"
End WsRestFul 


/*/{Protheus.doc} GET
Método para processamento da consulta
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 24/07/2023
@version 1.0
@type method
@param Empresa, string, código da empresa
@parma Filial , string, código da filial
@param Codigo , string, código do tipo de contrato
/*/
WsMethod GET WSReceive Empresa, Filial, Codigo WsService cstTipoContrato   
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

	rpcSetType(3)			                //Informa que não haverá consumo de licenças
	rpcSetEnv(Self:Empresa, Self:Filial)	//Prepara ambiente para empresa 01 e filial 01

    dbSelectArea("CN1")

	Self:Codigo := padR(allTrim(Self:Codigo), len(CN1->CN1_CODIGO), " ")

    oUtils  := pfwUtils():New()
	oAlerts := pfwAlerts():New()
	oAlerts:Empty()

    cWhere := "%"
    if empty(Self:Codigo)
        cWhere += "CN1.CN1_CODIGO = CN1.CN1_CODIGO "
    else
        cWhere += "CN1.CN1_CODIGO = '" + Self:Codigo + "' "
    endIf
    cWhere += "%"

    if select("qCN1") > 0
        qCN1->(dbCloseArea())
    endIf

    beginSql alias "qCN1"
        SELECT CN1.CN1_FILIAL, CN1.CN1_CODIGO, CN1.CN1_DESCRI
        FROM %table:CN1% CN1
        WHERE CN1.%notDel%
          AND CN1.CN1_FILIAL = %xFilial:CN1%
          AND %exp:cWhere%
        ORDER BY CN1.CN1_FILIAL, CN1.CN1_CODIGO
    endSql

    dbSelectArea("qCN1")
    qCN1->(dbGoTop())

    if qCN1->(eof())
        oAlerts:Add('cstTipoContrato:Get' ;
                    , 'Registros não encontrados!' ;
                    , 'E' ;
                    , 'Não foram encontrados dados para a consulta.')
    else
        oJSon := pfwJSon():New(.f., .f., .t.)
        oJSon:AddNode()
        oJSon:AddNodeData('tipoDeContrato')

        do while !qCN1->(eof())
            oJSon:AddNode()
            oJSon:AddField("empresa"  , Self:Empresa)
            oJSon:AddField("filial"   , qCN1->CN1_FILIAL)
            oJSon:AddField("codigo"   , qCN1->CN1_CODIGO)
            oJSon:AddField("descricao", qCN1->CN1_DESCRI)
            oJSon:EndNode()

            qCN1->(dbSkip())
        endDo

        oJSon:EndNodeData()
        oJSon:EndNode()

        cJSon := oJSon:GetJSon()
        oJSon:Destroy()
    endIf

    if select('qCN1') > 0
        qCN1->(dbCloseArea())
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
