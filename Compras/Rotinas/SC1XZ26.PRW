#Include "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "FWMVCDEF.ch"
/*
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao: SC1XZ26 -  Grupo de Aprova艫o Solicita艫o de Compra         艮�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
臼�Author: Everton Forti       Uso: Conasa         Data: 10/10/2022       艮�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
// FUN巴O PRINCIPAL
User Function SC1XZ26()
    Local oBrowse := FwLoadBrw("SC1XZ26")

    oBrowse:Activate()
Return (NIL)

// BROWSEDEF() SER� �TIL PARA FUTURAS HERAN�AS: FWLOADBRW()
Static Function BrowseDef()
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("Z26")
    oBrowse:SetDescription("GRUPO DE APROVA巴O SC")
	//oBrowse:SetOnlyFields( { 'E1_PREFIXO','E1_NUM','E1_CCUSTO','E1_PARCELA','E1_TIPO','E1_NATUREZ','E1_PORTADO','E1_CLIENTE','E1_LJA','E1_NOMCLI','E1_EMISSAO','E1_EMIS1','E1_VENCTO','E1_VENCREA','E1_BAIXA','E1_HIST','E1_EMISSAO','E1_LA','E1_CO' } )
    //oBrowse:AddLegend("EMPTY(E1_LA)", "RED", "N�o Contabilizado")
    //oBrowse:AddLegend("!EMPTY(E1_LA)", "GREEN", "Contabilizado")
     
   // DEFINE DE ONDE SER� RETIRADO O MENUDEF
   oBrowse:SetMenuDef("SC1XZ26")
Return (oBrowse)

// OPERA杯ES DA ROTINA
Static Function MenuDef()
    // FUN巴O PARA CRIAR MENUDEF
    //Local aRotina := FWMVCMenu("SC1XZ26")
    Local aRotina := {}
    
    ADD OPTION aRotina TITLE 'Visualizar'       ACTION 'VIEWDEF.SC1XZ26' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'          ACTION 'VIEWDEF.SC1XZ26' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'          ACTION 'VIEWDEF.SC1XZ26' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'          ACTION 'VIEWDEF.SC1XZ26' OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Imprimir'         ACTION 'VIEWDEF.SC1XZ26' OPERATION 8 ACCESS 0
    //Adicionando op苺es
	//ADD OPTION aRotina TITLE 'Faturamento' ACTION 'VIEWDEF.zMVCMdX' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1

Return (aRotina)

// REGRAS DE NEG�CIO
Static Function ModelDef()
    // INSTANCIA O MODELO
    Local oModel := MPFormModel():New("COMP011M")

    // INSTANCIA O SUBMODELO
    Local oStruZ26 := FwFormStruct(1, "Z26")

    // DEFINE O SUBMODELO COMO FIELD
    oModel:AddFields("Z26MASTER", NIL, oStruZ26)

    // DESCRI巴O DO MODELO
    oModel:SetDescription("Controle Contabilizacao")

	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'E1_FILIAL', 'E1_NUM','E1_PREFIXO','E1_CLIENTE','E1_LOJA'})

    // DESCRI巴O DO SUBMODELO
    oModel:GetModel("Z26MASTER"):SetDescription("GRUPO APROVA巴O SC")
Return (oModel)

// INTERFACE GR�FICA
Static Function ViewDef()
    // INSTANCIA A VIEW
    Local oView := FwFormView():New()

    // INSTANCIA AS SUBVIEWS
    Local oStruZ26 := FwFormStruct(2, "Z26")

    // RECEBE O MODELO DE DADOS
    Local oModel := FwLoadModel("SC1XZ26")

    // INDICA O MODELO DA VIEW
    oView:SetModel(oModel)

    // CRIA ESTRUTURA VISUAL DE CAMPOS
    oView:AddField("VIEW_Z26", oStruZ26, "Z26MASTER")

    // CRIA BOX HORIZONTAL
    oView:CreateHorizontalBox("TELA" , 100)

    // RELACIONA OS BOX COM A ESTRUTURA VISUAL
    oView:SetOwnerView("VIEW_Z26", "TELA")
Return (oView)
