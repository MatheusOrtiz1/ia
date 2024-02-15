#Include "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "FWMVCDEF.ch"
/*
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao: SF1DTLANC -  Desmarca Contabilização do Nota de Entrada     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±ºAuthor: Everton Forti       Uso: Conasa         Data: 01/06/2022       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// FUNÇÃO PRINCIPAL
User Function SF1DTLANC()

    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("SF1")
    oBrowse:SetDescription("DESMARCA CONTABILIZACAO NOTA DE ENTRADA")

    oBrowse:AddLegend("EMPTY(F1_DTLANC)", "GREEN", "Não Contabilizado")
    oBrowse:AddLegend("!EMPTY(F1_DTLANC)", "RED", "Contabilizado")

   // DEFINE DE ONDE SERÁ RETIRADO O MENUDEF
   //oBrowse:SetMenuDef("SF1DTLANC")

   oBrowse:Activate()
Return (oBrowse)

// OPERAÇÕES DA ROTINA
Static Function MenuDef()
    // FUNÇÃO PARA CRIAR MENUDEF
    //Local aRotina := FWMVCMenu("SE1XE1LA")
    Local aRotina := {}
    
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.SF1DTLANC' OPERATION 2 ACCESS 0
    //ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.SF1DTLANC' OPERATION 3 ACCESS 0
    //ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.SF1DTLANC' OPERATION 4 ACCESS 0
    //ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.SF1DTLANC' OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.SF1DTLANC' OPERATION 8 ACCESS 0
    //ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.SF1DTLANC' OPERATION 9 ACCESS 0
    ADD OPTION aRotina TITLE 'Desmarca Linha'               ACTION 'U_SF1XLA()' OPERATION 10 ACCESS 0
    ADD OPTION aRotina TITLE 'Desmarca Contabilização'      ACTION 'U_Desmarc()' OPERATION 10 ACCESS 0

    //Adicionando opções
	//ADD OPTION aRotina TITLE 'Faturamento' ACTION 'VIEWDEF.zMVCMdX' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    
Return (aRotina)
// REGRAS DE NEGÓCIO
Static Function ModelDef()
    // INSTANCIA O MODELO
    Local oModel := MPFormModel():New("COMP011M")

    // INSTANCIA O SUBMODELO
    Local oStruSF1 := FwFormStruct(1, "SF1")

    // DEFINE O SUBMODELO COMO FIELD
    oModel:AddFields("SF1MASTER", NIL, oStruSF1)

    // DESCRIÇÃO DO MODELO
    oModel:SetDescription("Desmarca Contabilização Nota De Entrada")

	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'F1_FILIAL','F1_DOC','F1_SERIE','F1_FORNECE','F1_LOJA','F1_TIPO'})

    // DESCRIÇÃO DO SUBMODELO
    oModel:GetModel("SF1MASTER"):SetDescription("Desmarca Contabilização Nota de Entrada")
Return (oModel)

// INTERFACE GRÁFICA
Static Function ViewDef()
    // RECEBE O MODELO DE DADOS
    Local oModel := FwLoadModel("SF1DTLANC")

    // INSTANCIA AS SUBVIEWS
    Local oStruSF1 := FwFormStruct(2, "SF1")

    // INSTANCIA A VIEW
    Local oView := FwFormView():New()

    // INDICA O MODELO DA VIEW
    oView:SetModel(oModel)

    // CRIA ESTRUTURA VISUAL DE CAMPOS
    oView:AddField("VIEW_SF1", oStruSF1, "SF1MASTER")

    // CRIA BOX HORIZONTAL
    oView:CreateHorizontalBox("TELA" , 100)

    // RELACIONA OS BOX COM A ESTRUTURA VISUAL
    oView:SetOwnerView("VIEW_SF1", "TELA")
Return (oView)


User Function SF1XLA()

IF !EMPTY(SF1->F1_DTLANC)
    IF RECLOCK("SF1",.F.)
        SF1->F1_DTLANC = CTOD("  /  /    ")
    MSUNLOCK()
    ENDIF
    
    MSGINFO( "Registro Desmarcado, favor recontabilizar!", "Sucesso" )

ENDIF

RETURN
