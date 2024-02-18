//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

//Variveis Estaticas
Static cTitulo := "Cadastro de Observacao"
Static cAliasMVC := "Z33"

/*/{Protheus.doc} User Function CADOBSZ
Cadastro de Observacao
@author EVERTON HENRIQUE FORTI
@since 06/08/2023
/*/

User Function CADOBSZ()
	Local aArea   := FWGetArea()
	Local oBrowse
	Local nIgnore := 1
	Private aRotina := {}

	//Definicao do menu
	aRotina := MenuDef()

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasMVC)
	oBrowse:SetDescription(cTitulo)

	//Ativa a Browse
	oBrowse:Activate()

	//Tratativa para ignorar warnings de ViewDef e ModelDef nunca chamados
	If nIgnore == 0
		ModelDef()
		ViewDef()
	EndIf

	FWRestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao CADOBSZ
@author EVERTON HENRIQUE FORTI
@since 06/08/2023
/*/

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.CADOBSZ" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.CADOBSZ" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.CADOBSZ" OPERATION 4 ACCESS 0
	//ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.CADOBSZ" OPERATION 5 ACCESS 0
	//ADD OPTION aRotina TITLE "IMP_PADRAO" ACTION "U_IMPRIMI" OPERATION 6 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao CADOBSZ
@author EVERTON HENRIQUE FORTI
@since 06/08/2023
/*/

Static Function ModelDef()
	Local oStruct := FWFormStruct(1, cAliasMVC)
	Local oModel
	Local bPre := Nil
	Local bPos := Nil
	Local bCancel := Nil


	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("CADOBSZM", bPre, bPos, /*bCommit*/, bCancel)
	oModel:AddFields("Z33MASTER", /*cOwner*/, oStruct)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("Z33MASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:SetPrimaryKey({})
Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao CADOBSZ
@author EVERTON HENRIQUE FORTI
@since 06/08/2023
/*/

Static Function ViewDef()
	Local oModel := FWLoadModel("CADOBSZ")
	Local oStruct := FWFormStruct(2, cAliasMVC)
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_Z33", oStruct, "Z33MASTER")
	oView:CreateHorizontalBox("TELA" , 100 )
	oView:SetOwnerView("VIEW_Z33", "TELA")

Return oView
