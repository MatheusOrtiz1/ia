#include "totvs.ch"
#Include "fwmvcdef.ch"
#include "fatcargasdef.ch"

#define CARGA_COM_FRETE "1"

/*/{Protheus.doc} CriarPedidoExecutor
Classe executora de criar pedido
@type class
@author Rodrigo Godinho
@since 16/08/2023
/*/
CLASS CriarPedidoExecutor FROM LongNameClass
	METHOD New() CONSTRUCTOR
	METHOD Execute()
	METHOD GerarPedido()
	METHOD UpdCarga(cMsgErro)
	METHOD VldNegFin()
	METHOD GetItemFrete(cCodClie, cLojaClie)
ENDCLASS

/*/{Protheus.doc} CriarPedidoExecutor::New
Construtor
@type method
@author Rodrigo Godinho
@since 16/08/2023
@return object, Instância da classe
/*/
METHOD New() CLASS CriarPedidoExecutor
Return

/*/{Protheus.doc} CriarPedidoExecutor::Execute
Método execute
@type method
@author Rodrigo Godinho
@since 16/08/2023
/*/
METHOD Execute() CLASS CriarPedidoExecutor
	Local aArea		:= GetArea()

	If Z29->Z29_STATUS == STATUS_CARGA_BAIXADA
		If FWAlertYesNo("Você confirma a criação do pedido de venda?", "Gerar Pedido") .And. ::VldNegFin()	
			FWMsgRun(, {|oSay| ::GerarPedido() }, "Gerar pedido", "Processando dados...")
		EndIf
	Else
		FWAlertWarning("A criação do pedido só pode ser realizada em cargas com status 'Baixada'.", "Geração de Pedido")
	EndIf

	RestArea(aArea)
Return

/*/{Protheus.doc} CriarPedidoExecutor::GerarPedido
Método que cria o pedido
@type method
@author Rodrigo Godinho
@since 16/08/2023
/*/
METHOD GerarPedido() CLASS CriarPedidoExecutor
	Local oDataPV 		:= DataEntidadePedidoVendaCONASA():New()
	Local oDataCarga 	:= DataCarga():New()
	Local oEntPV		:= EntidadePedidoDeVendaConasa():New()
	Local oEntItem		:= EntidadeItemPedidoDeVendaConasa():New()
	Local lRetExec		:= .F.
	Local cMsgErro		:= ""
	Local cMsgNF		:= ""
	Local cAuxMsg		:= ""
	Local aSolucao		:= {}
	Local oEntItFrete
	
	oEntPV:cCodClie := Z29->Z29_CODCLI
	oEntPV:cLojaClie := Z29->Z29_LOJA
	oEntPV:cIdZ29 := Z29->Z29_ID
	// Obter a observação de NF da carga
	If !Empty(Z29->Z29_OBSNF)
		cMsgNF := AllTrim(Z29->Z29_OBSNF)
	EndIf
	// Obter a observação da análise
	If !Empty(cMsgNf)
		cMsgNF += CRLF
	EndIf
	cAuxMsg := AllTrim(oDataCarga:GetObsAnalise(Z29->Z29_ID))
	If !Empty(cMsgNF)
		cMsgNF += cAuxMsg
	EndIf
	// Obter a observação de mudança de produto da análise
	If !Empty(cMsgNf)
		cMsgNF += CRLF
	EndIf
	cAuxMsg := AllTrim(oDataCarga:GetObsAnMudaProd(Z29->Z29_ID))
	If !Empty(cMsgNF)
		cMsgNF += cAuxMsg
	EndIf
	oEntPV:cMsgNF := cMsgNF
	oEntItem:cCodProd := Z29->Z29_SBTIPO
	oEntItem:nQtdVend := Z29->Z29_VOLUME
	If !Empty(Z29->Z29_PRCNEG)
		oEntItem:nPrecoUnit := Z29->Z29_PRCNEG
	EndIf
	oEntPV:AddItem(oEntItem)
	oEntItFrete := ::GetItemFrete(Z29->Z29_CODCLI, Z29->Z29_LOJA)
	If ValType(oEntItFrete) == "O"
		oEntPV:AddItem(oEntItFrete)
	EndIf
	BEGIN TRANSACTION
		lRetExec := oDataPV:Insert(oEntPV, @cMsgErro)
		If lRetExec
			lRetExec := ::UpdCarga(@cMsgErro)
			If !lRetExec
				DisarmTransaction()
			EndIf
		EndIf
	END TRANSACTION
	If lRetExec
		FWAlertSuccess("Pedido " + AllTrim(SC5->C5_NUM) + " gerado com sucesso.", "Gerar pedido")
	Else
		If !Empty(cMsgErro)
			aSolucao := {"Verifique os dados, tente executar novamente e caso o problema persista contate o administrador do sistema."}
			Help( , , "Gerar Pedido", , cMsgErro, 1, 0, , , , , ,)
		Else
			FWAlertError("Ocorreu um erro na geração do pedido, contate o administrador do sistema.", "Gerar pedido")
		EndIf
	EndIf
	If ValType(oEntItFrete) == "O"
		FreeObj(oEntItFrete)
	EndIf
	FreeObj(oEntItem)
	FreeObj(oEntPV)
	FreeObj(oDataPV)
Return

/*/{Protheus.doc} CriarPedidoExecutor::UpdCarga
Método que atualiza a carga
@type method
@author Rodrigo Godinho
@since 16/08/2023
@param cMsgErro, character, Recebe a mensagem de erro por referência
@return logical, Se operação foi realizada com sucesso
/*/
METHOD UpdCarga(cMsgErro) CLASS CriarPedidoExecutor
	Local lRet		:= .F.
	Local aErro		:= {}
	Local cNumPV	:= ""
	Local oDataPV	:= DataEntidadePedidoVendaCONASA():New()
	Local oModelZ29
	Local oStrucZ29
	
	cNumPV := oDataPV:NumByIdZ29(Z29->Z29_ID)
	If !Empty(cNumPV)
		oModelZ29 := FWLoadModel("CTRFATUR")
		oStrucZ29 := oModelZ29:GetModel("Z29MASTER"):GetStruct()
		oStrucZ29:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
		oModelZ29:SetOperation(MODEL_OPERATION_UPDATE)
		If oModelZ29:Activate()
			oModelZ29:SetValue("Z29MASTER", "Z29_STATUS", STATUS_CARGA_PEDIDO_EMITIDO)
			oModelZ29:SetValue("Z29MASTER", "Z29_NUMPV", SC5->C5_NUM)
			If oModelZ29:VldData()
				lRet := oModelZ29:CommitData()
			Else
				Default cMsgErro	:= ""
				aErro := oModel:GetErrorMessage()       
				cMsgErro += "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
				cMsgErro += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
				cMsgErro += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
				cMsgErro += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
				cMsgErro += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
				cMsgErro += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
				cMsgErro += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
				cMsgErro += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
				cMsgErro += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
			EndIf
			oModelZ29:Deactivate()
		EndIf
		oModelZ29:Destroy()
		FreeObj(oModelZ29)
	Else
		cMsgErro := "Não foi possível identificar o pedido gerado por esta carga."
	EndIf
	FreeObj(oDataPV)
Return lRet

/*/{Protheus.doc} CriarPedidoExecutor::VldNegFin
Verifica se há a necessidade de negociação financeira
@type method
@author Rodrigo Godinho
@since 16/08/2023
@return logical, Se ha a necessidade de negociação financeira
/*/
METHOD VldNegFin() CLASS CriarPedidoExecutor
	Local lRet			:= .T.
	Local oDataCarga	:= DataCarga():New()

	If oDataCarga:IsAnAprRess(Z29->Z29_ID) .And. Empty(Z29->Z29_PRCNEG)
		If FWAlertYesNo("Esta carga requer Negociação Financeira. Deseja realizar a Negociação Financeira?", "Gerar pedido")
			U_ClassExec(NegociacaoFinanceiraExecutor():New())
			If Empty(Z29->Z29_PRCNEG)
				lRet := .F.
				FWAlertWarning("Como a Negociação Financeira não foi concluida, o pedido não será gerado.", "Gerar pedido")
			EndIf
		Else
			lRet := .F.
			FWAlertWarning("Como a Negociação Financeira não foi realizada, o pedido não será gerado.", "Gerar pedido")
		EndIf
	EndIf

	FreeObj(oDataCarga)
Return lRet

/*/{Protheus.doc} CriarPedidoExecutor::GetItemFrete
Retorna o item de frete
@type method
@author Rodrigo Godinho
@since 29/08/2023
@param cCodClie, character, Codigo do cliente
@param cLojaClie, character, Loja do cliente
@return object, Objeto de item do pedido que representa o frete
/*/
METHOD GetItemFrete(cCodClie, cLojaClie) CLASS CriarPedidoExecutor
	Local oRet
	Local aArea			:= GetArea()
	Local aInfoClie		:= GetAdvFVal("SA1", {"A1_TABELA","A1_XFRECAR"}, xFilial("SA1") + AvKey(cCodClie, "A1_COD") + AvKey(cLojaClie, "A1_LOJA"), 1, {"", ""}, .T.)
	Local cTabPreco		:= aInfoClie[1]
	Local cFreteCarga	:= aInfoClie[2]
	Local cCodProd		:= ""
	Local nValorFrete	:= 0
	
	If cFreteCarga == CARGA_COM_FRETE
		cCodProd := AvKey(AllTrim(GetMV("CO_PRODFRE", , "FRETE")), "B1_COD")
		nValorFrete := MaTabPrVen(cTabPreco, cCodProd, 1, cCodClie, cLojaClie)
		If nValorFrete > 0
			oRet := EntidadeItemPedidoDeVendaConasa():New()
			oRet:cCodProd := cCodProd
			oRet:nQtdVend := 1
		EndIf
	EndIf
	RestArea(aArea)
Return oRet
