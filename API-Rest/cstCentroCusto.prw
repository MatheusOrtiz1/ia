#include "totvs.ch"
#include "restFul.ch"

/*
Programa.: cstCentroCusto.prw
Tipo.....: API Rest 
Autor....: Odair Batista - TOTVS OESTE (Unidade Londrina)
Data.....: 18/07/2023
Descrição: API para consulta de centro de custo 
Notas....: 
*/


/*/{Protheus.doc} cstCentroCusto 
Serviço para chamada externa
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 18/07/2023
@version 1.0
@type service
/*/
WsRestFul cstCentroCusto description "API para consulta de centro de custo" Format Application_JSon 
    WsData Empresa as string
    WsData Filial  as string
	WsData Codigo  as string
	WsData Classe  as string

	WsMethod GET description "Método para consulta" WsSyntax "/cstCentroCusto/{Empresa, Filial, Codigo, Classe}"
End WsRestFul 


/*/{Protheus.doc} GET
Método para processamento da consulta
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 18/07/2023
@version 1.0
@type method
@param Empresa, string, código da empresa
@parma Filial , string, código da filial
@param Codigo , string, código do centro de custo
@param Classe , string, classe do centro de custo (1=Sintético, 2=Analítico)
@obs
Se não for informado a classe do centro de custo, retorna todos
/*/
WsMethod GET WSReceive Empresa, Filial, Codigo, Classe WsService cstCentroCusto   
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
	default Self:Classe  := ""

	rpcSetType(3)			                //Informa que não haverá consumo de licenças
	rpcSetEnv(Self:Empresa, Self:Filial)	//Prepara ambiente para empresa 01 e filial 01

    dbSelectArea("CTT")

	Self:Codigo := padR(allTrim(Self:Codigo), len(CTT->CTT_CUSTO), " ")
	Self:Classe := allTrim(Self:Classe)

    oUtils  := pfwUtils():New()
	oAlerts := pfwAlerts():New()
	oAlerts:Empty()

    cWhere := "%"
    if empty(Self:Codigo)
        cWhere += "CTT.CTT_CUSTO = CTT.CTT_CUSTO "
    else
        cWhere += "CTT.CTT_CUSTO = '" + Self:Codigo + "' "
    endIf
    if empty(Self:Classe)
        cWhere += "AND CTT.CTT_CLASSE = CTT.CTT_CLASSE "
    else
        cWhere += "AND CTT.CTT_CLASSE = '" + Self:Classe + "' "
    endIf
    cWhere += "%"

    if select("qCTT") > 0
        qCTT->(dbCloseArea())
    endIf

    beginSql alias "qCTT"
        SELECT CTT.CTT_FILIAL, CTT.CTT_CUSTO, CTT.CTT_DESC01, CTT.CTT_CLASSE
        FROM %table:CTT% CTT
        WHERE CTT.%notDel%
          AND CTT.CTT_FILIAL = %xFilial:CTT%
          AND CTT.CTT_BLOQ <> '1'
          AND %exp:cWhere%
        ORDER BY CTT.CTT_FILIAL, CTT.CTT_CUSTO
    endSql

    dbSelectArea("qCTT")
    qCTT->(dbGoTop())

    if qCTT->(eof())
        oAlerts:Add('cstCentroCusto:Get' ;
                    , 'Registros não encontrados!' ;
                    , 'E' ;
                    , 'Não foram encontrados dados para a consulta.')
    else
        oJSon := pfwJSon():New(.f., .f., .t.)
        oJSon:AddNode()
        oJSon:AddNodeData('centroDeCusto')

        do while !qCTT->(eof())
            oJSon:AddNode()
            oJSon:AddField("empresa"  , Self:Empresa)
            oJSon:AddField("filial"   , qCTT->CTT_FILIAL)
            oJSon:AddField("codigo"   , qCTT->CTT_CUSTO)
            oJSon:AddField("descricao", qCTT->CTT_DESC01)
            oJSon:AddField("classe"   , qCTT->CTT_CLASSE)
            oJSon:EndNode()

            qCTT->(dbSkip())
        endDo

        oJSon:EndNodeData()
        oJSon:EndNode()

        cJSon := oJSon:GetJSon()
        oJSon:Destroy()
    endIf

    if select('qCTT') > 0
        qCTT->(dbCloseArea())
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
