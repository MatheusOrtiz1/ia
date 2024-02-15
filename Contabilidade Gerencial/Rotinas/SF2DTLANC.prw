#Include "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "FWMVCDEF.ch"
/*
�������������������������������������������������������������������������͹��
���Descricao: SF2DTLANC - Desmarca Contabiliza��o do Nota de Saida        ���
�����������������������������������������������������������������������������
���Author: Everton Forti       Uso: Conasa         Data: 01/06/2022       ���
�����������������������������������������������������������������������������
*/
// FUN��O PRINCIPAL
User Function SF2DTLANC()
    Local oBrowse := FwLoadBrw("SF2DTLANC")

    oBrowse:Activate()
Return (NIL)

// BROWSEDEF() SER� �TIL PARA FUTURAS HERAN�AS: FWLOADBRW()
Static Function BrowseDef()
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("SF2")
    oBrowse:SetDescription("DESMARCA CONTABILIZACAO NOTA DE SAIDA")

    oBrowse:AddLegend("EMPTY(F2_DTLANC)", "GREEN", "N�o Contabilizado")
    oBrowse:AddLegend("!EMPTY(F2_DTLANC)", "RED", "Contabilizado")

   // DEFINE DE ONDE SER� RETIRADO O MENUDEF
   oBrowse:SetMenuDef("SF2DTLANC")

Return (oBrowse)
// OPERA��ES DA ROTINA
Static Function MenuDef()
    // FUN��O PARA CRIAR MENUDEF
    //Local aRotina := FWMVCMenu("SE1XE1LA")
    Local aRotina := {}
    
    ADD OPTION aRotina TITLE 'Visualizar'                   ACTION 'VIEWDEF.SF2DTLANC' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Desmarca Linha'               ACTION 'U_SF2XLA()' OPERATION 10 ACCESS 0
    ADD OPTION aRotina TITLE 'Desmarca Contabiliza��o'      ACTION 'U_Desmarc()' OPERATION 10 ACCESS 0

    //Adicionando op��es
	//ADD OPTION aRotina TITLE 'Faturamento' ACTION 'VIEWDEF.zMVCMdX' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1

Return (aRotina)
// REGRAS DE NEG�CIO
Static Function ModelDef()
    // INSTANCIA O MODELO
    Local oModel := MPFormModel():New("COMP011M")

    // INSTANCIA O SUBMODELO
    Local oStruSF2 := FwFormStruct(1, "SF2")

    // DEFINE O SUBMODELO COMO FIELD
    oModel:AddFields("SF2MASTER", NIL, oStruSF2)

    // DESCRI��O DO MODELO
    oModel:SetDescription("Desmarca Contabiliza��o Nota De Saida")

	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'F2_FILIAL','F2_DOC','F2_SERIE','F2_CLIENTE','F2_LOJA','F2_FORMUL','F2_TIPO'})

    // DESCRI��O DO SUBMODELO
    oModel:GetModel("SF2MASTER"):SetDescription("Desmarca Contabiliza��o Nota de Saida")
Return (oModel)

// INTERFACE GR�FICA
Static Function ViewDef()
    // INSTANCIA A VIEW
    Local oView := FwFormView():New()

    // INSTANCIA AS SUBVIEWS
    Local oStruSF2 := FwFormStruct(2, "SF2")

    // RECEBE O MODELO DE DADOS
    Local oModel := FwLoadModel("SF2DTLANC")

    // INDICA O MODELO DA VIEW
    oView:SetModel(oModel)

    // CRIA ESTRUTURA VISUAL DE CAMPOS
    oView:AddField("VIEW_SF2", oStruSF2, "SF2MASTER")

    // CRIA BOX HORIZONTAL
    oView:CreateHorizontalBox("TELA" , 100)

    // RELACIONA OS BOX COM A ESTRUTURA VISUAL
    oView:SetOwnerView("VIEW_SF2", "TELA")
Return (oView)

User Function SF2XLA()

IF !EMPTY(SF2->F2_DTLANC)
    IF RECLOCK("SF2",.F.)
        SF2->F2_DTLANC = CTOD("  /  /    ")
    MSUNLOCK()
    ENDIF
    
    MSGINFO( "Registro Desmarcado, favor recontabilizar!", "Sucesso" )

ENDIF

RETURN
