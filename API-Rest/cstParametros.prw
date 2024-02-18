#include "totvs.ch"
#include "restFul.ch"

/*
Programa.: cstParametros.prw
Tipo.....: API Rest 
Autor....: Odair Batista - TOTVS OESTE (Unidade Londrina)
Data.....: 18/07/2023
Descrição: API para consulta de parâmetros do Protheus 
Notas....: 
*/


/*/{Protheus.doc} cstParametros 
Serviço para chamada externa
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 18/07/2023
@version 1.0
@type service
/*/
WsRestFul cstParametros description "API para consulta de parâmetros do Protheus" Format Application_JSon 
    WsData Empresa as string
    WsData Filial  as string
	WsData Codigo  as string

	WsMethod GET description "Método para consulta" WsSyntax "/cstParametros/{Empresa, Filial, Codigo}"
End WsRestFul 


/*/{Protheus.doc} GET
Método para processamento da consulta
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 18/07/2023
@version 1.0
@type method
@param Empresa, string, código da empresa
@param Filial , string, código da filial 
@param Codigo , string, código do cliente
/*/
WsMethod GET WSReceive Empresa, Filial, Codigo WsService cstParametros   
    local oAlerts  := nil
 	local aAlerts  := {}
	local cJSon    := ""
    local oJSon    := nil
    local oUtils   := nil
    local nRow     := 0
    local xContent := nil

	default Self:Empresa := "01"
	default Self:Filial  := ""
	default Self:Codigo  := ""

	rpcSetType(3)			        //Informa que não haverá consumo de licenças
	rpcSetEnv(Self:Empresa, "01")	//Prepara ambiente para empresa 01 e filial 01

    oUtils  := pfwUtils():New()
	oAlerts := pfwAlerts():New()
	oAlerts:Empty()

    if upper(Self:Codigo) == "VERSION"
        xContent := getVersao()                         //Retorna a versão, base de dados e ambiente que está em uso no momento.
    elseIf upper(Self:Codigo) == "CLIENTPATH"
        xContent := getClientDir()                      //Retorna o path completo de onde está sendo executado o Remote. Ex.: C:\AP6\BIN\REMOTE\
    elseIf upper(Self:Codigo) == "ENVIRONMENT"
        xContent := getEnvServer()                      //Retorna o nome do Environment que está sendo utilizado no momento.
    elseIf upper(Self:Codigo) == "STARTPATH"
        xContent := getSrvProfString("STARTPATH", "")   //Retorna o StartPath definido no ini do server
    elseIf upper(Self:Codigo) == "ROOTPATH"
        xContent := getSrvProfString ("ROOTPATH", "")   //Retorna o RootPath definido no ini do server
    elseIf upper(Self:Codigo) == "COMPUTERNAME"
        xContent := getComputerName()                   //Nome da estação
    else 
        xContent := superGetMv(Self:Codigo, .f., "null[xValue]", Self:Filial)
    endIf 

    if xContent == "null[xValue]"
        oAlerts:Add('cstParametros:Get' ;
                    , 'Parâmetros não encontrado!' ;
                    , 'E' ;
                    , 'Não foi encontrado o parâmetro [' + Self:Codigo + '] para a consulta' ;
                      + if(empty(Self:Filial), '.', ' na filial [' + Self:Filial + '].'))
    else
        oJSon := pfwJSon():New(.f., .f., .t.,,, .t.)
        oJSon:AddNode()
        oJSon:AddField("empresa", Self:Empresa)
        oJSon:AddField("filial" , Self:Filial)
        oJSon:AddField("codigo" , Self:Codigo)
        oJSon:AddField("tipo"   , valType(xContent))

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
