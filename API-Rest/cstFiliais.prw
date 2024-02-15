#include "totvs.ch"
#include "restFul.ch"

/*
Programa.: cstFiliais.prw
Tipo.....: API Rest 
Autor....: Odair Batista - TOTVS OESTE (Unidade Londrina)
Data.....: 19/07/2023
Descri��o: API para consulta de filiais por empresa 
Notas....: 
*/


/*/{Protheus.doc} cstFiliais 
Servi�o para chamada externa
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 19/07/2023
@version 1.0
@type service
/*/
WsRestFul cstFiliais description "API para consulta de filiais por empresa" Format Application_JSon 
    WsData Empresa as string
    WsData Filial  as string

	WsMethod GET description "M�todo para consulta" WsSyntax "/cstFiliais/{Empresa, Filial}"
End WsRestFul 


/*/{Protheus.doc} GET
M�todo para processamento da consulta
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 19/07/2023
@version 1.0
@type method
@param Empresa, string, c�digo da empresa
@param Filial , string, c�digo da filial 
/*/
WsMethod GET WSReceive Empresa, Filial WsService cstFiliais   
    local oAlerts  := nil
 	local aAlerts  := {}
	local cJSon    := ""
    local oJSon    := nil
    local oUtils   := nil
    local nRow     := 0
    local nEmpresa := 0
    local nEmpIni  := 1
    local nEmpFin  := 99
    local nFilial  := 0
    local nFilIni  := 1
    local nFilFin  := 99
    local aFields  := {}
    local aData    := {}

	default Self:Empresa := ""
	default Self:Filial  := ""

	rpcSetType(3)			//Informa que n�o haver� consumo de licen�as
	rpcSetEnv("01", "01")	//Prepara ambiente para empresa 01 e filial 01

    oUtils  := pfwUtils():New()
	oAlerts := pfwAlerts():New()
	oAlerts:Empty()

    aFields := { ;
        "M0_CODIGO",;    //Posi��o [1]
        "M0_CODFIL",;    //Posi��o [2]
        "M0_NOMECOM",;   //Posi��o [3]
        "M0_CGC",;       //Posi��o [4]
        "M0_INSCM",;     //Posi��o [5]
        "M0_CIDENT",;    //Posi��o [6]
        "M0_ESTENT",;    //Posi��o [7]
        "M0_ENDENT",;    //Posi��o [8]
        "M0_BAIRENT",;   //Posi��o [9]
        "M0_CEPENT",;    //Posi��o [10]
        "M0_COMPENT",;   //Posi��o [11]
        "M0_TEL";        //Posi��o [12]
    }

    if val(Self:Empresa) > 0
        nEmpIni := val(Self:Empresa)
        nEmpFin := val(Self:Empresa)
    endIf

    if val(Self:Filial) > 0
        nFilIni := val(Self:Filial)
        nFilFin := val(Self:Filial)
    endIf

    oJSon := pfwJSon():New(.f., .f., .t.,,, .t.)
    oJSon:AddNode()
    oJSon:AddNodeData('filiais')

    for nEmpresa := nEmpIni to nEmpFin
        for nFilial := nFilIni to nFilFin
            aData := fwSM0Util():GetSM0Data(strZero(nEmpresa, 2), strZero(nFilial, 2), aFields)
            if !empty(aData)
                oJSon:AddNode()
                oJSon:AddField("empresa"          , aData[1][2])
                oJSon:AddField("filial"           , aData[2][2])
                oJSon:AddField("nome"             , aData[3][2])
                oJSon:AddField("cnpj"             , aData[4][2])
                oJSon:AddField("incricaoMunicipal", aData[5][2])
                oJSon:AddField("cidade"           , aData[6][2])
                oJSon:AddField("estado"           , aData[7][2])
                oJSon:AddField("endereco"         , aData[8][2])
                oJSon:AddField("bairro"           , aData[9][2])
                oJSon:AddField("cep"              , aData[10][2])
                oJSon:AddField("complemento"      , aData[11][2])
                oJSon:AddField("telefone"         , aData[12][2])
                oJSon:EndNode()
            endIf
        next nFilial 
    next nEmpresa

    oJSon:EndNodeData()
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
