#Include "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "FWMVCDEF.ch"
/*
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao: SE2XE2LA -  Desmarca Contabilização Contas a Receber E1_LA    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±ºAuthor: Everton Forti       Uso: Conasa         Data: 01/06/2022       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// FUNÇÃO PRINCIPAL
User Function SE1XE1LA()
    Local oBrowse := FwLoadBrw("SE1XE1LA")

    oBrowse:Activate()
Return (NIL)

// BROWSEDEF() SERÁ ÚTIL PARA FUTURAS HERANÇAS: FWLOADBRW()
Static Function BrowseDef()
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("SE1")
    oBrowse:SetDescription("CONTROLE FLAG CONTABILIZACAO")
	//oBrowse:SetOnlyFields( { 'E1_PREFIXO','E1_NUM','E1_CCUSTO','E1_PARCELA','E1_TIPO','E1_NATUREZ','E1_PORTADO','E1_CLIENTE','E1_LJA','E1_NOMCLI','E1_EMISSAO','E1_EMIS1','E1_VENCTO','E1_VENCREA','E1_BAIXA','E1_HIST','E1_EMISSAO','E1_LA','E1_CO' } )
    oBrowse:AddLegend("EMPTY(E1_LA)", "RED", "Não Contabilizado")
    oBrowse:AddLegend("!EMPTY(E1_LA)", "GREEN", "Contabilizado")
     
   // DEFINE DE ONDE SERÁ RETIRADO O MENUDEF
   oBrowse:SetMenuDef("SE1XE1LA")
Return (oBrowse)

// OPERAÇÕES DA ROTINA
Static Function MenuDef()
    // FUNÇÃO PARA CRIAR MENUDEF
    //Local aRotina := FWMVCMenu("SE1XE1LA")
    Local aRotina := {}
    
    ADD OPTION aRotina TITLE 'Visualizar'                   ACTION 'VIEWDEF.SE1XE1LA' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Desmarca Linha'               ACTION 'U_SE1XLA()' OPERATION 10 ACCESS 0
    ADD OPTION aRotina TITLE 'Desmarca Contabilização'      ACTION 'U_Desmarc()' OPERATION 10 ACCESS 0

    //Adicionando opções
	//ADD OPTION aRotina TITLE 'Faturamento' ACTION 'VIEWDEF.zMVCMdX' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1

Return (aRotina)

// REGRAS DE NEGÓCIO
Static Function ModelDef()
    // INSTANCIA O MODELO
    Local oModel := MPFormModel():New("COMP011M")

    // INSTANCIA O SUBMODELO
    Local oStruSE1 := FwFormStruct(1, "SE1")

    // DEFINE O SUBMODELO COMO FIELD
    oModel:AddFields("SE1MASTER", NIL, oStruSE1)

    // DESCRIÇÃO DO MODELO
    oModel:SetDescription("Controle Contabilizacao")

	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'E1_FILIAL', 'E1_NUM','E1_PREFIXO','E1_CLIENTE','E1_LOJA'})

    // DESCRIÇÃO DO SUBMODELO
    oModel:GetModel("SE1MASTER"):SetDescription("Desmarca Contabilizacao")
Return (oModel)

// INTERFACE GRÁFICA
Static Function ViewDef()
    // INSTANCIA A VIEW
    Local oView := FwFormView():New()

    // INSTANCIA AS SUBVIEWS
    Local oStruSE1 := FwFormStruct(2, "SE1")

    // RECEBE O MODELO DE DADOS
    Local oModel := FwLoadModel("SE1XE1LA")

    // INDICA O MODELO DA VIEW
    oView:SetModel(oModel)

    // CRIA ESTRUTURA VISUAL DE CAMPOS
    oView:AddField("VIEW_SE1", oStruSE1, "SE1MASTER")

    // CRIA BOX HORIZONTAL
    oView:CreateHorizontalBox("TELA" , 100)

    // RELACIONA OS BOX COM A ESTRUTURA VISUAL
    oView:SetOwnerView("VIEW_SE1", "TELA")
Return (oView)


User Function SE1XLA()

IF !EMPTY(SE1->E1_LA)
    IF RECLOCK("SE1",.F.)
        SE1->E1_LA = " "
    MSUNLOCK()
    ENDIF
    
    MSGINFO( "Registro Desmarcado, favor recontabilizar!", "Sucesso" )

ENDIF

RETURN
