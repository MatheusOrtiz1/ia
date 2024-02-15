#include "totvs.ch"
#Include "fwmvcdef.ch"
#include "fatcargasdef.ch"

/*/{Protheus.doc} DataCarga
Classe DATA relacionada a carga
@type class
@author Rodrigo Godinho
@since 17/08/2023
/*/
CLASS DataCarga FROM LongNameClass
	METHOD New() CONSTRUCTOR
	METHOD IsAnCanCli(cIdCarga)
	METHOD IsAnAprRess(cIdCarga)
	METHOD GetObsAnalise(cIdCarga)
	METHOD GetObsAnMudaProd(cIdCarga)
	METHOD UpdByNFCarga(cSerieNF, cNumNF)
	METHOD UpdFatCarga(cSerieNF, cNumNF, cMsgErro)
	METHOD UpdDelPV(cIdCarga, cMsgErro)
	METHOD UpdDelFatCarga(cSerieNF, cNumNF, cMsgErro)
ENDCLASS

/*/{Protheus.doc} DataCarga::New
Construtor
@type method
@author Rodrigo Godinho
@since 17/08/2023
@return object, Instancia da classe
/*/
METHOD New() CLASS DataCarga
Return

/*/{Protheus.doc} DataCarga::IsAnCanCli
Se a an�lise teve resultado Cancelado pelo cliente
@type method
@author Rodrigo Godinho
@since 17/08/2023
@param cIdCarga, character, Id da carga
@return logical, Si a an�lise teve resultado cancelado pelo cliente
/*/
METHOD IsAnCanCli(cIdCarga) CLASS DataCarga	
	Local lRet		:= .F.
	Local aArea		:= GetArea()
	Local cAliasQry	:= GetNextAlias()
	Local cStCanc	:= STATUS_ANALISE_CANCELADA_CLIENTE

	BeginSQL Alias cAliasQry
		SELECT Z35_ID
		FROM %Table:Z35%
		WHERE Z35_FILIAL = %xFilial:Z35%
			AND Z35_IDZ29 = %Exp:cIdCarga%
			AND Z35_RESULT = %Exp:cStCanc%
			AND %NotDel%
	EndSQL
	lRet := !(cAliasQry)->(Eof())
	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} DataCarga::IsAnAprRess
Se a an�lise teve resultado aprovado com ressalvas
@type method
@author Rodrigo Godinho
@since 17/08/2023
@param cIdCarga, character, Id da carga
@return logical, Se a an�lise teve resultado aprovado com ressalvas
/*/
METHOD IsAnAprRess(cIdCarga) CLASS DataCarga	
	Local lRet			:= .F.
	Local aArea			:= GetArea()
	Local cAliasQry		:= GetNextAlias()
	Local cStAprovRess	:= STATUS_ANALISE_APROVADA_COM_RESSALVAS

	BeginSQL Alias cAliasQry
		SELECT Z35_ID
		FROM %Table:Z35%
		WHERE Z35_FILIAL = %xFilial:Z35%
			AND Z35_IDZ29 = %Exp:cIdCarga%
			AND Z35_RESULT = %Exp:cStAprovRess%
			AND %NotDel%
	EndSQL
	lRet := !(cAliasQry)->(Eof())
	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} DataCarga::GetObsAnalise
Retorna a observa��o da an�lise
@type method
@author Rodrigo Godinho
@since 21/08/2023
@param cIdCarga, character, Id da carga
@return character, Observa��o da an�lise
/*/
METHOD GetObsAnalise(cIdCarga) CLASS DataCarga	
	Local cRet			:= ""
	Local aArea			:= GetArea()
	Local cAliasQry		:= GetNextAlias()

	BeginSQL Alias cAliasQry
		SELECT Z35_OBS
		FROM %Table:Z35%
		WHERE Z35_FILIAL = %xFilial:Z35%
			AND Z35_IDZ29 = %Exp:cIdCarga%
			AND %NotDel%
	EndSQL
	If !(cAliasQry)->(Eof())
		cRet := AllTrim((cAliasQry)->Z35_OBS)
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
Return cRet

/*/{Protheus.doc} DataCarga::GetObsAnMudaProd
Retorna a observa��o de mudan�a de produto
@type method
@author Rodrigo Godinho
@since 21/08/2023
@param cIdCarga, character, Id da carga
@return character, Observa��o de mudan�a de produto
/*/	
METHOD GetObsAnMudaProd(cIdCarga) CLASS DataCarga	
	Local cRet			:= ""
	Local aArea			:= GetArea()
	Local cAliasQry		:= GetNextAlias()
	
	BeginSQL Alias cAliasQry
		SELECT Z35_OBSPRD
		FROM %Table:Z35%
		WHERE Z35_FILIAL = %xFilial:Z35%
			AND Z35_IDZ29 = %Exp:cIdCarga%
			AND %NotDel%
	EndSQL
	If !(cAliasQry)->(Eof())
		cRet := AllTrim((cAliasQry)->Z35_OBSPRD)
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
Return cRet

/*/{Protheus.doc} DataCarga::UpdByNFCarga
Atualiza cargas com dados de faturamento
@type method
@author Rodrigo Godinho
@since 21/08/2023
@param cSerieNF, character, Serie
@param cNumNF, character, Numero da NF
/*/
METHOD UpdByNFCarga(cSerieNF, cNumNF) CLASS DataCarga
	Local aArea			:= GetArea()
	Local aAreaZ29		:= Z29->(GetArea())
	Local cAliasQry		:= GetNextAlias()
	Local cMsgErro		:= ""
	
	BeginSQL Alias cAliasQry
		SELECT DISTINCT Z29.R_E_C_N_O_ Z29_REC
		FROM %Table:SD2% SD2 (NOLOCK)
		JOIN %Table:SC5% SC5 (NOLOCK) ON C5_FILIAL = %xFilial:SC5% AND C5_NUM = D2_PEDIDO AND SC5.%NotDel%
		JOIN %Table:Z29% Z29 (NOLOCK) ON Z29_FILIAL = %xFilial:Z29% AND Z29_ID = C5_XIDZ29 AND Z29.%NotDel%
		WHERE D2_FILIAL = %xFilial:SD2%
			AND D2_SERIE = %Exp:cSerieNF%
			AND D2_DOC = %Exp:cNumNF%
			AND C5_XIDZ29 <> ' '
			AND SD2.%NotDel%
	EndSQL
	While !(cAliasQry)->(Eof())
		Z29->(dbGoTo((cAliasQry)->Z29_REC))
		If !Z29->(Eof())
			::UpdFatCarga(cSerieNF, cNumNF, cMsgErro)
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	
	RestArea(aAreaZ29)
	RestArea(aArea)
Return

/*/{Protheus.doc} DataCarga::UpdFatCarga
Atualiza o status de uma carga e seus dados de faturamento
@type method
@author Rodrigo Godinho
@since 21/08/2023
@param cSerieNF, character, Serie NF
@param cNumNF, character, N�mero NF
@param cMsgErro, character, Mensagem de erro( ser� populado com o erro por refer�ncia )
@return logical, Se teve sucesso na opera��o
/*/
METHOD UpdFatCarga(cSerieNF, cNumNF, cMsgErro) CLASS DataCarga
	Local lRet		:= .F.
	Local aErro		:= {}
	Local oModelZ29
	Local oStrucZ29
	
	oModelZ29 := FWLoadModel("CTRFATUR")
	oStrucZ29 := oModelZ29:GetModel("Z29MASTER"):GetStruct()
	oStrucZ29:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
	oModelZ29:SetOperation(MODEL_OPERATION_UPDATE)
	If oModelZ29:Activate()
		oModelZ29:SetValue("Z29MASTER", "Z29_STATUS", STATUS_CARGA_FATURADA)
		oModelZ29:SetValue("Z29MASTER", "Z29_SERNF", cSerieNF)
		oModelZ29:SetValue("Z29MASTER", "Z29_NFISCA", cNumNF)
		If oModelZ29:VldData()
			lRet := oModelZ29:CommitData()
		Else
			Default cMsgErro	:= ""
			aErro := oModel:GetErrorMessage()       
			cMsgErro += "Id do formul�rio de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
			cMsgErro += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
			cMsgErro += "Id do formul�rio de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
			cMsgErro += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
			cMsgErro += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
			cMsgErro += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
			cMsgErro += "Mensagem da solu��o: "        + ' [' + cValToChar(aErro[07]) + '], '
			cMsgErro += "Valor atribu�do: "            + ' [' + cValToChar(aErro[08]) + '], '
			cMsgErro += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
		EndIf
		oModelZ29:Deactivate()
	EndIf
	oModelZ29:Destroy()
	FreeObj(oModelZ29)
Return lRet

/*/{Protheus.doc} DataCarga::UpdDelPV
Atualiza a carga quando o pedido que foi gerado por uma carga � excluido
@type method
@author Rodrigo Godinho
@since 29/08/2023
@param cIdCarga, character, Id da carga
@param cMsgErro, character, Mensagem de erro
@return logical, Se atualizou com sucesso
/*/
METHOD UpdDelPV(cIdCarga, cMsgErro) CLASS DataCarga
	Local lRet		:= .F.
	Local aErro		:= {}
	Local aArea		:= GetArea()
	Local aAreaZ29	:= Z29->(GetArea())
	Local oModelZ29
	Local oStrucZ29

	Z29->(dbSetOrder(1))
	If Z29->(MSSeek( xFilial("Z29") + AvKey(cIdCarga, "Z29_ID") ))
		oModelZ29 := FWLoadModel("CTRFATUR")
		oStrucZ29 := oModelZ29:GetModel("Z29MASTER"):GetStruct()
		oStrucZ29:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
		oModelZ29:SetOperation(MODEL_OPERATION_UPDATE)
		If oModelZ29:Activate()
			oModelZ29:SetValue("Z29MASTER", "Z29_STATUS", STATUS_CARGA_BAIXADA)
			oModelZ29:SetValue("Z29MASTER", "Z29_NUMPV", "")
			If oModelZ29:VldData()
				lRet := oModelZ29:CommitData()
			Else
				Default cMsgErro	:= ""
				aErro := oModel:GetErrorMessage()       
				cMsgErro += "Id do formul�rio de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
				cMsgErro += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
				cMsgErro += "Id do formul�rio de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
				cMsgErro += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
				cMsgErro += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
				cMsgErro += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
				cMsgErro += "Mensagem da solu��o: "        + ' [' + cValToChar(aErro[07]) + '], '
				cMsgErro += "Valor atribu�do: "            + ' [' + cValToChar(aErro[08]) + '], '
				cMsgErro += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
			EndIf
			oModelZ29:Deactivate()
		EndIf
		oModelZ29:Destroy()
		FreeObj(oModelZ29)
	EndIf

	RestArea(aAreaZ29)
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} DataCarga::UpdDelFatCarga
Atualiza o status de uma carga e seus dados ap�s exclus�o fatura
@type method
@author Rodrigo Godinho
@since 21/08/2023
@param cSerieNF, character, Serie NF
@param cNumNF, character, N�mero NF
@param cMsgErro, character, Mensagem de erro( ser� populado com o erro por refer�ncia )
@return logical, Se teve sucesso na opera��o
/*/
METHOD UpdDelFatCarga(cSerieNF, cNumNF, cMsgErro) CLASS DataCarga
	Local lRet		:= .F.
	Local aErro		:= {}
	Local aArea			:= GetArea()
	Local aAreaZ29		:= Z29->(GetArea())
	Local cAliasQry		:= GetNextAlias()
	Local oModelZ29
	Local oStrucZ29
	
	BeginSQL Alias cAliasQry
		SELECT DISTINCT Z29.R_E_C_N_O_ Z29_REC
		FROM %Table:SF2% SF2 (NOLOCK)
		JOIN %Table:Z29% Z29 (NOLOCK) ON Z29_FILIAL = %xFilial:Z29% AND Z29_SERNF = F2_SERIE AND Z29_NFISCA = F2_DOC AND Z29.%NotDel%
		WHERE F2_FILIAL = %xFilial:SF2%
			AND F2_SERIE = %Exp:cSerieNF%
			AND F2_DOC = %Exp:cNumNF%
			AND SF2.%NotDel%
	EndSQL
	While !(cAliasQry)->(Eof())
		Z29->(dbGoTo((cAliasQry)->Z29_REC))
		If !Z29->(Eof())
			oModelZ29 := FWLoadModel("CTRFATUR")
			oStrucZ29 := oModelZ29:GetModel("Z29MASTER"):GetStruct()
			oStrucZ29:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
			oModelZ29:SetOperation(MODEL_OPERATION_UPDATE)
			If oModelZ29:Activate()
				oModelZ29:SetValue("Z29MASTER", "Z29_STATUS", STATUS_CARGA_PEDIDO_EMITIDO)
				oModelZ29:SetValue("Z29MASTER", "Z29_SERNF", "")
				oModelZ29:SetValue("Z29MASTER", "Z29_NFISCA", "")
				If oModelZ29:VldData()
					lRet := oModelZ29:CommitData()
				Else
					Default cMsgErro	:= ""
					aErro := oModel:GetErrorMessage()       
					cMsgErro += "Id do formul�rio de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
					cMsgErro += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
					cMsgErro += "Id do formul�rio de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
					cMsgErro += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
					cMsgErro += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
					cMsgErro += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
					cMsgErro += "Mensagem da solu��o: "        + ' [' + cValToChar(aErro[07]) + '], '
					cMsgErro += "Valor atribu�do: "            + ' [' + cValToChar(aErro[08]) + '], '
					cMsgErro += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
				EndIf
				oModelZ29:Deactivate()
			EndIf
			oModelZ29:Destroy()
			FreeObj(oModelZ29)
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	RestArea(aAreaZ29)
	RestArea(aArea)
Return lRet
