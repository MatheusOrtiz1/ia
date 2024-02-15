#Include "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "FWMVCDEF.ch"
/*
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao: SE2XE2LA -  Desmarca Contabilização Contas a Pagar E2_LA    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±ºAuthor: Everton Forti       Uso: Conasa         Data: 01/06/2022       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// FUNÇÃO PRINCIPAL
User Function SE2XE2LA()
    Local oBrowse := FwLoadBrw("SE2XE2LA")

    oBrowse:Activate()
Return (NIL)

// BROWSEDEF() SERÁ ÚTIL PARA FUTURAS HERANÇAS: FWLOADBRW()
Static Function BrowseDef()
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("SE2")
    oBrowse:SetDescription("DESMARCA CONTABILIZACAO  TITULOS A PAGAR")

    oBrowse:AddLegend("EMPTY(E2_LA)", "GREEN", "Não Contabilizado")
    oBrowse:AddLegend("!EMPTY(E2_LA)", "RED", "Contabilizado")

    // DEFINE DE ONDE SERÁ RETIRADO O MENUDEF
    oBrowse:SetMenuDef("SE2XE2LA")
Return (oBrowse)

// OPERAÇÕES DA ROTINA
Static Function MenuDef()
    // FUNÇÃO PARA CRIAR MENUDEF
    //Local aRotina := FWMVCMenu("SE1XE1LA")
    Local aRotina := {}
    
    ADD OPTION aRotina TITLE 'Visualizar'                   ACTION 'VIEWDEF.SE2XE2LA' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Desmarca Linha'               ACTION 'U_SE2XLA()' OPERATION 10 ACCESS 0
    ADD OPTION aRotina TITLE 'Desmarca Contabilização'      ACTION 'U_Desmarc()' OPERATION 10 ACCESS 0

    //Adicionando opções
	//ADD OPTION aRotina TITLE 'Faturamento' ACTION 'VIEWDEF.zMVCMdX' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1

Return (aRotina)

// REGRAS DE NEGÓCIO
Static Function ModelDef()
    // INSTANCIA O MODELO
    Local oModel := MPFormModel():New("COMP011M")

    // INSTANCIA O SUBMODELO
    Local oStruSE2 := FwFormStruct(1, "SE2")

    // DEFINE O SUBMODELO COMO FIELD
    oModel:AddFields("SE2MASTER", NIL, oStruSE2)

    // DESCRIÇÃO DO MODELO
    oModel:SetDescription("Desmarca Contabilização Titulos a Pagar")

    //Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'E2_FILIAL', 'E2_NUM','E2_PREFIXO','E2_FORNECE','E2_LOJA'})

    // DESCRIÇÃO DO SUBMODELO
    oModel:GetModel("SE2MASTER"):SetDescription("Desmarca Contabilização Titulos a Pagar")
Return (oModel)

// INTERFACE GRÁFICA
Static Function ViewDef()
    // INSTANCIA A VIEW
    Local oView := FwFormView():New()

    // INSTANCIA AS SUBVIEWS
    Local oStruSE2 := FwFormStruct(2, "SE2")

    // RECEBE O MODELO DE DADOS
    Local oModel := FwLoadModel("SE2XE2LA")

    // INDICA O MODELO DA VIEW
    oView:SetModel(oModel)

    // CRIA ESTRUTURA VISUAL DE CAMPOS
    oView:AddField("VIEW_SE2", oStruSE2, "SE2MASTER")

    // CRIA BOX HORIZONTAL
    oView:CreateHorizontalBox("TELA" , 100)

    // RELACIONA OS BOX COM A ESTRUTURA VISUAL
    oView:SetOwnerView("VIEW_SE2", "TELA")
Return (oView)

User Function SE2XLA()

IF !EMPTY(SE2->E2_LA)
    IF RECLOCK("SE2",.F.)
        SE2->E2_LA = " "
    MSUNLOCK()
    ENDIF
    
    MSGINFO( "Registro Desmarcado, favor recontabilizar!", "Sucesso" )

ENDIF

RETURN
