#include "protheus.ch"
#include "rwmake.ch"
#include "topConn.ch"
#include "fwMBrowse.ch"
#include "fwMVCDef.ch"

/*
Programa.: CADZAF.prw 
Tipo.....: Atualização 
Autor....: Daniel Gouvea - TOTVS OESTE - Unidade Londrina
Data.....: 03/11/2022
Descrição: CADASTRO INTEGRACAO COMPSIS
Notas....:   
*/

static oAlerts   := pfwAlerts():New()	//Instanciando a classe para controle de mensagens
static cProgram  := "CADZAF"			//Nome da função principal para chamada externa do programa
static cTitle  	 := "Cadastro Integração Faturamento"			//Título do programa

//-------------------------------------------------------------------
user function CADZAF()
	local aArea := getArea()

	private oBrowse := nil

	oBrowse := fwMBrowse():New()		//Instanciando o objeto browse

	oBrowse:SetAlias("ZAF")				//Setando a tabela
	oBrowse:SetDescription(cTitle)		//Setando a descrição da rotina

	//Adicionando as Legendas
    oBrowse:AddLegend( "ZAF->ZAF_TIPO == '1' ", "GREEN"		,    "GERA PEDIDO E FATURA NOTA FISCAL" )
    oBrowse:AddLegend( "ZAF->ZAF_TIPO == '2' ", "BLACK"		,    "GERA NDC" )
    oBrowse:AddLegend( "ZAF->ZAF_TIPO == '3' ", "YELLOW"	,    "GERA LANÇAMENTO CONTABIL" )
    oBrowse:AddLegend( "ZAF->ZAF_TIPO == '4' ", "RED"		,    "GERA CONTAS A RECEBER E BAIXA AUTOMATICAMENTE" )
    oBrowse:AddLegend( "ZAF->ZAF_TIPO == '5' ", "BLUE"		,    "GERA CONTAS A PAGAR E BAIXA AUTOMATICAMENTE" )

	oBrowse:Activate()		//Ativação do browser

	restArea(aArea)
return


static function menuDef()
	local aRot := {}

	//Adicionando opções
	add option aRot title 'Visualizar' action 'ViewDef.' + cProgram operation 1 access 0
	add option aRot title 'Incluir'    action 'ViewDef.' + cProgram operation 3 access 0
	add option aRot title 'Alterar'    action 'ViewDef.' + cProgram operation 4 access 0
	add option aRot title 'Excluir'    action 'ViewDef.' + cProgram operation 5 access 0

return(aRot)


static function modelDef()
	local oModel  := nil
	local oStrZAF := fwFormStruct(1, 'ZAF')

	oModel := mpFormModel():New('MainModel', /*{|oModel| preValidDef(oModel)}*/ ;	//Pré-validação do modelo
	, {|oModel| validDef(oModel)} ;		//Validação do modelo (Equilave ao "TUDOOK")
	, {|oModel| saveDef(oModel)} ;		//Gravação da edição do registro (Commit)
	, /*{|oModel| cancelDef(oModel)}*/)	//Cancelamento da edição do registro
	oModel:SetDescription(cTitle)

	//Criação de objetos de interface
	oModel:addFields('MFieldZAF',, oStrZAF)

	//Definindo propriedades de atributos (campos) em tela
//	oStrZCA:SetProperty("ZAJ_CODSAF" , MODEL_FIELD_WHEN, {|| INCLUI})

	oModel:SetPrimaryKey({"ZAF_FILIAL", "ZAF_EVENTO","ZAF_ORIGEM"})		//Indicando índice primário

	//Informando as descrições para os modelos de dados
	oModel:getModel('MFieldZAF'):SetDescription(cTitle)
return(oModel)


//-------------------------------------------------------------------
/*/{Protheus.doc} viewDef
Definição do interface
@author Odair Batista - TOTVS Unidade Londrina
@since 05/07/2018
@version 1.0
@type function
@return oView, objeto, View de interface
/*/
//-------------------------------------------------------------------
static function viewDef()
	local oView	  := nil
	local oModel  := modelDef()
	local oStrZAF := fwFormStruct(2, 'ZAF')


	oView := fwFormView():New()		//Instanciando a Viewer para interface

	oView:SetModel(oModel)			//Indicando o modelo de dados para a Viewer

	//Adicionando objetos de interface
	oView:AddField('formZAF', oStrZAF, 'MFieldZAF')

	oView:CreateHorizontalBox('boxZAF', 100)

	oView:SetOwnerView('formZAF', 'boxZAF')

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({|| .t.})
return(oView)


static function validDef(oModel)
	local areaZAF   := ZAF->(getArea())
	local oModelZAF := oModel:GetModel('MFieldZAF')
	local nOpc      := oModel:GetOperation()

	oAlerts:Empty()

	if nOpc == 3		//Insert
		IF CEMPANT=="43"
			IF oModelZAF:GetValue('ZAF_TIPO')=="1"
				if empty(alltrim(oModelZAF:GetValue('ZAF_TES')))
					oAlerts:Add("validDef", "TES vazia! Favor preencher o TES")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CLIENT')))
					oAlerts:Add("validDef", "Cliente vazio! Favor preencher o Cliente")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_LOJA')))
					oAlerts:Add("validDef", "Loja vazia! Favor preencher a loja")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CLVL')))
					oAlerts:Add("validDef", "Classe de Valor vazia! Favor preencher o Classe de Valor")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_NATURE')))
					oAlerts:Add("validDef", "Natureza vazia! Favor preencher a Natureza")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CCUSTO')))
					oAlerts:Add("validDef", "Centro de custo vazio! Favor preencher o Centro de custo")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_COD')))
					oAlerts:Add("validDef", "Produto vazio! Favor preencher o Produto")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_ITEMCT')))
					oAlerts:Add("validDef", "Item Contabil vazia! Favor preencher o Item Contabil")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_SERIE')))
					oAlerts:Add("validDef", "Serie NF em branco! Favor preencher Serie NF")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_COND')))
					oAlerts:Add("validDef", "Cond. Pagto em branco! Favor preencher Cond. Pagto")
				endif
			ELSEIF oModelZAF:GetValue('ZAF_TIPO')=="2" //NDC
				if empty(alltrim(oModelZAF:GetValue('ZAF_TES')))
					oAlerts:Add("validDef", "TES vazia! Favor preencher o TES")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CLIENT')))
					oAlerts:Add("validDef", "Cliente vazio! Favor preencher o Cliente")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_LOJA')))
					oAlerts:Add("validDef", "Loja vazia! Favor preencher a loja")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CLVL')))
					oAlerts:Add("validDef", "Classe de Valor vazia! Favor preencher o Classe de Valor")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_NATURE')))
					oAlerts:Add("validDef", "Natureza vazia! Favor preencher a Natureza")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CCUSTO')))
					oAlerts:Add("validDef", "Centro de custo vazio! Favor preencher o Centro de custo")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_DEB')))
					oAlerts:Add("validDef", "Conta debito vazia! Favor preencher a Conta debito")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CRED')))
					oAlerts:Add("validDef", "Conta credito vazia! Favor preencher a Conta credito")
				endif

			ELSEIF oModelZAF:GetValue('ZAF_TIPO')=="3"
				if empty(alltrim(oModelZAF:GetValue('ZAF_CRED')))
					oAlerts:Add("validDef", "Conta debito vazia! Favor preencher a Conta debito")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CRED')))
					oAlerts:Add("validDef", "Conta credito vazia! Favor preencher a Conta credito")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CCDEB')))
					oAlerts:Add("validDef", "Centro Custo debito vazia! Favor preencher o Centro Custo debito")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CCCRED')))
					oAlerts:Add("validDef", "Centro Custo credito vazia! Favor preencher o Centro Custo credito")
				endif

			ELSEIF oModelZAF:GetValue('ZAF_TIPO')=="4"
				if empty(alltrim(oModelZAF:GetValue('ZAF_CLIENT')))
					oAlerts:Add("validDef", "Cliente vazio! Favor preencher o Cliente")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_LOJA')))
					oAlerts:Add("validDef", "Loja vazia! Favor preencher a loja")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CLVL')))
					oAlerts:Add("validDef", "Classe de Valor vazia! Favor preencher o Classe de Valor")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_NATURE')))
					oAlerts:Add("validDef", "Natureza vazia! Favor preencher a Natureza")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CCUSTO')))
					oAlerts:Add("validDef", "Centro de custo vazio! Favor preencher o Centro de custo")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_BANCO')))
					oAlerts:Add("validDef", "Baixa vazio! Favor preencher o Caixa")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_AGENCI')))
					oAlerts:Add("validDef", "Agencia vazia! Favor preencher a Agencia")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CONTA')))
					oAlerts:Add("validDef", "Conta vazia! Favor preencher a Conta")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CCDEB')))
					oAlerts:Add("validDef", "Centro Custo debito vazia! Favor preencher o Centro Custo debito")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CCCRED')))
					oAlerts:Add("validDef", "Centro Custo credito vazia! Favor preencher o Centro Custo credito")
				endif


			ELSEIF oModelZAF:GetValue('ZAF_TIPO')=="5"
				if empty(alltrim(oModelZAF:GetValue('ZAF_CLIENT')))
					oAlerts:Add("validDef", "Cliente vazio! Favor preencher o Cliente")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_LOJA')))
					oAlerts:Add("validDef", "Loja vazia! Favor preencher a loja")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CLVL')))
					oAlerts:Add("validDef", "Classe de Valor vazia! Favor preencher o Classe de Valor")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_NATURE')))
					oAlerts:Add("validDef", "Natureza vazia! Favor preencher a Natureza")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CCUSTO')))
					oAlerts:Add("validDef", "Centro de custo vazio! Favor preencher o Centro de custo")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_BANCO')))
					oAlerts:Add("validDef", "Baixa vazio! Favor preencher o Caixa")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_AGENCI')))
					oAlerts:Add("validDef", "Agencia vazia! Favor preencher a Agencia")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CONTA')))
					oAlerts:Add("validDef", "Conta vazia! Favor preencher a Conta")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CCDEB')))
					oAlerts:Add("validDef", "Centro Custo debito vazia! Favor preencher o Centro Custo debito")
				endif
				if empty(alltrim(oModelZAF:GetValue('ZAF_CCCRED')))
					oAlerts:Add("validDef", "Centro Custo credito vazia! Favor preencher o Centro Custo credito")
				endif
			ENDIF

		ENDIF


	endIf

	if nOpc == 4		//Update

	endIf

	if nOpc == 3 .or. nOpc == 4		//Upsert
	endIf

	if nOpc == 5		//Delete

	endIf

	restArea(areaZAF)


	fwModelActive(oModel, .t.)

	oAlerts:Show()

	if oAlerts:HasErrors()
		help("", 1, "Erro ao validar dados",, "Existem campos com dados inconsistentes", 4, 8, .f.)
	endIf
return(!oAlerts:HasErrors())

static function saveDef(oModel)
	local lReturn := .t.

	//Antes de gravar

	begin transaction
		lReturn := fwFormCommit(oModel)		//Efetua a gravação padrão do modelo de dados

		if !lReturn
			disarmTransaction()
		endIf
	end transaction

	//Depois de gravar
return(lReturn)
