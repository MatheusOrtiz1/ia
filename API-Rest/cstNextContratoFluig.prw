#include "totvs.ch"
#include "restFul.ch"

/*
Programa.: cstNextContratoFluig.prw
Tipo.....: API Rest 
Autor....: Odair Batista - TOTVS OESTE (Unidade Londrina)
Data.....: 15/08/2023
Descrição: API para consulta de novo número de contrato/revisão no Protheus 
Notas....: 
*/


/*/{Protheus.doc} cstNextContratoFluig 
Serviço para chamada externa
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 15/08/2023
@version 1.0
@type service
/*/
WsRestFul cstNextContratoFluig description "API para consulta de novo número de contrato/revisão no Protheus" Format Application_JSon 
    WsData Empresa as string
    WsData Filial  as string
	WsData Numero  as string

	WsMethod GET description "Método para consulta" WsSyntax "/cstNextContratoFluig/{Empresa, Filial, Numero}"
End WsRestFul 


/*/{Protheus.doc} GET
Método para processamento da consulta
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 15/08/2023
@version 1.0
@type method
@param Empresa, string, código da empresa
@param Filial , string, código da filial 
@param Numero , string, numero do contrato. Preenchido apenas quando necessita da próxima revisão do contrato e não o contrato propriamente dito
/*/
WsMethod GET WSReceive Empresa, Filial, Numero WsService cstNextContratoFluig   
    local oAlerts  := nil
 	local aAlerts  := {}
	local cJSon    := ""
    local oJSon    := nil
    local oUtils   := nil
    local nRow     := 0
    local xContent := nil
    local cZAL     := ""
    local cNumero  := ""

	default Self:Empresa := "01"
	default Self:Filial  := "01"

	rpcSetType(3)			                //Informa que não haverá consumo de licenças
	rpcSetEnv(Self:Empresa, Self:Filial)	//Prepara ambiente para empresa 01 e filial 01

    oUtils  := pfwUtils():New()
	oAlerts := pfwAlerts():New()
	oAlerts:Empty()

    if Self:Numero == nil
        xContent := getSxeNum("ZAL", "ZAL_NUMERO")
        confirmSx8()
    else 
        cZAL    := getNextAlias()
        cNumero := Self:Numero

        if select(cZAL) > 0
            (cZAL)->(dbCloseArea())
        endIf 

        beginSql alias cZAL 
            SELECT ZAL.ZAL_REVISA
            FROM %table:ZAL% ZAL
            WHERE ZAL.%notDel%
              AND ZAL.ZAL_FILIAL = %xFilial:ZAL%
              AND ZAL.ZAL_NUMERO = %exp:cNumero%
            ORDER BY ZAL.ZAL_REVISA DESC  
        endSql 

        dbSelectArea(cZAL)
        (cZAL)->(dbGoTop())
        if (cZAL)->(eof())
            xContent := "001"
        else 
            xContent := strZero((val((cZAL)->ZAL_REVISA) + 1), 3)
        endIf 

        (cZAL)->(dbCloseArea())
    endIf 

    oJSon := pfwJSon():New(.f., .f., .t.,,, .t.)
    oJSon:AddNode()
    oJSon:AddField("empresa", Self:Empresa)
    oJSon:AddField("filial" , Self:Filial)
    oJSon:AddField("numero" , if(Self:Numero == nil, xContent, Self:Numero))
    oJSon:AddField("revisao", if(Self:Numero != nil, xContent, "   "))

    if valType(xContent) == "D"
        oJSon:AddField("valor", dToS(xContent))
    elseIf valType(xContent) == "L"
        oJSon:AddField("valor", if(xContent, "true", "false"))
    elseIf valType(xContent) == "N"
        oJSon:AddField("valor", val(strTran(cValToChar(xContent), ",", ".")))
    else
        oJSon:AddField("valor", xContent)
    endIf

    oJSon:EndNode()

    cJSon := oJSon:GetJSon()
    oJSon:Destroy()

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
